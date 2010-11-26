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
var COMMknob = void;
var swapCOMM = void;
var swapNAV = void;
var joystick = void;
var RANGEknob = void;

