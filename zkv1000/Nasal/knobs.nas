deviceClass.softkey = func (key) {
    me.softkeyActionTable[me.local.getNode("menu-level").getValue()][key]();
}

var _ALTknob = func (x) {
    fgcommand("property-adjust", props.Node.new({
        property: "/instrumentation/zkv1000/afcs/selected-alt-ft",
        step: x,
        min: 0,
        max: 16000,
        wrap: 0
    }));
}

var _HDGknob = func (x) {
    if (x) fgcommand("property-adjust", props.Node.new({
        property: "/instrumentation/zkv1000/afcs/heading-bug-deg",
        step: x,
        min: 0,
        max: 360,
        wrap: 1
    }));
    else fgcommand("property-assign", props.Node.new({
        property: "/instrumentation/zkv1000/afcs/heading-bug-deg",
        property: "/orientation/heading-magnetic-deg"
    }));
}

var _CRSknob = func (x) {
    if (x) fgcommand("property-adjust", props.Node.new({
        property: "/instrumentation/zkv1000/cdi/course",
        step: x,
        min: 0,
        max: 360,
        wrap: 1
    }));
    else fgcommand("property-assign", props.Node.new({
        property: "/instrumentation/zkv1000/cdi/course",
        property: "/instrumentation/zkv1000/cdi/radial"
    }));
}

var _BAROknob = func (x) {
    fgcommand("property-adjust", props.Node.new({
        property: "/instrumentation/altimeter/setting-inhg",
        step: x,
        min: 28.50,
        max: 33.00,
        warp: 0
    }));
}

var _NAVknob = func (x) {
    if (x) fgcommand("property-adjust", props.Node.new({
        property: "/instrumentation/zkv1000/radios/nav-freq-mhz",
        step: x,
        min: 108.00,
        max: 118.00,
        wrap: 1
    }));
    else {
        fgcommand("property-toggle", props.Node.new({
        property: "/instrumentation/zkv1000/radios/nav-tune"
    }));
    }
}

var _COMMknob = func (x) {
    if (x) fgcommand("property-adjust", props.Node.new({
        property: "/instrumentation/zkv1000/radios/comm-freq-mhz",
        step: x,
        min: 118.00,
        max: 137.975,
        wrap: 1
    }));
    else fgcommand("property-toggle", props.Node.new({
        property: "/instrumentation/zkv1000/radios/comm-tune"
    }));
}

var _swapNAV = func {
    var n = getprop("/instrumentation/zkv1000/radios/nav-tune");
    var tmp = getprop("/instrumentation/nav[" ~ n ~ "]/frequencies/selected-mhz");
    setprop("/instrumentation/nav[" ~ n ~ "]/frequencies/selected-mhz", getprop("/instrumentation/nav[" ~ n ~ "]/frequencies/standby-mhz"));
    setprop("/instrumentation/nav[" ~ n ~ "]/frequencies/standby-mhz", tmp);
#   fgcommand("property-swap", props.Node.new({
#       property: "/instrumentation/nav[" ~ n ~ "]/frequencies/selected-mhz",
#       property: "/instrumentation/nav[" ~ n ~ "]/frequencies/standby-mhz"
#   }));
}

var _swapCOMM = func (emergency = 0) {
    if (emergency) {
        setprop("/instrumentation/comm/frequencies/selected-mhz", 121.500);
        setprop("/instrumentation/zkv1000/radios/comm1-selected", 1);
        setprop("/instrumentation/zkv1000/radios/comm2-selected", 0);
    }
    else {
        var c = getprop("/instrumentation/zkv1000/radios/comm-tune");
        var tmp = getprop("/instrumentation/comm[" ~ c ~ "]/frequencies/selected-mhz");
        setprop("/instrumentation/comm[" ~ c ~ "]/frequencies/selected-mhz", getprop("/instrumentation/comm[" ~ c ~ "]/frequencies/standby-mhz"));
        setprop("/instrumentation/comm[" ~ c ~ "]/frequencies/standby-mhz", tmp);
#       fgcommand("property-swap", props.Node.new({
#           property: "/instrumentation/comm[" ~ c ~ "]/frequencies/selected-mhz",
#           property: "/instrumentation/comm[" ~ c ~ "]/frequencies/standby-mhz"
#       }));
    }
}

var _joystick = func (xdir, ydir) {
    print("youpi");
    fgcommand(
        "property-adjust", props.Node.new({
        property: "/instrumentation/zkv1000/map/longitude-deg",
        step: mapRange * xdir,
        min: -180,
        max: 180,
        wrap: 1
    }));
    fgcommand(
        "property-adjust", props.Node.new({
        property: "/instrumentation/zkv1000/map/latitude-deg",
        step: mapRange * ydir,
        min: -80,
        max: 80,
        wrap: 0
    }));
}

var _RANGEknob= func (dir) {
    if (dir) {
        fgcommand(
            "property-adjust", props.Node.new({
            property: "/instrumentation/zkv1000/map/range-index",
            step: dir,
            min: 0,
            max: size(mapRanges),
            wrap: 1
        }));
        mapRange = mapRanges[getprop("/instrumentation/zkv1000/map/range-index")];
    }
    elsif (panningMap) {
        panningMap = 0;
        map.getNode("latitude-deg").alias("/position/latitude-deg");
        map.getNode("longitude-deg").alias("/position/longitude-deg");
        setprop("/instrumentation/zkv1000/map/aircraft-pos-x", 0);
        setprop("/instrumentation/zkv1000/map/aircraft-pos-y", 0);
    }
    else {
        panningMap = 1;
        map.getNode("latitude-deg").unalias();
        map.getNode("longitude-deg").unalias();
        map.getNode("longitude-deg").setDoubleValue(getprop("/position/longitude-deg"));
        map.getNode("latitude-deg").setDoubleValue(getprop("/position/latitude-deg"));
    }
    setprop("/instrumentation/zkv1000/map/panning", panningMap);
}

#var _largeFMSknob = void;
#var _smallFMSknob = void;
#var _ENTsoftkey = void;
#var _Dsoftkey = void;
