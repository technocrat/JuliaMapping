const VALID_STATE_CODES = Dict(
    "Alabama" => "AL", "Alaska" => "AK", "Arizona" => "AZ", "Arkansas" => "AR",
    "California" => "CA", "Colorado" => "CO", "Connecticut" => "CT", "Delaware" => "DE",
    "Florida" => "FL", "Georgia" => "GA", "Hawaii" => "HI", "Idaho" => "ID",
    "Illinois" => "IL", "Indiana" => "IN", "Iowa" => "IA", "Kansas" => "KS",
    "Kentucky" => "KY", "Louisiana" => "LA", "Maine" => "ME", "Maryland" => "MD",
    "Massachusetts" => "MA", "Michigan" => "MI", "Minnesota" => "MN", "Mississippi" => "MS",
    "Missouri" => "MO", "Montana" => "MT", "Nebraska" => "NE", "Nevada" => "NV",
    "New Hampshire" => "NH", "New Jersey" => "NJ", "New Mexico" => "NM", "New York" => "NY",
    "North Carolina" => "NC", "North Dakota" => "ND", "Ohio" => "OH", "Oklahoma" => "OK",
    "Oregon" => "OR", "Pennsylvania" => "PA", "Rhode Island" => "RI", "South Carolina" => "SC",
    "South Dakota" => "SD", "Tennessee" => "TN", "Texas" => "TX", "Utah" => "UT",
    "Vermont" => "VT", "Virginia" => "VA", "Washington" => "WA", "West Virginia" => "WV",
    "Wisconsin" => "WI", "Wyoming" => "WY", "District of Columbia" => "DC"
)

const VALID_STATEFPS = ["01", "02", "04", "05", "06", "08", "09", "10", "11", "12", "13", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "44", "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56"]


std_crs     = "+proj=longlat +datum=WGS84"
conus_crs   = "+proj=aea +lat_0=37.5 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
conus_epsg  = "EPSG:5070"
alaska_epsg = "EPSG:3338"
hawaii_epsg = "EPSG:26904"

const KM_PER_MILE     = 1.609344
const EARTH_RADIUS_KM = 6371.0

const whites = ["white", "ivory", "ivory1", "mintcream", "snow", "snow1", "honeydew", "honeydew1", 
"floralwhite", "ghostwhite", "cornsilk", "cornsilk1", "seashell", "seashell1", "oldlace", 
"whitesmoke", "beige", "linen", "antiquewhite1", "ivory2", "antiquewhite", "honeydew2", 
"snow2", "cornsilk2", "seashell2", "navajowhite", "navajowhite1", "antiquewhite2",
"navajowhite2", "ivory3", "snow3", "honeydew3", "cornsilk3", "seashell3", "antiquewhite3"] 

const reds = ["lightsalmon",  "lightsalmon1",  "salmon1",  "lightsalmon2",  "darksalmon",  
"coral",  "salmon",  "lightcoral",  "salmon2",  "coral1",  "indianred1",  "tomato", 
"tomato1",  "lightsalmon3",  "coral2",  "indianred2",  "tomato2",  "salmon3", 
"firebrick1",  "indianred",  "red",  "red1",  "coral3",  "firebrick2",  "indianred3", 
"tomato3",  "red2",  "crimson",  "firebrick3",  "red3",  "lightsalmon4",  "salmon4", 
"firebrick",  "coral4",  "indianred4",  "tomato4",  "firebrick4",  "darkred",  "red4"]

const oranges = ["orange", "orange1", "orange2", "darkorange", "darkorange1", "darkorange2", 
"orange3", "orangered", "orangered1", "darkorange3", "orangered2", "orangered3", 
"orange4", "darkorange4", "orangered4"]

const yellows = ["lightyellow", "lightyellow1", "lemonchiffon", "lemonchiffon1", 
"lightgoldenrodyellow", "yellow", "yellow1", "khaki1", "lightyellow2", "lightgoldenrod1", 
"wheat1", "lemonchiffon2", "yellow2", "palegoldenrod", "khaki", "khaki2", "wheat", 
"lightgoldenrod", "lightgoldenrod2", "wheat2", "gold", "gold1", "gold2", "lightyellow3", 
"goldenrod1", "lemonchiffon3", "yellow3", "darkgoldenrod1", "khaki3", "lightgoldenrod3", 
"goldenrod2", "wheat3", "darkgoldenrod2", "darkkhaki", "gold3", "goldenrod", "goldenrod3", 
"darkgoldenrod3", "darkgoldenrod", "lightyellow4", "lemonchiffon4", "yellow4", "khaki4", 
"lightgoldenrod4", "wheat4", "gold4", "goldenrod4", "darkgoldenrod4"]

const greens = ["darkseagreen1", "darkolivegreen1", "olivedrab1", "aquamarine", "aquamarine1", 
"palegreen1", "greenyellow", "palegreen", "chartreuse", "chartreuse1", "seagreen1", 
"darkseagreen2", "lawngreen", "springgreen", "springgreen1", "darkolivegreen2", "green1", 
"lime", "olivedrab2", "mediumspringgreen", "lightgreen", "palegreen2", "aquamarine2", 
"chartreuse2", "seagreen2", "springgreen2", "green2", "darkseagreen3", "darkolivegreen3", 
"olivedrab3", "yellowgreen", "palegreen3", "aquamarine3", "mediumaquamarine", 
"chartreuse3", "seagreen3", "springgreen3", "limegreen", "darkseagreen", "green3", 
"lightseagreen", "mediumseagreen", "olivedrab", "darkseagreen4", "darkolivegreen4", 
"olivedrab4", "aquamarine4", "palegreen4", "olive", "seagreen", "seagreen4", 
"chartreuse4", "forestgreen", "springgreen4", "green4", "green", "darkolivegreen", 
"darkgreen"]

const cyans = ["lightcyan", "lightcyan1", "paleturquoise1", "lightcyan2", "aqua", "cyan", 
"cyan1", "paleturquoise", "paleturquoise2", "turquoise1", "cyan2", "turquoise2", 
"turquoise", "lightcyan3", "paleturquoise3", "mediumturquoise", "darkturquoise", "cyan3", 
"turquoise3", "lightcyan4", "paleturquoise4", "cyan4", "darkcyan", "turquoise4", "teal"]

const blues = ["azure", "azure1", "aliceblue", "darkslategray1", "azure2", "lightblue1", 
"cadetblue1", "lightsteelblue1", "slategray1", "darkslategray2", "gainsboro", 
"lightskyblue1", "lightblue2", "powderblue", "cadetblue2", "lightblue", "slategray2", 
"lightsteelblue2", "lightskyblue2", "azure3", "skyblue1", "lightskyblue", "skyblue", 
"lightsteelblue", "darkslategray3", "lightblue3", "cadetblue3", "skyblue2", "slategray3", 
"lightsteelblue3", "deepskyblue", "deepskyblue1", "steelblue1", "lightskyblue3", 
"deepskyblue2", "steelblue2", "skyblue3", "cornflowerblue", "cadetblue", "deepskyblue3", 
"dodgerblue", "dodgerblue1", "steelblue3", "azure4", "lightslategray", "lightslategrey", 
"lightslateblue", "dodgerblue2", "slateblue1", "darkslategray4", "royalblue1", 
"lightblue4", "slategray", "slategrey", "cadetblue4", "steelblue", "mediumslateblue", 
"slateblue2", "lightsteelblue4", "slategray4", "lightskyblue4", "royalblue2", 
"dodgerblue3", "royalblue", "skyblue4", "slateblue", "slateblue3", "royalblue3", 
"deepskyblue4", "steelblue4", "dodgerblue4", "blue", "blue1", "darkslategray", 
"darkslategrey", "darkslateblue", "slateblue4", "blue2", "royalblue4", "blue3", 
"mediumblue", "indigo", "midnightblue", "blue4", "darkblue", "navy", "navyblue"]

const purples = ["lavenderblush", "lavenderblush1", "thistle1", "mistyrose", "mistyrose1", 
"lavender", "lavenderblush2", "thistle2", "mistyrose2", "plum1", "thistle", 
"lavenderblush3", "plum2", "thistle3", "mistyrose3", "plum", "orchid1", "violet", "plum3", 
"orchid2", "mediumorchid1", "mediumpurple1", "orchid", "fuchsia", "magenta", "magenta1", 
"mediumorchid2", "orchid3", "mediumpurple2", "magenta2", "lavenderblush4", "mediumpurple", 
"darkorchid1", "mediumorchid", "mistyrose4", "thistle4", "mediumorchid3", "mediumpurple3", 
"darkorchid2", "magenta3", "plum4", "purple1", "purple2", "darkorchid3", "darkorchid", 
"blueviolet", "orchid4", "darkviolet", "purple3", "mediumorchid4", "mediumpurple4", 
"rebeccapurple", "darkmagenta", "magenta4", "purple", "darkorchid4", "purple4"]

const pinks = ["pink", "lightpink", "pink1", "lightpink1", "pink2", "lightpink2", 
"palevioletred1", "hotpink1", "pink3", "hotpink", "palevioletred2", "lightpink3", 
"hotpink2", "palevioletred", "maroon1", "violetred1", "palevioletred3", "deeppink", 
"deeppink1", "hotpink3", "violetred2", "maroon2", "deeppink2", "violetred3", "maroon3", 
"violetred", "pink4", "deeppink3", "lightpink4", "mediumvioletred", "palevioletred4", 
"hotpink4", "violetred4", "maroon4", "deeppink4", "maroon"]
 
const browns = ["papayawhip", "blanchedalmond", "bisque", "bisque1", "moccasin", "peachpuff", 
"peachpuff1", "burlywood1", "bisque2", "peachpuff2", "rosybrown1", "burlywood2", 
"rosybrown2", "burlywood", "bisque3", "tan1", "tan", "sandybrown", "peachpuff3", 
"burlywood3", "tan2", "rosybrown3", "sienna1", "chocolate1", "rosybrown", "sienna2", 
"chocolate2", "peru", "tan3", "brown1", "chocolate", "sienna3", "chocolate3", "brown2", 
"bisque4", "peachpuff4", "burlywood4", "rosybrown4", "brown3", "sienna", "tan4", 
"sienna4", "brown", "chocolate4", "saddlebrown", "brown4"]

const grays = ["gray100", "grey100", "gray99", "grey99", "gray98", "grey98", "gray97", "grey97", 
"gray96", "grey96", "gray95", "grey95", "gray94", "grey94", "gray93", "grey93", "gray92", 
"grey92", "gray91", "grey91", "gray90", "grey90", "gray89", "grey89", "gray88", "grey88", 
"gray87", "grey87", "gray86", "grey86", "gray85", "grey85", "gray84", "grey84", "gray83", 
"grey83", "lightgray", "lightgrey", "gray82", "grey82", "gray81", "grey81", "gray80", 
"grey80", "gray79", "grey79", "gray78", "grey78", "gray77", "grey77", "gray76", "grey76", 
"gray75", "grey75", "gray74", "grey74", "gray73", "grey73", "gray72", "grey72", "gray71", 
"grey71", "gray70", "grey70", "gray69", "grey69", "gray68", "grey68", "gray67", "grey67", 
"darkgray", "darkgrey", "gray66", "grey66", "gray65", "grey65", "gray64", "grey64", 
"gray63", "grey63", "gray62", "grey62", "gray61", "grey61", "gray60", "grey60", "gray59", 
"grey59", "gray58", "grey58", "gray57", "grey57", "gray56", "grey56", "gray55", "grey55", 
"gray54", "grey54", "gray53", "grey53", "gray52", "grey52", "gray51", "grey51", "gray", 
"grey", "gray50", "grey50", "gray49", "grey49", "gray48", "grey48", "gray47", "grey47", 
"gray46", "grey46", "gray45", "grey45", "gray44", "grey44", "gray43", "grey43", "gray42", 
"grey42", "dimgray", "dimgrey", "gray41", "grey41", "gray40", "grey40", "gray39", 
"grey39", "gray38", "grey38", "gray37", "grey37", "gray36", "grey36", "gray35", "grey35", 
"gray34", "grey34", "gray33", "grey33", "gray32", "grey32", "gray31", "grey31", "gray30", 
"grey30", "gray29", "grey29", "gray28", "grey28", "gray27", "grey27", "gray26", "grey26", 
"gray25", "grey25", "gray24", "grey24", "gray23", "grey23", "gray22", "grey22", "gray21", 
"grey21", "gray20", "grey20", "gray19", "grey19", "gray18", "grey18", "gray17", "grey17", 
"gray16", "grey16", "gray15", "grey15", "gray14", "grey14", "gray13", "grey13", "gray12", 
"grey12", "gray11", "grey11", "gray10", "grey10", "gray9", "grey9", "gray8", "grey8", 
"gray7", "grey7", "gray6", "grey6", "gray5", "grey5", "gray4", "grey4", "gray3", "grey3", 
"gray2", "grey2", "gray1", "grey1", "black", "gray0", "grey0"]

export whites, reds, oranges, yellows, greens, cyans, blues, purples, pinks, browns, grays, VALID_STATE_CODES, VALID_STATEFPS, std_crs, conus_crs, conus_epsg, alaska_epsg, hawaii_epsg, KM_PER_MILE, EARTH_RADIUS_KM
