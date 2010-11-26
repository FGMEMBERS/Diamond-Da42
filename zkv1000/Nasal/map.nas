var mapsRelativePath = "";
var mapsAbsolutePath = "";
var textureExtension = ".png";
var actual_map = "";
var panningMap = 0;

var mapRanges = [0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.0];
var mapRange = 0;

var init_map = func {
    var maps = "/zkv1000/maps";
    var root_l = common_l = common_c = 0;

    var home = string.normpath(getprop("/sim/fg-home"));
    var home_s = size(home);
    
    var root = string.normpath(getprop("/sim/fg-root"));
    var root_s = size(root);
    
    for (var i = 0; i < root_s; i += 1) 
        if (root[i] == `/`)
            root_l += 1;
    
    for (var i = 0; i < root_s and i < home_s; i += 1) {
        (home[i] == root[i]) or break;
        common_c += 1;
        if (home[i] == `/`) common_l += 1;
    }
    
    mapsRelativePath = "../../../../";
    for (var i = 0; i < root_l - common_l; i += 1)
        mapsRelativePath ~= "../";
    
    mapsRelativePath ~= substr(home, common_c, home_s) ~ maps;
    mapsAbsolutePath = home ~ maps;
    mapRange = mapRanges[getprop("/instrumentation/zkv1000/map/range-index")];
}

var moveMap = func {
    var lat = getprop("/instrumentation/zkv1000/map/latitude-deg");
    var lon = getprop("/instrumentation/zkv1000/map/longitude-deg");
    var map = sprintf("%s%03i%s%02i",
        (lon > 0)? "e" : "w",
        (lon > 0)? lon : (abs(lon) + 1),
        (lat > 0)? "n" : "s",
        (lat > 0)? lat : (abs(lat) + 1)
    );
    if (actual_map == map) {
        setprop("/instrumentation/zkv1000/map/moving-x", (lon > 0)? frac(lon) : 1 - abs(frac(lon)));
        setprop("/instrumentation/zkv1000/map/moving-y", (lat > 0)? frac(lat) : 1 - abs(frac(lat)));
    }
    elsif (io.stat(mapsAbsolutePath ~ "/terrain/" ~ map ~ textureExtension) != nil) {
        actual_map = map;
        setprop("/instrumentation/zkv1000/map/terrain-path", mapsRelativePath ~ "/terrain/" ~ map ~ textureExtension);

#        setprop("/instrumentation/zkv1000/map/objects-path", mapsRelativePath ~ "/objects/" ~ map ~ textureExtension);
#        setprop("/instrumentation/zkv1000/map/navaids-path", mapsRelativePath ~ "/navaids/" ~ map ~ textureExtension);

        setprop("/instrumentation/zkv1000/map/moving-x", (lon > 0)? frac(lon) : 1 - abs(frac(lon)));
        setprop("/instrumentation/zkv1000/map/moving-y", (lat > 0)? frac(lat) : 1 - abs(frac(lat)));
    }
    else {
        actual_map = "";
        setprop("/instrumentation/zkv1000/map/terrain-path", "");
#        setprop("/instrumentation/zkv1000/map/objects-path", "");
#        setprop("/instrumentation/zkv1000/map/navaids-path", "");
        setprop("/instrumentation/zkv1000/map/moving-x", 0);
        setprop("/instrumentation/zkv1000/map/moving-y", 0);
    }
    setprop("/instrumentation/zkv1000/map/alt", computeCursorPosition(alt));
    setprop("/instrumentation/zkv1000/map/alt-selected", computeCursorPosition(getprop("/instrumentation/zkv1000/afcs/selected-alt-ft")));
    setprop("/instrumentation/zkv1000/map/alt-1-min", computeCursorPosition(alt + vs));
}

var computeCursorPosition = func (v) {
    var ref = round_bis(v, (v < 1000)? 250 : 500);
    if (ref < 1500) ref /= 250;
    elsif (ref > 6500) ref = 15;
    else {
        ref /= 500;
        ref += 2;
    }
    return ref;
}

var _applyFilter = func {
}

var validFromMapDirectTo = func {
    ENTsoftkey = void;
}

var fromMapDirectTo = func {
    ENTsoftkey = validFromMapDirectTo;
}

#for use with topo filters
#var __applyFilter = func {
    #var ref = round_bis(alt, (alt < 1000)? 250 : 500);
    #var E_ref = "E_" ~ ((ref > 6000)? 6000 : ref);
    #setprop("/instrumentation/zkv1000/map/diffuse/elev_ref", E_ref);
    #setprop("/instrumentation/zkv1000/map/diffuse/red",   topo_filters[E_ref][0]);
    #setprop("/instrumentation/zkv1000/map/diffuse/green", topo_filters[E_ref][1]);
    #setprop("/instrumentation/zkv1000/map/diffuse/blue",  topo_filters[E_ref][2]);
#}

# TOPO filters from Atlas palette (NCGD.ap):
# Contour colours based on National Geophysical Data Center's DEM,
# appearing in Wikipedia:
#
# http://en.wikipedia.org/wiki/File:AYool_topography_15min.png
# no need them anyway as <ambient>, <diffuse> and <emission> material
# animations don't seem to have the expected effect (filter interesting
# altitudes on the displayed map), or I don't know how to use them 
# correctly ;)
#var topo_filters = {
#    E_0        :   [0.000, 0.627, 0.000],
#    E_250:  [0.000, 0.682, 0.000],
#    E_500:  [0.388, 0.722, 0.063],
#    E_750:  [0.757, 0.773, 0.169],
#    E_1000: [0.992, 1.000, 0.380],
#    E_1500: [0.890, 0.859, 0.333],
#    E_2000: [0.784, 0.714, 0.294],
#    E_2500: [0.682, 0.573, 0.247],
#    E_3000: [0.580, 0.439, 0.204],
#    E_3500: [0.482, 0.310, 0.169],
#    E_4000: [0.388, 0.192, 0.129],
#    E_4500: [0.298, 0.082, 0.090],
#    E_5000: [0.831, 0.278, 0.773],
#    E_5500: [0.867, 0.475, 0.820],
#    E_6000: [0.910, 0.690, 0.882]
#};


