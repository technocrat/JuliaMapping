using CairoMakie
using Colors
using Printf
using ColorSchemes

"""
    plot_named_color_groups(title, names; ncol=6, cell=(140,80), gap=(8,8), figsize=(1600,900))

Create a visual grid display of named colors with their RGB values.

# Arguments
- `title::AbstractString`: The title to display at the top of the plot
- `names::Vector{<:AbstractString}`: Vector of color names to display

# Keywords
- `ncol::Int=6`: Number of columns in the grid layout
- `cell::Tuple{Int,Int}=(140,80)`: Width and height of each color cell in pixels
- `gap::Tuple{Int,Int}=(8,8)`: Horizontal and vertical gap between cells in pixels  
- `figsize::Tuple{Int,Int}=(1600,900)`: Overall figure size in pixels

# Returns
- `Figure`: A CairoMakie Figure object containing the color grid

# Description
Each color swatch displays:
- The color name (centered at top)
- RGB values as decimal numbers (bottom left)
- Text color automatically chosen (black/white) based on background brightness

# Example
```julia
# Display a select red colors
reds = ["red", "crimson", "darkred", "firebrick"]
f = plot_named_color_groups("Red Colors", reds; ncol=4)
display(f)
# All reds
f = plot_named_color_groups("All Red Colors", :reds)
```

# Throws
- Error if any color name in `names` is not recognized by Colors.jl
"""
function plot_named_color_groups(title::AbstractString, 
    names::Vector{<:AbstractString};
    ncol::Int=6, cell::Tuple{Int,Int}=(140, 80),
    gap::Tuple{Int,Int}=(8, 8), 
    figsize::Tuple{Int,Int}=(1600, 900))
    # Parse names to colors (throws error if an unknown name is present)
    cols = RGB.(parse.(Colorant, names))
    
    # Layout math
    n = length(names)
    ncol = max(1, ncol)
    nrow = cld(n, ncol)   # rows needed
    
    f = Figure(size=figsize)
    f[1,1] = Label(f, title; fontsize=28, halign=:left, padding=(0,0,4,0))
    
    # Thin separator line under title
    ax_sep = CairoMakie.Axis(f[2,1];
    height=8, xticksvisible=false, yticksvisible=false)
    hidedecorations!(ax_sep); 
    hidespines!(ax_sep)
    lines!(ax_sep, [0, 1], [0, 0])
    
    # Swatch area
    ax = CairoMakie.Axis(f[3,1]; title="", 
        xticksvisible=false, yticksvisible=false)
    hidedecorations!(ax) 
    hidespines!(ax)
    
    # Use the cell dimensions for proper sizing
    cw, ch = cell[1], cell[2]
    total_w = ncol * cw + (ncol-1) * gap[1]
    total_h = nrow * ch + (nrow-1) * gap[2]
    xlims!(ax, 0, total_w)
    ylims!(ax, 0, total_h)
    
    brightness(c::RGB) = Gray(c).val
    labelcolor(c::RGB) = brightness(c) > 0.6 ? :black : :white
    
    for i in 1:n
        r = (i-1) ÷ ncol               # 0-based row
        c = (i-1) % ncol               # 0-based col
        r_inv = nrow - 1 - r
        x = c * cw
        y = r_inv * ch
        col = cols[i]
        
        poly!(ax, Rect(x, y, cw, ch); color=col, strokecolor=:transparent)
        px = cw * 0.05
        
        # Name on top (centered)
        text!(ax, x + cw/2, y + ch * 0.8;
            text=names[i], align=(:center, :center),
            fontsize=14,
            color=labelcolor(col))
        
        r_, g_, b_ = col.r, col.g, col.b
        text!(ax, x + px, y + ch * 0.3;
            text=@sprintf("%.2f, %.2f, %.2f", r_, g_, b_),
            align=(:left, :center), fontsize=14, 
            color=labelcolor(col))
    end
    
    # Set the row and column sizes for proper layout
    rowsize!(f.layout, 3, total_h)
    colsize!(f.layout, 1, total_w)
    f
end

"""
    show_named_color_groups()

Print the available named color groups to the console.

Displays the names of predefined color categories that can be used with 
`plot_named_color_group()`. These correspond to color arrays defined in 
the included "named_colors.jl" file.

# Example
```julia
show_named_color_groups()
# Output: whites reds oranges yellows greens cyans blues purples pinks browns grays
```
"""
function show_named_color_groups()
    println("whites ", "reds ", "oranges ", "yellows ", "greens ", "cyans ", "blues ", "purples ", "pinks ", "browns ", "grays")
end
export show_named_color_groups, plot_named_color_groups