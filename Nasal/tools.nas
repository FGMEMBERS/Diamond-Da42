var time_deice_max = 0;
var time_deice_windshield = 0;
var last_time = 0.0;
var g_dt = 0;

## from senecaII
# throttle, feather and condition with mouse
var MouseHandler = {
	new : func() {
		var obj = { parents : [ MouseHandler ] };

		obj.propertyX = nil;
		obj.factorX = 1.0;
		obj.propertyY = nil;
		obj.factorY = 1.0;
		obj.minY = 0.0;
		obj.maxY = 1.0;
		obj.minX = 0.0;
		obj.maxX = 1.0;

		obj.YListenerId = setlistener( "devices/status/mice/mouse/accel-y", 
		func(n) { obj.YListener(n); }, 1, 0 );
		
		obj.XListenerId = setlistener( "devices/status/mice/mouse/accel-x", 
		func(n) { obj.XListener(n); }, 1, 0 );

		return obj;
	},

	YListener : func(n) {
		me.propertyY == nil and return;
		me.factorY == 0 and return;
		n == nil and return;
		var v = n.getValue();
		v == nil and return;

		if(getprop(me.propertyY)!=nil){
			if(getprop(me.propertyY) > me.maxY){
				setprop(me.propertyX,me.maxX);
			}
			if(getprop(me.propertyY) < me.minY){
				setprop(me.propertyY,me.minY);
			}
		}
		if(getprop(me.propertyY)==nil or (getprop(me.propertyY) < me.maxY and getprop(me.propertyY) > me.minY) or (getprop(me.propertyY) >= me.maxY and v < 0) or (getprop(me.propertyY) <= me.minY and v > 0)){
			fgcommand("property-adjust", props.Node.new({ 
				"offset" : v,
				"factor" : me.factorY,
				"property" : me.propertyY
			}));
		}
	},
	
	XListener : func(n) {
		me.propertyX == nil and return;
		me.factorX == 0 and return;
		n == nil and return;
		var v = n.getValue();
		v == nil and return;
		
		if(getprop(me.propertyX)!=nil){
			if(getprop(me.propertyX) > me.maxX){
				setprop(me.propertyX,me.maxX);
			}
			if(getprop(me.propertyX) < me.minX){
				setprop(me.propertyX,me.minX);
			}
		}
		if(getprop(me.propertyX)==nil or (getprop(me.propertyX) < me.maxX and getprop(me.propertyX) > me.minX) or (getprop(me.propertyX) >= me.maxX and v < 0) or (getprop(me.propertyX) <= me.minX and v > 0)){
			fgcommand("property-adjust", props.Node.new({ 
				"offset" : v,
				"factor" : me.factorX,
				"property" : me.propertyX
			}));
		}
	},

	setX : func( propertyX = nil, factorX = 1.0 , minX = 0.0, maxX = 1.0) {
		me.propertyX = propertyX;
		me.factorX = factorX;
		me.minX = minX;
		me.maxX = maxX;
	},
	
	setY : func( propertyY = nil, factorY = 1.0 , minY = 0.0, maxY = 1.0) {
		me.propertyY = propertyY;
		me.factorY = factorY;
		me.minY = minY;
		me.maxY = maxY;
	},

};

var mouseHandler = MouseHandler.new();

var togglePilot = func {
	var visible = getprop("/controls/pilot/visible");
	if(visible==1){
		visible=0;
	}else{
		visible=1;
		setprop("/controls/rudders/rudder[0]/position",0.45);
	}
	setprop("/controls/pilot/visible",visible);
}

## reglage du palonnier
_setlistener("/sim/weight[1]/weight-lb", func {
	if(getprop("/sim/weight[1]/weight-lb")>0){
		setprop("/controls/rudders/rudder[1]/position",1);
	}else{
		setprop("/controls/rudders/rudder[1]/position",0.5);
	}
});

#on reprend les fonctions gear et flaps parce qu'ils sont dirigés par electricité
controls.gearDown = func(v) {

	##emergency gear down
	if(getprop("/controls/gear/emergency")!=nil and getprop("/controls/gear/emergency")==1){
		return;
	}
	
	#verification de l electricite
	if(getprop("/controls/electric/alimentation/gear")==nil or getprop("/controls/electric/alimentation/gear")==0){
		return;
	}
	
    if (v < 0) {
        if(!getprop("gear/gear[1]/wow")){
			setprop("/controls/gear/gear-down", 0);
			setprop("/controls/switches/geardown",0);
		}
    } elsif (v > 0) {
		setprop("/controls/gear/gear-down", 1);
		setprop("/controls/switches/geardown",1);
    }
}

var positionGear = func(){
	var position = getprop("/controls/switches/geardown");
	if(position!=nil){
		if(position==1){
			controls.gearDown(1);
		}else{
			controls.gearDown(-1);
		}
	}
}
setlistener("/controls/switches/geardown", positionGear);

var emergencyGearDown = func{
	if(getprop("/controls/gear/emergency")!=nil and getprop("/controls/gear/emergency")==1){
		setprop("/controls/gear/gear-down", 1);
	}
}
setlistener("/controls/gear/emergency",emergencyGearDown);

controls.flapsDown = func(step) {
	if(step==-1 and getprop("/controls/switches/flaplever-switch")>0){
		setprop("/controls/switches/flaplever-switch",getprop("/controls/switches/flaplever-switch")-1);
	}
	
	if(step==1 and getprop("/controls/switches/flaplever-switch")<2){
		setprop("/controls/switches/flaplever-switch",getprop("/controls/switches/flaplever-switch")+1);
	}
}

var lastFlapStep=0;
var positionFlaps = func(){
	position = getprop("/controls/switches/flaplever-switch");
	if(position!=nil){
		##flap no destroyed
		if(getprop("/sim/failure-manager/controls/flight/flaps/serviceable")==1){
			if(getprop("/controls/electric/alimentation/flap")!=nil and getprop("/controls/electric/alimentation/flap")==1){
				while(position!=lastFlapStep){
					if(position<lastFlapStep){
						controls.stepProps("/controls/flight/flaps", "/sim/flaps", -1);
						lastFlapStep = lastFlapStep - 1;
					}else if(position>lastFlapStep){
						controls.stepProps("/controls/flight/flaps", "/sim/flaps", 1);
						lastFlapStep = lastFlapStep + 1;
					}
				}
			}
		}
	}
}
setlistener("/controls/switches/flaplever-switch", positionFlaps);
setlistener("/controls/electric/alimentation/flap", positionFlaps);

var nyi = func (x) { gui.popupTip(x ~ ": not (yet ?) implemented", 3); }

##
# Initialization.
#
var engines = [];
_setlistener("/sim/signals/fdm-initialized", func {
    var sel = props.globals.getNode("/sim/input/selected", 1);
    var engs = props.globals.getNode("/controls/engines").getChildren("engine");

    foreach(var e; engs) {
        var index = e.getIndex();
        var s = sel.getChild("engine", index, 1);
        if(s.getType() == "NONE") s.setBoolValue(1);
        append(engines, { index: index, controls: e, selected: s });
    }
});

##
# Mise a zero de l'audio
#
_setlistener("/sim/signals/fdm-initialized", func {
	setprop("/instrumentation/nav[0]/audio-btn",0);
	setprop("/instrumentation/nav[0]/ident",0);
	setprop("/instrumentation/nav[1]/audio-btn",0);
	setprop("/instrumentation/nav[1]/ident",0);
});

var init = func {
	var save_list = ["/sim/model/livery/file",
				"/sim/model/livery/name",
				"/sim/model/livery/texture",
				"/sim/multiplay/callsign",
				"/sim/model/immat",
				"/engines/engine[0]/hours-running",
				"/engines/engine[1]/hours-running",
				"/consumables/fuel/tank[0]/level-gal_us-for_save",
                "/consumables/fuel/tank[1]/level-gal_us-for_save",
				"/consumables/fuel/fuel-gest/fuel-remaining",
				"/consumables/fuel/fuel-gest/fuel-used",
				"/controls/fuel/tank[0]/position",
				"/controls/fuel/tank[0]/lock",
				"/controls/fuel/tank[1]/position",
				"/controls/fuel/tank[1]/lock",

				];

	aircraft.data.add(save_list);
	tankSelection();
	
	##fuel level initialisation
	if(getprop("/consumables/fuel/tank[0]/level-gal_us-for_save")!=nil){
		setprop("/consumables/fuel/tank[0]/level-gal_us",getprop("/consumables/fuel/tank[0]/level-gal_us-for_save"));
		setprop("/consumables/fuel/tank[1]/level-gal_us",getprop("/consumables/fuel/tank[1]/level-gal_us-for_save"));
	}
	eltmsg();
	print("Initialisation DA42 ...done");
	
	main_loop();
}

# Setup listener call to start update loop once the fdm is initialized
setlistener("sim/signals/fdm-initialized", init);

#main loop
var main_loop = func {
	
	var time = getprop("/sim/time/elapsed-sec");
    var dt = time - last_time;
    last_time = time;
	
	stall_horn();
	deice_system(dt);
	fuel_consumtion_calcul(dt);
	da42.update_engine_params(dt);
	
	##failures
	check_g_load(dt);
	check_vne_flaps();
	check_vne_structure();
	check_pitot_icing();
	settimer(main_loop, 0.3);
}

var deice_system = func(dt){
	var deice_mode = getprop("/controls/deice/mode");
	var deice_windshield_mode = getprop("/controls/deice/mode_windshield");
	var deice_alimentation = getprop("/controls/electric/alimentation/deice");
	var deice_lightcone = getprop("/controls/switches/deice/icelight");
	var deice_speed = getprop("/controls/switches/deice/speed");
	var liquid_level = getprop("/consumables/deice");
	
	#allumage ice light cone
	if(deice_alimentation==1 and deice_lightcone==1){
		setprop("/controls/lighting/antiicelight",1);
	}else{
		setprop("/controls/lighting/antiicelight",0);
	}
	
	#changement de mode
	if(deice_alimentation==1 and liquid_level>0){##pour l'instant , on gere les lumieres en fonction de la presence de liquide
		if(deice_mode!=2){
			setprop("/controls/deice/mode",deice_speed);
			deice_mode = deice_speed;
			if(deice_mode == -1){
				time_deice_max = 0;
			}
		}else{
			time_deice_max = time_deice_max + dt;
			if(time_deice_max>120){# 2 minutes de fonctionnement
				time_deice_max = 0;
				setprop("/controls/deice/mode",deice_speed);
			}
		}
		
		#windshield deice
		if(deice_windshield_mode>0){
			deice_windshield_mode = deice_windshield_mode - dt;
			setprop("/controls/deice/mode_windshield",deice_windshield_mode);
		}
		
		#consommation 
		if(liquid_level!=nil and liquid_level>0){
			if(deice_mode==0){#mode normal, conso en 2h30
				liquid_level = liquid_level - dt;
			}elsif(deice_mode==1){#mode high, conso en 1h00
				liquid_level = liquid_level - dt*2.5;
			}elsif(deice_mode==2){#mode max, conso en 0h30
				liquid_level = liquid_level - dt*5;
			}elsif(deice_windshield_mode>0){
				liquid_level = liquid_level - dt*5;
			}
			
			if(liquid_level<0){
				liquid_level = 0;
			}
			setprop("/consumables/deice",liquid_level);
		}
	}else{
		setprop("/controls/deice/mode",-1);
		setprop("/controls/deice/mode_windshield",0);
	}
	
}

var changeView = func(num){
	var viewNumber = getprop("/sim/current-view/view-number");
	
	if(viewNumber==10 or  viewNumber==11){
		setprop("/sim/current-view/view-number", 0);
	}elsif(viewNumber==0){
		if(num==0){
			setprop("/sim/current-view/view-number", 10);
		}elsif(num==1){
			setprop("/sim/current-view/view-number", 11);
		}
	}
}

var deice_system_max_toggle = func{
	if(getprop("/controls/electric/alimentation/deice")!=nil and getprop("/controls/electric/alimentation/deice")==1 and getprop("/controls/deice/mode")!=nil and getprop("/controls/deice/mode")>-1){
		setprop("/controls/deice/mode",2);
		time_deice_max = 0;
	}
}
setlistener("/controls/switches/deice/max",deice_system_max_toggle);

##pitot heat
var toggle_pitot_heat = func{
	if(getprop("/instrumentation/pitot-heat/serviceable")==1 and getprop("/controls/switches/pitotheat-switch")==1){
		setprop("/instrumentation/pitot-heat/active",1);
	}else{
		setprop("/instrumentation/pitot-heat/active",0);
	}
}
setlistener("/instrumentation/pitot-heat/serviceable",toggle_pitot_heat);
setlistener("/controls/switches/pitotheat-switch",toggle_pitot_heat);

##dialogs
var notepad_dialog = gui.Dialog.new("/sim/gui/dialogs/da42/notepad/dialog", getprop("/sim/aircraft-dir")~"/Dialogs/notepad.xml");
var airport_infos_dialog = gui.Dialog.new("/sim/gui/dialogs/da42/airport-infos/dialog", getprop("/sim/aircraft-dir")~"/Dialogs/airports.xml");
var checklists_dialog = gui.Dialog.new("/sim/gui/dialogs/da42/checklists/dialog", getprop("/sim/aircraft-dir")~"/Dialogs/checklists.xml");
setlistener("/sim/signals/fdm-initialized", func {
	fgcommand("loadxml", props.Node.new({ filename: getprop("/sim/aircraft-dir")~"/Dialogs/checklists-text.xml", targetnode: "/sim/gui/dialogs/da42/checklists-list" }));
});

## autostart
var autostart = func{
	print("Auto start !!!");
	setprop("/controls/switches/master-switch",1);
	setprop("/controls/switches/masteravionic-switch",1);
	setprop("/controls/switches/left-alt-switch",1);
	setprop("/controls/switches/right-alt-switch",1);
	setprop("/controls/switches/left-master-engine-switch",1);
	setprop("/controls/switches/right-master-engine-switch",1);
	setprop("/controls/switches/starterkey-insert",1);
	
	setprop("/controls/switches/positionlight-switch",1);
	setprop("/controls/switches/strobelight-switch",1);
	
	setprop("/controls/switches/elt",-1);
	setprop("/controls/lighting/elt",-1);
	
	var pressure = getprop("/environment/pressure-inhg");
	setprop("/instrumentation/altimeter[0]/setting-inhg",pressure);
	setprop("/instrumentation/altimeter[1]/setting-inhg",pressure);
	gui.popupTip("Auto Start started, waiting for zkv1000 initialisation...", 3);
	settimer(autostart_suite,5);
}

var autostart_suite = func{
	setprop("/engines/engine[0]/rpm",900);
	setprop("/engines/engine[1]/rpm",900);
	
	setprop("/instrumentation/zkv1000/alerts/warning",0);
	setprop("/instrumentation/zkv1000/alerts/caution",0);
	zkv1000.device[1].ALERT();
	
	gui.popupTip("Auto Start done ... you can lauch ECU tests and ask take off permission ;-)", 3);
}

############################################
# ELT System from Cessna337
# Authors: Pavel Cueto, with A LOT of collaboration from Thorsten and AndersG
# Adaptation by Clément de l'Hamaide for DR400-jsbSim
############################################

var eltmsg = func {
  var lat = getprop("/position/latitude-string");
  var lon = getprop("/position/longitude-string");
  var aircraft = getprop("sim/description");
  var callsign = getprop("sim/multiplay/callsign");

  setlistener("sim/crashed", func(n) {
    if(n.getBoolValue()){
      if(getprop("/controls/switches/elt")==-1) {#armed
        var help_string = "ELT AutoMessage: " ~ aircraft ~ " " ~ callsign ~ " testing ELT at " ~lat~" LAT "~lon~" LON, requesting SAR service";
        setprop("/sim/multiplay/chat", help_string);
      }
    }
  });

  setlistener("/controls/switches/elt", func(n) {
    if(n.getValue()==1){
      var help_string = "ELT AutoMessage: " ~ aircraft ~ " " ~ callsign ~ " testing ELT at " ~lat~" LAT "~lon~" LON, requesting SAR service";
      setprop("/sim/multiplay/chat", help_string);
    }
  });
}

##test icing
var testIcing = func{
	setprop("/sim/icing/windshield",0.9);
	setprop("/sim/icing/wings",0.8);
	setprop("/sim/icing/other",0.7);
	setprop("/sim/icing/engines",0.8);
	setprop("/sim/icing/propellers",0.8);
	setprop("/sim/icing/pitot",0.9);
}

##toogle rembrandt
var toogleRembrandt = func{
	if(getprop("/sim/rendering/rembrandt/enabled")==1){
		setprop("/sim/rendering/rembrandt/enabled",0);
	}else{
		setprop("/sim/rendering/rembrandt/enabled",1);
	}
}

##toogle shaders
var toogleShaders = func{
	if(getprop("/controls/shaders/intvitres")==1){
		setprop("/controls/shaders/intvitres",0);
	}else{
		setprop("/controls/shaders/intvitres",1);
	}
	if(getprop("/controls/shaders/intverriere")==1){
		setprop("/controls/shaders/intverriere",0);
	}else{
		setprop("/controls/shaders/intverriere",1);
	}
	if(getprop("/controls/shaders/intvitreporte")==1){
		setprop("/controls/shaders/intvitreporte",0);
	}else{
		setprop("/controls/shaders/intvitreporte",1);
	}
}