var mapsLonMinus = func {
	var lon = getLon();
	lon = lon - 1;
	if(lon<-180){
		lon = 180;
	}
	setprop("/controls/books/maps/coords/lon",lon);
}

var mapsLonMaxus = func {
	var lon = getLon();
	lon = lon + 1;
	if(lon>180){
		lon = -180;
	}
	setprop("/controls/books/maps/coords/lon",lon);
}

var mapsLatMinus = func {
	var lat = getLat();
	lat = lat - 1;
	if(lat<-180){
		lay = 180;
	}
	setprop("/controls/books/maps/coords/lat",lat);
}

var mapsLatMaxus = func {
	var lat = getLat();
	lat = lat + 1;
	if(lat>180){
		lay = -180;
	}
	setprop("/controls/books/maps/coords/lat",lat);
}

var getLon = func {
	var result = getprop("/controls/books/maps/coords/lon");
	if(result < -180){
		result = getprop("/position/longitude-deg");
		setprop("/controls/books/maps/coords/lon",result);
	}
	return result;
}

var getLat = func {
	var result = getprop("/controls/books/maps/coords/lat");
	if(result < -180){
		result = getprop("/position/latitude-deg");
		setprop("/controls/books/maps/coords/lat",result);
	}
	return result;
}

var update_map = func {
	var lon = getLon();
	var lat = getLat();
	
	##calcul et chargement repris du zkv1000
	
	var map = sprintf("%s%03i%s%02i",
        (lon > 0)? "e" : "w",
        (lon > 0)? lon : (abs(lon) + 1),
        (lat > 0)? "n" : "s",
        (lat > 0)? lat : (abs(lat) + 1)
    );
	
	if (io.stat(mapsAbsolutePath ~ "/terrain/" ~ map ~ ".png") != nil) {
		setprop("/controls/books/maps/terrain-path", mapsRelativePath ~ "/terrain/" ~ map ~ ".png");
	}else{
		setprop("/controls/books/maps/terrain-path","");
	}
	
}

setlistener("/controls/books/maps/coords/lon",update_map);
setlistener("/controls/books/maps/coords/lat",update_map);
setlistener("/controls/books/maps/visible",update_map);

var mapsAbsolutePath = "";
var mapsRelativePath = "";

var init_map = func{
	var maps = "/zkv1000/maps";
    var home = string.normpath(getprop("/sim/fg-home"));
    var root = string.normpath(getprop("/sim/aircraft-dir"));
	
	var first_slash = 0;
	for(var i=0;i<size(home);i=i+1){
		if(substr(home,i,1)=="/"){
			first_slash = i;
			break;
		}
	}
	
	var nb_slash_root = 0;
	for(var i=0;i<size(root);i=i+1){
		if(substr(root,i,1)=="/"){
			nb_slash_root = nb_slash_root + 1;
		}
	}
	
	mapsRelativePath ~= "../../../../";
	for (var i = 0; i < nb_slash_root; i += 1)
        mapsRelativePath ~= "../";
	
	mapsRelativePath ~= substr(home, first_slash+1) ~ maps;
    mapsAbsolutePath = home ~ maps;
}

setlistener("sim/signals/fdm-initialized",init_map);

var init_coords = func {
	setprop("/controls/books/maps/coords/lon",-500);
	setprop("/controls/books/maps/coords/lat",-500);
}