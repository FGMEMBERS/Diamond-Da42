# Simple, generic moving map for modern civil airliners
# By Ryan M
#######################################################

# This script provides the necessary properties for creating moving maps

var moving_map = {
 	init: func{
		print("Moving map ... initialized");
		moving_map.update();
	},
  
	update: func{
		moving_map.width = getprop("instrumentation/zkv1000/moving-map/width-m");
		moving_map.height = getprop("instrumentation/zkv1000/moving-map/height-m");
		moving_map.range = getprop("instrumentation/zkv1000/moving-map/controls/range-nm");

		var aircraft_heading = props.globals.getNode("orientation/heading-magnetic-deg");
		if (aircraft_heading == nil){
			return;
		}

		if ((props.globals.getNode("instrumentation/zkv1000/device[0]/status")!=nil
				and	props.globals.getNode("instrumentation/zkv1000/device[0]/status").getValue()==5)
				or(props.globals.getNode("instrumentation/zkv1000/device[0]/status")!=nil
				and props.globals.getNode("instrumentation/zkv1000/device[1]/status").getValue()==5)){
			if (props.globals.getNode("instrumentation/zkv1000/moving-map/terrain-elevation/use-high-resolution").getBoolValue()){
				moving_map.update_terrain_hi();
			}else{
				moving_map.update_terrain();
			}
			settimer(moving_map.update, 2);
		}else{
			settimer(moving_map.update, 1);
		}
	},
  
	update_terrain: func{
		##gps failure or not inline
		if(getprop("/instrumentation/gps/serviceable")==0 or (getprop("/instrumentation/gps/power-btn1")==0 and getprop("/instrumentation/gps/power-btn2")==0 )){
			return;
		}
		var pos = geo.aircraft_position();
		var hdg = getprop("orientation/heading-magnetic-deg");
		var path = "instrumentation/zkv1000/moving-map/terrain-elevation/";

		pos.apply_course_distance(hdg - 90, moving_map.range / 2 * 1852);
		pos.apply_course_distance(hdg - 180, moving_map.range / 2 * 1852);
		for (var i = 0; i < 16; i += 1){
			for (var j = 0; j < 16; j += 1){
				var info = geodinfo(pos.lat(), pos.lon());
				var decalage = 0;
				if (info != nil){
					var altitude_terrain = info[0] * 3.28;
					var altitude_aircraft = getprop("/position/altitude-ft");
					var difference = altitude_aircraft - altitude_terrain;
					if(difference>1000){
						decalage = 0##black
					}elsif(difference>-100){
						decalage = 0.25;##yellow
					}else{
						decalage = 0.5;##red
					}
				}else{
					decalage = 0.75;##pas de donnees
				}
				setprop(path ~ "row[" ~ i ~ "]/col[" ~ j ~ "]", decalage);
				pos.apply_course_distance(hdg + 90, moving_map.range / 16 * 1852);
			}
			pos.apply_course_distance(hdg - 90, moving_map.range * 1852);
			pos.apply_course_distance(hdg, moving_map.range / 16 * 1852);
		}
	},
	
	update_terrain_hi: func{
		##gps failure or not inline
		if(getprop("/instrumentation/gps/serviceable")==0 or (getprop("/instrumentation/gps/power-btn1")==0 and getprop("/instrumentation/gps/power-btn2")==0 )){
			return;
		}
		var pos = geo.aircraft_position();
		var hdg = getprop("orientation/heading-magnetic-deg");
		var path = "instrumentation/zkv1000/moving-map/terrain-elevation/";

		pos.apply_course_distance(hdg - 90, moving_map.range / 2 * 1852);
		pos.apply_course_distance(hdg - 180, moving_map.range / 2 * 1852);
		for (var i = 0; i < 32; i += 1){
			for (var j = 0; j < 32; j += 1){
			var info = geodinfo(pos.lat(), pos.lon());
			var decalage = 0;
				if (info != nil){
					var altitude_terrain = info[0] * 3.28;
					var altitude_aircraft = getprop("/position/altitude-ft");
					var difference = altitude_aircraft - altitude_terrain;
					if(difference>1000){
						decalage = 0##black
					}elsif(difference>-100){
						decalage = 0.25;##yellow
					}else{
						decalage = 0.5;##red
					}
				}else{
					decalage = 0.75;##pas de donnees
				}
				setprop(path ~ "row[" ~ i ~ "]/col[" ~ j ~ "]", decalage);
				pos.apply_course_distance(hdg + 90, moving_map.range / 32 * 1852);
			}
			pos.apply_course_distance(hdg - 90, moving_map.range * 1852);
			pos.apply_course_distance(hdg, moving_map.range / 32 * 1852);
		}
	}
 };
 
setlistener("sim/signals/fdm-initialized", func{
	settimer(moving_map.init, 2);
}, 0, 0);
