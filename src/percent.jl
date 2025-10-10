"""
    percent(x::Float64)

Convert a decimal value to a percentage string with two decimal places.

Takes a decimal value (e.g., 0.5) and converts it to a formatted percentage string (e.g., "50.0%").

# Arguments
- `x::Float64`: A decimal value (typically between 0.0 and 1.0)

# Returns
- A string representation of the percentage with two decimal places and a "%" suffix

# Example
```julia
percent(0.5)        # Returns "50.0%"
percent(0.7532)     # Returns "75.32%"
percent(0.123456)   # Returns "12.35%"
percent(1.0)        # Returns "100.0%"
```

# Notes
- Values are multiplied by 100 and rounded to 2 decimal places
- Works with any Float64 value, not just those between 0 and 1
"""
function percent(x::Float64)
  x = Float64(x)
  return string(round(x * 100; digits=2)) * "%"
end 
