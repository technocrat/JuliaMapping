using AlgebraOfGraphics, CairoMakie
using AlgebraOfGraphics: density
using CairoMakie
using CSV
using DataFrames
using StatsBase

"""
    log_dist(df::DataFrame, col::Symbol)

Plot the log₁₀-transformed distribution of a numeric column with both histogram
and kernel density overlay.

# Arguments
- `df::DataFrame`: Input DataFrame containing the numeric column.
- `col::Symbol`: Column name to visualize.

# Details
The function computes `log10(x + 1)` for all nonmissing values in `df[!, col]`,
then draws:
- A normalized histogram (PDF scaling).
- A smooth kernel density estimate overlay.

# Returns
Displays an `AlgebraOfGraphics` plot showing the log-transformed distribution.

# Example
```julia
log_dist(df, :population)
```
"""
function log_dist(df::DataFrame, col::Symbol)
    # Create temporary DataFrame with log-transformed values
    temp_df = DataFrame(var = log10.(df[!, col] .+ 1))
    
    hist = data(temp_df) * mapping(:var) * histogram(bins=30, normalization=:pdf) * visual(color=:gray)
    density_layer = data(temp_df) * mapping(:var) * visual(Density, color=:green, strokewidth=2, alpha = 0.7)
    plt = hist + density_layer
    draw(plt, axis = (xlabel = "Log10($(string(col)))", ylabel = "Density"))
end

"""
scaled_dist(df::DataFrame, col::Symbol; bandwidth_pct=0.05, bins=30)

Plot the distribution of a numeric column with adaptive kernel bandwidth scaling.

# Arguments

- df::DataFrame: Input DataFrame.

- col::Symbol: Column name to visualize.

- bandwidth_pct::Float64=0.05: Fraction of the data range used as bandwidth
for the kernel density estimate.

- bins::Int=30: Number of histogram bins.

# Details

Computes a histogram normalized as a PDF, and overlays a kernel density curve
with bandwidth proportional to the column range (bandwidth = range * bandwidth_pct).

# Returns

Displays an AlgebraOfGraphics plot showing the histogram and scaled density.

# Example
scaled_dist(df, :income; bandwidth_pct=0.03, bins=40)

"""
function scaled_dist(df::DataFrame, col::Symbol; bandwidth_pct=0.05, bins=30)
    # Calculate adaptive bandwidth based on data range
    col_range = maximum(df[!, col]) - minimum(df[!, col])
    scaled_bandwidth = col_range * bandwidth_pct
    
    hist = data(df) * mapping(col) * histogram(bins=bins, normalization=:pdf) * visual(color=:gray)
    density_layer = data(df) * mapping(col) * visual(Density, bandwidth=scaled_bandwidth, color=:green, strokewidth=1, alpha=0.7)
    
    plt = hist + density_layer
    draw(plt, axis = (xlabel = string(col), ylabel = "Density"))
end

"""
    quick_hist(df::DataFrame, column::Symbol; bins=20)

Create a histogram with negative values colored brown and positive values colored green.

# Arguments
- `df`: DataFrame containing the data
- `column::Symbol`: Column name to plot
- `bins=20`: Number of histogram bins (default: 20)

# Returns
- Figure object from AlgebraOfGraphics

# Example
```julia
fg = quick_hist(df, :Population)
fg = quick_hist(df, :Population, bins=30)
```
"""
function quick_hist(df::DataFrame, column::Symbol; bins=20)
    # Get the data and check for actual negative values
    data_vec = df[!, column]
    has_negative = any(data_vec .< 0)
    
    if !has_negative
        # All positive - just plot in green
        plt = data(df) * mapping(column) * histogram(; bins=bins) * visual(color=:green)
        fg = draw(plt)
    else
        # Split data by sign
        df_neg = filter(row -> row[column] < 0, df)
        df_pos = filter(row -> row[column] >= 0, df)
        
        # Create layers
        layers = []
        if nrow(df_neg) > 0
            push!(layers, data(df_neg) * mapping(column) * histogram(; bins=bins) * visual(color=:yellow))
        end
        if nrow(df_pos) > 0
            push!(layers, data(df_pos) * mapping(column) * histogram(; bins=bins) * visual(color=:green))
        end
        
        fg = draw(sum(layers))
    end
    
    return fg
end

export log_dist, scaled_dist, quick_hist