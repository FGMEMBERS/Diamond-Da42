var xpdr_digits = 1;
var xpdr_id_timer = 0;
var tofromflag = nil;

var radios_list = [
    "/instrumentation/nav/frequencies/standby-mhz",
    "/instrumentation/nav[1]/frequencies/standby-mhz",
    "/instrumentation/nav/frequencies/selected-mhz",
    "/instrumentation/nav[1]/frequencies/selected-mhz",
    "/instrumentation/comm/frequencies/standby-mhz",
    "/instrumentation/comm[1]/frequencies/standby-mhz",
    "/instrumentation/comm/frequencies/selected-mhz",
    "/instrumentation/comm[1]/frequencies/selected-mhz",
];

foreach (var r; radios_list) props.globals.getNode(r ~ "-dec",1).setIntValue(0);

var setNavTune = func {
    var freq = radios.getNode("nav-freq-mhz", 1);
    freq.unalias();
    freq.alias(radios_list[getprop("/instrumentation/zkv1000/radios/nav-tune")]);
}

var setCommTune = func {
    var freq = radios.getNode("comm-freq-mhz", 1);
    freq.unalias();
    freq.alias(radios_list[getprop("/instrumentation/zkv1000/radios/comm-tune") + 4]);
}

var XPDR_change_cursor_position = func (dir) {
    xpdr_digits = (xpdr_digits == 1)? 100 : 1;
    xpdr_id_timer += 1;
    settimer(func { ENTsoftkey(1) }, 10);
}

var XPDR_enter_digits = func (dir) {
    var code = getprop("/instrumentation/transponder/id-code");
    var c = substr(sprintf("%04i", code), (xpdr_digits == 1)? 2 : 0, 2);
    if (dir > 0) {
    if (c[0] == `7`and c[1] == `7`) {
        dir = -77;
    }
    elsif (c[1] == `7`) {
        dir = 3;
    }
    }
    else {
    if (c[0] == `0` and c[1] == `0`) {
        dir = 77;
    }
    elsif (c[1] == `0`) {
        dir = -3;
    }
    }
    setprop("/instrumentation/transponder/id-code", code + (dir * xpdr_digits));
    xpdr_id_timer += 1;
    settimer(func { ENTsoftkey(1) }, 10);
}

var XPDR_activate_code = func (timer = 0) {
    if (timer) {
    xpdr_id_timer -= 1;
    xpdr_id_timer == 0 or return;
    }
    #goto(0);
    largeFMSknob = void;
    smallFMSknob = void;
    ENTsoftkey = void;
}

var checkMarkerBeacon = func {
    if (getprop("/instrumentation/marker-beacon/inner")) {
        alerts.getNode("marker-beacon").setIntValue(1);
    }
    elsif (getprop("/instrumentation/marker-beacon/middle")) {
        alerts.getNode("marker-beacon").setIntValue(2);
    }
    elsif (getprop("/instrumentation/marker-beacon/outer")) {
        alerts.getNode("marker-beacon").setIntValue(3);
    }
    else {
        alerts.getNode("marker-beacon").setIntValue(0);
    }
}