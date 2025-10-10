using DataFrames
"""
    @ensure_types(df, type_specs...)

Ensure that specified columns in a DataFrame have the correct data types by performing automatic type conversions.

# Arguments
- `df`: The DataFrame to modify
- `type_specs...`: Variable number of type specifications in the format `column::Type`

# Type Specifications
Each type specification should be in the format `column::Type` where:
- `column` is the column name (Symbol or String)
- `Type` is the target Julia type (e.g., `Int`, `Float64`, `String`)

# Supported Conversions
- String to Integer: Uses `parse()` to convert string representations of numbers
- String to Float: Uses `parse()` to convert string representations of floating-point numbers  
- Float to Integer: Uses `round()` to convert floating-point numbers to integers
- Other conversions: Uses `convert()` for general type conversions

# Examples
```julia
# Convert Population to Int and Expend to Float64
@ensure_types df Population::Int Expend::Float64

# Convert multiple columns at once
@ensure_types df Deaths::Int Population::Int Expend::Float64
```

# Notes
- The macro modifies the DataFrame in-place
- Prints progress messages for successful conversions
- Issues warnings for columns that don't exist
- Throws errors for conversion failures
- Returns the modified DataFrame
"""
macro ensure_types(df, type_specs...)
    conversions = []
    
    for spec in type_specs
        if spec isa Expr && spec.head == :(::) && length(spec.args) == 2
            col = spec.args[1]
            typ = spec.args[2]
            
            # Convert column name to Symbol at macro expansion time
            col_sym = col isa QuoteNode ? col.value : col
            col_str = string(col_sym)
            
            push!(conversions, quote
                local target_type = $(esc(typ))
                local col_symbol = $(QuoteNode(col_sym))
                
                if hasproperty($(esc(df)), col_symbol)
                    try
                        println("Converting column '$($col_str)' to ", target_type)
                        
                        local current_col = $(esc(df))[!, col_symbol]
                        local current_type = eltype(current_col)
                        
                        if target_type <: Integer && current_type <: AbstractString
                            # Parse strings to integers (handle decimal strings by parsing as float first)
                            $(esc(df))[!, col_symbol] = round.(target_type, parse.(Float64, current_col))
                        elseif target_type <: AbstractFloat && current_type <: AbstractString
                            # Parse strings to floats
                            $(esc(df))[!, col_symbol] = parse.(target_type, current_col)
                        elseif target_type <: Integer && current_type <: AbstractFloat
                            # Convert floats to integers (with rounding)
                            $(esc(df))[!, col_symbol] = round.(target_type, current_col)
                        else
                            # Use convert for other cases
                            $(esc(df))[!, col_symbol] = convert.(target_type, current_col)
                        end
                        
                        println("✓ Successfully converted column '$($col_str)'")
                    catch e
                        error("Failed to convert column '$($col_str)' to ", target_type, ": ", e)
                    end
                else
                    @warn "Column '$($col_str)' not found in DataFrame"
                end
            end)
        end
    end
    
    return quote
        $(conversions...)
        $(esc(df))
    end
end

export ensure_types
