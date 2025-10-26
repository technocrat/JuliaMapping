# using statements moved to JuliaMapping.jl
"""
    bullseye(capital::String, capital_coords::String)

Create an interactive HTML map with concentric circles (bullseye) centered on the specified capital city.

This function generates a Leaflet-based interactive map displaying concentric circles at 
fixed radii of 50, 100, 200, and 400 miles from the specified capital. The map includes 
a marker at the center point and a legend showing the distance bands with their corresponding colors.

# Arguments
- `capital::String`: The name of the capital city (used for the marker popup and output filename)
- `capital_coords::String`: Coordinates in DMS (Degrees, Minutes, Seconds) format "DD° MM′ SS″ N/S, DD° MM′ SS″ E/W"

# Details
- Uses OpenStreetMap tiles for the base map
- Concentric circles are drawn at 50, 100, 200, and 400 miles from center
- Default color scheme: `#D32F2F`, `#388E3C`, `#1976D2`, `#FBC02D`, `#7B1FA2`
- Requires the `dms_to_decimal` function to convert coordinates

# Returns
Nothing. Creates an HTML file and opens it in the default web browser.

# Output Files
Creates an HTML file named "`{capital}.html`" in the current working directory.

# Example
```julia
bullseye("Nashville", "36° 09′ 44″ N, 86° 46′ 28″ W")
# Creates "Nashville.html" and opens it in the browser
```

# Notes
The generated HTML file is self-contained and can be shared or hosted independently.
"""
function bullseye(capital::String, capital_coords::String)
    pal = ("'Red', 'Green', 'Yellow', 'Blue', 'Purple'",
        "'#E74C3C', '#2ECC71', '#3498DB', '#F1C40F', '#9B59B6'",
        "'#FF4136', '#2ECC40', '#0074D9', '#FFDC00', '#B10DC9'",
        "'#D32F2F', '#388E3C', '#1976D2', '#FBC02D', '#7B1FA2'",
        "'#FF5733', '#C70039', '#900C3F', '#581845', '#FFC300'")
    centerpoint = dms_to_decimal(capital_coords)
    from = capital
    file_path = "$(capital).html"
    bands = "50, 100, 200, 400"
    band_colors = pal[4]
    bullseye_html = """
<!DOCTYPE html>
<html>
<head>
  <title>Leaflet Template</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    body, html {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
    }
    .flex-container {
        display: flex;
        align-items: flex-start;
        width: 100%;
        height: 100%;
    }
    #map {
        flex: 1;
        height: 100vh;
        margin: 0;
    }
    .tables-container {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        padding: 20px;
    }
    table {
        border-collapse: collapse;
        width: 200px;
    }
    th, td {
        border: 1px solid black;
        padding: 8px;
        text-align: right;
    }
    .legend {
        padding: 6px 8px;
        background: white;
        background: rgba(255,255,255,0.9);
        box-shadow: 0 0 15px rgba(0,0,0,0.2);
        border-radius: 5px;
        line-height: 24px;
    }
</style>
</head>
<body>
<div class="flex-container">
  <div id="map">
  </div>
  <div class="tables-container">
  </div>
</div>
<script>
var mapOptions = {
   center: [$centerpoint],
   zoom: 7
};
var map = new L.map('map', mapOptions);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors',
    maxZoom: 19
}).addTo(map);

var marker = L.marker([$centerpoint]);
marker.addTo(map);
marker.bindPopup('$from').openPopup();

function milesToMeters(miles) {
   return miles * 1609.34;
}

var colors = [$band_colors];
var radii = [$bands].map(Number);

radii.forEach(function(radius, index) {
    var circle = L.circle([$centerpoint], {
        radius: milesToMeters(radius),
        color: colors[index],
        weight: 2,
        fill: true,
        fillColor: colors[index],
        fillOpacity: 0.05,
        interactive: false
    }).addTo(map);
    console.log('Added circle:', radius, 'miles');
});

var legend = L.control({position: 'bottomleft'});
legend.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'legend');
    div.innerHTML = '<strong>Miles from center</strong><br>';
    radii.forEach(function(radius, i) {
        div.innerHTML +=
            '<i style="background:' + colors[i] + '; width: 18px; height: 18px; float: left; margin-right: 8px; opacity: 0.7;"></i> ' +
            radius + '<br>';
    });
    return div;
};
legend.addTo(map);

// Add resize handler to ensure map fills container after window resize
window.addEventListener('resize', function() {
    map.invalidateSize();
});
</script>
</body>
</html>
"""

    open(file_path, "w") do file
        write(file, bullseye_html)
    end
    run(`open $file_path`)
end



export bullseye