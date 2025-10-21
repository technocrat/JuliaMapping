using StatsBase
"""
    analyze_skewness(df::DataFrame, column::Symbol)

Analyze the skewness of a dataset with multiple metrics.

# Arguments
- `df`: DataFrame containing the data
- `column`: Column name to analyze

# Returns
- NamedTuple with skewness metrics
"""
function analyze_skewness(df::DataFrame, column::Symbol)
    data = df[!, column]
    sk = skewness(data)
    kt = kurtosis(data)
    
    # Interpretation
    if abs(sk) < 0.5
        sk_interp = "approximately symmetric"
    elseif abs(sk) < 1
        sk_interp = sk > 0 ? "moderately right-skewed" : "moderately left-skewed"
    else
        sk_interp = sk > 0 ? "highly right-skewed" : "highly left-skewed"
    end
    
    println("Skewness Analysis for $column:")
    println("=" ^ 50)
    println("Skewness coefficient: $(round(sk, digits=3))")
    println("Interpretation: $sk_interp")
    println("Kurtosis (excess): $(round(kt, digits=3))")
    println("\nFor reference:")
    println("  Normal distribution: skewness = 0, kurtosis = 0")
    println("  |skewness| > 1 suggests log transform may help")
    
    return (skewness=sk, kurtosis=kt, interpretation=sk_interp)
end

"""
    compare_skewness(df::DataFrame, column::Symbol)

Compare skewness before and after log transformation.

# Arguments
- `df`: DataFrame containing the data
- `column`: Column name to analyze

# Returns
- NamedTuple with original and log-transformed skewness
"""
function compare_skewness(df::DataFrame, column::Symbol)
    data = df[!, column]
    
    # Original
    sk_orig = skewness(data)
    
    # Log-transformed (handle zeros and negatives)
    data_positive = filter(x -> x > 0, data)
    sk_log = skewness(log10.(data_positive))
    
    println("Skewness Comparison for $column:")
    println("=" ^ 50)
    println("Original:        $(round(sk_orig, digits=3))")
    println("Log-transformed: $(round(sk_log, digits=3))")
    println("\nReduction: $(round(abs(sk_orig) - abs(sk_log), digits=3))")
    println(abs(sk_log) < abs(sk_orig) ? "✓ Log transform reduces skewness" : "✗ Log transform doesn't help")
    
    return (original=sk_orig, log_transformed=sk_log)
end

export analyze_skewness, compare_skewness