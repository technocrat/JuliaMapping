using ArchGDAL
using GeometryBasics
using Statistics
"""
    create_county_union(counties::DataFrame, geometry_col=:geometry)

Create a union of all county geometries for use as a clipping boundary.

# Arguments
- `counties`: DataFrame containing county geometries, typically loaded from a shapefile
- `geometry_col`: Symbol or string specifying the column name containing geometry data (default: `:geometry`)

# Returns
- An ArchGDAL geometry object representing the union of all county boundaries

# Details
This function iteratively unions all county geometries to create a single boundary
that can be used for clipping operations. The function includes progress reporting
and error handling to manage large datasets with many counties.

# Example
```julia
using GeoDataFrames, ArchGDAL

# Load county data
counties = GeoDataFrames.read("data/counties.shp")

# Create union for clipping
county_boundary = create_county_union(counties)
```

# Notes
- Progress is reported every 500 counties processed
- Errors during union operations are caught and reported as warnings
- The function assumes geometries are in the same coordinate reference system
- Returns an ArchGDAL geometry suitable for spatial clipping operations
"""
function create_county_union(counties::DataFrame, geometry_col=:geometry)
    println("Creating union of all counties for clipping...")
    
    # df.geometry contains ArchGDAL.IGeometry objects, use them directly
    county_geoms = counties[!, geometry_col]
    
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

export create_county_union