
"""
    with_commas(x)

Format numeric values with comma separators for thousands.

Converts numeric values to Int64 and adds comma separators using the Humanize.digitsep function,
making large numbers more readable.

# Arguments
- `x`: A numeric value or array of numeric values

# Returns
- A string or array of strings with comma-separated digits

# Example
```julia
with_commas(1000000)        # Returns "1,000,000"
with_commas([1234, 5678])   # Returns ["1,234", "5,678"]
with_commas(1234.56)        # Returns "1,235" (rounded to Int64)
```

# Notes
- Values are converted to Int64, so decimal portions are truncated/rounded
- Uses the Humanize package for formatting
"""
function with_commas(x)
  x = Int64.(x)
  return Humanize.digitsep.(x)
end

export with_commas
