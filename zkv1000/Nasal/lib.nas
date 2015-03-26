var nyi = func (x) { gui.popupTip(x ~ ": not yet implemented", 3); }

var void = func { }

var frac = func (x) { return (x - int(x)) };

var round = func (x, m = 1) {
    var v = x / m;
    if (frac(v) >= 0.5) v += 1;
    return (int(v) * m);
}

var round_bis = func (x, m) {
    var r = round(x, m);
    if (r > x) r -= m;
    return r;
}

var alt = vs = vs_abs = ias = tas = pitch = roll = agl = stall = rpm = 0;
var getData = func {
    alt = math.abs(getprop("/instrumentation/altimeter/indicated-altitude-ft"));
    vs = getprop("/velocities/vertical-speed-fps") * 60; 
    ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
    pitch = getprop("/orientation/pitch-deg");
    roll = getprop("/orientation/pitch-deg");
    agl = getprop("/position/altitude-agl-ft");
    stall = getprop("/sim/alarms/stall-warning");
}

####
# Search nav facilities
var searchNearestNavaid = func (type, number) {
    #getprop("/instrumentation/zkv1000/searches-locked") or return;
    props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(number + 1);
    props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
    props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
    setprop("/instrumentation/gps/scratch/type", type);
    setprop("/instrumentation/gps/command", "nearest");
}

var lockSearches = func (v = 1) {
    props.globals.getNode("/instrumentation/zkv1000/searches-locked", 1).setBoolValue(v);
}

var unlockSearches = func {
    lockSearches(0);
}

var searchGPSpoint = func (id,type){
	#getprop("/instrumentation/zkv1000/searches-locked") or return;
    props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(1);
    props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
    props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
    setprop("/instrumentation/gps/scratch/query", id);
	setprop("/instrumentation/gps/scratch/type", type);
    setprop("/instrumentation/gps/command", "search");
}

var animeCursors = void;
var computeAltitudeDiff = void;
var computeAirspeedDiff = void;
var FLCcomputation = void;
var checkRollAquisition = void;
var checkPitchAquisition = void;
var checkTrafficProximity = void;
var manageLandingGears = void;
var checkAbnormalAttitude = void;
var applyFilter = void;
var largeFMSknob = void;
var smallFMSknob = void;
var ENTsoftkey = void;
var Dsoftkey = void;
var ALTknob = void;
var HDGknob = void;
var CRSknob = void;
var BAROknob = void;
var NAVknob = void;
var NAVvolume = void;
var COMMknob = void;
var COMMvolume = void;
var swapCOMM = void;
var swapNAV = void;
var joystick = void;
var RANGEknob = void;

##calcul des positions pour le TIS , Traffic Information Service
var traffic_update = func {
	##annulation des anciens plot radar
	for(var i=0;i<8;i=i+1){
		setprop("instrumentation/zkv1000/radar/ai["~i~"]/valid",0);
	}
	var plots = [];
	var true_heading = getprop("/orientation/heading-deg");
	var myAlt = getprop("/position/altitude-ft");
	var test_dist=getprop("/instrumentation/radar/range");
	var ai_craft = props.globals.getNode("/ai/models").getChildren("aircraft");
	for(i=0; i<size(ai_craft);i=i+1) {
		var inRange = getprop("/ai/models/aircraft["~i~"]/radar/in-range");
		var true_airspeed_kt = getprop("ai/models/aircraft["~i~"]/velocities/true-airspeed-kt");
		if (inRange == 1 and true_airspeed_kt>0) {
			var tgt_offset = getprop("/ai/models/aircraft[" ~ i ~ "]/radar/h-offset");
			if(tgt_offset == nil) {
				tgt_offset = 0.0;
			}
			if (tgt_offset < 0){
				tgt_offset = 360 + tgt_offset;
			}
			if (tgt_offset > 360){
				tgt_offset = tgt_offset - 360;
			}
			
			var test1_dist = getprop("/ai/models/aircraft[" ~ i ~ "]/radar/range-nm");
			if(test1_dist == nil) {
				test1_dist=0.0;
			}
			var norm_dist = (1 / test_dist) * test1_dist;
			
			var aiAlt = getprop("ai/models/aircraft["~i~"]/position/altitude-ft");
			var diffAlt = (aiAlt-myAlt)/100;
			var diff_alt_fl_sign = 0;
			if(diffAlt>=0){
				diff_alt_fl_sign = 1;
			}else{
				diff_alt_fl_sign = -1;
			}

			var vert_speed = getprop("ai/models/aircraft["~i~"]/velocities/vertical-speed-fps");

			var relative_heading = 360 - getprop("/orientation/heading-deg") + getprop("ai/models/aircraft["~i~"]/orientation/true-heading-deg");
			if(relative_heading<0){
				relative_heading = relative_heading + 360;
			}
			
			var callsign = getprop("/ai/models/aircraft["~i~"]/callsign");
			if(size(callsign)>6){
				callsign = substr(getprop("/ai/models/aircraft["~i~"]/callsign"),0,6);
			}
			
			##calcul tis level : 0=altitude +1200 ft and range > 5nm, 1=altitude -1200 ft or range < 5nm, 2= 1 + collision possible (aialt > myalt and vertspeed>0)
			var tis_color = 1;
			var tis = 0;##white open diamond
			
			if(abs(aiAlt-myAlt)<1200){
				tis = 1;##white filled diamond
			}
			if(test1_dist<5){
				tis = 1;
			}
			
			if(tis==1){
				if((diffAlt<0 and vert_speed>0) or (diffAlt>0 and vert_speed<0)){
					tis=2;
				}
			}
			
			var plot = { callsign: callsign,relative_heading: relative_heading,vert_speed: vert_speed,true_airspeed_kt: true_airspeed_kt,tis: tis,tgt_offset: tgt_offset,diff_alt_fl: sprintf("%02.0f",diffAlt),diff_alt_fl_sign: diff_alt_fl_sign,norm_dist: norm_dist};
			append(plots,plot);
		}
	}
		
	var ai_multiplayer = props.globals.getNode("/ai/models").getChildren("multiplayer");
	for(i=0; i<size(ai_multiplayer);i=i+1) {
		var inRange = getprop("/ai/models/multiplayer["~i~"]/radar/in-range");
		var true_airspeed_kt = getprop("ai/models/multiplayer["~i~"]/velocities/true-airspeed-kt");
		if (inRange == 1 and true_airspeed_kt>0) {
			var tgt_offset = getprop("/ai/models/multiplayer[" ~ i ~ "]/radar/h-offset");
			if(tgt_offset == nil) {
				tgt_offset = 0.0;
			}
			if (tgt_offset < 0){
				tgt_offset = 360 + tgt_offset;
			}
			if (tgt_offset > 360){
				tgt_offset = tgt_offset - 360;
			}

			var test1_dist = getprop("/ai/models/multiplayer[" ~ i ~ "]/radar/range-nm");
			if(test1_dist == nil) {
				test1_dist=0.0;
			}
			var norm_dist = (1 / test_dist) * test1_dist;
			
			var aiAlt = getprop("ai/models/multiplayer["~i~"]/position/altitude-ft");
			var diffAlt = (aiAlt-myAlt)/100;
			var diff_alt_fl_sign = 0;
			if(diffAlt>=0){
				diff_alt_fl_sign = 1;
			}else{
				diff_alt_fl_sign = -1;
			}
			
			
			var vert_speed = getprop("ai/models/multiplayer["~i~"]/velocities/vertical-speed-fps");

			var relative_heading = 360 - getprop("/orientation/heading-deg") + getprop("ai/models/multiplayer["~i~"]/orientation/true-heading-deg");
			if(relative_heading<0){
				relative_heading = relative_heading + 360;
			}
			
			var callsign = getprop("/ai/models/multiplayer["~i~"]/callsign");
			callsign = "MP-"~i;
			if(size(callsign)>6){
				callsign = substr(getprop("/ai/models/multiplayer["~i~"]/callsign"),0,6);
			}
			
			##calcul tis level : 0=altitude +1200 ft and range > 5nm, 1=altitude -1200 ft or range < 5nm, 2= 1 + collision possible (aialt > myalt and vertspeed>0)
			var tis_color = 1;
			var tis = 0;##white open diamond
			
			if(abs(aiAlt-myAlt)<1200){
				tis = 1;##white filled diamond
			}
			if(test1_dist<5){
				tis = 1;
			}
			
			if(tis==1){
				if((diffAlt<0 and vert_speed>0) or (diffAlt>0 and vert_speed<0)){
					tis=2;
				}
			}
			
			var plot = { callsign: callsign,relative_heading: relative_heading,vert_speed: vert_speed,true_airspeed_kt: true_airspeed_kt,tis: tis,tgt_offset: tgt_offset,diff_alt_fl: sprintf("%02.0f",diffAlt),diff_alt_fl_sign: diff_alt_fl_sign,norm_dist: norm_dist};
			append(plots,plot);
		}
	}
		
	var plots_sorted = sort (plots, func (a,b) a.norm_dist - b.norm_dist);
	var max_i = 8;
	if(size(plots_sorted)<max_i){
		max_i = size(plots_sorted);
	}
	for(var i=0;i<max_i;i=i+1){
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/diff_alt_fl",plots_sorted[i].diff_alt_fl);
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/diff_alt_fl_sign",plots_sorted[i].diff_alt_fl_sign);
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/brg_offset",plots_sorted[i].tgt_offset);
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/tis",plots_sorted[i].tis);
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/valid",1);
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/true_airspeed_kt",plots_sorted[i].true_airspeed_kt);
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/vertical_speed_fps",plots_sorted[i].vert_speed);
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/relative_heading",plots_sorted[i].relative_heading);
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/callsign",plots_sorted[i].callsign);
		setprop("/instrumentation/zkv1000/radar/ai["~i~"]/norm_dist", plots_sorted[i].norm_dist);
	}
		
	settimer(traffic_update,1);
}
setlistener("/sim/signals/fdm-initialized",traffic_update);

##calcul des positions des airports, nav, fix pour la map symbol
var symbol_update1 = func {
	setprop("/instrumentation/zkv1000/symbols/symbol[0]/id", "0");
	setprop("/instrumentation/zkv1000/symbols/symbol[0]/type", "airport");
	setprop("/instrumentation/zkv1000/symbols/symbol[0]/brg_offset", 45);
	setprop("/instrumentation/zkv1000/symbols/symbol[0]/norm_dist", 0.5);
	setprop("/instrumentation/zkv1000/symbols/symbol[0]/valid", 1);
	
	setprop("/instrumentation/zkv1000/symbols/symbol[1]/id", "0");
	setprop("/instrumentation/zkv1000/symbols/symbol[1]/type", "fix");
	setprop("/instrumentation/zkv1000/symbols/symbol[1]/brg_offset", -45);
	setprop("/instrumentation/zkv1000/symbols/symbol[1]/norm_dist", 0.5);
	setprop("/instrumentation/zkv1000/symbols/symbol[1]/valid", 1);
	
	setprop("/instrumentation/zkv1000/symbols/symbol[2]/id", "0");
	setprop("/instrumentation/zkv1000/symbols/symbol[2]/type", "ndb");
	setprop("/instrumentation/zkv1000/symbols/symbol[2]/brg_offset", -135);
	setprop("/instrumentation/zkv1000/symbols/symbol[2]/norm_dist", 0.5);
	setprop("/instrumentation/zkv1000/symbols/symbol[2]/valid", 1);
	
	setprop("/instrumentation/zkv1000/symbols/symbol[3]/id", "0");
	setprop("/instrumentation/zkv1000/symbols/symbol[3]/type", "vor");
	setprop("/instrumentation/zkv1000/symbols/symbol[3]/brg_offset", 135);
	setprop("/instrumentation/zkv1000/symbols/symbol[3]/norm_dist", 0.5);
	setprop("/instrumentation/zkv1000/symbols/symbol[3]/valid", 1);
}
var symbol_update = func {

	if(getprop("/instrumentation/zkv1000/device[0]/status")==6 or getprop("/instrumentation/zkv1000/device[1]/status")==6){
		##gps failure or not inline
		if(getprop("/instrumentation/gps/serviceable")==0 or (getprop("/instrumentation/gps/power-btn1")==0 and getprop("/instrumentation/gps/power-btn2")==0 )){
			settimer(symbol_update,1);
			return;
		}
		var max_plots = 50;
		
		var plots = [];
		var type_symbol = [ "airport" , "vor" , "ndb" , "fix"];
		var symbol_map_range = getprop('/instrumentation/zkv1000/symbmap-range');
		
		for(var i=0;i<size(type_symbol);i=i+1){
			if(getprop("/instrumentation/zkv1000/symbols/"~type_symbol[i])==1){
				lockSearches();
				searchNearestNavaid(type_symbol[i], max_plots);
				unlockSearches();
				while (getprop('/instrumentation/gps/scratch/has-next')) {
					var id = getprop('/instrumentation/gps/scratch/ident');
					var range = getprop('/instrumentation/gps/scratch/distance-nm') / symbol_map_range; 
					var bearing = 360 - getprop("/orientation/heading-deg") + getprop('/instrumentation/gps/scratch/mag-bearing-deg');
					if(bearing<0){
						bearing = bearing + 360;
					}
					var type = type_symbol[i];
					
					if(type=="vor"){
						id = id ~ " " ~ sprintf("%2.2f",getprop('/instrumentation/gps/scratch/frequency-mhz'));
					}
					
					if(type=="ndb"){
						id = id ~ " " ~ sprintf("%2.1f",getprop('/instrumentation/gps/scratch/frequency-khz'));
					}
					
					var plot = { id: id,bearing: bearing,type: type,range: range};
					if(range<=1){
						append(plots,plot);
					}else{
						break;
					}
					setprop("/instrumentation/gps/command", "next");
				}
			}
		}

		var plots_sorted = sort (plots, func (a,b) a.range - b.range);
		var nb_plots = max_plots;
		if(nb_plots>size(plots_sorted)){
			nb_plots = size(plots_sorted);
		}
		for(var i=0;i<nb_plots;i=i+1){
			props.globals.getNode("/instrumentation/zkv1000/symbols/symbol["~i~"]/id",1).setValue(plots_sorted[i].id);
			props.globals.getNode("/instrumentation/zkv1000/symbols/symbol["~i~"]/type",1).setValue(plots_sorted[i].type);
			props.globals.getNode("/instrumentation/zkv1000/symbols/symbol["~i~"]/brg_offset",1).setDoubleValue(plots_sorted[i].bearing);
			props.globals.getNode("/instrumentation/zkv1000/symbols/symbol["~i~"]/norm_dist",1).setDoubleValue(plots_sorted[i].range);
			props.globals.getNode("/instrumentation/zkv1000/symbols/symbol["~i~"]/valid",1).setIntValue(1);
		}
		for(var i=nb_plots;i<max_plots;i=i+1){
			props.globals.getNode("/instrumentation/zkv1000/symbols/symbol["~i~"]/valid",1).setIntValue(0);
		}
	}
	
	settimer(symbol_update,1);
}
setlistener("/instrumentation/zkv1000/device[0]/status",symbol_update);
setlistener("/instrumentation/zkv1000/device[1]/status",symbol_update);

var update_cdi_source = func {
	var zkvcdi = props.globals.getNode("/instrumentation/zkv1000/cdi",1);
	zkvcdi.getNode("course").unalias();
	var no_nav = -1;
	
	if(getprop("/instrumentation/zkv1000/radios/nav1-selected")==1){
		no_nav = 0;
	}elsif(getprop("/instrumentation/zkv1000/radios/nav2-selected")==1){
		no_nav = 1;
	}
	if(no_nav>-1){
		if(getprop("/instrumentation/zkv1000/cdi/has-gs")==1){
			zkvcdi.getNode("course").alias("/orientation/heading-magnetic-deg");
		}else{
			zkvcdi.getNode("course").alias("/instrumentation/nav[" ~ no_nav ~ "]/radials/selected-deg");
		}
	}
}
setlistener("/instrumentation/nav[0]/has-gs",update_cdi_source);
setlistener("/instrumentation/nav[1]/has-gs",update_cdi_source);

var searchLastChar = func(chaine, char){
	var result = -1;
	var char_a_tester = substr(chaine,char,1);
	for(var i=0;i<size(tab_chiffres_lettres);i=i+1){
		if(tab_chiffres_lettres[i]==char_a_tester){
			result = i;
			break;
		}
	}
	return result;
}