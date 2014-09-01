var vs_gearup = 300;
var ias_gearup = 90;
var agl_geardown = 1000;
var ias_geardown = 100;
var VNE = 240;

var inAirCheckings = func {
    if (getprop("/gear/gear/wow")) {
        alerts.getNode("traffic-proximity").setIntValue(0);
        checkTrafficProximity = void;
        checkAbnormalAttitude = void;
        manageLandingGears = void;
        GND(); # set XPDR mode
    }
    else {
        if (multiplayer.is_active()) checkTrafficProximity = _checkTrafficProximity;
        checkAbnormalAttitude = _checkAbnormalAttitude;
        manageLandingGears = _gearsUp;
        ALT(); #set XPDR mode
    }
    init_main_loop();
}

var _checkTrafficProximity = func {
    var dist = 0;
    var self = geo.aircraft_position();
    foreach (var mp; multiplayer.model.list) {
        var n = mp.node;
        var x = n.getNode("position/global-x").getValue();
        var y = n.getNode("position/global-y").getValue();
        var z = n.getNode("position/global-z").getValue();
        var ac = geo.Coord.new().set_xyz(x, y, z);
        dist = self.direct_distance_to(ac);
        if (dist < 2000) {
            alerts.getNode("traffic-proximity").setIntValue(2);
            break;
        }
    elsif (dist < 6000) {
        alerts.getNode("traffic-proximity").setIntValue(1);
    }
    else
        alerts.getNode("traffic-proximity").setIntValue(0);
    }
}

var _gearsUp = func {
    #if (vs > vs_gearup and ias > ias_gearup) {
    #   controls.gearDown(-1);
    #    if (agl > agl_geardown) {
    #        manageLandingGears = _gearsDown;
    #        init_main_loop();
    #    }
    #}
    #else
    #    controls.gearDown(1);
}

var _gearsDown = func {
    #if (agl < agl_geardown and ias < ias_geardown) {
    #   controls.gearDown(1);
    #    manageLandingGears = _gearsUp;
    #    init_main_loop();
    #}
}

var AbnormalAttitudes = [
    func { return stall },
    func { return pitch > 50 },
    func { return pitch < -30 },
    func { return abs(roll) > 60 },
    func { return (agl < 1500 and vs < -800)},
    func { return vs < -3000 }
];


var _checkAbnormalAttitude = func {
    var alert = 9999;
    for (var c = 0; c < size(AbnormalAttitudes); c += 1) {
        if (AbnormalAttitudes[c]()) {
            animeCursors = pfdCursors;
            setPitchMode("", 0);
            #init_main_loop(); # already called by setPitchMode
            foreach (var p; device) p == nil or p.local.getNode("status").setIntValue(1);
            joystick = void;
            RANGEknob = void;
            break;
        }
    }
}
