# JuliaMapping

This Julia package is a companion to *Julia Mapping: A Practical Guide* (in press 2025) for mapping, geospatial analysis, and data visualization. This package provides utilities for geographic calculations, coordinate transformations, data processing, and visualization of geospatial data.

## Installation

```julia
using Pkg
Pkg.add("JuliaMapping")
```

## Features

### Geographic Calculations
- **Distance Calculations**: Haversine distance between geographic points
- **Coordinate Transformations**: DMS (Degrees-Minutes-Seconds) to decimal degrees conversion
- **Centroid Extraction**: Extract centroids from geographic shapes
- **Geographic Shapes**: Generate geographic circles and custom markers

### Data Processing
- **Text Utilities**: String formatting, hard wrapping, splitting text
- **Table Utilities**: Add margins/totals to DataFrames, format tables as text
- **Numeric Formatting**: Percentage formatting, comma formatting for numbers
- **Type Conversion**: Automatic type conversion and formatting utilities

### Statistical Analysis
- **Distribution Analysis**: Skewness detection, uniformity assessment
- **Clustering Detection**: Identify natural clusters in data
- **Binning Recommendations**: Compare quantile vs. Fisher-Jenks methods
- **Data Spread Assessment**: Evaluate data distribution patterns

### Visualization
- **Color Schemes**: Comprehensive color palettes for mapping
- **Plotting Utilities**: Color scheme grids, histograms, small multiples
- **Mapping Functions**: Contour generation, dot density maps, radius maps
- **Electoral Visualization**: Specialized contour functions for political data

### Geospatial Data
- **Shapefile Inspection**: Tools to examine shapefile contents
- **Geographic Constants**: State codes, EPSG codes, coordinate systems
- **Spatial Operations**: Union, clipping, and boundary operations
- **Statistical Functions**: Point pattern analysis, hypothesis testing

## Quick Start

```julia
using JuliaMapping

# Calculate distance between two cities
dist = haversine_distance_km(-74.0060, 40.7128, -118.2437, 34.0522)  # NYC to LA
println("Distance: ", with_commas(round(Int, dist)), " km")

# Convert coordinates from DMS to decimal
coords = dms_to_decimal("40° 42' 46.0\" N, 74° 0' 21.6\" W")
println("NYC coordinates: ", coords)

# Format numbers nicely
println(percent(0.1524))  # "15.24%"
println(with_commas(1234567))  # "1,234,567"

# Access geographic constants
println("California state code: ", VALID_STATE_CODES["California"])  # "CA"
println("Earth radius: ", EARTH_RADIUS_KM, " km")  # 6371.0 km
```

## Key Functions

### Geographic Functions
- `haversine_distance_km(lon1, lat1, lon2, lat2)`: Calculate geodesic distance
- `dms_to_decimal(coords)`: Convert DMS coordinates to decimal degrees
- `extract_centroid(geometry)`: Extract centroid from geographic shapes

### Utility Functions
- `with_commas(number)`: Add comma separators to numbers
- `percent(decimal)`: Convert decimal to percentage string
- `hard_wrap(text, width)`: Wrap text at specified width
- `split_string_into_n_parts(text, n)`: Split text into n parts

### Data Functions
- `add_row_totals(df)`: Add row totals to DataFrame
- `add_col_totals(df)`: Add column totals to DataFrame
- `add_totals(df)`: Add both row and column totals
- `format_table_as_text(headers, rows)`: Format tabular data as text

### Visualization Functions
- `plot_colorscheme_grid(schemes)`: Display color scheme options
- `plot_named_color_groups()`: Show available color groups
- `quick_hist(data)`: Generate quick histogram

### Constants Available
- `VALID_STATE_CODES`: Dictionary of US state names to abbreviations
- `VALID_STATEFPS`: Array of valid state FIPS codes
- `EARTH_RADIUS_KM`: Earth's radius in kilometers (6371.0)
- `KM_PER_MILE`: Kilometers per mile conversion (1.609344)
- Color arrays: `whites`, `reds`, `oranges`, `yellows`, `greens`, `cyans`, `blues`, `purples`, `pinks`, `browns`, `grays`
- CRS definitions: `std_crs`, `conus_crs`, `conus_epsg`, `alaska_epsg`, `hawaii_epsg`

## Examples

### Working with Geographic Data
```julia
using JuliaMapping

# Calculate distances between multiple points
points = [(40.7128, -74.0060), (34.0522, -118.2437), (41.8781, -87.6298)]  # NYC, LA, Chicago
for i in 1:length(points)-1
    lat1, lon1 = points[i]
    lat2, lon2 = points[i+1]
    dist = haversine_distance_km(lon1, lat1, lon2, lat2)
    println("Distance ", i, " to ", i+1, ": ", with_commas(round(Int, dist)), " km")
end
```

### Data Formatting
```julia
using DataFrames, JuliaMapping

# Create a sample DataFrame
df = DataFrame(
    State = ["California", "Texas", "Florida"], 
    Population = [39538223, 29145505, 21538187],
    Area = [423967, 695662, 170312]
)

# Add totals
df_with_totals = add_totals(df, cols_to_sum=["Population", "Area"])
println(df_with_totals)
```

## Testing

This package has comprehensive test coverage with 98 test cases covering all major functions:

```julia
# Run tests from the package directory
using Pkg
Pkg.test("JuliaMapping")
```

Test coverage includes:
- Geographic calculations and coordinate transformations
- Data processing and formatting utilities
- Statistical analysis functions
- Margin and table operations
- String manipulation
- Type conversion and validation

## Documentation

Comprehensive documentation is available through Julia's built-in help system:

```julia
using JuliaMapping
?haversine_distance_km  # View function docstring
?with_commas
?add_totals
```

For full documentation, visit the generated docs in `docs/build/index.html`.

## Dependencies

This package builds on Julia's rich ecosystem including:
- **Geospatial**: ArchGDAL, GeoDataFrames, GeoMakie, NaturalEarth
- **Visualization**: CairoMakie, ColorSchemes, Colors
- **Data**: DataFrames, CSV, Statistics
- **Analysis**: Distributions, HypothesisTests, GLM

See `Project.toml` for the complete dependency list and version constraints.

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## License

MIT License
