using DataFrames
"""
    dots(df::DataFrame, dots::Int)

Calculate dot density values for wheat production visualization.

# Arguments
- `df::DataFrame`: DataFrame containing wheat production data with `wheat2017bu` column
- `dots::Int`: Number of bushels represented by each dot

# Returns
- `Vector{Int}`: Number of dots needed for each row based on production levels

# Examples
```julia
wheat_df = DataFrame(wheat2017bu = [5000, 12000, 800])
dot_counts = dots(wheat_df, 1000)  # Each dot represents 1000 bushels
# Returns: [5, 12, 0] (dots per county)
```

# Notes
- Uses floor division to ensure whole dots only
- Specifically designed for wheat production dot density maps
- Part of the agricultural visualization workflow
- Returns 0 for counties with production below the dot threshold
"""
function dots(df::DataFrame, dots::Int)
    bu = df.wheat2017bu
    Int.(floor.(bu ./ dots))
end

export dots