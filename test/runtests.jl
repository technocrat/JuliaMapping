using JuliaMapping
using Test

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
end
