using Documenter
using JuliaMapping

DocMeta.setdocmeta!(JuliaMapping, :DocTestSetup, :(using JuliaMapping); recursive=true)

makedocs(;
    modules=[JuliaMapping],
    authors="User",
    sitename="JuliaMapping.jl",
    format=Documenter.HTML(;
        prettyurls=false,
    ),
    pages=[
        "Home" => "index.md",
    ],
)
