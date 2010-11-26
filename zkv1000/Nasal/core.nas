var main_loop_id = 0;
var loop_check_functions_max_index = 0;
var loop_check_functions = [];
var device = [nil, nil];
var deviceClass = {};

var init_main_loop = func {
    loop_check_functions = [
        pfdCursors,
        checkTrafficProximity,
        checkMarkerBaecon,
        moveMap,
        checkRollAquisition,
        checkPitchAquisition,
        pfdCursors,
        computeAltitudeDiff,
        computeAirspeedDiff,
        moveMap,
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
    m.local.getNode("brg1",1).setBoolValue(0);
    m.local.getNode("brg2",1).setBoolValue(0);
    m.local.getNode("dme",1).setBoolValue(0);
#    m.local.getNode("show-terrain", 1).setBoolValue(0);
#    m.local.getNode("show-objects", 1).setBoolValue(0);
#    m.local.getNode("show-navaids", 1).setBoolValue(0);
    m.local.getNode("hsi-360", 1).setBoolValue(1);
    if (d == 1 and device[0] != nil) {
        m.goto(12);
        m.local.getNode("status",1).setIntValue(2);
        RANGEknob = _RANGEknob;
        joystick = _joystick;
    }
    else {
        m.goto(0);
        m.local.getNode("status",1).setIntValue(1);
    }
    return m;
}

var powerOn = func (d) {
    device[d] = deviceClass.new(d);
    printf("zkv1000 %s switched on!", d == 0 ? "PFD" : "MFD");

    if (device[abs(d - 1)] == nil) {
        init_main_loop();
        ALTknob = _ALTknob;
        HDGknob = _HDGknob;
        CRSknob = _CRSknob;
        BAROknob = _BAROknob;
        NAVknob = _NAVknob;
        COMMknob = _COMMknob;
        swapCOMM = _swapCOMM;
        swapNAV = _swapNAV;
#        joystick = void;
#        RANGEknob = void;
        setlistener("/gear/gear/wow", inAirCheckings, 0, 0);
#        fgcommand("reinit", props.Node.new({subsytem : "xml-autopilot"}));
        settimer(main_loop, 0);
    }
}


