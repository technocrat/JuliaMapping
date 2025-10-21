
"""
    clip_rings_to_states(rings, state_union)

Clip distance rings to state boundaries using spatial intersection.

# Arguments
- `rings`: Dictionary mapping distance values to ArchGDAL geometry objects representing distance rings
- `state_union`: ArchGDAL geometry object representing the union of all state boundaries

# Returns
- Dictionary with the same keys as input `rings`, containing clipped geometry objects

# Details
This function clips each distance ring to the state boundaries by computing the spatial
intersection between each ring and the state union. If clipping fails for any ring,
the original unclipped geometry is retained to ensure the workflow continues.

# Example
```julia
using ArchGDAL

# Create distance rings and state union
rings = Dict(25 => ring_25_miles, 50 => ring_50_miles, 75 => ring_75_miles)
state_boundary = create_state_union(states)

# Clip rings to state boundaries
clipped_rings = clip_rings_to_states(rings, state_boundary)
```

# Notes
- Progress is reported for each ring being clipped
- Errors during intersection operations are caught and reported as warnings
- Original geometries are preserved if clipping fails
- Returns geometries suitable for visualization and further spatial analysis
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
clip_rings_to_states