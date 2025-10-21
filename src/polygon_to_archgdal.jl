using ArchGDAL
using GeometryBasics
using Statistics

"""
    polygon_to_archgdal(poly::Polygon)

Convert a GeometryBasics.Polygon to an ArchGDAL geometry object.

# Arguments
- `poly`: A `Polygon` object from GeometryBasics containing the polygon vertices

# Returns
- An ArchGDAL polygon geometry object that can be used for spatial operations

# Details
This function extracts the exterior ring coordinates from a GeometryBasics.Polygon
and creates a corresponding ArchGDAL polygon. The function automatically closes
the ring if it's not already closed by duplicating the first point at the end.

# Example
```julia
using GeometryBasics, ArchGDAL

# Create a simple polygon
points = [Point2f(0,0), Point2f(1,0), Point2f(1,1), Point2f(0,1)]
poly = Polygon(points)

# Convert to ArchGDAL geometry
gdal_poly = polygon_to_archgdal(poly)
```

# Notes
- The function handles both closed and unclosed polygon rings
- Returns an ArchGDAL geometry suitable for spatial analysis operations
- Coordinate order is preserved (longitude, latitude for geographic data)
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

export polygon_to_archgdal