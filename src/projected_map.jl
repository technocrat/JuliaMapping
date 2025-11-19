using CairoMakie
using GeoDataFrames
using GeoMakie
using JuliaMapping
gdf = GeoDataFrames.read("data/2024_shp/cb_2024_us_state_500k.shp")
conus = subset(gdf, :NAME => ByRow(x -> x in keys(VALID_STATE_CODES)))
conus = subset(conus, :NAME => ByRow(x -> !(x in ["Alaska", "Hawaii"])))
fig = Figure(size = (1600,800))
ga = GeoAxis(fig[1, 1]; 
    dest = "+proj=aea +lat_0=32.8 +lon_0=-96.8 +lat_1=30 +lat_2=37 +datum=NAD83 +units=m +no_defs")
hidedecorations!(ga)
poly!(ga, conus.geometry)
display(fig)