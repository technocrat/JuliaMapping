using JuliaMapping
using Test

@testset "JuliaMapping.jl" begin
    @testset "Basic functionality" begin
        @test JuliaMapping.greet() isa Nothing
    end
end