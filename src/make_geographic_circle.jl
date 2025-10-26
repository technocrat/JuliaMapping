"""
    make_geographic_circle(center_geo, radius_deg, n_pts=64)

Create a circular polygon in geographic coordinates (longitude/latitude in degrees).

# Arguments
- `center_geo`: Tuple or vector containing (longitude, latitude) of the circle center in degrees
- `radius_deg`: Radius of the circle in degrees
- `n_pts`: Number of points to approximate the circle (default: 64)

# Returns
- Vector of `Point2f` objects representing the circle vertices

# Details
This function creates a circular polygon by generating points around the center at regular angular intervals. 
The function accounts for latitude distortion by dividing the longitude offset by the cosine of the latitude,
ensuring the circle appears approximately circular on a map projection.

# Example
```julia
# Create a circle centered at (0°N, 0°E) with 1-degree radius
circle_points = make_geographic_circle((0.0, 0.0), 1.0, 32)
```

# Notes
- The circle is created in geographic coordinates (WGS84, EPSG:4326)
- Latitude distortion correction is applied to maintain circular appearance
- Enter π and θ symbols in the REPL with \\piTAB and \\thetaTAB
"""
function make_geographic_circle(center_geo, radius_deg, n_pts=64)
    lon, lat = center_geo
    angles = range(0, 2π; length=n_pts)
    # Adjust for latitude distortion
    lat_factor = cos(deg2rad(lat))
    [Point2f(lon + radius_deg * cos(θ) / lat_factor, 
             lat + radius_deg * sin(θ)) for θ in angles]
end

export make_geographic_circle
