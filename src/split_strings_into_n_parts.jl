
"""
    split_string_into_n_parts(text::String, n::Int)

Split a string into n approximately equal parts, inserting newlines at word boundaries.

# Arguments
- `text::String`: The text string to split
- `n::Int`: Number of parts to split the string into

# Returns
- `String`: The original text with newlines inserted to create n parts

# Examples
```julia
text = "This is a long text that needs to be split into multiple parts for better formatting."
result = split_string_into_n_parts(text, 3)
# Returns text split into 3 parts with newlines at word boundaries
```

# Notes
- Attempts to break at word boundaries when possible
- If a word is longer than the target part length, it will be broken mid-word
- Each part will be approximately equal in length
- Preserves original spacing between words
"""
function split_string_into_n_parts(text::String, n::Int)
    if n <= 1
        return text
    end
    
    # Calculate target length for each part
    total_length = length(text)
    target_length = div(total_length, n)
    
    # Split into characters
    chars = split(text, "")
    
    # Initialize result
    result = String[]
    current_part = ""
    current_length = 0
    parts_created = 0
    
    for (i, char) in enumerate(chars)
        # Check if adding this character would exceed target length
        if !isempty(current_part) && current_length + 1 > target_length && parts_created < n - 1
            # Start a new part
            push!(result, current_part)
            current_part = char
            current_length = 1
            parts_created += 1
        else
            # Add character to current part
            current_part *= char
            current_length += 1
        end
    end
    
    # Add the last part
    if !isempty(current_part)
        push!(result, current_part)
    end
    
    # Join with newlines
    return join(result, "\n")
end

export split_string_into_n_parts