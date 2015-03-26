var pitModes = {
    "PIT": "pitch-hold",
    "ALT": "altitude-hold",
    "VS": "vertical-speed-hold",
    "FLC": "flight-level-change",
    "GS": "gs1-hold",
    "GP": "",
    "VPTH": "vertical-path",
    "GA": "go-around"
};
var pitMode = "";

var rollModes = {
    "ROL": "wing-leveler",
    "HDG": "dg-heading-hold",
    "GA": "go-around",
    "GPS": "",
    "VOR": "nav1-hold",
    "LOC": "",
    "VAPP": "",
};
var rollMode = "";

var AFCS = {
    nose_inc : 0,
    nose_node : "",
    nose_max : 0,
    nose_min : 0,
    AP  : func { 
              if (getPitchMode() == "") setPitchMode("PIT");
              setprop("/autopilot/locks/passive-mode", getprop("/autopilot/locks/passive-mode")? 0 : 1);
          },
    FD : func { 
             setPitchMode(getPitchMode() == "" ? "PIT" : "");
         },
    ROL : func {
              setRollMode("ROL");
              settings.getNode("heading-bug-deg").unalias();
              afcs.getNode("roll-armed").setBoolValue(0);
              setprop("/autopilot/internal/target-roll-deg", 0);
          },
    HDG : func { 
              settings.getNode("heading-bug-deg").alias(afcs.getNode("heading-bug-deg"));
          },
    NAV : func { 
              settings.getNode("heading-bug-deg").unalias();
              afcs.getNode("roll-armed").setBoolValue(0);
              checkRollAquisition = checkNavAquisition;
          },
    PIT : func { 
              AFCS.nose_inc = 0.5;
              AFCS.nose_node = "/autopilot/internal/target-pitch-deg";
              AFCS.nose_min = -15;
              AFCS.nose_max = 20;
              setprop(AFCS.nose_node, round(pitch));
          },
    VS  : func { 
              AFCS.nose_node = "/autopilot/settings/vertical-speed-fpm";
              AFCS.nose_inc = 100;
              AFCS.nose_min = -3000;
              AFCS.nose_max = 1500;
              setprop(AFCS.nose_node, round(vs, AFCS.nose_inc));
              setprop("/autopilot/settings/target-altitude-ft", getprop(afcs.getNode("selected-alt-ft").getPath()));
              checkPitchAquisition = checkSelectedAltAquisition;
          },
    ALT : func { 
              setprop("/autopilot/settings/target-altitude-ft", getprop(afcs.getNode("selected-alt-ft").getPath()));
			  print("test=",afcs.getNode("selected-alt-ft").getPath());
              checkPitchAquisition = checkSelectedAltAquisition;
          },
    FLC : func { 
              AFCS.nose_node = "/autopilot/settings/target-speed-kt";
              AFCS.nose_inc = 1;
              AFCS.nose_min = 70;
              AFCS.nose_max = 165;
              computeAirspeedDiff = _computeAirspeedDiff;
              checkPitchAquisition = checkSelectedAltAquisition;
              setprop(AFCS.nose_node, round(ias, AFCS.nose_inc));
              setprop("/autopilot/settings/target-altitude-ft", getprop(afcs.getNode("selected-alt-ft").getPath()));
              FLCcomputation = _FLCcomputation;
          },
    NOSEUP : func { 
                 AFCS.nose_inc or return;
                 var s = getprop(AFCS.nose_node) + AFCS.nose_inc;
                 s <= AFCS.nose_max or return;
                 setprop(AFCS.nose_node, getprop(AFCS.nose_node) + AFCS.nose_inc);
             },
    NOSEDOWN : func { 
                   AFCS.nose_inc or return;
                   var s = getprop(AFCS.nose_node) - AFCS.nose_inc;
                   s >= AFCS.nose_min or return;
                   setprop(AFCS.nose_node, getprop(AFCS.nose_node) - AFCS.nose_inc);
               },
    VNV : func { 
              nyi("VNV");
          },
    APR : func {
              nyi("APR");
          },
    APDISC : void,
    CWS : void,
    GA : void
};

var checkNavAquisition = func {
    var r = getprop("/instrumentation/zkv1000/cdi/radial");
    var h = getprop("/orientation/heading-deg");
    var d = getprop("/instrumentation/zkv1000/cdi/course-deflection");
    if (d < 0.5) {
        rollBlinking.switch(0);
        setprop("/instrumentation/zkv1000/afcs/roll-armed-mode", 0);
    }
    elsif (d > 1) {
        rollBlinking.switch(0);
        setprop("/instrumentation/zkv1000/afcs/roll-armed-mode", pitMode);
    }
    else {
        getprop("/instrumentation/zkv1000/afcs/roll-armed") or rollBlinking.switch(1);
        setprop("/instrumentation/zkv1000/afcs/roll-armed-mode", rollMode);
    }
}

var checkSelectedAltAquisition = func {
    var s = getprop("/autopilot/settings/target-altitude-ft");
    var diff = abs(alt - s);
    var climb = (alt - s > 0);
    if (diff < 50) {
        pitchBlinking.switch(0);
        setPitchMode("ALT");
    }
    elsif (diff > 400) {
        setprop("/instrumentation/zkv1000/vertical-speed-fpm", (climb and !getPitchMode("VS"))? 1000 : -500);
        if (!getPitchMode("FLC")) setPitchMode("VS", 0);
        pitchBlinking.switch(0);
    }
    else {
        setprop("/instrumentation/zkv1000/vertical-speed-fpm", climb? 100 : -100);
        setPitchMode("VS");
        getprop("/instrumentation/zkv1000/afcs/pitch-armed") or pitchBlinking.switch(1);
    }
}

# Note: use SetPitchMode("") to exit the Flight Director mode
var setPitchMode = func (m, s=1) {
    checkPitchAquisition = void;
    FLCcomputation = void;
    computeAirspeedDiff = void;
    AFCS.nose_inc = 0;
    if (pitMode == m and s) pitMode = "PIT";
    else pitMode = m;
    setprop("/autopilot/locks/pitch", pitMode != "" ? pitModes[pitMode] : pitMode);
    setprop("/instrumentation/zkv1000/afcs/pit-active-mode", pitMode);
    setprop("/instrumentation/zkv1000/afcs/pit-armed-mode", pitMode);
    setprop("/instrumentation/zkv1000/afcs/pit-armed-mode-text", pitMode);
    setprop("/instrumentation/zkv1000/afcs/pit-active-mode-text", pitMode);
    setprop("/instrumentation/zkv1000/afcs/pit-active-mode-blink", 0);
    if (pitMode != "") {
        computeAltitudeDiff = _computeAltitudeDiff;
        setprop("/instrumentation/zkv1000/afcs/alt-bug-visible", 1);
        if (getRollMode() == "") setRollMode("ROL");
    }
    else {
        setprop("/instrumentation/zkv1000/afcs/alt-bug-visible", 0);
        rollBlinking.switch(0);
        computeAltitudeDiff = void;
        computeAirspeedDiff = void;
        setRollMode("", 0);
    }
    init_main_loop();
}

var setRollMode = func (m, s=1) {
    checkRollAquisition = void;
    if (rollMode == m and s) rollMode = "ROL";
    else rollMode = m;
    setprop("/autopilot/locks/roll", rollMode != "" ? rollModes[rollMode] : rollMode);
    setprop("/instrumentation/zkv1000/afcs/roll-active-mode", rollMode);
    setprop("/instrumentation/zkv1000/afcs/roll-armed-mode", rollMode);
    setprop("/instrumentation/zkv1000/afcs/roll-armed-mode-text", rollMode);
    setprop("/instrumentation/zkv1000/afcs/roll-active-mode-text", rollMode);
    setprop("/instrumentation/zkv1000/afcs/roll-active-mode-blink", 0);
    if (rollMode != "") {
        setprop("/instrumentation/zkv1000/afcs/fd-bars-visible", 1);
        if (getPitchMode() == "") setPitchMode("PIT");
		
		if(rollMode == "HDG"){
			zkv1000.AFCS.HDG();
			print("hdg");
		}
		
    }
    else {
        setprop("/instrumentation/zkv1000/afcs/fd-bars-visible", 0);
        settings.getNode("heading-bug-deg").unalias();
        rollBlinking.switch(0);
    }
    init_main_loop();
}

var getPitchMode = func (mode = nil) {
    var m = getprop("/autopilot/locks/pitch");
    if (mode)
        return (m == mode);
    else
        return m;
}

var getRollMode = func (mode = nil) { 
    var m = getprop("/autopilot/locks/roll"); 
    if (mode)
        return (m == mode);
    else
        return m;
}


var _FLCcomputation = func {
    var t1 = getprop("/autopilot/internal/flc-airspeed-pitch-deg");
    var t2 = getprop("/autopilot/internal/flc-altitude-pitch-deg");
    setprop("/autopilot/internal/target-pitch-deg", (t1 + t2) / 2);
}

var _computeAltitudeDiff = func {
    var sel = getprop("/instrumentation/zkv1000/afcs/selected-alt-ft");
    setprop("/instrumentation/zkv1000/afcs/selected-alt-ft-diff", sel - alt);
}

var _computeAirspeedDiff = func {
    var sel = getprop("/autopilot/settings/target-speed-kt");
    setprop("/instrumentation/zkv1000/afcs/selected-ias-kt-diff", sel - ias);
}

var settings = props.globals.getNode("/autopilot/settings");

var pitchBlinking = nil;
var rollBlinking = nil;

var init_AFCS = func {
     pitchBlinking = aircraft.light.new(afcs.getNode("pit-active-mode-blink").getPath(), 
        [0.5, 0.5], 
        afcs.getNode("pitch-armed").getPath());
     pitchBlinking.switch(0);

     rollBlinking = aircraft.light.new(afcs.getNode("roll-active-mode-blink").getPath(), 
        [0.5, 0.5], 
        afcs.getNode("roll-armed").getPath());
     rollBlinking.switch(0);
     #if (getprop("/sim/systems/autopilot/path") == "Aircraft/Generic/generic-autopilot.xml") {
     #    setprop("/sim/systems/autopilot/path", "Aircraft/Diamond-Da42/zkv1000/Systems/autopilot.xml");
     #}
	 
	 ##pour test
	 settings.getNode("target-altitude-ft").alias(afcs.getNode("selected-alt-ft"));
	 
	 print("AFCS initiated...");
}


