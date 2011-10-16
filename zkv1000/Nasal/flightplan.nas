var gps = props.globals.getNode("/instrumentation/gps/", 1);
var cmd = gps.getNode("command", 1);
var scratch = gps.getNode("scratch");
var flightplan = gps.getNode("flightplan", 1);

scratch.getNode("exact", 1).setBoolValue(0);
var searchType = scratch.getNode("type", 1);
var searchQuery = scratch.getNode("query", 1);
var searchMax = scratch.getNode("max-results", 1);

var flightplan_vector = [];

var copy_scratch = func {
    var s = "/instrumentation/gps/scratch/";
    var dest = geo.Coord.new();
    dest.set_latlon(getprop(s ~ "latitude-deg"), getprop(s ~ "longitude-deg"), getprop(s ~ "altitude-ft"));
    dest["name"] = getprop(s ~ "name");
    dest["ident"] = getprop(s ~ "ident");
    dest["frequency-mhz"] = getprop(s ~ "frequency-mhz");
    return dest;
}

var build = func (from, to) {
    var dist = from.distance_to(to) / 2;
    var course = from.course_to(to);
    var midpoint = geo.Coord.new(from).apply_course_distance(course, dist);

    scratch.getNode("latitude-deg").setDoubleValue(midpoint.lat());
    scratch.getNode("longitude-deg").setDoubleValue(midpoint.lon());
    searchType.setValue("fix");
    searchMax.setIntValue(1);
    cmd.setValue("nearest");
    
    var wp = copy_scratch();

    wp.distance_to(to) > 18520 or return;
    wp.distance_to(from) > 18520 or return;
    abs(from.course_to(wp) - wp.course_to(to)) < 30 or return;

    build(from, wp);
    append(flightplan_vector, wp);
    build(wp, to);
}

var new_flightplan = func {
    flightplan_vector = [];
    flightplan.removeChildren("wp");

    print("LFBT->LFPT");
    searchType.setValue("airport");
    searchQuery.setValue("lfbt");
    cmd.setValue("search");
    var departure = copy_scratch();

    searchType.setValue("airport");
    searchQuery.setValue("kgcn");
    cmd.setValue("search");
    var destination = copy_scratch();

    print("building flightplan");

    var begin = getprop("/sim/time/elapsed-sec");

    append(flightplan_vector, departure);
    build(departure, destination);
    append(flightplan_vector, destination);

    var end = getprop("/sim/time/elapsed-sec");
    print(end, " ", begin);

    for (var i = 0; i < size(flightplan_vector); i += 1) {
        print(flightplan_vector[i].ident);
    }

    flightplan_vector = departure = destination = nil;
    print("flightplan complete");
}
