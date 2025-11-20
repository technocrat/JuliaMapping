# using statements moved to JuliaMapping.jl

"""
    assess_data_spread(df::DataFrame, col::Symbol, n_bins::Int=5)

Evaluate the distribution of data across equal-interval bins to determine if equal-interval 
binning is appropriate for the specified column.

# Arguments
- `df::DataFrame`: Input dataframe containing the data
- `col::Symbol`: Column name to analyze
- `n_bins::Int=5`: Number of bins to create for the analysis

# Returns
- `Vector{Int}`: Array containing the count of observations in each bin

# Output
Prints a detailed bin distribution report and recommendation for binning strategy.
Warns if any bins contain less than 5% of total observations, suggesting alternative
methods like Fisher-Jenks or quantile-based binning for better balance.

# Example
```julia
df = DataFrame(value = rand(1000))
bin_counts = assess_data_spread(df, :value, 10)
```
"""
function assess_data_spread(df::DataFrame, col::Symbol, n_bins::Int=5)
    data = df[!, col]
    
    # Create equal interval bins
    min_val, max_val = extrema(data)
    interval_width = (max_val - min_val) / n_bins
    breaks = [min_val + i * interval_width for i in 0:n_bins]
    
    # Count observations per bin
    bin_counts = zeros(Int, n_bins)
    for val in data
        bin_idx = min(n_bins, Int(ceil((val - min_val) / interval_width)))
        bin_idx = max(1, bin_idx)
        bin_counts[bin_idx] += 1
    end
    
    # Check if any bins are severely underpopulated
    min_count = minimum(bin_counts)
    total_count = length(data)
    min_pct = min_count / total_count * 100
    
    println("Bin distribution:")
    for (i, count) in enumerate(bin_counts)
        pct = count / total_count * 100
        println("  Bin $i: $count observations ($(round(pct, digits=1))%)")
    end
    
    println("\nRecommendation:")
    if min_pct < 5
        println("⚠ Equal intervals leave bins with <5% of data")
        println("  Consider: Fisher-Jenks or quantiles for better balance")
    else
        println("✓ Data is spread well—equal intervals appropriate")
    end
    
    return bin_counts
end
"""
    assess_uniform_distribution(df::DataFrame, col::Symbol)

Analyze whether data follows a uniform distribution pattern, helping determine 
if equal-interval binning is suitable for the specified column.

# Arguments
- `df::DataFrame`: Input dataframe containing the data
- `col::Symbol`: Column name to analyze for uniformity

# Returns
- `NamedTuple{(:skewness, :interval_cv), Tuple{Float64, Float64}}`: Tuple containing:
  - `skewness`: Measure of distribution asymmetry (0 indicates symmetry)
  - `interval_cv`: Coefficient of variation for quantile intervals

# Output
Prints skewness, interval coefficient of variation, and a uniformity assessment.
Also generates a histogram visualization via `raw_hist()`.

# Notes
- Skewness near 0 and interval CV < 0.3 suggest suitability for equal intervals
- Higher values indicate consideration of alternative binning methods

# Example
```julia
df = DataFrame(value = rand(1000))
stats = assess_uniform_distribution(df, :value)
```
"""
function assess_uniform_distribution(df::DataFrame, col::Symbol)
    data = df[!, col]
    
    # Check skewness (should be close to 0 for uniform)
    sk = skewness(data)
    
    # Check distribution across quantiles
    quants = quantile(data, [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9])
    intervals = diff(quants)
    
    # Calculate coefficient of variation of interval sizes
    interval_cv = std(intervals) / mean(intervals)
    
    println("Skewness: $(round(sk, digits=3))")
    println("Interval CV: $(round(interval_cv, digits=3))")
    println("Uniformity score: $(interval_cv < 0.3 ? "Good for equal intervals" : "Consider other methods")")
    
    # Histogram to visualize
    raw_hist(df, col)
    
    return (skewness=sk, interval_cv=interval_cv)
end

"""
    check_outlier_emphasis(df::DataFrame, col::Symbol)

Identify and quantify outliers in data to determine if equal-interval binning 
would appropriately highlight extreme values.

# Arguments
- `df::DataFrame`: Input dataframe containing the data
- `col::Symbol`: Column name to analyze for outliers

# Returns
Nothing (results are printed to console)

# Output
Prints the percentage of outliers detected using the IQR method (1.5 × IQR rule).
Provides recommendations based on outlier prevalence:
- If >5% outliers: Confirms equal intervals will highlight these extremes
- Suggests quantiles as alternative for balanced visualization

# Method
Uses Tukey's fence method: outliers are values outside [Q1 - 1.5×IQR, Q3 + 1.5×IQR]

# Example
```julia
df = DataFrame(value = [rand(95); rand(5) .* 100])  # Data with outliers
check_outlier_emphasis(df, :value)
```
"""
function check_outlier_emphasis(df::DataFrame, col::Symbol)
    data = df[!, col]
    
    # Calculate IQR
    q1, q3 = quantile(data, [0.25, 0.75])
    iqr = q3 - q1
    
    # Count potential outliers
    lower_bound = q1 - 1.5 * iqr
    upper_bound = q3 + 1.5 * iqr
    n_outliers = sum((data .< lower_bound) .| (data .> upper_bound))
    outlier_pct = n_outliers / length(data) * 100
    
    println("Outlier percentage: $(round(outlier_pct, digits=1))%")
    
    if outlier_pct > 5
        println("✓ Equal intervals will highlight these outliers")
        println("  Alternative: Use quantiles if you want balanced visualization")
    end
end


"""
    detect_clustering(df::DataFrame, col::Symbol; n_bins::Int=5) -> Vector{Int}

Identify natural clusters and gaps in data to determine if Fisher-Jenks binning
is appropriate.

This function analyzes the distribution of gaps between consecutive sorted values
to detect whether the data contains natural clusters. Large gaps suggest natural
breakpoints that Fisher-Jenks optimization would identify effectively.

# Arguments
- `df::DataFrame`: Input DataFrame containing the data
- `col::Symbol`: Column name to analyze
- `n_bins::Int=5`: Number of bins to create (used for recommendation threshold)

# Returns
- `Vector{Int}`: Indices of locations with large gaps (potential natural breaks)

# Interpretation
- If number of large gaps ≥ `n_bins - 1`: Strong clustering detected → Use Fisher-Jenks
- If fewer large gaps: Weak clustering → Quantiles may be simpler
- Large gaps are defined as those exceeding mean + 1.5 × standard deviation

# Details
The function:
1. Sorts data and calculates gaps between consecutive values
2. Identifies "large" gaps using statistical threshold
3. Produces a histogram of gap sizes
4. Recommends binning strategy based on clustering strength

# Example
```julia
large_gaps = detect_clustering(counties, :margin_pct, n_bins=5)
# Prints analysis and shows gap distribution histogram
# Returns indices where natural breaks occur
```

# See also
[`compare_quantile_vs_jenks`](@ref), [`assess_uniform_distribution`](@ref)
"""
function detect_clustering(df::DataFrame, col::Symbol; n_bins::Int=5)
    data = sort(df[!, col])
    n = length(data)
    
    # Calculate gaps between consecutive sorted values
    gaps = diff(data)
    
    # Find large gaps (potential natural breaks)
    gap_threshold = mean(gaps) + 1.5 * std(gaps)
    large_gaps = findall(gaps .> gap_threshold)
    
    println("=== CLUSTERING ANALYSIS ===")
    println("Mean gap between sorted values: $(round(mean(gaps), digits=4))")
    println("Std of gaps: $(round(std(gaps), digits=4))")
    println("Number of large gaps (>1.5σ): $(length(large_gaps))")
    
    if length(large_gaps) >= n_bins - 1
        println("\n✓ Strong clustering detected - Fisher-Jenks recommended")
        println("  Natural break locations: $(data[large_gaps])")
    else
        println("\n→ Weak clustering - Quantiles may be simpler")
    end
    
    # Visualize gap distribution
    gap_df = DataFrame(gap = gaps)
    raw_hist(gap_df, :gap)
    
    return large_gaps
end


"""
    compute_fixed_intervals(dfs::Vector{DataFrame}, col::Symbol, n_bins::Int=5) -> Vector{Float64}

Calculate fixed equal-interval breaks across multiple DataFrames for consistent
map series comparisons.

When creating a series of choropleth maps (e.g., across time periods or regions),
using consistent bin breaks enables meaningful visual comparison. This function
computes global min/max across all datasets and creates equal-width intervals.

# Arguments
- `dfs::Vector{DataFrame}`: Vector of DataFrames to analyze
- `col::Symbol`: Column name present in all DataFrames
- `n_bins::Int=5`: Number of bins to create

# Returns
- `Vector{Float64}`: Bin break points (length = `n_bins + 1`)
  - First element is global minimum
  - Last element is global maximum
  - Interior elements divide range into equal widths

# Use Cases
- Time series maps (comparing same region across years)
- Atlas-style maps (comparing different regions)
- Multi-panel comparisons where color scales must match

# Example
```julia
# Compare election results across 2020 and 2024
breaks = compute_fixed_intervals([counties_2020, counties_2024], :margin_pct, 5)
# Use these breaks for both maps to enable direct comparison
# breaks will be something like: [-0.6, -0.36, -0.12, 0.12, 0.36, 0.6]
```

# Notes
- Ensures all maps use identical color-to-value mapping
- May result in empty bins if data ranges differ substantially between DataFrames
- Alternative to this approach: use quantiles computed on combined data

# See also
[`compare_quantile_vs_jenks`](@ref), [`assess_data_spread`](@ref)
"""
function compute_fixed_intervals(dfs::Vector{DataFrame}, col::Symbol, n_bins::Int=5)
    # Find global min/max across all time periods
    all_data = vcat([df[!, col] for df in dfs]...)
    global_min = minimum(all_data)
    global_max = maximum(all_data)
    
    # Create equal intervals
    interval_width = (global_max - global_min) / n_bins
    breaks = [global_min + i * interval_width for i in 0:n_bins]
    
    return breaks
end


"""
    compare_quantile_vs_jenks(df::DataFrame, col::Symbol; k::Int=5) -> NamedTuple

Compare quantile and Fisher-Jenks binning strategies by analyzing bin width variability.

This function computes quantile breaks and evaluates whether the resulting bins
have consistent widths. High variability in bin widths suggests that data has
natural clustering that Fisher-Jenks would capture more effectively.

# Arguments
- `df::DataFrame`: Input DataFrame containing the data
- `col::Symbol`: Column name to analyze
- `k::Int=5`: Number of bins to create

# Returns
- `NamedTuple` with fields:
  - `quantile_breaks`: Vector of k+1 break points from quantile method
  - `width_cv`: Coefficient of variation of quantile bin widths

# Interpretation
- `width_cv < 1.0`: Quantile widths are relatively uniform → Quantiles appropriate
- `1.0 ≤ width_cv ≤ 2.0`: Moderate variation → Either method works, depends on goals
- `width_cv > 2.0`: Highly variable widths → Data has clusters, Fisher-Jenks recommended

# Details
The coefficient of variation (CV) is calculated as: CV = σ(bin_widths) / μ(bin_widths)

High CV indicates that some bins span large ranges while others span small ranges,
which is a strong indicator of natural clustering in the data.

# Example
```julia
result = compare_quantile_vs_jenks(counties, :margin_pct, k=5)
# === COMPARING QUANTILES VS FISHER-JENKS ===
# 
# QUANTILES (k=5):
#   Bin 1: [-0.547, -0.263] - width: 0.284 - count: ~20.0%
#   Bin 2: [-0.263, -0.109] - width: 0.154 - count: ~20.0%
#   Bin 3: [-0.109, 0.176] - width: 0.285 - count: ~20.0%
#   Bin 4: [0.176, 0.426] - width: 0.250 - count: ~20.0%
#   Bin 5: [0.426, 0.831] - width: 0.405 - count: ~20.0%
#   Width CV: 0.342
# 
# INTERPRETATION:
# → Moderate variation in quantile widths
#   Either method could work—depends on communication goals
```

# Rationale
When quantile bins have very different widths, it means observations are unevenly
distributed across the value range. This is exactly what Fisher-Jenks is designed
to handle by finding optimal breakpoints between clusters.

# Notes
- This function analyzes quantiles only; for actual Fisher-Jenks breaks, use
  a dedicated package like `NaturalBreaks.jl` or implement the algorithm
- By definition, quantile bins always have equal counts (~100/k percent each)
- The diagnostic focuses on bin width variation as a proxy for clustering

# See also
[`detect_clustering`](@ref), [`choose_binning_for_margins`](@ref)
"""
function compare_quantile_vs_jenks(df::DataFrame, col::Symbol; k::Int=5)
    data = df[!, col]
    
    println("=== COMPARING QUANTILES VS FISHER-JENKS ===\n")
    
    # Quantile breaks
    quant_probs = range(0, 1, length=k+1)
    quant_breaks = quantile(data, quant_probs)
    quant_widths = diff(quant_breaks)
    
    println("QUANTILES (k=$k):")
    for i in 1:k
        width = quant_widths[i]
        pct = 100/k  # By definition, equal count
        println("  Bin $i: [$(round(quant_breaks[i], digits=3)), $(round(quant_breaks[i+1], digits=3))] - width: $(round(width, digits=3)) - count: ~$(round(pct, digits=1))%")
    end
    
    # Calculate coefficient of variation for quantile widths
    quant_cv = std(quant_widths) / mean(quant_widths)
    println("  Width CV: $(round(quant_cv, digits=3))")
    
    println("\nINTERPRETATION:")
    if quant_cv > 2.0
        println("⚠ Quantile bins have highly variable widths (CV=$(round(quant_cv, digits=2)))")
        println("  This suggests clusters in the data")
        println("  → Fisher-Jenks would likely produce more meaningful breaks")
    elseif quant_cv > 1.0
        println("→ Moderate variation in quantile widths")
        println("  Either method could work—depends on communication goals")
    else
        println("✓ Quantile widths are relatively uniform")
        println("  Quantiles are appropriate for this data")
    end
    
    return (quantile_breaks=quant_breaks, width_cv=quant_cv)
end


"""
    choose_binning_for_margins(df::DataFrame; k::Int=5) -> Nothing

Comprehensive analysis and recommendation for binning political margin data in
choropleth maps.

This function integrates multiple diagnostic approaches specifically tailored for
political margin/vote share data. It considers skewness, clustering patterns, bin
width variation, and domain-specific characteristics (competitive vs. landslide districts)
to provide an evidence-based binning recommendation.

# Arguments
- `df::DataFrame`: Input DataFrame containing margin data (must have `:margin_pct` column)
- `k::Int=5`: Number of bins to create

# Returns
- `Nothing`: Function prints comprehensive analysis and recommendation

# Details
The function performs the following analyses:
1. **Skewness analysis**: Evaluates distribution asymmetry
2. **Clustering detection**: Identifies natural breaks in the data
3. **Quantile comparison**: Assesses bin width variability
4. **Domain analysis**: Calculates percentages of competitive and landslide districts

# Domain-Specific Thresholds
- **Competitive districts**: |margin| < 10% (±0.1)
- **Landslide districts**: |margin| > 30% (±0.3)

# Recommendation Logic
Recommends Fisher-Jenks if:
- >30% of districts are competitive AND <10% are landslides (high clustering)
- Quantile width CV > 2.0 (strong evidence of natural clusters)

Recommends Quantiles if:
- Skewness > 1.5 (extreme skew requiring visual balance)
- Data is more uniformly distributed

# Example
```julia
choose_binning_for_margins(counties, k=5)
# === BINNING RECOMMENDATION FOR MARGIN DATA ===
# 
# [Skewness Analysis output]
# [Clustering Analysis output]
# [Quantile Comparison output]
# 
# === DOMAIN-SPECIFIC ANALYSIS ===
# Competitive districts (±10%): 1245 (39.8%)
# Landslide districts (>30%): 234 (7.5%)
# 
# === FINAL RECOMMENDATION ===
# ✓ Use FISHER-JENKS
#   Rationale: High concentration of competitive districts suggests
#             natural clustering that Jenks will reveal better than quantiles
```

# Use Cases
- Electoral data visualization (vote margins, partisan lean)
- Policy analysis (approval ratings, opinion polls)
- Any ratio/percentage data with potential clustering around central values

# Prerequisites
Requires that the DataFrame has a `:margin_pct` column. For other margin columns,
modify the function or create a standardized column first.

# See also
[`analyze_skewness`](@ref), [`detect_clustering`](@ref), [`compare_quantile_vs_jenks`](@ref)
"""
function choose_binning_for_margins(df::DataFrame; k::Int=5)
    println("=== BINNING RECOMMENDATION FOR MARGIN DATA ===\n")
    
    # 1. Check skewness
    stats = analyze_skewness(df, :margin_pct)
    
    # 2. Detect clustering
    clusters = detect_clustering(df, :margin_pct, n_bins=k)
    
    # 3. Compare methods
    comparison = compare_quantile_vs_jenks(df, :margin_pct, k=k)
    
    # 4. Domain-specific considerations for political margins
    println("\n=== DOMAIN-SPECIFIC ANALYSIS ===")
    
    # Count competitive districts (within ±10%)
    competitive = sum(abs.(df.margin_pct) .< 0.1)
    comp_pct = competitive / nrow(df) * 100
    
    println("Competitive districts (±10%): $competitive ($(round(comp_pct, digits=1))%)")
    
    # Count landslides (>30% margin)
    landslides = sum(abs.(df.margin_pct) .> 0.3)
    land_pct = landslides / nrow(df) * 100
    
    println("Landslide districts (>30%): $landslides ($(round(land_pct, digits=1))%)")
    
    println("\n=== FINAL RECOMMENDATION ===")
    
    if comp_pct > 30 && land_pct < 10
        println("✓ Use FISHER-JENKS")
        println("  Rationale: High concentration of competitive districts suggests")
        println("            natural clustering that Jenks will reveal better than quantiles")
    elseif comparison.width_cv > 2.0
        println("✓ Use FISHER-JENKS") 
        println("  Rationale: Large variation in quantile widths indicates")
        println("            data has natural structure worth preserving")
    elseif abs(stats.skewness) > 1.5
        println("→ Consider QUANTILES")
        println("  Rationale: Extreme skew + need for visual balance")
        println("  Alternative: Use Fisher-Jenks with more bins to capture structure")
    else
        println("→ Use QUANTILES for simplicity")
        println("  But consider Fisher-Jenks if audience is analytical")
    end
end

using AlgebraOfGraphics
using JuliaMapping
using DataFrames

"""
  log_dist(df::DataFrame, col::Symbol)

Create a histogram with overlaid density curve for log₁₀-transformed data.

Applies log₁₀(x + 1) transformation to the specified column and displays the distribution
using a normalized histogram (PDF) with a kernel density estimate overlay.

# Arguments
- `df::DataFrame`: Input data frame
- `col::Symbol`: Column name to visualize

# Visual elements
- Cadet blue histogram with 30 bins (α = 0.7)
- Red density curve overlay (stroke width = 2)

# Example
```julia
log_dist(census_data, :population)
```
"""
function log_dist(df::DataFrame, col::Symbol)
  # Create temporary DataFrame with log-transformed values
  temp_df = DataFrame(var = log10.(df[!, col] .+ 1))
  
  hist = data(temp_df) * mapping(:var) * histogram(bins=30, normalization=:pdf) * visual(color=:cadetblue, alpha=0.7)
  density_layer = data(temp_df) * mapping(:var) * visual(Density, color=:red, strokewidth=2)
  
  plt = hist + density_layer
  draw(plt, axis = (xlabel = "Log10($(string(col)))", ylabel = "Density"))
end

"""
  raw_dist(df::DataFrame, col::Symbol)

Create a histogram with overlaid density curve for untransformed data.

Displays the distribution of the specified column using a normalized histogram (PDF)
with a kernel density estimate overlay.

# Arguments
- `df::DataFrame`: Input data frame
- `col::Symbol`: Column name to visualize

# Visual elements
- Cadet blue histogram with 30 bins (α = 0.7)
- Red density curve overlay (stroke width = 2)

# Example
```julia
raw_dist(survey_data, :income)
```
"""
function raw_dist(df::DataFrame, col::Symbol)
  hist = data(df) * mapping(col) * histogram(bins=30, normalization=:pdf) * visual(color=:cadetblue, alpha=0.7)
  density_layer = data(df) * mapping(col) * visual(Density, color=:red, strokewidth=2)
  
  plt = hist + density_layer
  draw(plt, axis = (xlabel = string(col), ylabel = "Density"))
end

"""
  scaled_dist(df::DataFrame, col::Symbol; bandwidth_pct=0.05, bins=30)

Create a histogram with overlaid density curve using adaptive bandwidth scaling.

Displays the distribution with a kernel density estimate that uses bandwidth proportional
to the data range, allowing better control over smoothing relative to the scale of the data.

# Arguments
- `df::DataFrame`: Input data frame
- `col::Symbol`: Column name to visualize

# Keywords
- `bandwidth_pct::Float64=0.05`: Bandwidth as percentage of data range (0.0 to 1.0)
- `bins::Int=30`: Number of histogram bins

# Visual elements
- Cadet blue histogram (α = 0.7)
- Red density curve overlay with scaled bandwidth (stroke width = 2)

# Example
```julia
scaled_dist(measurements, :temperature, bandwidth_pct=0.1, bins=50)
```
"""

function scaled_dist(df::DataFrame, col::Symbol; bandwidth_pct=0.05, bins=30)
  # Calculate adaptive bandwidth based on data range
  col_range = maximum(df[!, col]) - minimum(df[!, col])
  scaled_bandwidth = col_range * bandwidth_pct
  
  hist = data(df) * mapping(col) * histogram(bins=bins, normalization=:pdf) * visual(color=:cadetblue, alpha=0.7)
  density_layer = data(df) * mapping(col) * visual(Density, bandwidth=scaled_bandwidth, color=:red, strokewidth=2)
  
  plt = hist + density_layer
  draw(plt, axis = (xlabel = string(col), ylabel = "Density"))
end

export log_dist, raw_dist, scaled_dist, assess_data_spread, assess_uniform_distribution, check_outlier_emphasis, detect_clustering, compute_fixed_intervals, compare_quantile_vs_jenks, choose_binning_for_margins