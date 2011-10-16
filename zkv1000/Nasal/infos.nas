var wind_opt1 = func () {
    if (ias > 50) {
        var n = getprop("/environment/wind-from-north-fps") * 0.59248;
        var e = getprop("/environment/wind-from-east-fps") * 0.59248;
        setprop("/instrumentation/zkv1000/infos/wind-line", n > 0 ?
                sprintf("N %i", n)
               :sprintf("S %i", -n));
        setprop("/instrumentation/zkv1000/infos/wind-line[1]", e > 0 ?
                sprintf("E %i", e)
               :sprintf("W %i", -e));
    }
    else {
        setprop("/instrumentation/zkv1000/infos/wind-line", "WIND");
        setprop("/instrumentation/zkv1000/infos/wind-line[1]", "DATA");
    }
}

var wind_opt2 = func () {
    if (ias > 50) {
        setprop("/instrumentation/zkv1000/infos/wind-line", sprintf("SPD %i", getprop("/environment/wind-speed-kt")));
        setprop("/instrumentation/zkv1000/infos/wind-line[1]", sprintf("DIR %03i", getprop("/environment/wind-from-heading-deg")));
    }
    else {
        setprop("/instrumentation/zkv1000/infos/wind-line", "WIND");
        setprop("/instrumentation/zkv1000/infos/wind-line[1]", "DATA");
    }
}

var wind_opt3 = func () {
    if (ias > 50) {
        var n = getprop("/environment/wind-from-north-fps") * 0.59248;
        var e = getprop("/environment/wind-from-north-fps") * 0.59248;
        var h = getprop("/orientation/heading-magnetic-deg") * D2R;
        var f = e * math.cos(h) - n * math.sin(h);
        var x = n * math.cos(h) + e * math.sin(h);
        setprop("/instrumentation/zkv1000/infos/wind-line", f > 0 ?
                sprintf("HD %i", f)
               :sprintf("RR %i", -f));
        setprop("/instrumentation/zkv1000/infos/wind-line[1]", x > 0 ?
                sprintf("XR %i", x)
               :sprintf("XL %i", -x));
    }
    else {
        setprop("/instrumentation/zkv1000/infos/wind-line", "WIND");
        setprop("/instrumentation/zkv1000/infos/wind-line[1]", "DATA");
    }
}

var wind_infos = void;
