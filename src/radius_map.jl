using ArchGDAL
using GeometryBasics
using Statistics

"""
    make_geographic_circle(center_geo, radius_deg, n_pts=64)

Create a circle polygon in geographic coordinates (latitude/longitude).

Generates points around a circle centered at the given geographic coordinates, adjusting
for latitude distortion using a cosine correction factor.

# Arguments
- `center_geo`: Tuple `(lon, lat)` representing the center point in degrees
- `radius_deg`: Radius of the circle in degrees
- `n_pts`: Number of points to use for the circle perimeter (default: `64`)

# Returns
- Vector of `Point2f` objects representing the circle's perimeter

# Details
- Applies latitude correction factor `cos(lat)` to adjust for map distortion
- Points are generated counterclockwise starting from 0 radians
- Higher `n_pts` values create smoother circles

# Example
```julia
center = (-86.7816, 36.1627)  # Nashville, TN
radius = 0.5  # approximately 35 miles
circle_points = make_geographic_circle(center, radius, 100)
```

# Notes
Enter the symbols for π and θ in the REPL with `\\piTAB` and `\\thetaTAB`
"""
function make_geographic_circle(center_geo, radius_deg, n_pts=64)
    lon, lat = center_geo
    angles = range(0, 2π; length=n_pts)
    # Adjust for latitude distortion
    lat_factor = cos(deg2rad(lat))
    [Point2f(lon + radius_deg * cos(θ) / lat_factor, 
             lat + radius_deg * sin(θ)) for θ in angles]
end

"""
    polygon_to_archgdal(poly::Polygon)

Convert a GeometryBasics Polygon to an ArchGDAL geometry object.

Extracts coordinates from a GeometryBasics polygon and creates an equivalent ArchGDAL
polygon geometry, ensuring the ring is properly closed.

# Arguments
- `poly::Polygon`: A GeometryBasics Polygon object with an exterior ring

# Returns
- An ArchGDAL polygon geometry object

# Details
- Extracts x and y coordinates from the polygon's exterior ring
- Automatically closes the ring if not already closed (first point = last point)
- Uses `ArchGDAL.createpolygon` for geometry construction

# Example
```julia
points = [Point2f(0, 0), Point2f(1, 0), Point2f(1, 1), Point2f(0, 1)]
poly = Polygon(points)
archgdal_geom = polygon_to_archgdal(poly)
```
"""
function polygon_to_archgdal(poly::Polygon)
    points = poly.exterior
    # Create coordinate arrays
    x_coords = [p[1] for p in points]
    y_coords = [p[2] for p in points]
    
    # Close the ring if not already closed
    if x_coords[1] != x_coords[end] || y_coords[1] != y_coords[end]
        push!(x_coords, x_coords[1])
        push!(y_coords, y_coords[1])
    end
    
    # Create ArchGDAL polygon using coordinate vectors
    return ArchGDAL.createpolygon(x_coords, y_coords)
end

"""
    create_state_union(states::DataFrame, geometry_col=:geometry)

Create a unified geometry representing the union of all state or county geometries.

Iteratively combines all geometries in a DataFrame using ArchGDAL's union operation,
which is useful for creating boundaries for clipping isopleth rings or other spatial operations.

# Arguments
- `states::DataFrame`: DataFrame containing state or county geometry data
- `geometry_col`: Symbol specifying the column name with ArchGDAL geometry objects (default: `:geometry`)

# Returns
- An ArchGDAL geometry object representing the union of all input geometries

# Details
- Progress is printed every 500 geometries for large datasets
- Handles union errors gracefully with warning messages
- Despite the name, works with any administrative boundary (states, counties, etc.)

# Example
```julia
state_boundary = create_state_union(states_df)
county_boundary = create_state_union(counties_df, geometry_col=:geom)
```

# Notes
The function name mentions "state" but it works for any geometry collection.
"""
function create_state_union(states::DataFrame, geometry_col=:geometry)
    println("Creating union of all counties for clipping...")
    
    # df.geometry contains ArchGDAL.IGeometry objects, use them directly
    state_geoms = states[!, geometry_col]
    
    # Create union of all counties
    state_union = state_geoms[1]
    for i in 2:length(state_geoms)
        if i % 500 == 0
            println("Processing state ", i, " of ", length(state_geoms))
        end
        try
            state_union = ArchGDAL.union(state_union, state_geoms[i])
        catch e
            println("Warning: Could not union state ", i, ": ", e)
        end
    end
    
    return state_union
end

"""
    clip_rings_to_states(rings, state_union)

Clip isopleth rings to match state or regional boundaries.

Takes a dictionary of distance rings and clips each one to the provided boundary geometry,
ensuring rings don't extend beyond state/county borders.

# Arguments
- `rings`: Dictionary mapping distances to ArchGDAL ring geometries
- `state_union`: ArchGDAL geometry representing the boundary to clip to

# Returns
- Dictionary mapping distances to clipped ArchGDAL geometries

# Details
- Uses ArchGDAL's `intersection` operation for clipping
- Prints progress for each distance ring
- If clipping fails for a ring, keeps the original unclipped geometry
- Error messages are printed but don't stop execution

# Example
```julia
rings = create_isopleth_rings(centroids, [25, 50, 75, 100])
state_boundary = create_state_union(states_df)
clipped = clip_rings_to_states(rings, state_boundary)
```

# Notes
Essential for creating clean visualizations where rings respect political boundaries.
"""
function clip_rings_to_states(rings, state_union)
    clipped_rings = Dict()
    
    for (distance, ring_geom) in rings
        println("Clipping ring for ", distance, " miles...")
        try
            # Intersect ring with state union
            clipped_ring = ArchGDAL.intersection(ring_geom, state_union)
            clipped_rings[distance] = clipped_ring
        catch e
            println("Error clipping ring for ", distance, " miles: ", e)
            # Keep original if clipping fails
            clipped_rings[distance] = ring_geom
        end
    end
    
    return clipped_rings
end

"""
    create_isopleth_rings(centroids_geo, distances=[25, 50, 75, 100, 150])

Create nested distance rings (isopleths) around multiple center points, like elevation contours.

Generates concentric rings showing areas within specified distances from multiple center points.
Each ring represents the area between two distance thresholds, creating a donut-like shape.

# Arguments
- `centroids_geo`: Vector of tuples `(lon, lat)` representing center points
- `distances`: Vector of distances in miles for ring boundaries (default: `[25, 50, 75, 100, 150]`)

# Returns
- Dictionary mapping each distance to its corresponding ArchGDAL ring geometry

# Details
- Converts miles to degrees using approximation: 1 degree ≈ 69 miles
- First ring includes all area within the first distance
- Subsequent rings are annular (donut-shaped): area between current and previous distance
- Uses `ArchGDAL.union` to combine overlapping circles from multiple centers
- Uses `ArchGDAL.difference` to create donut rings
- Prints progress for each distance ring

# Example
```julia
centers = [(-86.78, 36.16), (-84.39, 33.75)]  # Nashville and Atlanta
rings = create_isopleth_rings(centers, [50, 100, 150, 200])
# Returns: Dict(50 => ring1, 100 => ring2, 150 => ring3, 200 => ring4)
```

# Notes
- Ring geometries may extend beyond political boundaries; use `clip_rings_to_states` to clip them
- The approximation of 69 miles/degree is reasonably accurate for mid-latitudes
- Useful for visualizing service areas, travel distances, or influence zones
"""
function create_isopleth_rings(centroids_geo, distances=[25, 50, 75, 100, 150])
    rings = Dict()
    previous_zone = nothing
    
    for (i, dist) in enumerate(distances)
        println("Creating ring for ", dist, " miles...")
        
        radius_degrees = dist / 69.0
        circles = [Polygon(make_geographic_circle(c, radius_degrees)) for c in centroids_geo]
        
        # Convert to ArchGDAL and create union
        circle_geoms = [polygon_to_archgdal(poly) for poly in circles]
        current_zone = circle_geoms[1]
        for j in 2:length(circle_geoms)
            current_zone = ArchGDAL.union(current_zone, circle_geoms[j])
        end
        
        if i == 1
            # First ring is just the zone itself
            rings[dist] = current_zone
        else
            # Subsequent rings are current zone minus previous zone
            ring = ArchGDAL.difference(current_zone, previous_zone)
            rings[dist] = ring
        end
        
        previous_zone = current_zone
    end
    
    return rings
end

export create_isopleth_rings, create_state_union, clip_rings_to_states