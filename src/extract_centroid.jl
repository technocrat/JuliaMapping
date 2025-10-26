
"""
    extract_centroid(geometry)

Extract the centroid coordinates from a geometry object.

# Arguments
- `geometry`: An ArchGDAL geometry object

# Returns
- A tuple `(x, y)` containing the longitude and latitude coordinates of the centroid

# Example
```julia
centroid_x, centroid_y = extract_centroid(geom)
```
"""
function extract_centroid(geometry)
    centroid = ArchGDAL.centroid(geometry)
    return ArchGDAL.getx(centroid, 0), ArchGDAL.gety(centroid, 0)
end

export extract_centroid
