module JuliaMapping

include("bullseye.jl")
include("choose_bin.jl")
include("clip_rings_to_states.jl")
include("constants.jl")
include("contours.jl")
include("create_isopleth_rings.jl")
include("create_county_union.jl"),
include("create_state_union.jl"),
include("dms_to_decimal.jl")
include("dots.jl")
include("ensure_types.jl")
include("extract_centroid.jl")
include("format_table_as_text.jl")
include("get_gdp.jl")
include("get_nth_table.jl")
include("get_sheet.jl")
include("hard_wrap.jl")
include("haversine_distance_km.jl")
include("hist_dist.jl")
include("inspect_shp.jl")
include("make_geographic_circle.jl")
include("margins.jl")
include("percent.jl")
include("plot_colorscheme_grid.jl")
include("plot_named_color_groups.jl")
include("polygon_to_archgdal.jl")
include("skew_test.jl")
include("small_multiples.jl")
include("snow.jl")
include("split_strings_into_n_parts.jl")
include("with_commas.jl")

# Export functions
export add_col_totals,
       add_row_totals,
       add_totals,
       analyze_skewness,
       assess_spread_data,
	   assess_uniform_distribution,
       bullseye,
       check_outlier_emphasis
       clip_rings_to_states,
       compare_skewness,
       create_state_union,
       create_county_union,
       create_filled_voting_contours!,
       create_isopleth_rings,
       create_state_union,
       create_county_union,
       create_voting_contours!,
       dms_to_decimal,
       dots,
       extract_centroid,
       format_breaks,
       format_table_as_text,
       get_gdp,
       get_nth_table,
       get_sheet,
       hard_wrap,
       haversine_distance_km,
       log_dist,
       inspect_shp,
       make_combined_table,
       make_geographic_circle,
       percent,
       pick_random_subset,
       plot_colorscheme_grid,
       plot_county_interval,
       plot_named_color_groups,
       polygon_to_archgdal,
       pump_comparison_test,
       quick_hist,
       ripleys_k,
       scaled_dist,
       show_named_color_groups,
       split_string_into_n_parts,
       uniform_subset_sum_indices,
       with_commas,
       detect_clustering, 
       compute_fixed_intervals, 
       compare_quantile_vs_jenks 
       choose_binning_for_margins

# Export constants
export VALID_STATE_CODES,
       VALID_STATEFPS,
       std_crs,
       conus_crs,
       conus_epsg,
       alaska_epsg,
       hawaii_epsg,
       KM_PER_MILE,
       EARTH_RADIUS_KM,
       whites,
       reds,
       oranges,
       yellows,
       greens,
       cyans,
       blues,
       purples,
       pinks,
       browns,
       grays

end # module JuliaMapping
