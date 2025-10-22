using DataFrames
using Statistics
using StatsBase

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
Also generates a histogram visualization via `quick_hist()`.

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
    quick_hist(df, col)
    
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
