"""
    create_county_union(df; geometry_col=:geometry)

Create a unified geometry representing the union of all county geometries in a DataFrame.

This function iteratively combines all county geometries using ArchGDAL's union operation,
which is useful for creating a boundary for clipping or masking operations.

# Arguments
- `df`: DataFrame containing county geometry data
- `geometry_col`: Symbol specifying the column name containing ArchGDAL geometry objects (default: `:geometry`)

# Returns
- An ArchGDAL geometry object representing the union of all input geometries

# Details
- Progress is printed every 500 counties for large datasets
- Handles union errors gracefully with warning messages
- The result can be used for clipping contours or other spatial operations

# Example
```julia
county_union = create_county_union(county_df)
county_union = create_county_union(county_df, geometry_col=:geom)
```
"""
function create_county_union(df; geometry_col=:geometry)
    println("Creating union of all counties for clipping...")
    
    # df.geometry contains ArchGDAL.IGeometry objects, use them directly
    county_geoms = df[!, geometry_col]
    
    # Create union of all counties
    county_union = county_geoms[1]
    for i in 2:length(county_geoms)
        if i % 500 == 0
            println("Processing county ", i, " of ", length(county_geoms))
        end
        try
            county_union = ArchGDAL.union(county_union, county_geoms[i])
        catch e
            println("Warning: Could not union county ", i, ": ", e)
        end
    end
    
    return county_union
end

"""
    create_voting_contours!(ga, df; geometry_col=:geometry, value_col=:republican_pct, resolution=200, levels=10)

Create smooth contour lines on an existing plot representing spatial interpolation of a value across geographic regions.

# Arguments
- `ga`: An existing Makie plot axis/figure to add contours to
- `df`: DataFrame containing geometry and value columns for interpolation
- `geometry_col::Symbol=:geometry`: Column name containing ArchGDAL geometry objects (default: `:geometry`)
- `value_col::Symbol=:republican_pct`: Column name containing numeric values to interpolate (default: `:republican_pct`)
  Can also use `:democratic_pct`, `:third_party_pct`, or any numeric column
- `resolution::Int=200`: Grid resolution for interpolation (higher = smoother but slower)
- `levels::Int=10`: Number of contour levels to draw, or a vector of specific levels

# Returns
- Tuple of (contour_lines, interpolated_grid_Z, x_grid, y_grid)

# Details
- Uses Gaussian kernel density weighting for smooth interpolation
- Adaptive bandwidth based on data extent for automatic smoothing
- Contour lines are labeled with values
- Designed for political/electoral data (margins, vote shares, etc.)

# Example
```julia
fig, ax, plt = scatter(counties_df.longitude, counties_df.latitude)
cs, Z, x_grid, y_grid = create_voting_contours!(ax, counties_df, value_col=:margin_pct)
```
"""
function create_voting_contours!(ga, df;
    geometry_col=:geometry,
    value_col=:republican_pct,  # or :democratic_pct, :third_party_pct
    resolution=200,
    levels=10)
    
    # Extract centroids and values
    n = nrow(df)
    centroids_x = Vector{Float64}(undef, n)
    centroids_y = Vector{Float64}(undef, n)
    values = Vector{Float64}(undef, n)
    
    for (i, row) in enumerate(eachrow(df))
        centroids_x[i], centroids_y[i] = extract_centroid(row[geometry_col])
        values[i] = row[value_col]
    end
    
    # Get bounds
    x_min, x_max = extrema(centroids_x)
    y_min, y_max = extrema(centroids_y)
    
    # Create interpolation grid
    x_grid = range(x_min, x_max, length=resolution)
    y_grid = range(y_min, y_max, length=resolution)
    Z = Matrix{Float64}(undef, length(y_grid), length(x_grid))
    
    # Interpolation with adaptive bandwidth
    bandwidth = (x_max - x_min) / 30  # Adjust for smoothness
    
    Threads.@threads for i in 1:length(y_grid)
        y = y_grid[i]
        for j in 1:length(x_grid)
            x = x_grid[j]
            
            # Gaussian weighting
            weights = exp.(-((centroids_x .- x).^2 .+ (centroids_y .- y).^2) ./ (2 * bandwidth^2))
            
            # Weighted average
            Z[i, j] = sum(weights .* values) / sum(weights)
        end
    end
    
    # Create contour levels
    if isa(levels, Int)
        min_val, max_val = extrema(values)
        contour_levels = range(min_val + 0.02, max_val - 0.02, length=levels)
    else
        contour_levels = levels
    end
    
    # Add contour lines
    cs = contour!(ga, x_grid, y_grid, Z,
                  levels=contour_levels,
                  color=:black,
                  linewidth=1.5,
                  labels=true,
                  labelsize=10)
    
    return cs, Z, x_grid, y_grid
end


"""
    create_filled_voting_contours!(ga, df; geometry_col=:geometry, value_col=:republican_pct, resolution=150, colormap=:RdBu)

Create a filled contour plot (like a topographic map) showing spatial interpolation of a value across geographic regions.

# Arguments
- `ga`: An existing Makie plot axis/figure to add filled contours to
- `df`: DataFrame containing geometry and value columns for interpolation
- `geometry_col::Symbol=:geometry`: Column name containing ArchGDAL geometry objects (default: `:geometry`)
- `value_col::Symbol=:republican_pct`: Column name containing numeric values to interpolate (default: `:republican_pct`)
  Can also use `:democratic_pct`, `:third_party_pct`, margin data, or any numeric column
- `resolution::Int=150`: Grid resolution for interpolation (higher = smoother but slower)
- `colormap::Symbol=:RdBu`: Makie colormap for the filled regions
  Use `:RdBu` for red-blue diverging (good for margins), `:viridis` for sequential data, etc.

# Returns
- Tuple of (filled_contours, interpolated_grid_Z, x_grid, y_grid)

# Details
- Uses Gaussian kernel density weighting for smooth interpolation
- Adaptive bandwidth based on data extent (slightly larger than `create_voting_contours!` for visibility)
- Draws both filled regions and contour lines for dual representation
- Filled regions have transparency (alpha=0.7) to show layer composition
- Contour lines overlaid in black for clarity
- Designed for political/electoral data visualization

# Example
```julia
fig, ax, plt = scatter(counties_df.longitude, counties_df.latitude)
cf, Z, x_grid, y_grid = create_filled_voting_contours!(ax, counties_df, value_col=:margin_pct, colormap=:RdBu)
```
"""
function create_filled_voting_contours!(ga, df;
    geometry_col=:geometry,
    value_col=:republican_pct,
    resolution=150,
    colormap=:RdBu)
    
    # Extract data
    n = nrow(df)
    centroids_x = Vector{Float64}(undef, n)
    centroids_y = Vector{Float64}(undef, n)
    values = Vector{Float64}(undef, n)
    
    for (i, row) in enumerate(eachrow(df))
        centroids_x[i], centroids_y[i] = extract_centroid(row[geometry_col])
        values[i] = row[value_col]
    end
    
    # Create grid
    x_min, x_max = extrema(centroids_x)
    y_min, y_max = extrema(centroids_y)
    
    x_grid = range(x_min, x_max, length=resolution)
    y_grid = range(y_min, y_max, length=resolution)
    Z = zeros(length(y_grid), length(x_grid))
    
    # Smooth interpolation
    bandwidth = (x_max - x_min) / 25
    
    for (i, y) in enumerate(y_grid)
        for (j, x) in enumerate(x_grid)
            weights = exp.(-((centroids_x .- x).^2 .+ (centroids_y .- y).^2) ./ (2 * bandwidth^2))
            Z[i, j] = sum(weights .* values) / sum(weights)
        end
    end
    
    # Create filled contours
    cf = contourf!(ga, x_grid, y_grid, Z,
                   levels=15,
                   colormap=colormap,
                   alpha=alpha)
    
    # Add contour lines
    contour!(ga, x_grid, y_grid, Z,
             levels=10,
             color=:black,
             linewidth=1,
             alpha=0.6,
             labels=true,
             labelsize=9)
    
    return cf, Z, x_grid, y_grid
end

export create_county_union, create_voting_contours!, create_filled_voting_contours!