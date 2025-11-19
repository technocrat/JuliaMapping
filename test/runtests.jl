using JuliaMapping
using Test
using DataFrames

@testset "JuliaMapping.jl" begin
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
        # Function requires both lat and lon in format "lat, lon"
        result = dms_to_decimal("40° 42' 46.0\" N, 74° 0' 21.6\" W")
        coords = split(result, ", ")
        lat = parse(Float64, coords[1])
        lon = parse(Float64, coords[2])
        @test lat ≈ 40.7128 atol=0.01
        @test lon ≈ -74.0060 atol=0.01
    end
    
    @testset "Utility functions" begin
        # Test with_commas function
        @test with_commas(1000) == "1,000"
        @test with_commas(1234567) == "1,234,567"
        
        # Test percent function
        @test percent(0.5) == "50.0%"
        @test percent(0.123) == "12.3%"
    end
    
    @testset "Constants" begin
        # Test that constants are defined
        @test isa(VALID_STATE_CODES, Dict)
        @test isa(VALID_STATEFPS, Vector)
        @test KM_PER_MILE ≈ 1.609344
        @test EARTH_RADIUS_KM ≈ 6371.0
        
        # Test state code lookup
        @test VALID_STATE_CODES["California"] == "CA"
        @test "01" ∈ VALID_STATEFPS  # Alabama FIPS code
    end
    
    @testset "String manipulation" begin
        # Test hard_wrap function
        text = "This is a very long string that needs to be wrapped at a specific width"
        wrapped = hard_wrap(text, 20)
        lines = split(wrapped, "\n")
        @test all(length(line) <= 20 for line in lines)
        
        # Test split_string_into_n_parts function
        result = split_string_into_n_parts("Hello World Test", 2)
        parts = split(result, "\n")
        @test length(parts) == 2
    end
    
    @testset "Margin functions" begin
        # Test data setup
        df = DataFrame(
            Category = ["A", "B", "C"],
            Value1 = [1000, 2000, 3000],
            Value2 = [500, 1500, 2500]
        )
        
        # Test 1: add_totals formats numeric values with comma separators when format_commas is true
        @testset "add_totals with comma formatting" begin
            result = add_totals(df; format_commas=true)
            # Check that numeric values are formatted with commas
            @test result[1, :Value1] == "1,000"
            @test result[2, :Value1] == "2,000"
            @test result[3, :Value1] == "3,000"
            @test result[4, :Value1] == "6,000"  # Total row
            @test result[1, :Total] == "1,500"   # Row total
            @test result[4, :Total] == "10,500"  # Grand total (sum of Total column)
            # Check all values are strings
            @test all(typeof(v) == String for v in result[!, :Value1])
        end
        
        # Test 2: add_totals returns correct DataFrame without comma formatting when format_commas is false
        @testset "add_totals without comma formatting" begin
            result = add_totals(df; format_commas=false)
            # Check that numeric values remain as numbers
            @test result[1, :Value1] == 1000
            @test result[2, :Value1] == 2000
            @test result[3, :Value1] == 3000
            @test result[4, :Value1] == 6000    # Total row
            @test result[1, :Total] == 1500     # Row total
            @test result[4, :Total] == 10500    # Grand total (sum of Total column)
            # Check values are numeric
            @test all(v isa Number for v in result[!, :Value1])
        end
        
        # Test 3: add_col_totals correctly sums specified columns
        @testset "add_col_totals with specified columns" begin
            result = add_col_totals(df; cols_to_sum=["Value1"])
            # Check that only Value1 is summed
            @test result[4, :Value1] == 6000
            # Value2 should have a label, not a sum
            @test ismissing(result[4, :Value2])
            # Category should have "Total" label
            @test result[4, :Category] == "Total"
        end
        
        # Test 4: add_col_totals correctly sums all numeric columns when cols_to_sum is not provided
        @testset "add_col_totals with all numeric columns" begin
            result = add_col_totals(df)
            # Check that all numeric columns are summed
            @test result[4, :Value1] == 6000
            @test result[4, :Value2] == 4500
            # Category should have "Total" label
            @test result[4, :Category] == "Total"
            # Check that we have 4 rows (3 original + 1 total)
            @test nrow(result) == 4
        end
        
        # Test 5: add_col_totals correctly handles cases with missing values in columns
        @testset "add_col_totals with missing values" begin
            df_missing = DataFrame(
                Category = ["A", "B", "C"],
                Value1 = [1000, missing, 3000],
                Value2 = [500, 1500, missing]
            )
            # When columns contain missing values, they must be explicitly specified
            result = add_col_totals(df_missing; cols_to_sum=["Value1", "Value2"])
            # Check that sums skip missing values
            @test result[4, :Value1] == 4000  # 1000 + 3000
            @test result[4, :Value2] == 2000  # 500 + 1500
            # Category should have "Total" label
            @test result[4, :Category] == "Total"
        end
    end
end
