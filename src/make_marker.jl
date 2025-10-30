using Makie

"""
    make_marker(n::Int, size::Real, shape::String) -> BezierPath

Create a custom marker composed of multiple geometric shapes arranged in a grid pattern for Makie plots.

# Arguments
- `n::Int`: Number of shapes to include in the marker (arranged in a grid)
- `size::Real`: Size of each individual shape in the marker
- `shape::String`: Type of shape to draw. Supported values:
  - `"+"`: Plus sign (cross with horizontal and vertical bars)
  - `"_"`: Underscore (horizontal bar)
  - `"±"`: Plus-minus sign (horizontal bars with vertical bar on top)
  - `"#"`: Hash sign (two horizontal and two vertical bars forming a grid)
  - `"*"`: Asterisk (plus with two diagonal bars)
  - `"="`: Equal sign (two horizontal bars)
  - `"|"`: Vertical bar
  - `":"`: Colon (two dots vertically aligned)

# Returns
- `BezierPath`: A Makie BezierPath object containing all shapes arranged in a grid

# Details
The shapes are arranged in a square grid pattern with automatic spacing. The grid size is
calculated as `ceil(sqrt(n))` to accommodate all `n` shapes. Line thickness is set to 20%
of the specified size, and spacing between shapes is 3× the size parameter.

# Examples
```julia
using Makie, CairoMakie

# Create a marker with 4 plus signs
marker = make_marker(4, 10.0, "+")

# Use in a scatter plot
fig = Figure()
ax = Axis(fig[1, 1])
scatter!(ax, [1, 2, 3], [1, 2, 3], marker=marker, markersize=30)
fig

# Create markers with different shapes
plus_marker = make_marker(9, 5.0, "+")
underscore_marker = make_marker(6, 5.0, "_")
plusminus_marker = make_marker(4, 5.0, "±")
hash_marker = make_marker(4, 5.0, "#")
asterisk_marker = make_marker(9, 5.0, "*")
equal_marker = make_marker(6, 5.0, "=")
pipe_marker = make_marker(4, 5.0, "|")
colon_marker = make_marker(6, 5.0, ":")
```

# Throws
- `error`: If `shape` is not one of the supported values ("+", "_", "±", "#", "*", "=", "|", ":")
"""
function make_marker(n::Int, size::Real, shape::String)
    thickness = size * 0.2  # thickness of the lines
    commands = []
    
    # Arrange in a grid pattern
    grid_size = ceil(Int, sqrt(n))  # number of shapes per row/column
    spacing = size * 3  # space between shapes
    
    # Center the grid
    offset = (grid_size - 1) * spacing / 2
    
    count = 0
    for row in 0:(grid_size-1)
        for col in 0:(grid_size-1)
            count += 1
            if count > n
                break
            end
            
            cx = col * spacing - offset
            cy = row * spacing - offset
            
            if shape == "+"
                # Horizontal bar
                append!(commands, [
                    MoveTo(Point2f(cx - size, cy - thickness)),
                    LineTo(Point2f(cx + size, cy - thickness)),
                    LineTo(Point2f(cx + size, cy + thickness)),
                    LineTo(Point2f(cx - size, cy + thickness)),
                    ClosePath(),
                    # Vertical bar
                    MoveTo(Point2f(cx - thickness, cy - size)),
                    LineTo(Point2f(cx + thickness, cy - size)),
                    LineTo(Point2f(cx + thickness, cy + size)),
                    LineTo(Point2f(cx - thickness, cy + size)),
                    ClosePath()
                ])
                
            elseif shape == "_"
                # Horizontal bar
                append!(commands, [
                    MoveTo(Point2f(cx - size, cy - thickness)),
                    LineTo(Point2f(cx + size, cy - thickness)),
                    LineTo(Point2f(cx + size, cy + thickness)),
                    LineTo(Point2f(cx - size, cy + thickness)),
                    ClosePath()
                ])
                
            elseif shape == "±"
                offset_y = size * 0.4
                # Top horizontal bar
                append!(commands, [
                    MoveTo(Point2f(cx - size, cy + offset_y - thickness)),
                    LineTo(Point2f(cx + size, cy + offset_y - thickness)),
                    LineTo(Point2f(cx + size, cy + offset_y + thickness)),
                    LineTo(Point2f(cx - size, cy + offset_y + thickness)),
                    ClosePath(),
                    # Vertical bar
                    MoveTo(Point2f(cx - thickness, cy + offset_y)),
                    LineTo(Point2f(cx + thickness, cy + offset_y)),
                    LineTo(Point2f(cx + thickness, cy + size)),
                    LineTo(Point2f(cx - thickness, cy + size)),
                    ClosePath(),
                    # Bottom horizontal bar
                    MoveTo(Point2f(cx - size, cy - offset_y - thickness)),
                    LineTo(Point2f(cx + size, cy - offset_y - thickness)),
                    LineTo(Point2f(cx + size, cy - offset_y + thickness)),
                    LineTo(Point2f(cx - size, cy - offset_y + thickness)),
                    ClosePath()
                ])
                
            elseif shape == "#"
                # Hash sign (grid pattern)
                offset_bar = size * 0.5
                # Top horizontal bar
                append!(commands, [
                    MoveTo(Point2f(cx - size, cy + offset_bar - thickness)),
                    LineTo(Point2f(cx + size, cy + offset_bar - thickness)),
                    LineTo(Point2f(cx + size, cy + offset_bar + thickness)),
                    LineTo(Point2f(cx - size, cy + offset_bar + thickness)),
                    ClosePath(),
                    # Bottom horizontal bar
                    MoveTo(Point2f(cx - size, cy - offset_bar - thickness)),
                    LineTo(Point2f(cx + size, cy - offset_bar - thickness)),
                    LineTo(Point2f(cx + size, cy - offset_bar + thickness)),
                    LineTo(Point2f(cx - size, cy - offset_bar + thickness)),
                    ClosePath(),
                    # Left vertical bar
                    MoveTo(Point2f(cx - offset_bar - thickness, cy - size)),
                    LineTo(Point2f(cx - offset_bar + thickness, cy - size)),
                    LineTo(Point2f(cx - offset_bar + thickness, cy + size)),
                    LineTo(Point2f(cx - offset_bar - thickness, cy + size)),
                    ClosePath(),
                    # Right vertical bar
                    MoveTo(Point2f(cx + offset_bar - thickness, cy - size)),
                    LineTo(Point2f(cx + offset_bar + thickness, cy - size)),
                    LineTo(Point2f(cx + offset_bar + thickness, cy + size)),
                    LineTo(Point2f(cx + offset_bar - thickness, cy + size)),
                    ClosePath()
                ])
                
            elseif shape == "*"
                # Asterisk (plus with diagonals)
                diag = size / sqrt(2)
                # Horizontal bar
                append!(commands, [
                    MoveTo(Point2f(cx - size, cy - thickness)),
                    LineTo(Point2f(cx + size, cy - thickness)),
                    LineTo(Point2f(cx + size, cy + thickness)),
                    LineTo(Point2f(cx - size, cy + thickness)),
                    ClosePath(),
                    # Vertical bar
                    MoveTo(Point2f(cx - thickness, cy - size)),
                    LineTo(Point2f(cx + thickness, cy - size)),
                    LineTo(Point2f(cx + thickness, cy + size)),
                    LineTo(Point2f(cx - thickness, cy + size)),
                    ClosePath(),
                    # Diagonal bar (bottom-left to top-right)
                    MoveTo(Point2f(cx - diag - thickness/sqrt(2), cy - diag + thickness/sqrt(2))),
                    LineTo(Point2f(cx - diag + thickness/sqrt(2), cy - diag - thickness/sqrt(2))),
                    LineTo(Point2f(cx + diag + thickness/sqrt(2), cy + diag - thickness/sqrt(2))),
                    LineTo(Point2f(cx + diag - thickness/sqrt(2), cy + diag + thickness/sqrt(2))),
                    ClosePath(),
                    # Diagonal bar (top-left to bottom-right)
                    MoveTo(Point2f(cx - diag - thickness/sqrt(2), cy + diag - thickness/sqrt(2))),
                    LineTo(Point2f(cx - diag + thickness/sqrt(2), cy + diag + thickness/sqrt(2))),
                    LineTo(Point2f(cx + diag + thickness/sqrt(2), cy - diag + thickness/sqrt(2))),
                    LineTo(Point2f(cx + diag - thickness/sqrt(2), cy - diag - thickness/sqrt(2))),
                    ClosePath()
                ])
                
            elseif shape == "="
                # Equal sign (two horizontal bars)
                offset_y = size * 0.35
                # Top horizontal bar
                append!(commands, [
                    MoveTo(Point2f(cx - size, cy + offset_y - thickness)),
                    LineTo(Point2f(cx + size, cy + offset_y - thickness)),
                    LineTo(Point2f(cx + size, cy + offset_y + thickness)),
                    LineTo(Point2f(cx - size, cy + offset_y + thickness)),
                    ClosePath(),
                    # Bottom horizontal bar
                    MoveTo(Point2f(cx - size, cy - offset_y - thickness)),
                    LineTo(Point2f(cx + size, cy - offset_y - thickness)),
                    LineTo(Point2f(cx + size, cy - offset_y + thickness)),
                    LineTo(Point2f(cx - size, cy - offset_y + thickness)),
                    ClosePath()
                ])
                
            elseif shape == "|"
                # Vertical bar
                append!(commands, [
                    MoveTo(Point2f(cx - thickness, cy - size)),
                    LineTo(Point2f(cx + thickness, cy - size)),
                    LineTo(Point2f(cx + thickness, cy + size)),
                    LineTo(Point2f(cx - thickness, cy + size)),
                    ClosePath()
                ])
                
            elseif shape == ":"
                # Colon (two dots)
                dot_radius = thickness * 1.5
                offset_y = size * 0.5
                # Top dot (approximated as a small square)
                append!(commands, [
                    MoveTo(Point2f(cx - dot_radius, cy + offset_y - dot_radius)),
                    LineTo(Point2f(cx + dot_radius, cy + offset_y - dot_radius)),
                    LineTo(Point2f(cx + dot_radius, cy + offset_y + dot_radius)),
                    LineTo(Point2f(cx - dot_radius, cy + offset_y + dot_radius)),
                    ClosePath(),
                    # Bottom dot
                    MoveTo(Point2f(cx - dot_radius, cy - offset_y - dot_radius)),
                    LineTo(Point2f(cx + dot_radius, cy - offset_y - dot_radius)),
                    LineTo(Point2f(cx + dot_radius, cy - offset_y + dot_radius)),
                    LineTo(Point2f(cx - dot_radius, cy - offset_y + dot_radius)),
                    ClosePath()
                ])
                
            else
                error("Unknown shape: $shape. Must be one of: +, _, ±, #, *, =, |, :")
            end
        end
        if count > n
            break
        end
    end
    
    return BezierPath(commands)
end

export make_marker