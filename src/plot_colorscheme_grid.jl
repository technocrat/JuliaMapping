
"""
    plot_colorscheme_grid(schemes; ncol=2)

Create a grid display of ColorScheme colorbars for visual comparison.

# Arguments
- `schemes::Vector`: Vector of ColorScheme names (as symbols) or ColorScheme objects to display

# Keywords
- `ncol::Int=2`: Number of columns in the grid layout

# Returns
- `Figure`: A CairoMakie Figure object containing the colorbar grid

# Description
Displays multiple ColorSchemes as horizontal colorbars arranged in a grid layout.
Each colorbar is labeled with its scheme name. Useful for comparing color palettes
or selecting appropriate schemes for data visualization.

The figure height automatically adjusts based on the number of rows needed.
Each colorbar is displayed horizontally with a fixed height of 30 pixels.

# Example
```julia
# Display common sequential schemes
schemes = [:viridis, :plasma, :inferno, :magma]
f = plot_colorscheme_grid(schemes; ncol=2)
display(f)

# Compare diverging schemes
diverging = [:RdBu, :RdYlBu, :PiYG, :BrBG]
f = plot_colorscheme_grid(diverging; ncol=2)

# Display all schemes in a category
sequential = [:viridis, :plasma, :inferno, :magma, :cividis, :twilight]
f = plot_colorscheme_grid(sequential; ncol=3)
```

# See Also
- `ColorSchemes.colorschemes` - Dictionary of all available ColorSchemes
- Browse schemes at: https://juliagraphics.github.io/ColorSchemes.jl/stable/catalogue/
"""
function plot_colorscheme_grid(schemes; ncol=2)
    n = length(schemes)
    nrow = cld(n, ncol)
    
    fig = Figure(size=(800, 200 * nrow))
    
    for (i, scheme) in enumerate(schemes)
        row = (i - 1) ÷ ncol + 1
        col = (i - 1) % ncol + 1
        
        Colorbar(fig[row, col],
            colormap = scheme,
            label = string(scheme),
            vertical = false,
            height = 30)
    end
    
    return fig
end

export plot_colorscheme_grid
