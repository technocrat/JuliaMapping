"""
    inspect_shp(path::String)

Prints the structure and field names of a shapefile for inspection.

# Arguments
- `path::String`: Path to the shapefile (.shp file)

# Details
This function reads a shapefile and prints:
- Layer name
- Feature count (number of records)
- All field/column names available in the shapefile

# Example
```julia
inspect_shp("/path/to/data.shp")
# Output:
# Layer name: data
# Feature count: 1234
# Fields:
#  - ID
#  - NAME
#  - geometry
```
"""
function inspect_shp(path::String)
    dataset = ArchGDAL.read(path)
    layer = ArchGDAL.getlayer(dataset, 0)
    layerdefn = ArchGDAL.layerdefn(layer)
    
    println("Layer name: ", ArchGDAL.getname(layer))
    println("Feature count: ", ArchGDAL.nfeature(layer))
    println("Fields:")
    
    # Get field names by iterating through field definitions
    nfields = ArchGDAL.nfield(layerdefn)
    for i in 0:(nfields-1)
        fd = ArchGDAL.getfielddefn(layerdefn, i)
        field_name = ArchGDAL.getname(fd)
        println(" - ", field_name)
    end
    
    ArchGDAL.destroy(dataset)
end

export inspect_shp
