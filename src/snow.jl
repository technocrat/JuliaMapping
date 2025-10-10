using GLM
using Dates
using Distances
using KernelDensity
using Statistics
using Random
using LinearAlgebra
using Distributions

"""
    uniform_subset_sum_indices(counts::AbstractVector{<:Integer}, target::Integer; rng=Random.default_rng())

Find indices of elements that sum to a target value using uniform random selection via dynamic programming.

Uses a dynamic programming approach to uniformly sample from all possible subsets of `counts` 
that sum exactly to `target`. Each valid subset has an equal probability of being selected.

# Arguments
- `counts::AbstractVector{<:Integer}`: Vector of integer values (e.g., counts per category)
- `target::Integer`: The desired sum
- `rng`: Random number generator (default: `Random.default_rng()`)

# Returns
- Vector of indices whose corresponding `counts` values sum to `target`
- Returns empty `Int[]` if no valid subset exists

# Algorithm
1. Builds a DP table counting all possible ways to achieve each sum
2. Uses `BigInt` arithmetic to handle large combinatorial counts
3. Backtracks through the DP table, randomly choosing to include/exclude each element
4. Inclusion probability = (ways to include) / (total ways from this state)

# Example
```julia
counts = [10, 20, 30, 40, 50]
target = 80
indices = uniform_subset_sum_indices(counts, target)
# Might return [1, 3, 4] since counts[[1,3,4]] = [10,30,40] sum to 80
sum(counts[indices]) == target  # Always true if indices is non-empty
```

# Notes
- Useful for statistical sampling when you need exactly N items from categories
- Computationally intensive for large vectors or large target values
- Related to the subset sum problem, but with uniform random selection
"""
function uniform_subset_sum_indices(counts::AbstractVector{<:Integer},
    target::Integer; rng=Random.default_rng())
    n = length(counts)
    T = target
    dp = fill(BigInt(0), n + 1, T + 1)
    dp[1, 1] = BigInt(1)

    @inbounds for i in 1:n
        wi = counts[i]
        for s in 0:T
            dp[i+1, s+1] += dp[i, s+1]
            if wi <= s
                dp[i+1, s+1] += dp[i, s-wi+1]
            end
        end
    end

    total = dp[n+1, T+1]
    total == 0 && return Int[]

    sel = Int[]
    s = T
    @inbounds for i in n:-1:1
        wi = counts[i]
        c_excl = dp[i, s+1]
        c_incl = (wi <= s) ? dp[i, s-wi+1] : BigInt(0)
        tot_here = c_excl + c_incl

        if tot_here == 0
            return Int[]
        end

        p_incl = c_incl == 0 ? 0.0 : Float64(BigFloat(c_incl) / BigFloat(tot_here))
        if rand(rng) < p_incl
            push!(sel, i)
            s -= wi
        end
    end

    @assert s == 0
    reverse!(sel)
    return sel
end

"""
    pick_random_subset(data, target_sum; rng=Random.default_rng())

Select a random subset of rows from a DataFrame where a count column sums to a target value.

Convenience wrapper around `uniform_subset_sum_indices` that works directly with DataFrames
containing a `:Count` column.

# Arguments
- `data`: DataFrame with a `:Count` column containing integer values
- `target_sum`: The desired sum of the `:Count` column
- `rng`: Random number generator (default: `Random.default_rng()`)

# Returns
- A subset of the input DataFrame (rows whose `:Count` values sum to `target_sum`)
- Returns empty DataFrame if no valid subset exists

# Example
```julia
using DataFrames
deaths = DataFrame(
    location = ["A", "B", "C", "D", "E"],
    Count = [5, 10, 15, 20, 25]
)
subset = pick_random_subset(deaths, 40)
# Returns rows that sum to exactly 40 deaths, e.g., rows with counts [5, 15, 20]
```

# Notes
- Assumes the DataFrame has a `:Count` column
- Each valid subset has equal probability of selection
- Useful for bootstrap sampling with exact sample size constraints
"""
function pick_random_subset(data, target_sum; rng=Random.default_rng())
    indices = uniform_subset_sum_indices(data.Count, target_sum; rng=rng)
    return data[indices, :]
end

"""
    pump_comparison_test(pump_1_mean, other_means, n_permutations=10000)

Perform a permutation test to compare one pump against the mean of other pumps.

Tests whether Pump 1 has a significantly lower mean than other pumps using a one-tailed 
permutation test. Inspired by John Snow's cholera analysis comparing the Broad Street pump 
to other water pumps in London.

# Arguments
- `pump_1_mean`: Mean value for the pump of interest (e.g., mean deaths)
- `other_means`: Vector of mean values for comparison pumps
- `n_permutations`: Number of permutations for the test (default: `10000`)

# Returns
A tuple `(p_value, observed_diff)` where:
- `p_value`: Proportion of permutations with difference ≤ observed difference
- `observed_diff`: Observed difference (Pump 1 mean - mean of others)

# Details
- Null hypothesis: All pumps come from the same distribution
- Tests if Pump 1 is unusually low (one-tailed test)
- Prints the observed difference to console
- Randomly permutes pump labels and recalculates the test statistic

# Example
```julia
pump_1 = 8.5  # Mean deaths near Broad Street pump
others = [3.2, 2.8, 3.5, 2.9, 3.1]  # Mean deaths near other pumps
p_value, diff = pump_comparison_test(pump_1, others, 10000)
println("P-value: \$p_value")
# If p_value < 0.05, Pump 1 has significantly higher mean deaths
```

# Notes
- Small p-values suggest Pump 1 is unusually high (or low, depending on metric)
- Based on resampling without replacement (permutation test)
- Named after John Snow's 1854 cholera outbreak investigation
"""
function pump_comparison_test(pump_1_mean, other_means, n_permutations=10000)
    observed_diff = pump_1_mean - mean(other_means)
    println("Observed difference (Pump 1 - mean of others): $(round(observed_diff, digits=2))")

    all_means = [pump_1_mean; other_means]
    more_extreme_count = 0

    for i in 1:n_permutations
        shuffled_means = shuffle(all_means)
        random_pump_1 = shuffled_means[1]
        random_others = shuffled_means[2:end]
        random_diff = random_pump_1 - mean(random_others)

        if random_diff <= observed_diff
            more_extreme_count += 1
        end
    end

    p_value = more_extreme_count / n_permutations
    return p_value, observed_diff
end

"""
    ripleys_k(coords, distances; area=nothing)

Calculate Ripley's K-function to detect spatial clustering or dispersion of point patterns.

Ripley's K-function measures the spatial distribution of points at various distance scales.
Values higher than expected indicate clustering; lower values indicate dispersion.

# Arguments
- `coords`: 2×n matrix where each column is a point `[x, y]`
- `distances`: Vector of distance thresholds to evaluate
- `area`: Optional study area size; if `nothing`, calculated as bounding box area

# Returns
- Vector of K-function values, one for each distance in `distances`

# Formula
For distance d: K(d) = (A/n²) × 2 × (number of point pairs within distance d)

Where:
- A = study area
- n = number of points

# Interpretation
- K(d) ≈ πd² for complete spatial randomness (CSR)
- K(d) > πd² suggests clustering at distance d
- K(d) < πd² suggests dispersion/regularity at distance d
- Often transformed to L(d) = √(K(d)/π) - d for easier interpretation

# Example
```julia
# Points in 2D space (cholera deaths)
coords = [1.0 2.0 3.0 5.0 5.5;
          1.0 1.5 2.0 5.0 5.2]
distances = [0.5, 1.0, 2.0, 3.0]
k_values = ripleys_k(coords, distances)

# Check for clustering
for (d, k) in zip(distances, k_values)
    expected = π * d^2
    println("Distance \$d: K=\$k (expected=\$expected)")
end
```

# Notes
- Computational complexity: O(n² × length(distances))
- Named after statistician Brian Ripley
- Commonly used in spatial epidemiology and ecology
- John Snow's cholera analysis can be analyzed with this function
"""
function ripleys_k(coords, distances; area=nothing)
    n = size(coords, 2)
    
    if area === nothing
        x_range = maximum(coords[1, :]) - minimum(coords[1, :])
        y_range = maximum(coords[2, :]) - minimum(coords[2, :])
        area = x_range * y_range
    end
    
    k_values = Float64[]
    
    for d in distances
        pair_count = 0
        for i in 1:n
            for j in (i+1):n
                dist = sqrt(sum((coords[:, i] - coords[:, j]).^2))
                if dist <= d
                    pair_count += 1
                end
            end
        end
        
        k_d = (area / n^2) * 2 * pair_count
        push!(k_values, k_d)
    end
    
    return k_values
end

export uniform_subset_sum_indices, pick_random_subset, pump_comparison_test, ripleys_k
