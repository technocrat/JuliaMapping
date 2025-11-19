using JuliaMapping
conus = subset(gdf, :STATEFP => ByRow(x -> x in VALID_STATEFPS))
conus = subset(conus, :STATEFP => ByRow(x -> !(x in ["02","15"])))
using CairoMakie
using GeoDataFrames
using GeoMakie
gdf = GeoDataFrames.read("data/2024_shp/cb_2024_us_state_500k.shp")
conus = subset(gdf, :NAME => ByRow(x -> x in keys(VALID_STATE_CODES)))
conus = subset(conus, :NAME => ByRow(x -> !(x in ["Alaska", "Hawaii"])))
f = Figure(size = (1600,800))
ga = GeoAxis(f[1, 1], aspect = DataAspect())
poly!(ga,conus.geometry)
resize_to_layout!(f)
display(f)