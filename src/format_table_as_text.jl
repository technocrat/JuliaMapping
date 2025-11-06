"""
    format_table_as_text(headers::Vector{String}, rows::Vector{Vector{String}}, padding::Int=2)

Format data as an ASCII table with borders and proper column alignment.

# Arguments
- `headers::Vector{String}`: Column header names
- `rows::Vector{Vector{String}}`: Data rows, where each row is a vector of strings
- `padding::Int=2`: Additional padding space around each cell (default: 2)

# Returns
- `String`: Formatted ASCII table with Unicode box-drawing characters

# Examples
```julia
headers = ["Name", "Age", "City"]
rows = [["Alice", "25", "New York"], 
        ["Bob", "30", "Chicago"],
        ["Carol", "22", "Boston"]]
table = format_table_as_text(headers, rows)
# Returns a formatted table with borders and proper alignment
```

# Notes
- Uses Unicode box-drawing characters (┌─┬─┐│├─┼─┤└─┴─┘)
- Automatically calculates column widths based on content
- Each cell is padded for consistent spacing
- Useful for creating publication-ready ASCII tables
"""
function format_table_as_text(headers::Vector{String}, rows::Vector{Vector{String}}, 
    padding::Int=2)
    parser = Parser()
    all_rows = [headers; rows]

    # Calculate column widths
    col_widths = Int[]
    for col in 1:length(headers)
    max_width = maximum(length(row[col]) for row in all_rows)
    push!(col_widths, max_width + padding)
    end

    # Format rows
    formatted_lines = String[]

    # Header
    header_line = join([rpad(headers[i], col_widths[i]) for i in 1:length(headers)], "│")
    push!(formatted_lines, "│" * header_line * "│")

    # Separator
    separator = "├" * join([repeat("─", col_widths[i]) for i in 1:length(headers)], "┼") * "┤"
    push!(formatted_lines, separator)

    # Data rows
    for row in rows
    data_line = join([rpad(row[i], col_widths[i]) for i in 1:length(row)], "│")
    push!(formatted_lines, "│" * data_line * "│")
    end

    # Top and bottom borders
    top_border = "┌" * join([repeat("─", col_widths[i]) for i in 1:length(headers)], "┬") * "┐"
    bottom_border = "└" * join([repeat("─", col_widths[i]) for i in 1:length(headers)], "┴") * "┘"

    return join([top_border, formatted_lines..., bottom_border], "\n")
end

export format_table_as_text