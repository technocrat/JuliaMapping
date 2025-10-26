
"""
    format_breaks(breaks::Vector{String})

Format numeric range strings with comma separators for better readability.

Converts range strings like "1000 - 5000" into formatted strings like "1,000 to 5,000",
making population or other numeric ranges more human-readable.

# Arguments
- `breaks::Vector{String}`: Vector of range strings in format "number - number"

# Returns
- Vector of formatted range strings with commas and "to" separator

# Example
```julia
breaks = ["1000 - 5000", "5000 - 10000", "10000 - 50000"]
formatted = format_breaks(breaks)
# Returns: ["1,000 to 5,000", "5,000 to 10,000", "10,000 to 50,000"]
```

# Details
- Parses each range string by splitting on " - "
- Converts to integers with rounding
- Applies comma formatting using `with_commas`
- Joins formatted values with " to "
"""
function format_breaks(breaks::Vector{String})
    ranges = [round.(Int, parse.(Float64, split(s, " - "))) for s in breaks]
    formatted_ranges = [with_commas.(range) for range in ranges]
    return [join(range, " to ") for range in formatted_ranges]
end

"""
    make_combined_table(data::DataFrame, half::String, formatted_breaks::Vector{String} = formatted_breaks)

Create a formatted summary table of population statistics by bins.

Generates a text-based table showing population totals, percentages, and cumulative statistics
for either the first or second half of population bins. Useful for creating small multiple displays
with separate tables for each half.

# Arguments
- `data::DataFrame`: DataFrame containing `:bin` and `:population` columns
- `half::String`: Either "first" (bins 1-4) or "second" (bins 5-8)
- `formatted_breaks::Vector{String}`: Vector of formatted range labels (default: `formatted_breaks`)

# Returns
- String containing a formatted text table with columns:
  - Interval: The population range
  - Population: Total population in the bin
  - Percent: Percentage of national total
  - Cumulative: Cumulative population
  - Cumulative: Cumulative percentage

# Details
- Groups data by bin and sums population
- Calculates percentages relative to national total
- Computes cumulative population and percentages
- Formats numbers with commas for readability
- Uses PrettyTables with right-aligned columns

# Example
```julia
table_text = make_combined_table(county_data, "first", formatted_breaks)
println(table_text)
```

# Notes
The table is formatted as a string suitable for display or saving to file.
"""
function make_combined_table(data::DataFrame, half::String, formatted_breaks::Vector{String} = formatted_breaks)
    combined = combine(groupby(data, :bin), :population => sum)
    national_total = sum(combined.population_sum)
    if half == "first"
        combined = combined[1:4, :]
        combined.breaks = formatted_breaks[1:4]
    else
        combined = combined[5:8, :]
        combined.breaks = formatted_breaks[5:8]
    end
    combined.cumulative_population = cumsum(combined.population_sum)
    combined.percent_population = percent.(combined.population_sum ./ national_total)
    combined.cumulative_percent = percent.(cumsum(combined.population_sum) ./ national_total)
    combined.population_sum = with_commas.(combined.population_sum)
    combined.cumulative_population = with_commas.(combined.cumulative_population)
    select!(combined, :breaks, :population_sum, :percent_population, :cumulative_population, :cumulative_percent)
    return sprint() do io
        pretty_table(io, combined; header = ["Interval", "Population", "Percent", "Cumulative", "Cumulative"], backend = Val(:text),alignment = [:r, :r, :r, :r, :r])
    end
end

"""
    plot_county_interval(data::DataFrame, f::Figure, brk::Int64, formatted_breaks::Vector{String})

Plot counties within a specific population bin on a small multiples figure.

Creates a single panel in a 2×2 grid showing counties that fall within a particular population
bin, highlighted against a background of all counties. Part of a small multiples visualization.

# Arguments
- `data::DataFrame`: DataFrame containing county geometries and `:bin` classification
- `f::Figure`: Makie Figure object to add the plot to
- `brk::Int64`: Bin number to plot (1-8)
- `formatted_breaks::Vector{String}`: Vector of formatted range labels for titles

# Returns
Nothing. Modifies the figure in place by adding a GeoAxis panel.

# Details
- Creates a GeoAxis in EPSG:5070 projection (US Albers Equal Area)
- Positions panels in a 2×2 grid (bins 5-8 map to positions 1-4 for second figure)
- Row calculation: `ceil(display_brk / 2)`
- Column calculation: odd bins → column 1, even bins → column 2
- Background: All counties in white with thin gray borders
- Foreground: Counties in current bin colored using YlGn (Yellow-Green) colorscheme
- Title shows the formatted population range
- Decorations (axes, ticks) are hidden

# Example
```julia
f = Figure(resolution=(1200, 1000))
for brk in 1:4
    plot_county_interval(county_data, f, brk, formatted_breaks)
end
```

# Notes
Designed for creating small multiple displays showing population distribution patterns.
"""
function plot_county_interval(data::DataFrame, f::Figure, brk::Int64, formatted_breaks::Vector{String})
    classize = subset(data, :bin => ByRow(x -> x == brk))
    
    # Adjust for breaks 5-8: map them to positions 1-4
    display_brk = brk > 4 ? brk - 4 : brk
    row = ceil(Int, display_brk / 2)
    col = display_brk % 2 == 1 ? 1 : 2
    
    ga = GeoAxis(f[row, col]; dest = "EPSG:5070", title = "$(formatted_breaks[brk])")
    hidedecorations!(ga)
    poly!(ga, data.geometry, color = :white, strokecolor = colorschemes[:grays][1], strokewidth = 0.05)
    poly!(ga, classize.geometry, color = colorschemes[:YlGn][brk])
end

export plot_county_interval, make_combined_table, format_breaks
