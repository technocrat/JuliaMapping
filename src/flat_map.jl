using CairoMakie
using GeoDataFrames
using GeoMakie
using JuliaMapping
gdf = GeoDataFrames.read("data/2024_shp/cb_2024_us_state_500k.shp")
conus = subset(gdf, :NAME => ByRow(x -> x in keys(VALID_STATE_CODES)))
conus = subset(conus, :NAME => ByRow(x -> !(x in ["Alaska", "Hawaii"])))
f = Figure(size = (1600,800))
ga = GeoAxis(f[1, 1],  aspect = DataAspect(), source = dest = conus_crs)
hidedecorations!(ga)
poly!(ga,conus.geometry)
colsize!(f.layout, 1, Auto(true))
rowsize!(f.layout, 1, Auto(true))
display(f)