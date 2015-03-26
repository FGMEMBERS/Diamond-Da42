var zkv = cdi = brg1 = brg2 = radios = alerts = infos = cursors = afcs = map = mud = eis = gps = nil;

var init_props = func {
    zkv = props.globals.getNode("/instrumentation/zkv1000",1);
    zkv.getNode("emission",1).setDoubleValue(0.6);
    zkv.getNode("body-emission",1).setDoubleValue(0.0);
    zkv.getNode("body-texture",1).setValue("");

    cdi = zkv.getNode("cdi", 1);
    cdi.getNode("visible",1).setBoolValue(0);
    cdi.getNode("in-range",1).setBoolValue(0);
    cdi.getNode("pointer-type",1).setIntValue(0);
    cdi.getNode("course",1).setDoubleValue(0.0);
    cdi.getNode("course-deflection",1).setDoubleValue(0.0);
    cdi.getNode("radial",1).setDoubleValue(0.0);
    cdi.getNode("from-flag",1).setBoolValue(0);
	cdi.getNode("has-gs",1).setBoolValue(0);
	cdi.getNode("gs-needle-deflection-norm",1).setDoubleValue(0.0);

	brg1 = zkv.getNode("brg1", 1);
	brg1.getNode("course",1).setDoubleValue(0.0);
	brg1.getNode("nav1",1).setDoubleValue(0.0);
	brg1.getNode("name",1).setValue("");
	brg1.getNode("type",1).setValue("");
	brg1.getNode("frequence",1).setDoubleValue(0.0);
	brg1.getNode("nav-distance",1).setDoubleValue(0.0);
	brg1.getNode("in-range",1).setBoolValue(0);
	brg1.getNode("visible",1).setBoolValue(0);
	brg2 = zkv.getNode("brg2", 1);
	brg2.getNode("course",1).setDoubleValue(0.0);
	brg2.getNode("nav2",1).setDoubleValue(0.0);
	brg2.getNode("name",1).setValue("");
	brg2.getNode("type",1).setValue("");
	brg2.getNode("frequence",1).setDoubleValue(0.0);
	brg2.getNode("nav-distance",1).setDoubleValue(0.0);
	brg2.getNode("in-range",1).setBoolValue(0);
	brg2.getNode("visible",1).setBoolValue(0);
	
    radios = zkv.getNode("radios", 1);
    radios.getNode("swap-symbol", 1).setValue("<-->");
    radios.getNode("nav1-selected",1).setIntValue(0);
    radios.getNode("nav2-selected",1).setIntValue(0);
    radios.getNode("nav-tune",1).setIntValue(0);
    radios.getNode("nav-freq-mhz",1).alias("/instrumentation/nav/frequencies/standby-mhz");
    radios.getNode("comm1-selected",1).setIntValue(1);
    radios.getNode("comm2-selected",1).setIntValue(0);
    radios.getNode("comm-tune",1).setIntValue(0);
    radios.getNode("comm-freq-mhz",1).alias("/instrumentation/comm/frequencies/standby-mhz");
    radios.getNode("xpdr-mode",1).setValue("GND");

    cursors = zkv.getNode("cursors", 1);
    cursors.getNode("alt[0]",1).setIntValue(1);
    cursors.getNode("alt[1]",1).setIntValue(1);
    cursors.getNode("alt[2]",1).setIntValue(1);
    cursors.getNode("ias[0]",1).setIntValue(1);
    cursors.getNode("ias[1]",1).setIntValue(1);
    cursors.getNode("ias[2]",1).setIntValue(0);

    alerts = zkv.getNode("alerts",1);
    alerts.getNode("traffic-proximity",1).setIntValue(0);
    alerts.getNode("marker-beacon", 1).setIntValue(0);
	alerts.getNode("warning", 1).setBoolValue(0);
	alerts.getNode("caution", 1).setBoolValue(0);
	alerts.getNode("advisory", 1).setBoolValue(0);
	alerts.getNode("nbinfos", 1).setIntValue(0);
	alerts.getNode("posinfos", 1).setIntValue(0);
	props.globals.getNode("/sim/alarms/warning",1).alias("/instrumentation/zkv1000/alerts/warning");
	
    infos = zkv.getNode("infos", 1);
    infos.getNode("course",1).setBoolValue(0);
    infos.getNode("heading",1).setBoolValue(0);
    infos.getNode("wind-line",1).setValue("");
    infos.getNode("wind-line[1]",1).setValue("");
    infos.getNode("brg1-line",1).setValue("");
    infos.getNode("brg1-line[1]",1).setValue("");
    infos.getNode("brg1-line[2]",1).setValue("");
    infos.getNode("brg2-line",1).setValue("");
    infos.getNode("brg2-line[1]",1).setValue("");
    infos.getNode("brg2-line[2]",1).setValue("");
    infos.getNode("dme-line",1).setValue("NAV1");
    infos.getNode("dme-line[1]",1).setValue("");
    infos.getNode("dme-line[2]",1).setValue("");
    infos.getNode("ktas",1).setDoubleValue(0.0);

    afcs = zkv.getNode("afcs",1);
    afcs.getNode("fd-bars-visible",1).setBoolValue(0);
    afcs.getNode("alt-bug-visible",1).setBoolValue(0);
    afcs.getNode("heading-bug-deg",1).setDoubleValue(getprop("/orientation/heading-magnetic-deg"));
    afcs.getNode("target-pitch-deg",1).setDoubleValue(0.0);
    afcs.getNode("selected-alt-ft",1).setDoubleValue(0.0);
    afcs.getNode("selected-alt-ft-diff",1).setDoubleValue(0.0);
    afcs.getNode("selected-ias-kt-diff",1).setDoubleValue(0.0);
    afcs.getNode("vertical-speed-fpm",1).setDoubleValue(0.0);
    afcs.getNode("roll-armed", 1).setBoolValue(0);
    afcs.getNode("pitch-armed", 1).setBoolValue(0);
    afcs.getNode("roll-armed-mode-text",1).setValue("");
    afcs.getNode("roll-active-mode-text",1).setValue("");
    afcs.getNode("roll-armed-mode",1).setIntValue(0);
    afcs.getNode("roll-active-mode",1).setIntValue(0);
    afcs.getNode("roll-active-mode-blink",1).setBoolValue(0);
    afcs.getNode("pit-armed-mode-text",1).setValue("");
    afcs.getNode("pit-active-mode-text",1).setValue("");
    afcs.getNode("pit-armed-mode",1).setIntValue(0);
    afcs.getNode("pit-active-mode",1).setIntValue(0);
    afcs.getNode("pit-active-mode-blink",1).setBoolValue(0);

    map = zkv.getNode("map",1);
    map.getNode("terrain-path",1).setValue("");
    map.getNode("objects-path",1).setValue("");
    map.getNode("navaids-path",1).setValue("");
    map.getNode("moving-x",1).setDoubleValue(0.0);
    map.getNode("moving-y",1).setDoubleValue(0.0);
    map.getNode("alt",1).setIntValue(0);
    map.getNode("alt-selected",1).setIntValue(0);
    map.getNode("alt-1-min",1).setIntValue(0);
    map.getNode("latitude-deg", 1).alias("/position/latitude-deg");
    map.getNode("longitude-deg", 1).alias("/position/longitude-deg");
    map.getNode("range-index", 1).setIntValue(0);
    map.getNode("panning", 1).setBoolValue(0);

    eis = zkv.getNode("eis", 1);
    eis.getNode("circle[0]", 1).setDoubleValue(0.0);
    eis.getNode("circle[1]", 1).setDoubleValue(0.0);
    for (var i = 0; i <= 14; i += 1) eis.getNode("bar["~i~"]", 1).setDoubleValue(0.0);

	gps = zkv.getNode("gps", 1);
	gps.getNode("mode",1).setValue("");
	gps.getNode("id",1).setValue("");
	gps.getNode("heading-needle-deflexion",1).setDoubleValue(0.0);
	
    props.globals.getNode("/instrumentation/transponder/id-code",1).setIntValue(1200);
    props.globals.getNode("/autopilot/settings/heading-bug-deg", 1).alias("/instrumentation/zkv1000/afcs/heading-bug-deg");
    props.globals.getNode("/autopilot/settings/target-altitude-ft",1).setDoubleValue(0.0);
    props.globals.getNode("/autopilot/settings/target-speed-kt",1).setDoubleValue(0.0);
    props.globals.getNode("/autopilot/settings/vertical-speed-fpm",1).setDoubleValue(0.0);
    props.globals.getNode("/autopilot/internal/target-pitch-deg",1).setDoubleValue(0.0);
    props.globals.getNode("/autopilot/internal/flc-altitude-pitch-deg",1).setDoubleValue(0.0);
    props.globals.getNode("/autopilot/internal/flc-airspeed-pitch-deg",1).setDoubleValue(0.0);
    props.globals.getNode("/autopilot/internal/target-roll-deg",1).setDoubleValue(0.0);
    props.globals.getNode("/autopilot/locks/pitch",1).setValue("");
    props.globals.getNode("/autopilot/locks/roll",1).setValue("");
    props.globals.getNode("/autopilot/locks/passive-mode", 1).setIntValue(1);
	
	props.globals.getNode("/instrumentation/gps/config/hard-surface-runways-only", 1).setBoolValue(0);
}

var setGpsNeedleDeflexion = func {
	var needle_deflexion = getprop("/instrumentation/gps/wp/wp[1]/course-error-nm");
	var distance = getprop("/instrumentation/gps/wp/wp[1]/distance-nm");
	needle_deflexion = needle_deflexion / distance;
	needle_deflexion = 82 * needle_deflexion;
	
	if(needle_deflexion>10){
		needle_deflexion = 10;
	}elsif(needle_deflexion<-10){
		needle_deflexion = -10;
	}
	setprop("/instrumentation/zkv1000/gps/heading-needle-deflexion",needle_deflexion);
	settimer(setGpsNeedleDeflexion,0.1);
}

var set_listeners = func {
    setlistener("/instrumentation/nav[0]/radials/selected-deg", popup_course_info,  0, 0);
    setlistener("/instrumentation/nav[1]/radials/selected-deg", popup_course_info,  0, 0);
	setlistener("/instrumentation/gps/selected-course-deg", popup_course_info,  0, 0);
    setlistener("/instrumentation/zkv1000/afcs/heading-bug-deg",popup_hdg_info,     0, 0);
    setlistener("/instrumentation/zkv1000/afcs/selected-alt-ft",popup_selected_alt, 0, 0);
    setlistener("/instrumentation/zkv1000/radios/nav-tune",     setNavTune,         0, 0);
    setlistener("/instrumentation/zkv1000/radios/comm-tune",    setCommTune,        0, 0);
	setGpsNeedleDeflexion();
}

var load_nasal = func {
    var zkv1000_dir = getprop("/sim/aircraft-dir") ~ "/zkv1000/Nasal/";
    io.load_nasal(zkv1000_dir ~ "lib.nas",    "zkv1000");
    io.load_nasal(zkv1000_dir ~ "core.nas",   "zkv1000");
    io.load_nasal(zkv1000_dir ~ "alerts.nas", "zkv1000");
    io.load_nasal(zkv1000_dir ~ "radios.nas", "zkv1000");
    io.load_nasal(zkv1000_dir ~ "afcs.nas",   "zkv1000");
    io.load_nasal(zkv1000_dir ~ "map.nas",    "zkv1000");
    io.load_nasal(zkv1000_dir ~ "menu.nas",   "zkv1000");
    io.load_nasal(zkv1000_dir ~ "display.nas","zkv1000");
    io.load_nasal(zkv1000_dir ~ "knobs.nas",  "zkv1000");
    io.load_nasal(zkv1000_dir ~ "infos.nas",  "zkv1000");
    io.load_nasal(zkv1000_dir ~ "mud.nas",    "zkv1000");
}

var zkv1000_init = func {
    load_nasal();
    init_props();
	init_alerts();
    init_AFCS();
    init_map();
    set_listeners();
	fgcommand("loadxml", props.Node.new({ filename: getprop("/sim/aircraft-dir") ~ "/zkv1000/Systems/comms.xml", targetnode: "/instrumentation/zkv1000/airport_radios" }));
    print("zkv1000 loaded");
}

setlistener("/sim/signals/fdm-initialized", zkv1000_init, 0, 0);

var init_alerts = func{
#level : 2=warning, 1=caution, 0=advisory

	##alerts : warning
	alerts.getNode("alerts-list/alert[0]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[0]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[0]/label", 1).setValue("DOOR OPEN");
	alerts.getNode("alerts-list/alert[0]/text0", 1).setValue("FRONT DOOR OR CANOPY OR BAGGAGE");
	alerts.getNode("alerts-list/alert[0]/text1", 1).setValue("IS NOT CLOSED AND LOCKED");
	
	alerts.getNode("alerts-list/alert[1]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[1]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[1]/label", 1).setValue("LEFT ALTN FAIL");
	alerts.getNode("alerts-list/alert[1]/text0", 1).setValue("LEFT ENGINE ALTERNATOR HAS FAILED");
	alerts.getNode("alerts-list/alert[1]/text1", 1).setValue("");

	alerts.getNode("alerts-list/alert[2]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[2]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[2]/label", 1).setValue("RIGHT	ALTN FAIL");
	alerts.getNode("alerts-list/alert[2]/text0", 1).setValue("RIGHT ENGINE ALTERNATOR HAS FAILED");
	
	alerts.getNode("alerts-list/alert[3]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[3]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[3]/label", 1).setValue("LEFT OIL PRES");
	alerts.getNode("alerts-list/alert[3]/text0", 1).setValue("LEFT ENGINE OIL PRESSURE");
	alerts.getNode("alerts-list/alert[3]/text1", 1).setValue("IS LESS THAN 1 PSI");
	
	alerts.getNode("alerts-list/alert[4]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[4]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[4]/label", 1).setValue("RIGHT OIL PRES");
	alerts.getNode("alerts-list/alert[4]/text0", 1).setValue("RIGHT ENGINE OIL PRESSURE");
	alerts.getNode("alerts-list/alert[4]/text1", 1).setValue("IS LESS THAN 1 PSI");
	
	alerts.getNode("alerts-list/alert[5]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[5]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[5]/label", 1).setValue("LEFT STARTER");
	alerts.getNode("alerts-list/alert[5]/text0", 1).setValue("LEFT ENGINE STARTER IS ENGAGED");
	
	alerts.getNode("alerts-list/alert[6]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[6]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[6]/label", 1).setValue("RIGHT STARTER");
	alerts.getNode("alerts-list/alert[6]/text0", 1).setValue("RIGHT ENGINE STARTER IS ENGAGED");
	
	alerts.getNode("alerts-list/alert[7]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[7]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[7]/label", 1).setValue("AIRSPEED FAIL");
	alerts.getNode("alerts-list/alert[7]/text0", 1).setValue("THE DISPLAY SYSTEM IS NOT RECEIVING");
	alerts.getNode("alerts-list/alert[7]/text1", 1).setValue("AIRSPEED INPUT FROM AIRDATA CMP");
	
	alerts.getNode("alerts-list/alert[8]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[8]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[8]/label", 1).setValue("ALTITUDE FAIL");
	alerts.getNode("alerts-list/alert[8]/text0", 1).setValue("THE DISPLAY SYSTEM IS NOT RECEIVING");
	alerts.getNode("alerts-list/alert[8]/text1", 1).setValue("ALTITUDE INPUT FROM AIRDATA CMP");
	
	alerts.getNode("alerts-list/alert[9]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[9]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[9]/label", 1).setValue("ATTITUDE FAIL");
	alerts.getNode("alerts-list/alert[9]/text0", 1).setValue("THE DISPLAY SYSTEM IS NOT RECEIVING");
	alerts.getNode("alerts-list/alert[9]/text1", 1).setValue("ATTITUDE REFERENCE FROM THE AHRS");
	
	alerts.getNode("alerts-list/alert[10]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[10]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[10]/label", 1).setValue("HDG");
	alerts.getNode("alerts-list/alert[10]/text0", 1).setValue("THE DISPLAY SYSTEM IS NOT RECEIVING");
	alerts.getNode("alerts-list/alert[10]/text1", 1).setValue("VALID HEADING INPUT FROM THE AHRS");
	
	alerts.getNode("alerts-list/alert[11]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[11]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[11]/label", 1).setValue("L ENG TEMP");
	alerts.getNode("alerts-list/alert[11]/text0", 1).setValue("LEFT ENGINE TEMPERATURE IS MORE");
	alerts.getNode("alerts-list/alert[11]/text1", 1).setValue("THAN 105 DEGREES");
	
	alerts.getNode("alerts-list/alert[12]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[12]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[12]/label", 1).setValue("R ENG TEMP");
	alerts.getNode("alerts-list/alert[12]/text0", 1).setValue("RIGHT ENGINE TEMPERATURE IS MORE");
	alerts.getNode("alerts-list/alert[12]/text1", 1).setValue("THAN 105 DEGREES");

	alerts.getNode("alerts-list/alert[13]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[13]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[13]/label", 1).setValue("L OIL TEMP");
	alerts.getNode("alerts-list/alert[13]/text0", 1).setValue("LEFT ENGINE OIL TEMPERATURE IS");
	alerts.getNode("alerts-list/alert[13]/text1", 1).setValue("MORE THAN 140 DEGREES");
	
	alerts.getNode("alerts-list/alert[14]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[14]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[14]/label", 1).setValue("R OIL TEMP");
	alerts.getNode("alerts-list/alert[14]/text0", 1).setValue("RIGHT ENGINE OIL TEMPERATURE IS");
	alerts.getNode("alerts-list/alert[14]/text1", 1).setValue("MORE THAN 140 DEGREES");
	
	alerts.getNode("alerts-list/alert[15]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[15]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[15]/label", 1).setValue("L FUEL TEMP");
	alerts.getNode("alerts-list/alert[15]/text0", 1).setValue("LEFT ENGINE FUEL TEMPERATURE IS");
	alerts.getNode("alerts-list/alert[15]/text1", 1).setValue("MORE THAN 75 DEGREES");
	
	alerts.getNode("alerts-list/alert[16]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[16]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[16]/label", 1).setValue("R FUEL TEMP");
	alerts.getNode("alerts-list/alert[16]/text0", 1).setValue("RIGHT ENGINE FUEL TEMPERATURE IS");
	alerts.getNode("alerts-list/alert[16]/text1", 1).setValue("MORE THAN 75 DEGREES");
	
	alerts.getNode("alerts-list/alert[17]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[17]/level", 1).setIntValue(2);
	alerts.getNode("alerts-list/alert[17]/label", 1).setValue("XPDR FAIL");
	alerts.getNode("alerts-list/alert[17]/text0", 1).setValue("DISPLAY SYSTEM IS NOT RECEIVING");
	alerts.getNode("alerts-list/alert[17]/text1", 1).setValue("VALID TRANSPONDER INFORMATION");
	
	##alerts : caution
	alerts.getNode("alerts-list/alert[18]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[18]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[18]/label", 1).setValue("DEICE LVL LO");
	alerts.getNode("alerts-list/alert[18]/text0", 1).setValue("DEICING FLUID LEVEL IS LOW");
	
	alerts.getNode("alerts-list/alert[19]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[19]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[19]/label", 1).setValue("L FUEL LOW");
	alerts.getNode("alerts-list/alert[19]/text0", 1).setValue("LEFT ENGINE MAIN TANK FUEL");
	alerts.getNode("alerts-list/alert[19]/text1", 1).setValue("QUANTITY IS LOW");
	
	alerts.getNode("alerts-list/alert[20]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[20]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[20]/label", 1).setValue("R FUEL LOW");
	alerts.getNode("alerts-list/alert[20]/text0", 1).setValue("RIGHT ENGINE MAIN TANK FUEL");
	alerts.getNode("alerts-list/alert[20]/text1", 1).setValue("QUANTITY IS LOW");
	
	alerts.getNode("alerts-list/alert[21]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[21]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[21]/label", 1).setValue("PITOT FAIL");
	alerts.getNode("alerts-list/alert[21]/text0", 1).setValue("PITOT HEAT HAS FAILED");
	
	alerts.getNode("alerts-list/alert[22]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[22]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[22]/label", 1).setValue("PITOT HT OFF");
	alerts.getNode("alerts-list/alert[22]/text0", 1).setValue("PITOT HEAT IS OFF");
	
	alerts.getNode("alerts-list/alert[23]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[23]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[23]/label", 1).setValue("L ECU A FAIL");
	alerts.getNode("alerts-list/alert[23]/text0", 1).setValue("LEFT ECU A FAILED OR TESTED");
	
	alerts.getNode("alerts-list/alert[24]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[24]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[24]/label", 1).setValue("L ECU B FAIL");
	alerts.getNode("alerts-list/alert[24]/text0", 1).setValue("LEFT ECU B FAILED OR TESTED");
	
	alerts.getNode("alerts-list/alert[25]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[25]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[25]/label", 1).setValue("R ECU A FAIL");
	alerts.getNode("alerts-list/alert[25]/text0", 1).setValue("RIGHT ECU A FAILED OR TESTED");
	
	alerts.getNode("alerts-list/alert[26]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[26]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[26]/label", 1).setValue("R ECU B FAIL");
	alerts.getNode("alerts-list/alert[26]/text0", 1).setValue("RIGHT ECU B FAILED OR TESTED");
	
	alerts.getNode("alerts-list/alert[27]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[27]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[27]/label", 1).setValue("COM 1 FAIL");
	alerts.getNode("alerts-list/alert[27]/text0", 1).setValue("COMM 1 FAILED OR NOT SWITCH ON");
	
	alerts.getNode("alerts-list/alert[28]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[28]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[28]/label", 1).setValue("COM 2 FAIL");
	alerts.getNode("alerts-list/alert[28]/text0", 1).setValue("COMM 2 FAILED OR NOT SWITCH ON");
	
	alerts.getNode("alerts-list/alert[29]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[29]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[29]/label", 1).setValue("NAV 1 FAIL");
	alerts.getNode("alerts-list/alert[29]/text0", 1).setValue("NAV 1 FAILED OR NOT SWITCH ON");
	
	alerts.getNode("alerts-list/alert[30]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[30]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[30]/label", 1).setValue("NAV 2 FAIL");
	alerts.getNode("alerts-list/alert[30]/text0", 1).setValue("NAV 2 FAILED OR NOT SWITCH ON");
	
	alerts.getNode("alerts-list/alert[31]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[31]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[31]/label", 1).setValue("GPS 1 FAIL");
	alerts.getNode("alerts-list/alert[31]/text0", 1).setValue("GPS 1 FAILED OR NOT SWITCH ON");
	
	alerts.getNode("alerts-list/alert[32]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[32]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[32]/label", 1).setValue("GPS 2 FAIL");
	alerts.getNode("alerts-list/alert[32]/text0", 1).setValue("GPS 2 FAILED OR NOT SWITCH ON");
	
	alerts.getNode("alerts-list/alert[33]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[33]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[33]/label", 1).setValue("ADF FAIL");
	alerts.getNode("alerts-list/alert[33]/text0", 1).setValue("ADF FAILED OR NOT SWITCH ON");
	
	alerts.getNode("alerts-list/alert[34]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[34]/level", 1).setIntValue(1);
	alerts.getNode("alerts-list/alert[34]/label", 1).setValue("DME FAIL");
	alerts.getNode("alerts-list/alert[34]/text0", 1).setValue("DME FAILED OR NOT SWITCH ON");
	
	##alerts : advisory
	alerts.getNode("alerts-list/alert[35]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[35]/level", 1).setIntValue(0);
	alerts.getNode("alerts-list/alert[35]/label", 1).setValue("MFD FAN FAIL");
	alerts.getNode("alerts-list/alert[35]/text0", 1).setValue("COOLING FAN FOR THE MFD IS");
	alerts.getNode("alerts-list/alert[35]/text1", 1).setValue("INOPERATIVE");
	
	alerts.getNode("alerts-list/alert[36]/active", 1).setBoolValue(0);
	alerts.getNode("alerts-list/alert[36]/level", 1).setIntValue(0);
	alerts.getNode("alerts-list/alert[36]/label", 1).setValue("PFD FAN FAIL");
	alerts.getNode("alerts-list/alert[36]/text0", 1).setValue("COOLING FAN FOR THE PFD IS");
	alerts.getNode("alerts-list/alert[36]/text1", 1).setValue("INOPERATIVE");

}

##display of the last radio messages
var replay_dialog = gui.Dialog.new("/sim/gui/dialogs/da42/replay/dialog", getprop("/sim/aircraft-dir")~"/zkv1000/Systems/radio_replay_dialog.xml");