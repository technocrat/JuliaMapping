"""
    dms_to_decimal(coords::AbstractString) -> String

Convert coordinates from degrees, minutes, seconds (DMS) format to decimal degrees (DD).

# Arguments
- `coords::AbstractString`: Coordinates in DMS format with flexible symbols and direction indicators

# Returns
- `String`: Coordinates in decimal degrees format "±DD.DDDD, ±DD.DDDD"

# Format
Input format is flexible:
- Degrees, minutes, and seconds can use °/′/″ symbols or be plain numbers
- Direction can be N/North/n/north, S/South/s/south, E/East/e/east, W/West/w/west
- Direction can appear before or after the coordinate
- Latitude and longitude separated by comma
- Spaces between components are optional

# Example
```julia
# Various formats work
dms_to_decimal("42° 21′ 37″ N, 71° 03′ 28″ W")
dms_to_decimal("42 21 37 N, 71 03 28 W")
dms_to_decimal("North 42° 21′ 37″, West 71° 03′ 28″")
dms_to_decimal("42° 21′ 37″ north, 71° 03′ 28″ west")
dms_to_decimal("40° 26′ 46.302″ N, 79° 58′ 56.484″ W")
```

# Throws
- `ArgumentError`: If input format is invalid or coordinates are out of range
"""
function dms_to_decimal(coords::AbstractString)
    # Input validation
    if !occursin(",", coords)
        throw(ArgumentError("Invalid format: Latitude and longitude must be separated by comma"))
    end
    
    # Split the input string into latitude and longitude parts
    lat_dms, lon_dms = split(coords, ",")
    
    function to_decimal(dms::AbstractString)
        # Remove extra whitespace
        dms = strip(dms)
        
        # Normalize unicode characters and remove symbols
        dms = replace(dms, '′' => " ", '″' => " ", '°' => " ")
        dms = replace(dms, ''' => " ")  # Handle alternative apostrophe
        
        # Create case-insensitive pattern for directions
        # Match direction at beginning or end, with full names or abbreviations
        dir_pattern = r"(?i)(north|south|east|west|n|s|e|w)"
        
        # Extract direction
        dir_match = match(dir_pattern, dms)
        if isnothing(dir_match)
            throw(ArgumentError("Invalid format: Missing direction (N/S/E/W or North/South/East/West)"))
        end
        
        dir = uppercase(first(dir_match.captures[1]))  # Get first letter, uppercase
        
        # Remove direction from string
        dms = replace(dms, dir_pattern => "")
        
        # Extract numbers (degrees, minutes, seconds)
        # Handle optional decimal points for seconds
        numbers = Float64[]
        for m in eachmatch(r"\d+(?:\.\d+)?", dms)
            push!(numbers, parse(Float64, m.match))
        end
        
        # Validate we have 1-3 numbers (degrees, or degrees+minutes, or degrees+minutes+seconds)
        if length(numbers) < 1 || length(numbers) > 3
            throw(ArgumentError("Invalid format: Expected 1-3 numeric values (degrees, minutes, seconds)"))
        end
        
        # Extract components with defaults
        deg = numbers[1]
        min = length(numbers) >= 2 ? numbers[2] : 0.0
        sec = length(numbers) >= 3 ? numbers[3] : 0.0
        
        # Validate ranges
        if deg < 0 || deg > 180
            throw(ArgumentError("Degrees must be between 0 and 180"))
        end
        if min < 0 || min >= 60
            throw(ArgumentError("Minutes must be between 0 and 59"))
        end
        if sec < 0 || sec >= 60
            throw(ArgumentError("Seconds must be between 0 and 59"))
        end
        
        # Calculate decimal degrees
        decimal = deg + (min / 60) + (sec / 3600)
        
        # Validate based on direction
        if (dir in ['N', 'S'] && decimal > 90) || (dir in ['E', 'W'] && decimal > 180)
            throw(ArgumentError("Invalid coordinate value for direction $dir"))
        end
        
        # Apply direction
        decimal *= (dir in ['S', 'W']) ? -1 : 1
        
        return decimal
    end
    
    try
        # Convert latitude and longitude to decimal degrees
        lat_decimal = to_decimal(lat_dms)
        lon_decimal = to_decimal(lon_dms)
        
        # Format with consistent precision
        return @sprintf("%.14f, %.14f", lat_decimal, lon_decimal)
    catch e
        if e isa ArgumentError
            rethrow(e)
        else
            throw(ArgumentError("Failed to parse coordinates: $(e.msg)"))
        end
    end
end
export dms_to_decimal