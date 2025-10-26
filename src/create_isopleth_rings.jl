

"""
    create_isopleth_rings(centroids_geo, distances=[25, 50, 75, 100, 150])

Create nested isopleth rings around geographic centroids, similar to elevation contours.

# Arguments
- `centroids_geo`: Vector of `Point2f` objects representing geographic centroids (longitude, latitude)
- `distances`: Vector of distances in miles for creating rings (default: `[25, 50, 75, 100, 150]`)

# Returns
- Dictionary mapping distance values to ArchGDAL geometry objects representing nested rings

# Details
This function creates concentric rings around each centroid at specified distances. The rings
are created as nested zones where each ring represents the area between its distance and
the previous distance (e.g., 25-50 miles, 50-75 miles, etc.). This creates an isopleth-like
visualization similar to elevation contours on topographic maps.

The function:
1. Converts distances from miles to degrees (approximate conversion: 1° ≈ 69 miles)
2. Creates circles around each centroid at each distance
3. Unions circles at the same distance to create zones
4. Creates rings by taking the difference between consecutive zones

# Example
```julia
using GeometryBasics, ArchGDAL

# Define centroids and distances
centroids = [Point2f(-74.0, 40.7), Point2f(-87.6, 41.9)]  # NYC, Chicago
distances = [50, 100, 150, 200]

# Create isopleth rings
rings = create_isopleth_rings(centroids, distances)
```

# Notes
- Distance conversion uses approximate factor of 69 miles per degree
- First ring represents the area from 0 to the first distance
- Subsequent rings represent areas between consecutive distances
- Progress is reported for each distance being processed
- Returns ArchGDAL geometries suitable for spatial operations and visualization
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

export create_isopleth_rings
