var vs_gearup = 300;
var ias_gearup = 90;
var agl_geardown = 1000;
var ias_geardown = 100;
var VNE = 194;
var NB_ALERTS_DISPLAY = 7;

var inAirCheckings = func {
    if (getprop("/gear/gear/wow")) {
        alerts.getNode("traffic-proximity").setIntValue(0);
        checkTrafficProximity = void;
        checkAbnormalAttitude = void;
        manageLandingGears = void;
        setprop("/instrumentation/zkv1000/radios/xpdr-mode","GND"); # set XPDR mode
    }
    else {
        #if (multiplayer.is_active()) checkTrafficProximity = _checkTrafficProximity;
	checkTrafficProximity = _checkTrafficProximity;
        checkAbnormalAttitude = _checkAbnormalAttitude;
        manageLandingGears = _gearsUp;
        setprop("/instrumentation/zkv1000/radios/xpdr-mode","ALT"); #set XPDR mode
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
            #foreach (var p; device) p == nil or p.local.getNode("status").setIntValue(1);
            joystick = void;
            RANGEknob = void;
            break;
        }
    }
}

var getAlert = func(no){
	var result = 0;
	if(getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~no~"]/active")!=nil){
		result = getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~no~"]/active");
	}
	return result;
}

var setAlert = func(no,state){
	setprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~no~"]/active",state);
}

var checkAlerts = func{
	##zkv1000 off
	if(getprop("/instrumentation/zkv1000/serviceable")==0){
		return;
	}
	
	##calculate alerts
	var warning = getprop("/instrumentation/zkv1000/alerts/warning");
	var caution = getprop("/instrumentation/zkv1000/alerts/caution");
	var advisory = getprop("/instrumentation/zkv1000/alerts/advisory");
	var last_state = 0;
	
	##doors
	last_state = getAlert(0);
	if((getprop("/instrumentation/doors/crew/position-norm")!=nil and getprop("/instrumentation/doors/crew/position-norm")>0)
			or (getprop("/controls/doors/door[0]/locked")!=nil and getprop("/controls/doors/door[0]/locked")>0)
			or (getprop("/instrumentation/doors/passenger/position-norm")!=nil and getprop("/instrumentation/doors/passenger/position-norm")>0)
			or (getprop("/controls/doors/door[1]/locked")!=nil and getprop("/controls/doors/door[1]/locked")>0)
			or (getprop("/instrumentation/doors/leftbagage/position-norm")!=nil and getprop("/instrumentation/doors/leftbagage/position-norm")>0)
			or (getprop("/controls/doors/door[2]/locks/lock[0]/locked")!=nil and getprop("/controls/doors/door[2]/locks/lock[0]/locked")>0)
			or (getprop("/controls/doors/door[2]/locks/lock[1]/locked")!=nil and getprop("/controls/doors/door[2]/locks/lock[1]/locked")>0)
			or (getprop("/instrumentation/doors/rightbagage/position-norm")!=nil and getprop("/instrumentation/doors/rightbagage/position-norm")>0)
			or (getprop("/controls/doors/door[3]/locks/lock[0]/locked")!=nil and getprop("/controls/doors/door[3]/locks/lock[0]/locked")>0)
			or (getprop("/controls/doors/door[3]/locks/lock[1]/locked")!=nil and getprop("/controls/doors/door[3]/locks/lock[1]/locked")>0)
		){
		if(last_state==0){
			warning = 1;
			setAlert(0,1);
		}
	}else{
		if(last_state==1){
			setAlert(0,0);
		}
	}
	
	##left alternator
	last_state = getAlert(1);
	if(getprop("/systems/electrical/bus/left-main-bus")!=nil and getprop("/systems/electrical/bus/left-main-bus")<28 and getprop("/engines/engine[0]/running")==1 and getprop("/engines/engine[0]/rpm")>610){
		if(last_state==0){
			warning = 1;
			setAlert(1,1);
		}
	}else{
		if(last_state==1){
			setAlert(1,0);
		}
	}
	
	##right alternator
	last_state = getAlert(2);
	if(getprop("/systems/electrical/bus/right-main-bus")!=nil and getprop("/systems/electrical/bus/right-main-bus")<28 and getprop("/engines/engine[1]/running")==1 and getprop("/engines/engine[1]/rpm")>610){
		if(last_state==0){
			warning = 1;
			setAlert(2,1);
		}
	}else{
		if(last_state==1){
			setAlert(2,0);
		}
	}
	
	##left oil pressure
	last_state = getAlert(3);
	if(getprop("/engines/engine[0]/oil-pressure-psi")!=nil and getprop("/engines/engine[0]/oil-pressure-psi")<1 and getprop("/engines/engine[0]/running")==1 and getprop("/engines/engine[0]/rpm")>610){
		if(last_state==0){
			warning = 1;
			setAlert(3,1);
		}
	}else{
		if(last_state==1){
			setAlert(3,0);
		}
	}
	
	##right oil pressure
	last_state = getAlert(4);
	if(getprop("/engines/engine[1]/oil-pressure-psi")!=nil and getprop("/engines/engine[1]/oil-pressure-psi")<1 and getprop("/engines/engine[1]/running")==1 and getprop("/engines/engine[1]/rpm")>610){
		if(last_state==0){
			warning = 1;
			setAlert(4,1);
		}
	}else{
		if(last_state==1){
			setAlert(4,0);
		}
	}
	
	##left starter
	last_state = getAlert(5);
	if(getprop("/controls/engines/engine[0]/starter")==1 and getprop("/engines/engine[0]/running")==1 and getprop("/engines/engine[0]/rpm")>100){
		if(last_state==0){
			warning = 1;
			setAlert(5,1);
		}
	}else{
		if(last_state==1){
			setAlert(5,0);
		}
	}
	
	##right starter
	last_state = getAlert(6);
	if(getprop("/controls/engines/engine[1]/starter")==1 and getprop("/engines/engine[1]/running")==1 and getprop("/engines/engine[1]/rpm")>100){
		if(last_state==0){
			warning = 1;
			setAlert(6,1);
		}
	}else{
		if(last_state==1){
			setAlert(6,0);
		}
	}
	
	##airspeed fail 
	last_state = getAlert(7);
	if(getprop("/instrumentation/adc/serviceable")==0){
		if(last_state==0){
			warning = 1;
			setAlert(7,1);
		}
	}else{
		if(last_state==1){
			setAlert(7,0);
		}
	}
	
	##altitude fail 
	last_state = getAlert(8);
	if(getprop("/instrumentation/adc/serviceable")==0){
		if(last_state==0){
			warning = 1;
			setAlert(8,1);
		}
	}else{
		if(last_state==1){
			setAlert(8,0);
		}
	}
	
	##attitude fail starter
	last_state = getAlert(9);
	if(getprop("/instrumentation/ahrs/serviceable")==0){
		if(last_state==0){
			warning = 1;
			setAlert(9,1);
		}
	}else{
		if(last_state==1){
			setAlert(9,0);
		}
	}
	
	##hdg fail starter
	last_state = getAlert(10);
	if(getprop("/instrumentation/ahrs/serviceable")==0){
		if(last_state==0){
			warning = 1;
			setAlert(10,1);
		}
	}else{
		if(last_state==1){
			setAlert(10,0);
		}
	}
	
	##left engine temp
	last_state = getAlert(11);
	if(getprop("/engines/engine[0]/coolant-temperature-degc")!=nil and getprop("/engines/engine[0]/coolant-temperature-degc")>105){
		if(last_state==0){
			warning = 1;
			setAlert(11,1);
		}
	}else{
		if(last_state==1){
			setAlert(11,0);
		}
	}
	
	##right engine temp
	last_state = getAlert(12);
	if(getprop("/engines/engine[1]/coolant-temperature-degc")!=nil and getprop("/engines/engine[1]/coolant-temperature-degc")>105){
		if(last_state==0){
			warning = 1;
			setAlert(12,1);
		}
	}else{
		if(last_state==1){
			setAlert(12,0);
		}
	}
	
	##left oil temp
	last_state = getAlert(13);
	if(getprop("/engines/engine[0]/oil-temperature-degc")!=nil and getprop("/engines/engine[0]/oil-temperature-degc")>140){
		if(last_state==0){
			warning = 1;
			setAlert(13,1);
		}
	}else{
		if(last_state==1){
			setAlert(13,0);
		}
	}
	
	##right oil temp
	last_state = getAlert(14);
	if(getprop("/engines/engine[1]/oil-temperature-degc")!=nil and getprop("/engines/engine[1]/oil-temperature-degc")>140){
		if(last_state==0){
			warning = 1;
			setAlert(14,1);
		}
	}else{
		if(last_state==1){
			setAlert(14,0);
		}
	}
	
	##left fuel temp
	last_state = getAlert(15);
	if(getprop("/engines/engine[0]/fuel-temperature-degc")!=nil and getprop("/engines/engine[0]/fuel-temperature-degc")>75){
		if(last_state==0){
			warning = 1;
			setAlert(15,1);
		}
	}else{
		if(last_state==1){
			setAlert(15,0);
		}
	}
	
	##right fuel temp
	last_state = getAlert(16);
	if(getprop("/engines/engine[1]/fuel-temperature-degc")!=nil and getprop("/engines/engine[1]/fuel-temperature-degc")>75){
		if(last_state==0){
			warning = 1;
			setAlert(16,1);
		}
	}else{
		if(last_state==1){
			setAlert(16,0);
		}
	}
	
	##xpdr fail
	last_state = getAlert(17);
	if(getprop("/instrumentation/transponder/serviceable")==0){
		if(last_state==0){
			warning = 1;
			setAlert(17,1);
		}
	}else{
		if(last_state==1){
			setAlert(17,0);
		}
	}
	
	##deice low
	last_state = getAlert(18);
	if(getprop("/consumables/deice")<3000){##30%
		if(last_state==0){
			caution = 1;
			setAlert(18,1);
		}
	}else{
		if(last_state==1){
			setAlert(18,0);
		}
	}
	
	##left fuel low
	last_state = getAlert(19);
	if(getprop("/consumables/fuel/tank[0]/level-gal_us")<5){
		if(last_state==0){
			caution = 1;
			setAlert(19,1);
		}
	}else{
		if(last_state==1){
			setAlert(19,0);
		}
	}
	
	##right fuel low
	last_state = getAlert(20);
	if(getprop("/consumables/fuel/tank[1]/level-gal_us")<5){
		if(last_state==0){
			caution = 1;
			setAlert(20,1);
		}
	}else{
		if(last_state==1){
			setAlert(20,0);
		}
	}
	
	## pitot heat fail
	last_state = getAlert(21);
	if(getprop("/instrumentation/pitot-heat/serviceable")==0){
		if(last_state==0){
			caution = 1;
			setAlert(21,1);
		}
	}else{
		if(last_state==1){
			setAlert(21,0);
		}
	}
	
	## pitot heat off
	last_state = getAlert(22);
	if(getprop("/instrumentation/pitot-heat/active")==0){
		if(last_state==0){
			caution = 1;
			setAlert(22,1);
		}
	}else{
		if(last_state==1){
			setAlert(22,0);
		}
	}
	
	## left ecu a failed
	last_state = getAlert(23);
	if(getprop("/controls/electric/alimentation/engines/engine[0]/ecus/ecu[0]/serviceable")==0 or getprop("/controls/electric/alimentation/engines/engine[0]/ecus/ecu[0]/test-ecu")==1){
		if(last_state==0){
			caution = 1;
			setAlert(23,1);
		}
	}else{
		if(last_state==1){
			setAlert(23,0);
		}
	}
	
	## left ecu b failed
	last_state = getAlert(24);
	if(getprop("/controls/electric/alimentation/engines/engine[0]/ecus/ecu[1]/serviceable")==0 or getprop("/controls/electric/alimentation/engines/engine[0]/ecus/ecu[1]/test-ecu")==1){
		if(last_state==0){
			caution = 1;
			setAlert(24,1);
		}
	}else{
		if(last_state==1){
			setAlert(24,0);
		}
	}
	
	## right ecu a failed
	last_state = getAlert(25);
	if(getprop("/controls/electric/alimentation/engines/engine[1]/ecus/ecu[0]/serviceable")==0 or getprop("/controls/electric/alimentation/engines/engine[1]/ecus/ecu[0]/test-ecu")==1){
		if(last_state==0){
			caution = 1;
			setAlert(25,1);
		}
	}else{
		if(last_state==1){
			setAlert(25,0);
		}
	}
	
	## right ecu b failed
	last_state = getAlert(26);
	if(getprop("/controls/electric/alimentation/engines/engine[1]/ecus/ecu[1]/serviceable")==0 or getprop("/controls/electric/alimentation/engines/engine[1]/ecus/ecu[1]/test-ecu")==1){
		if(last_state==0){
			caution = 1;
			setAlert(26,1);
		}
	}else{
		if(last_state==1){
			setAlert(26,0);
		}
	}
	
	## comm1 failed
	last_state = getAlert(27);
	if(getprop("/instrumentation/comm[0]/serviceable")==0 or getprop("/instrumentation/comm[0]/power-btn")==0){
		if(last_state==0){
			caution = 1;
			setAlert(27,1);
		}
	}else{
		if(last_state==1){
			setAlert(27,0);
		}
	}
	
	## comm2 failed
	last_state = getAlert(28);
	if(getprop("/instrumentation/comm[1]/serviceable")==0 or getprop("/instrumentation/comm[1]/power-btn")==0){
		if(last_state==0){
			caution = 1;
			setAlert(28,1);
		}
	}else{
		if(last_state==1){
			setAlert(28,0);
		}
	}
	
	## nav1 failed
	last_state = getAlert(29);
	if(getprop("/instrumentation/nav[0]/serviceable")==0 or getprop("/instrumentation/nav[0]/power-btn")==0){
		if(last_state==0){
			caution = 1;
			setAlert(29,1);
		}
	}else{
		if(last_state==1){
			setAlert(29,0);
		}
	}
	
	## nav2 failed
	last_state = getAlert(30);
	if(getprop("/instrumentation/nav[1]/serviceable")==0 or getprop("/instrumentation/nav[1]/power-btn")==0){
		if(last_state==0){
			caution = 1;
			setAlert(30,1);
		}
	}else{
		if(last_state==1){
			setAlert(30,0);
		}
	}
	
	## gps1 failed (in the real da42, threre are 2 gps...
	last_state = getAlert(31);
	if(getprop("/instrumentation/gps/serviceable")==0 or getprop("/instrumentation/gps/power-btn1")==0){
		if(last_state==0){
			caution = 1;
			setAlert(31,1);
		}
	}else{
		if(last_state==1){
			setAlert(31,0);
		}
	}
	
	## gps2 failed (in the real da42, threre are 2 gps...
	last_state = getAlert(32);
	if(getprop("/instrumentation/gps/serviceable")==0 or getprop("/instrumentation/gps/power-btn2")==0){
		if(last_state==0){
			caution = 1;
			setAlert(32,1);
		}
	}else{
		if(last_state==1){
			setAlert(32,0);
		}
	}
	
	## adf failed
	last_state = getAlert(33);
	if(getprop("/instrumentation/adf/serviceable")==0 or getprop("/instrumentation/adf/power-btn")==0){
		if(last_state==0){
			caution = 1;
			setAlert(33,1);
		}
	}else{
		if(last_state==1){
			setAlert(33,0);
		}
	}
	
	## dme failed
	last_state = getAlert(34);
	if(getprop("/instrumentation/dme/serviceable")==0 or getprop("/instrumentation/dme/power-btn")==0){
		if(last_state==0){
			caution = 1;
			setAlert(34,1);
		}
	}else{
		if(last_state==1){
			setAlert(34,0);
		}
	}
	
	##mfd fan fail
	last_state = getAlert(35);
	if(getprop("/instrumentation/zkv1000/fans/serviceable")==0){
		if(last_state==0){
			advisory = 1;
			setAlert(35,1);
		}
	}else{
		if(last_state==1){
			setAlert(35,0);
		}
	}
	
	##pfd fan fail
	last_state = getAlert(36);
	if(getprop("/instrumentation/zkv1000/fans/serviceable")==0){
		if(last_state==0){
			advisory = 1;
			setAlert(36,1);
		}
	}else{
		if(last_state==1){
			setAlert(36,0);
		}
	}
	
	setprop("/instrumentation/zkv1000/alerts/warning",warning);
	setprop("/instrumentation/zkv1000/alerts/caution",caution);
	setprop("/instrumentation/zkv1000/alerts/advisory",advisory);

	##display alerts
	var nbLignes = 0;
	
	var alerts = alerts.getNode("alerts-list").getChildren();
	for(var i=0;i<size(alerts);i=i+1){
		if(getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/active")==1 and nbLignes<NB_ALERTS_DISPLAY){
			setprop("/instrumentation/zkv1000/alerts/display-list/line["~nbLignes~"]/active",1);
			setprop("/instrumentation/zkv1000/alerts/display-list/line["~nbLignes~"]/level",getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/level"));
			setprop("/instrumentation/zkv1000/alerts/display-list/line["~nbLignes~"]/label",getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/label"));
			nbLignes = nbLignes + 1;
		}
	}
	
	for(var i=nbLignes;i<NB_ALERTS_DISPLAY;i=i+1){
		setprop("/instrumentation/zkv1000/alerts/display-list/line["~i~"]/active",0);
	}
	if(nbLignes>NB_ALERTS_DISPLAY){
		nbLignes = NB_ALERTS_DISPLAY;
	}
	setprop("/instrumentation/zkv1000/alerts/nbinfos",nbLignes);
}

var calc_pos_alerts_infos = func{
	var nbinfos = getprop("/instrumentation/zkv1000/alerts/nbinfos");
	var pos = 3 - nbinfos;#limitation a 6 alerts
	setprop("/instrumentation/zkv1000/alerts/posinfos",pos);
}
setlistener("/instrumentation/zkv1000/alerts/nbinfos",calc_pos_alerts_infos);

