"""
    format_breaks(breaks::Vector{String}) -> Vector{String}

Formats a vector of string representations of ranges into a human-readable format.

# Arguments
- `breaks::Vector{String}`: A vector of strings, each representing a numerical range. 
  Each string is expected to be in the format `"start - end"`, where `start` and `end` are numerical values.

# Returns
- A `Vector{String}` where each element is a formatted range string in the form `"start to end"`.
  - The numerical values in the range are rounded to the nearest integer and formatted with commas for better readability.

# Example
julia> breaks = ["1000 - 2000", "3000.5 - 4000.2", "500000 - 1000000"];
julia> format_breaks(breaks)
["1,000 to 2,000", "3,001 to 4,000", "500,000 to 1,000,000"]
"""
function format_breaks(breaks::Vector{String})
    ranges = [round.(Int, parse.(Float64, split(s, " - "))) for s in breaks]
    formatted_ranges = [with_commas.(range) for range in ranges]
    return [join(range, " to ") for range in formatted_ranges]
end


export format_breaks