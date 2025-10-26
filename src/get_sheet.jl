
"""
    get_sheet(file_name::String, sheet::Int) -> DataFrame

Read a specific sheet from an Excel file and return it as a DataFrame.

# Arguments
- `file_name::String`: Path to the Excel file (.xlsx format)
- `sheet::Int`: Sheet number to read (1-indexed)

# Returns
- `DataFrame`: The Excel sheet data converted to a DataFrame

# Examples
```julia
# Read the first sheet from an Excel file
df = get_sheet("data.xlsx", 1)

# Read the third sheet
df = get_sheet("sales_report.xlsx", 3)
```
"""
function get_sheet(file_name::String,sheet::Int)
  spreadsheet = XLSX.readxlsx(file_name)
  table = XLSX.gettable(spreadsheet[sheet])
  return DataFrame(table)
end

export get_sheet
