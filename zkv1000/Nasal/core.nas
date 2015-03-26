var main_loop_id = 0;
var loop_check_functions_max_index = 0;
var loop_check_functions = [];
var device = [nil, nil];
var deviceClass = {};

var init_main_loop = func {
    loop_check_functions = [
        pfdCursors,
        checkTrafficProximity,
        checkMarkerBeacon,
		checkAlerts,
        moveMap,
        checkRollAquisition,
        checkPitchAquisition,
        pfdCursors,
        computeAltitudeDiff,
        computeAirspeedDiff,
        checkAbnormalAttitude,
        manageLandingGears
    ];
    loop_check_functions_max_index = size(loop_check_functions);
}

var main_loop = func () {
    getData();
    FLCcomputation();
    loop_check_functions[main_loop_id]();
    main_loop_id += 1;
    if (main_loop_id == loop_check_functions_max_index) main_loop_id = 0;
    settimer(main_loop, 0);
}

deviceClass.new = func (d) {
    var node = zkv.getNode("device[" ~ d ~ "]", 1);
    var m = { parents: [ deviceClass, menuClass.new(node) ] };
    m.local = node;
    m.local.getNode("status",1).setIntValue(0);
    m.local.getNode("menu-level",1).setIntValue(0);
    m.local.getNode("menu-text",1).setValue("");
    m.local.getNode("wind-data",1).setBoolValue(0);
	m.local.getNode("baro-hpa",1).setBoolValue(0);
    m.local.getNode("brg1",1).setBoolValue(0);
    m.local.getNode("brg2",1).setBoolValue(0);
    m.local.getNode("dme",1).setBoolValue(0);
	
	m.local.getNode("terrain",1).setBoolValue(0);
	m.local.getNode("traffic",1).setBoolValue(0);
	m.local.getNode("topo",1).setBoolValue(0);
#    m.local.getNode("show-terrain", 1).setBoolValue(0);
#    m.local.getNode("show-objects", 1).setBoolValue(0);
#    m.local.getNode("show-navaids", 1).setBoolValue(0);
    m.local.getNode("hsi-360", 1).setBoolValue(1);
	
	m.local.getNode("menu-action",1).getNode("largeKnobAction",1).setValue("void");
	m.local.getNode("menu-action",1).getNode("smallKnobAction",1).setValue("void");
	m.local.getNode("menu-action",1).getNode("ENTsoftkey",1).setValue("void");
	m.local.getNode("menu-action",1).getNode("MENUsoftkey",1).setValue("void");
	
    return m;
}

var powerOn = func (d) {
	if(getprop("/instrumentation/zkv1000/device["~d~"]/status")!=nil and getprop("/instrumentation/zkv1000/device["~d~"]/status")>0){
		return;
	}
    device[d] = deviceClass.new(d);
    printf("zkv1000 %s switched on!", d == 0 ? "PFD" : "MFD");

    if (device[abs(d - 1)] == nil) {
        init_main_loop();
        ALTknob = _ALTknob;
        HDGknob = _HDGknob;
        CRSknob = _CRSknob;
        BAROknob = _BAROknob;
        NAVknob = _NAVknob;
		NAVvolume = _NAVvolume;
        COMMknob = _COMMknob;
		COMMvolume = _COMMvolume;
        swapCOMM = _swapCOMM;
        swapNAV = _swapNAV;
		#RANGEknob = _RANGEknob;
        joystick = _joystick;
		
#        joystick = void;
#        RANGEknob = void;
        setlistener("/gear/gear/wow", inAirCheckings, 0, 0);
#        fgcommand("reinit", props.Node.new({subsytem : "xml-autopilot"}));
        settimer(main_loop, 0);
    }
	if(getprop("/instrumentation/zkv1000/device["~abs(d - 1)~"]/status")==nil or getprop("/instrumentation/zkv1000/device["~abs(d - 1)~"]/status")==0 or getprop("/instrumentation/zkv1000/device["~abs(d - 1)~"]/status")==2){
		setprop("/instrumentation/zkv1000/device["~d~"]/status",1);
		device[d].goto(0);
	}else{
		setprop("/instrumentation/zkv1000/device["~d~"]/status",7);
		device[d].goto(15);
		device[d].setENTsoftkeyAction("enterStartup");
	}
	
	#on allume l'eis sur le mfd
	if(d==1){
		setprop("/instrumentation/zkv1000/device["~d~"]/eis-display",1);
	}
}

var powerOff = func (d) {
	if(getprop("/instrumentation/zkv1000/device["~d~"]/status")!=nil and getprop("/instrumentation/zkv1000/device["~d~"]/status")==0){
		return;
	}
	printf("zkv1000 %s switched off!", d == 0 ? "PFD" : "MFD");
	setprop("/instrumentation/zkv1000/device["~d~"]/status",0);
	if(getprop("/instrumentation/zkv1000/device["~abs(d - 1)~"]/status")!=nil and getprop("/instrumentation/zkv1000/device["~abs(d - 1)~"]/status")!=0){
		#if the other display shut off or fail, automatic bascule to primary display and eis display
		setprop("/instrumentation/zkv1000/device["~abs(d - 1)~"]/status",1);
		setprop("/instrumentation/zkv1000/device["~abs(d - 1)~"]/eis-display",1);
	}
	device[d] = nil;
	
	##RAZ alerts
	if(getprop("/instrumentation/zkv1000/device[0]/status")==0 and getprop("/instrumentation/zkv1000/device[1]/status")==0 ){
		setprop("/instrumentation/zkv1000/alerts/warning",0);
		setprop("/instrumentation/zkv1000/alerts/caution",0);
		setprop("/instrumentation/zkv1000/alerts/advisory",0);
	}
}

var checkPowerPfd = func{
	if(getprop("/instrumentation/zkv1000/device[0]/serviceable")!=nil and getprop("/instrumentation/zkv1000/device[0]/serviceable")==1){
		powerOn(0);
	}else{
		powerOff(0);
	}
}

var checkPowerMfd = func{
	if(getprop("/instrumentation/zkv1000/device[1]/serviceable")!=nil and getprop("/instrumentation/zkv1000/device[1]/serviceable")==1){
		powerOn(1);
	}else{
		powerOff(1);
	}
}

setlistener("/instrumentation/zkv1000/device[0]/serviceable",checkPowerPfd);
setlistener("/instrumentation/zkv1000/device[1]/serviceable",checkPowerMfd);

var toggleReversionaryMode = func {
	setprop("/instrumentation/zkv1000/device[0]/status",1);
	setprop("/instrumentation/zkv1000/device[0]/eis-display",1);
	setprop("/instrumentation/zkv1000/device[1]/status",1);
	setprop("/instrumentation/zkv1000/device[1]/eis-display",1);
}
