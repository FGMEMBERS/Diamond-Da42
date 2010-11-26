var course_timer = hdg_timer = asel_timer = 0;

var pfdCursors = func {
    setprop("/instrumentation/zkv1000/infos/ktas", aircraft.kias_to_ktas(ias, alt));
    cursors.getNode("alt[0]").setIntValue((alt >= 10000)? 0 : 1);
    cursors.getNode("alt[1]").setIntValue((alt >=  1000)? 0 : 1);
    cursors.getNode("alt[2]").setIntValue((alt >=   100)? 0 : 1);
    cursors.getNode("ias[0]").setIntValue((ias >=   100)? 0 : 1);
    cursors.getNode("ias[1]").setIntValue((ias >=    10)? 0 : 1);
    cursors.getNode("ias[2]").setIntValue(0);
    if (ias > VNE) {
        cursors.getNode("ias[0]").setIntValue(-4);
        cursors.getNode("ias[1]").setIntValue(-4);
        cursors.getNode("ias[2]").setIntValue(-4);
    }
    wind_infos();
    setprop("/instrumentation/zkv1000/infos/time", sprintf("%02i %02i %02i",
                getprop("/sim/time/real/hour"),
                getprop("/sim/time/real/minute"),
                getprop("/sim/time/real/second")));
    setprop('/instrumentation/zkv1000/eis/circle[0]', getprop('/engines/engine/mp-osi') / 30);
    setprop('/instrumentation/zkv1000/eis/circle[1]', getprop('/engines/engine/rpm') / 2600);
    setprop('/instrumentation/zkv1000/eis/bar[0]', getprop('/engines/engine/fuel-flow-gph') / 26.67);
    setprop('/instrumentation/zkv1000/eis/bar[2]', getprop('/engines/engine/oil-temperature-degf') / 250);
    setprop('/instrumentation/zkv1000/eis/bar[7]', getprop('/consumables/fuel/tank/level-gal_us') / 18);
    setprop('/instrumentation/zkv1000/eis/bar[8]', getprop('/consumables/fuel/tank[1]/level-gal_us') / 18);
}

var withdraw_course_info = func {
    course_timer -= 1;
    course_timer == 0 or return;
    setprop("/instrumentation/zkv1000/infos/course", 0);
}

var popup_course_info = func {
    getprop("/instrumentation/zkv1000/cdi/visible") or return;
    setprop("/instrumentation/zkv1000/infos/course", 1);
    course_timer += 1;
    settimer(withdraw_course_info, 10);
}

var withdraw_hdg_info = func {
    hdg_timer -= 1;
    hdg_timer == 0 or return;
    setprop("/instrumentation/zkv1000/infos/heading", 0);
}

var popup_hdg_info = func {
    setprop("/instrumentation/zkv1000/infos/heading", 1);
    hdg_timer += 1;
    settimer(withdraw_hdg_info, 10);
}

var withdraw_selected_alt = func {
    asel_timer -= 1;
    asel_timer == 0 or return;
    setprop("/instrumentation/zkv1000/afcs/alt-bug-visible", getprop("/instrumentation/zkv1000/afcs/fd-bars-visible"));
}

var popup_selected_alt = func {
    setprop("/instrumentation/zkv1000/afcs/alt-bug-visible", 1);
    _computeAltitudeDiff();
    asel_timer += 1;
    settimer(withdraw_selected_alt, 10);
}


