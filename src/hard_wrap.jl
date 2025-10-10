
"""
    hard_wrap(text::String, width::Int)

Hard-wrap text at the specified width, breaking at word boundaries when possible.
Each line is right-padded to the specified width.

# Arguments
- `text::String`: The text to wrap
- `width::Int`: Maximum line width in characters

# Returns
- `String`: Text with line breaks inserted and each line padded to width

# Examples
```julia
text = "This is a long sentence that will be wrapped at word boundaries."
wrapped = hard_wrap(text, 20)
# Returns text wrapped to 20 characters per line with padding
```

# Notes
- Right-pads each line to exactly the specified width
- Attempts to break at word boundaries when possible
- If a word is longer than the width, it will be broken mid-word
- Useful for creating fixed-width text layouts
"""
function hard_wrap(text::String, width::Int)
    if width <= 0
        return text
    end
    
    words = split(text, " ")
    lines = String[]
    current_line = ""
    
    for word in words
        # If adding this word would exceed the width
        if length(current_line) + length(word) + 1 > width
            # If current line is not empty, start a new line
            if !isempty(current_line)
                push!(lines, rpad(current_line, width))
                current_line = word
            else
                # Current line is empty, so the word itself is too long
                # Break the word if it exceeds width
                if length(word) > width
                    # Break the word at the width limit
                    push!(lines, rpad(word[1:width], width))
                    current_line = word[width+1:end]
                else
                    current_line = word
                end
            end
        else
            # Add word to current line
            if isempty(current_line)
                current_line = word
            else
                current_line *= " " * word
            end
        end
    end
    
    # Add the last line if it's not empty
    if !isempty(current_line)
        push!(lines, rpad(current_line, width))
    end
    
    return join(lines, "\n")
end

export hard_wrap