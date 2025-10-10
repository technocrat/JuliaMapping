using CairoMakie

"""
    quick_hist(v::Vector{T}; xlab="Value", ylab="Frequency", title="Histogram") where T <: Real

Create a quick histogram visualization with color-coded bars based on value sign.

Generates a histogram with 30 bins, coloring bars blue for negative values and red for 
non-negative values. Automatically handles missing values by removing them.

# Arguments
- `v::Vector{T}`: Vector of numeric values to plot (missing values are automatically skipped)
- `xlab::String`: Label for x-axis (default: `"Value"`)
- `ylab::String`: Label for y-axis (default: `"Frequency"`)
- `title::String`: Plot title (default: `"Histogram"`)

# Returns
- `Figure`: A Makie Figure object (800×600 pixels, fontsize 24)

# Details
- Uses 30 bins for histogram calculation
- Bar colors: Blue for bins centered at negative values, Red for non-negative
- Bars have black outlines (strokewidth = 1)
- Missing values are automatically removed before plotting
- Bar width matches bin width for proper spacing

# Example
```julia
# Simple histogram
data = randn(1000)
fig = quick_hist(data)

# Custom labels
temperatures = randn(500) .* 10 .+ 20
fig = quick_hist(temperatures, 
                 xlab="Temperature (°C)", 
                 ylab="Count", 
                 title="Temperature Distribution")
                 
# Save the figure
save("histogram.png", fig)
```

# Notes
The color coding is useful for visualizing distributions that cross zero, such as 
temperature anomalies, profit/loss data, or standardized residuals.
"""
function quick_hist(v::Vector{T}; xlab::String="Value", ylab::String="Frequency", title::String="Histogram") where T <: Real
    data    = collect(skipmissing(v))
    h       = fit(Histogram, data; nbins = 30)
    edges   = h.edges[1]                       # length = nbins+1
    counts  = h.weights                        # length = nbins
    centers = (edges[1:end-1] .+ edges[2:end]) ./ 2
    
    # blue for negative‐center bins, red for non‐negative
    bar_colors = ifelse.(centers .< 0, :blue, :red)
    
    fig = Figure(size = (800, 600), fontsize = 24)
    ax  = Axis(fig[1, 1];
    xlabel = xlab,
    ylabel = ylab,
    title  = title,
    )
    
    barplot!(ax, centers, counts;
    width       = diff(edges),
    color       = bar_colors,
    strokecolor = :black,
    strokewidth = 1,
    )
        
    return fig
end

export quick_hist