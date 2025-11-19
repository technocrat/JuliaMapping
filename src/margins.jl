# Helper: choose a type-compatible label for a given column eltype
label_for_column(::Type{T}, label::AbstractString) where {T} =
    Base.nonmissingtype(T) <: AbstractString ? label :
    Base.nonmissingtype(T) <: Symbol         ? Symbol(label) :
                                               missing

"""
    add_row_totals(df; total_col_name="Total", cols_to_sum=nothing)
Add a column with per-row totals (skips `missing`). By default sums all numeric columns.
"""
function add_row_totals(df::DataFrame; total_col_name="Total", cols_to_sum=nothing)
    result = copy(df)
    total_sym = Symbol(total_col_name)
    cols = isnothing(cols_to_sum) ? names(result, Number) : Symbol.(cols_to_sum)
    if !isempty(cols)
        result[!, total_sym] = map(r -> sum(skipmissing(r[cols])), eachrow(result))
    end
    return result
end

"""
    add_col_totals(df; total_row_name="Total", cols_to_sum=nothing)
Append a final row with per-column totals. Non-numeric columns get a type-compatible label.
"""
function add_col_totals(df::DataFrame; total_row_name="Total", cols_to_sum=nothing)
    result = copy(df)
    cols = isnothing(cols_to_sum) ? Symbol.(names(result, Number)) : Symbol.(cols_to_sum)
    new_row = NamedTuple{Tuple(Symbol.(names(result)))}(
        Symbol(col) ∈ cols ? sum(skipmissing(result[!, col])) :
                     label_for_column(eltype(result[!, col]), total_row_name)
        for col in names(result)
    )
    push!(result, new_row; promote=true)
    return result
end

"""
    add_totals(df; total_row_name="Total", total_col_name="Total", cols_to_sum=nothing, format_commas=false)
Add both a row totals column and a bottom totals row (which also totals the new column).
Optionally formats all numeric values with comma separators.
"""
function add_totals(df::DataFrame; total_row_name="Total", total_col_name="Total", cols_to_sum=nothing, format_commas=false)
    base_cols = isnothing(cols_to_sum) ? names(df, Number) : Symbol.(cols_to_sum)
    with_row_totals = add_row_totals(df; total_col_name=total_col_name, cols_to_sum=base_cols)
    cols_for_col_totals = union(base_cols, [Symbol(total_col_name)])
    with_both = add_col_totals(with_row_totals; total_row_name=total_row_name, cols_to_sum=cols_for_col_totals)
    
    if format_commas
        # Convert all columns to strings with comma formatting
        result = DataFrame()
        
        for col in names(with_both)
            col_data = with_both[!, col]
            # Format each value individually
            formatted = String[]
            for val in col_data
                if ismissing(val)
                    push!(formatted, "")
                elseif val isa Number
                    push!(formatted, Humanize.digitsep(Int64(val)))
                else
                    push!(formatted, string(val))
                end
            end
            result[!, col] = formatted
        end
        return result
    else
        return with_both
    end
end

export add_row_totals, add_col_totals, add_totals