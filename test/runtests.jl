using JuliaMapping
using Test
using DataFrames
using Statistics

@testset "JuliaMapping.jl" begin

# ==================== EXISTING TESTS ====================
@testset "Distance calculations" begin
    # Test haversine distance
    # Distance between NYC and LA (approximate)
    # Note: function takes (lon1, lat1, lon2, lat2)
    nyc_lon, nyc_lat = -74.0060, 40.7128
    la_lon, la_lat = -118.2437, 34.0522
    dist = haversine_distance_km(nyc_lon, nyc_lat, la_lon, la_lat)
    @test dist ≈ 3944.42 atol=50.0  # Allow for approximation differences
end

@testset "DMS conversion" begin
    # Test degrees-minutes-seconds to decimal conversion
    result = dms_to_decimal("40° 42' 46.0\" N, 74° 0' 21.6\" W")
    coords = split(result, ", ")
    lat = parse(Float64, coords[1])
    lon = parse(Float64, coords[2])
    @test lat ≈ 40.7128 atol=0.01
    @test lon ≈ -74.0060 atol=0.01
end

@testset "Basic utility functions" begin
    # Test with_commas function
    @test with_commas(1000) == "1,000"
    @test with_commas(1234567) == "1,234,567"
    @test with_commas(0) == "0"
    @test with_commas(100) == "100"
    
    # Test percent function
    @test percent(0.5) == "50.0%"
    @test percent(0.123) == "12.3%"
    @test percent(0.0) == "0.0%"
    @test percent(1.0) == "100.0%"
end

@testset "Constants" begin
    # Test that constants are defined
    @test isa(VALID_STATE_CODES, Dict)
    @test isa(VALID_STATEFPS, Vector)
    @test KM_PER_MILE ≈ 1.609344
    @test EARTH_RADIUS_KM ≈ 6371.0
    
    # Test state code lookup
    @test VALID_STATE_CODES["California"] == "CA"
    @test "01" ∈ VALID_STATEFPS
end

@testset "String manipulation" begin
    # Test hard_wrap function
    text = "This is a very long string that needs to be wrapped at a specific width"
    wrapped = hard_wrap(text, 20)
    lines = split(wrapped, "\n")
    @test all(length(line) <= 20 for line in lines)
    @test length(lines) > 1  # Should wrap into multiple lines
    
    # Test split_string_into_n_parts function
    result = split_string_into_n_parts("Hello World Test", 2)
    parts = split(result, "\n")
    @test length(parts) == 2
    
    # Test with different numbers of parts
    result3 = split_string_into_n_parts("One Two Three Four", 3)
    parts3 = split(result3, "\n")
    @test length(parts3) == 3
end

@testset "Margin/Table functions" begin
    df = DataFrame(
        Category = ["A", "B", "C"],
        Value1 = [1000, 2000, 3000],
        Value2 = [500, 1500, 2500]
    )
    
    @testset "add_totals with comma formatting" begin
        result = add_totals(df; format_commas=true)
        @test result[1, :Value1] == "1,000"
        @test result[2, :Value1] == "2,000"
        @test result[3, :Value1] == "3,000"
        @test result[4, :Value1] == "6,000"
        @test result[1, :Total] == "1,500"
        @test result[4, :Total] == "10,500"
        @test all(typeof(v) == String for v in result[!, :Value1])
    end
    
    @testset "add_totals without comma formatting" begin
        result = add_totals(df; format_commas=false)
        @test result[1, :Value1] == 1000
        @test result[2, :Value1] == 2000
        @test result[3, :Value1] == 3000
        @test result[4, :Value1] == 6000
        @test result[1, :Total] == 1500
        @test result[4, :Total] == 10500
        @test all(v isa Number for v in result[!, :Value1])
    end
    
    @testset "add_col_totals with specified columns" begin
        result = add_col_totals(df; cols_to_sum=["Value1"])
        @test result[4, :Value1] == 6000
        @test ismissing(result[4, :Value2])
        @test result[4, :Category] == "Total"
    end
    
    @testset "add_col_totals with all numeric columns" begin
        result = add_col_totals(df)
        @test result[4, :Value1] == 6000
        @test result[4, :Value2] == 4500
        @test result[4, :Category] == "Total"
        @test nrow(result) == 4
    end
    
    @testset "add_col_totals with missing values" begin
        df_missing = DataFrame(
            Category = ["A", "B", "C"],
            Value1 = [1000, missing, 3000],
            Value2 = [500, 1500, missing]
        )
        result = add_col_totals(df_missing; cols_to_sum=["Value1", "Value2"])
        @test result[4, :Value1] == 4000
        @test result[4, :Value2] == 2000
        @test result[4, :Category] == "Total"
    end
end

# ==================== NEW TESTS ====================

@testset "Statistical analysis functions" begin
    @testset "Skewness analysis" begin
        # Create test data with known skewness properties
        df_symmetric = DataFrame(value = [1.0, 2.0, 3.0, 4.0, 5.0])
        # This should print but not error
        @test_nowarn analyze_skewness(df_symmetric, :value)
    end
end

@testset "Data spread assessment" begin
    @testset "Assess data spread" begin
        df = DataFrame(value = rand(100))
        # Test that function runs and returns bin counts
        bin_counts = @test_nowarn assess_data_spread(df, :value, 5)
        @test isa(bin_counts, Vector{Int})
        @test length(bin_counts) == 5
        @test sum(bin_counts) == 100  # All observations accounted for
    end
    
    @testset "Assess uniform distribution" begin
        df = DataFrame(value = rand(100))
        result = @test_nowarn assess_uniform_distribution(df, :value)
        @test isa(result, NamedTuple)
        @test haskey(result, :skewness)
        @test haskey(result, :interval_cv)
        @test isa(result.skewness, Float64)
        @test isa(result.interval_cv, Float64)
    end
    
    @testset "Check outlier emphasis" begin
        df = DataFrame(value = [1, 2, 3, 4, 5, 100])  # 100 is an outlier
        @test_nowarn check_outlier_emphasis(df, :value)
    end
end

@testset "Clustering and binning" begin
    @testset "Detect clustering" begin
        df = DataFrame(value = [1, 2, 3, 10, 11, 12, 20, 21, 22])  # Three clusters
        large_gaps = @test_nowarn detect_clustering(df, :value, n_bins=3)
        @test isa(large_gaps, Vector)
    end
    
    @testset "Compute fixed intervals" begin
        df1 = DataFrame(value = rand(50))
        df2 = DataFrame(value = rand(50))
        breaks = @test_nowarn compute_fixed_intervals([df1, df2], :value, 5)
        @test isa(breaks, Vector{Float64})
        @test length(breaks) == 6  # n_bins + 1
        @test breaks[1] <= breaks[end]
        @test issorted(breaks)
    end
    
    @testset "Compare quantile vs Jenks" begin
        df = DataFrame(value = rand(100))
        result = @test_nowarn compare_quantile_vs_jenks(df, :value; k=5)
        @test isa(result, NamedTuple)
        @test haskey(result, :quantile_breaks)
        @test haskey(result, :width_cv)
        @test length(result.quantile_breaks) == 6  # k + 1
    end
end

@testset "Type conversion and formatting" begin
    @testset "Format breaks" begin
        breaks = ["100 - 200", "300.5 - 400.2"]
        formatted = @test_nowarn format_breaks(breaks)
        @test isa(formatted, Vector{String})
        @test length(formatted) == 2
    end
    
    @testset "Percent formatting" begin
        @test percent(0.25) == "25.0%"
        @test percent(0.001) == "0.1%"
        @test percent(0.9999) == "99.99%"
    end
end

@testset "Font availability" begin
    @testset "Font detection" begin
        # Test return type
        result = is_font_available("Helvetica")
        @test isa(result, Bool)
        
        # Test that function returns a boolean (doesn't error)
        result_nonexistent = is_font_available("XYZ_NonexistentFont_XYZ")
        @test isa(result_nonexistent, Bool)
    end
end

@testset "Additional exported functions" begin
    @testset "add_row_totals" begin
        df = DataFrame(
            Category = ["A", "B"],
            Value1 = [10, 20],
            Value2 = [30, 40]
        )
        # Test that function exists and doesn't error
        result = @test_nowarn add_row_totals(df)
        @test isa(result, DataFrame)
        @test nrow(result) >= nrow(df)
    end
    
    @testset "Color constants" begin
        # Test that color groups are defined
        @test isa(whites, Vector)
        @test isa(reds, Vector)
        @test isa(blues, Vector)
        @test isa(greens, Vector)
        @test length(whites) > 0
        @test length(reds) > 0
    end
    
    @testset "Coordinate reference systems" begin
        # Test CRS constants
        @test !isnothing(std_crs)
        @test !isnothing(conus_crs)
        @test !isnothing(conus_epsg)
        @test !isnothing(alaska_epsg)
        @test !isnothing(hawaii_epsg)
    end
    
    @testset "Create state union" begin
        # Create a minimal test - just verify function exists
        # Full testing would require actual shapefile data
        @test isdefined(JuliaMapping, :create_state_union)
    end
    
    @testset "Create county union" begin
        # Verify function is defined
        @test isdefined(JuliaMapping, :create_county_union)
    end
    
    @testset "pick_random_subset" begin
        # pick_random_subset takes a DataFrame with a Count column
        df = DataFrame(Count = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        subset = @test_nowarn pick_random_subset(df, 25)
        @test isa(subset, DataFrame)
    end
    
    @testset "uniform_subset_sum_indices" begin
        # uniform_subset_sum_indices takes a vector of integers
        counts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        indices = @test_nowarn uniform_subset_sum_indices(counts, 25)
        @test isa(indices, Vector)
        @test all(idx -> 1 <= idx <= length(counts), indices)
    end
 end

end
