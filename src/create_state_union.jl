"""
    create_state_union(states::DataFrame, geometry_col=:geometry)

Create a union of all state geometries for use as a clipping boundary.

# Arguments
- `states`: DataFrame containing state geometries, typically loaded from a shapefile
- `geometry_col`: Symbol or string specifying the column name containing geometry data (default: `:geometry`)

# Returns
- An ArchGDAL geometry object representing the union of all state boundaries

# Details
This function iteratively unions all state geometries to create a single boundary
that can be used for clipping operations. The function includes progress reporting
and error handling to manage large datasets with many states.

# Example
```julia
using GeoDataFrames, ArchGDAL

# Load state data
states = GeoDataFrames.read("data/states.shp")

# Create union for clipping
state_boundary = create_state_union(states)
```

# Notes
- Progress is reported every 500 states processed
- Errors during union operations are caught and reported as warnings
- The function assumes geometries are in the same coordinate reference system
- Returns an ArchGDAL geometry suitable for spatial clipping operations
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

export create_state_union
