
"""
    get_nth_table(url::String, n::Int=1) -> DataFrame

Get the nth HTML table from a webpage and return as a DataFrame.

# Arguments
- `url::String`: The URL of the webpage to scrape
- `n::Int=1`: The table index to get (1-based indexing). Defaults to 1 for the first table.

# Returns
- `DataFrame`: The fetched table with cleaned text content

# Throws
- `HTTP.ExceptionRequest.StatusError`: If the webpage cannot be accessed
- `ArgumentError`: If no tables are found on the page
- `BoundsError`: If the requested table index `n` exceeds the number of tables found

# Examples
```julia
# Get first table from Wikipedia or other web page
url = "https://en.wikipedia.org/wiki/List_of_European_countries_by_area"
df = get_nth_table(url)

# Get second table
df2 = get_nth_table(url, 2)

# Save to CSV
using CSV
CSV.write("table_data.csv", df)
```

# Notes
- Headers are automatically detected from `<th>` elements
- Cell text is cleaned by removing extra whitespace and newlines
- If rows have different numbers of columns, they are padded or truncated to match headers
- Generic column names are created if no headers are found
"""
function get_nth_table(url::String, n::Int=1)
    # Fetch the webpage
    response = HTTP.get(url)
    html_content = String(response.body)
    
    # Parse HTML
    doc = parsehtml(html_content)
    
    # Find all tables and select the nth one
    tables = []
    for elem in PreOrderDFS(doc.root)
        if typeof(elem) == HTMLElement{:table}
            push!(tables, elem)
        end
    end
    
    if isempty(tables)
        error("No tables found on the page")
    end
    
    if n < 1 || n > length(tables)
        error("Table index $n out of range. Found $(length(tables)) tables on the page.")
    end
    
    table = tables[n]
    
    # get table data
    rows = []
    headers = String[]
    
    # Process table rows
    for elem in PreOrderDFS(table)
        if typeof(elem) == HTMLElement{:tr}
            row_data = String[]
            
            # Check if this is a header row
            is_header_row = false
            for cell_elem in PreOrderDFS(elem)
                if typeof(cell_elem) == HTMLElement{:th}
                    is_header_row = true
                    break
                end
            end
            
            # get cell data
            for cell_elem in PreOrderDFS(elem)
                if typeof(cell_elem) == HTMLElement{:td} || typeof(cell_elem) == HTMLElement{:th}
                    cell_text = ""
                    for text_elem in PreOrderDFS(cell_elem)
                        if typeof(text_elem) == HTMLText
                            cell_text *= text_elem.text
                        end
                    end
                    # Clean up text (remove extra whitespace, newlines)
                    cell_text = strip(replace(cell_text, r"\s+" => " "))
                    push!(row_data, cell_text)
                end
            end
            
            if !isempty(row_data)
                if is_header_row && isempty(headers)
                    headers = row_data
                else
                    push!(rows, row_data)
                end
            end
        end
    end
    
    # Create DataFrame
    if isempty(headers)
        # If no headers found, create generic ones
        max_cols = maximum(length.(rows))
        headers = ["Column_$i" for i in 1:max_cols]
    end
    
    # Ensure all rows have the same number of columns
    max_cols = length(headers)
    for i in eachindex(rows)
        # pad with empty strings until we reach max_cols
        while length(rows[i]) < max_cols
            push!(rows[i], "")
        end
    
        # truncate any extra columns beyond max_cols
        if length(rows[i]) > max_cols
            rows[i] = rows[i][1:max_cols]
        end
    end
    
    
    # Convert to DataFrame
    df = DataFrame()
    for (i, header) in enumerate(headers)
        df[!, Symbol(header)] = [row[i] for row in rows]
    end
    
    return df
end

export get_nth_table
