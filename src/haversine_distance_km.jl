"""
    haversine_distance_km(lon1, lat1, lon2, lat2)

Calculate geodesic distance between two points using the Haversine formula.
"""
function haversine_distance_km(lon1::Float64, lat1::Float64, lon2::Float64, lat2::Float64)
    dlat = deg2rad(lat2 - lat1)
    dlon = deg2rad(lon2 - lon1)
    
    a = sin(dlat/2)^2 + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dlon/2)^2
    c = 2 * atan(sqrt(a), sqrt(1-a))
    
    return EARTH_RADIUS_KM * c
end

export haversine_distance_km