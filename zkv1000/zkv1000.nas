var zkv = cdi = radios = alerts = infos = cursors = afcs = map = mud = eis = nil;

var init_props = func {
    zkv = props.globals.getNode("/instrumentation/zkv1000",1);
    zkv.getNode("emission",1).setDoubleValue(0.5);
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
    infos.getNode("dme-line",1).setValue("");
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
    for (var i = 0; i <= 8; i += 1) eis.getNode("bar["~i~"]", 1).setDoubleValue(0.0);

    mud = zkv.getNode("mud", 1);
    mud.getNode("displayed", 1).setBoolValue(0);
    mud.getNode("title", 1).setValue("");
    mud.getNode("selected-block", 1).setIntValue(0);
    mud.getNode("first-displayed-block", 1).setIntValue(0);
    mud.getNode("last-displayed-block", 1).setIntValue(0);
    for (var i = 0; i < maxMUDlines; i += 1) {
        mud.getNode("line[" ~ i ~ "]", 1).setValue("");
        mud.getNode("sel-line[" ~ i ~ "]", 1).setBoolValue(0);
    }

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
}

var set_listeners = func {
    setlistener("/instrumentation/nav[0]/radials/selected-deg", popup_course_info,  0, 0);
    setlistener("/instrumentation/nav[1]/radials/selected-deg", popup_course_info,  0, 0);
    setlistener("/instrumentation/zkv1000/afcs/heading-bug-deg",popup_hdg_info,     0, 0);
    setlistener("/instrumentation/zkv1000/afcs/selected-alt-ft",popup_selected_alt, 0, 0);
    setlistener("/instrumentation/zkv1000/radios/nav-tune",     setNavTune,         0, 0);
    setlistener("/instrumentation/zkv1000/radios/comm-tune",    setCommTune,        0, 0);
}

var load_nasal = func {
    var zkv1000_dir = getprop("/sim/fg-root") ~ "/Aircraft/Diamond-Da42/zkv1000/Nasal/";
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
    init_AFCS();
    init_map();
    set_listeners();
    print("zkv1000 loaded");
}

setlistener("/sim/signals/fdm-initialized", zkv1000_init, 0, 0);

