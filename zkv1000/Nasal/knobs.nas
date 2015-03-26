deviceClass.softkey = func (key) {
    me.softkeyActionTable[me.local.getNode("menu-level").getValue()][key]();
}


deviceClass.FPLsoftkey = func {
    me.FPL();
}

deviceClass.Dsoftkey = func {
	me.D();
}

var knobsClass = {
    new: func (node) {
        var m = { parents: [ knobsClass ] };
        m.map = node.getNode("map", 1);
        m.map_path = m.map.getPath();
        m.node = node;
        return m;
    },

    joystick: func (xdir, ydir) {
        var coef = mapRanges[getprop(me.map_path ~ "/range-index")];
        fgcommand(
            "property-adjust", props.Node.new({
            property: me.map_path ~ "/longitude-deg",
            step: coef * xdir,
            min: -180,
            max: 180,
            wrap: 1
        }));
        fgcommand(
            "property-adjust", props.Node.new({
            property: me.map_path ~ "/latitude-deg",
            step: coef * ydir,
            min: -80,
            max: 80,
            wrap: 0
        }));
    },

    RANGEknob: void,

	##stockage of the actions in the tree properties, i don t succeed the functions largeFMSknob associations to work ...
    largeFMSknob: func(dir){
		var action = me.getLargeFMSknobAction();
		if(action=="void"){
			##no action
		}elsif(action=="select"){
			me.mud.select(me.mud, dir);
		}elsif(action=="selectSearchType"){
			me.selectSearchType(dir);
		}elsif(action=="XPDR_change_cursor_position"){
			XPDR_change_cursor_position();
		}elsif(action=="select10"){
			me.mud.select(me.mud, dir*10);
		}elsif(action=="selectD_letterChange"){
			me.selectD_letterChange(dir);
		}elsif(action=="selectD_select10"){
			me.selectD_select10(dir);
		}
	},
	
	setLargeFMSknobAction: func(action){
		me.local.getNode("menu-action",1).getNode("largeKnobAction",1).setValue(action);
	},
	
	getLargeFMSknobAction: func {
		return me.local.getNode("menu-action",1).getNode("largeKnobAction",1).getValue();
	},

    smallFMSknob: func(dir){
		var action = me.getsmallFMSknobAction();
		if(action=="void"){
			##no action
		}elsif(action=="select"){
			me.mud.select(me.mud, dir);
		}elsif(action=="changeAdfDmeValues"){
			me.changeAdfDmeValues(me.mud.getSelectedBlock(), dir);
		}elsif(action=="changeNRST"){
			me.changeNRST(dir);
		}elsif(action=="XPDR_enter_digits"){
			XPDR_enter_digits();
		}elsif(action=="selectD_letterIncrease"){
			me.selectD_letterIncrease(dir);
		}elsif(action=="selectD_select"){
			me.selectD_select(dir);
		}
	},
	
	setSmallFMSknobAction: func(action){
		me.local.getNode("menu-action",1).getNode("smallKnobAction",1).setValue(action);
	},
	
	getsmallFMSknobAction: func {
		return me.local.getNode("menu-action",1).getNode("smallKnobAction",1).getValue();
	},

    ENTsoftkey: func{
		var action = me.getENTsoftkeyAction();
		if(action=="void"){
			##no action
		}elsif(action=="apply"){
			me.mud.apply(me.mud);
		}elsif(action=="enterNRST"){
			me.enterNRST();
		}elsif(action=="XPDR_activate_code"){
			XPDR_activate_code();
		}elsif(action=="enterMenu"){
			me.enterMenu(FPLNOLINE);
		}elsif(action=="D_ENT_letter"){
			me.D_ENT_letter();
		}elsif(action=="D_ENT_select"){
			me.D_ENT_select();
		}elsif(action=="enterStartup"){
			me.ALERT();
		}
	},
	
	CLRsoftkey: func{
		var action = me.getCLRsoftkeyAction();
		if(action=="void"){
			##no action
		}elsif(action=="D_CLR_letter"){
			me.D_CLR_letter();
		}elsif(action=="D_CLR_select"){
			me.D_CLR_select();
		}
	},

	setENTsoftkeyAction: func(action){
		me.local.getNode("menu-action",1).getNode("ENTsoftkeyAction",1).setValue(action);
	},
	
	getENTsoftkeyAction: func {
		return me.local.getNode("menu-action",1).getNode("ENTsoftkeyAction",1).getValue();
	},
	
	setCLRsoftkeyAction: func(action){
		me.local.getNode("menu-action",1).getNode("CLRsoftkeyAction",1).setValue(action);
	},
	
	getCLRsoftkeyAction: func {
		return me.local.getNode("menu-action",1).getNode("CLRsoftkeyAction",1).getValue();
	},
	
	MENUsoftkey: func{
		var action = me.getMENUsoftkeyAction();
		if(action=="void"){
			##no action
		}elsif(action="displayMenu"){
			me.displayMenu();
		}
	},
	
	setMENUsoftkeyAction: func(action){
		me.local.getNode("menu-action",1).getNode("MENUsoftkeyAction",1).setValue(action);
	},
	
	getMENUsoftkeyAction: func {
		return me.local.getNode("menu-action",1).getNode("MENUsoftkeyAction",1).getValue();
	},
};

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

var _NAVvolume = func (x) {
	var selected_nav = getprop("/instrumentation/zkv1000/radios/nav-tune");
	if(getprop("/instrumentation/nav["~selected_nav~"]/serviceable")==1 and getprop("/instrumentation/nav["~selected_nav~"]/power-btn")==1){
		if (x) fgcommand("property-adjust", props.Node.new({
			property: "/instrumentation/nav["~selected_nav~"]/volume",
			step: x,
			min: 0.00,
			max: 1.00,
			wrap: 0
		}));
		else {
			fgcommand("property-toggle", props.Node.new({
			property: "/instrumentation/nav["~selected_nav~"]/ident"
		}));
		}
	}
}


var _NAVknob = func (x) {
	if (x){
		var selected_nav = getprop("/instrumentation/zkv1000/radios/nav-tune");
		if(getprop("/instrumentation/nav["~selected_nav~"]/serviceable")==1 and getprop("/instrumentation/nav["~selected_nav~"]/power-btn")==1){
			fgcommand("property-adjust", props.Node.new({
				property: "/instrumentation/zkv1000/radios/nav-freq-mhz",
				step: x,
				min: 108.00,
				max: 118.00,
				wrap: 1
			}));
		}
	}else{
		if(getprop("/instrumentation/nav[0]/serviceable")==1 and getprop("/instrumentation/nav[1]/serviceable")==1 and
			getprop("/instrumentation/nav[0]/power-btn")==1 and getprop("/instrumentation/nav[1]/power-btn")==1){
				fgcommand("property-toggle", props.Node.new({
				property: "/instrumentation/zkv1000/radios/nav-tune"
			}));
		}
	}
}

var _COMMvolume = func (x) {
	var selected_comm = getprop("/instrumentation/zkv1000/radios/comm-tune");
	if(getprop("/instrumentation/comm["~selected_comm~"]/serviceable")==1 and getprop("/instrumentation/comm["~selected_comm~"]/power-btn")==1){
		if (x) fgcommand("property-adjust", props.Node.new({
			property: "/instrumentation/comm["~selected_comm~"]/volume",
			step: x,
			min: 0.00,
			max: 1.00,
			wrap: 0
		}));
	}
}

var _COMMknob = func (x) {
	if (x){
		var selected_comm = getprop("/instrumentation/zkv1000/radios/comm-tune");
		if(getprop("/instrumentation/comm["~selected_comm~"]/serviceable")==1 and getprop("/instrumentation/comm["~selected_comm~"]/power-btn")==1){
			fgcommand("property-adjust", props.Node.new({
				property: "/instrumentation/zkv1000/radios/comm-freq-mhz",
				step: x,
				min: 118.00,
				max: 137.975,
				wrap: 1
			}));
		}
	}else{
		if(getprop("/instrumentation/comm[0]/serviceable")==1 and getprop("/instrumentation/comm[1]/serviceable")==1 and 
			getprop("/instrumentation/comm[0]/power-btn")==1 and getprop("/instrumentation/comm[1]/power-btn")==1){
			fgcommand("property-toggle", props.Node.new({
				property: "/instrumentation/zkv1000/radios/comm-tune"
			}));
		}
	}
}

var _swapNAV = func {
    var n = getprop("/instrumentation/zkv1000/radios/nav-tune");
	if(getprop("/instrumentation/nav["~n~"]/serviceable")==1 and getprop("/instrumentation/nav["~n~"]/power-btn")==1){
		var tmp = getprop("/instrumentation/nav[" ~ n ~ "]/frequencies/selected-mhz");
		setprop("/instrumentation/nav[" ~ n ~ "]/frequencies/selected-mhz", getprop("/instrumentation/nav[" ~ n ~ "]/frequencies/standby-mhz"));
		setprop("/instrumentation/nav[" ~ n ~ "]/frequencies/standby-mhz", tmp);
	}
}

var _swapCOMM = func (emergency = 0) {
	var c = getprop("/instrumentation/zkv1000/radios/comm-tune");
	if(getprop("/instrumentation/comm["~c~"]/serviceable")==1 and getprop("/instrumentation/comm["~c~"]/power-btn")==1){
		if (emergency) {
			setprop("/instrumentation/comm/frequencies/selected-mhz", 121.500);
			setprop("/instrumentation/zkv1000/radios/comm1-selected", 1);
			setprop("/instrumentation/zkv1000/radios/comm2-selected", 0);
		}
		else {
			var tmp = getprop("/instrumentation/comm[" ~ c ~ "]/frequencies/selected-mhz");
			setprop("/instrumentation/comm[" ~ c ~ "]/frequencies/selected-mhz", getprop("/instrumentation/comm[" ~ c ~ "]/frequencies/standby-mhz"));
			setprop("/instrumentation/comm[" ~ c ~ "]/frequencies/standby-mhz", tmp);
		}
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
