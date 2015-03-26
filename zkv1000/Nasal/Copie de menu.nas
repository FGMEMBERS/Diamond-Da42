var ADFVOL = 0;
var ADFSTBY = 0;
var ADFSEL = 0;
var ADFMODE = 0;
var DMEMODE = 2;
var XPDR_n = 3;
var XPDR_old = 0;
var XPDR_MODE = "";
var NRSTFREQTAB = [];
var NRSTFREQ = 0.0;
var NRSTIDTAB = [];
var NRSTID = "";

var FPLLINE = [];
var FPLNOLINE = [];
var DLINE = [];

##status lists
# 0 = Off Display
# 1 = PFD display
# 2 = Topo map
# 3 = Traffic
# 4 = Airport chart
# 5 = Terrain display
# 6 = Symbols display
# 7 = Startup display

var menuClass = {
    new: func (node) {
        var m = { parents: [ menuClass , knobsClass.new(node) ] };
        m.local = node;
		m.mud = mudClass.new(node);
        m.set_softkeyActionTable();
        return m;
    },

    local: nil,

    goto: func (l) {
        me.level = l;
        me.local.getNode("menu-level").setIntValue(l);
        me.local.getNode("menu-text").setValue(menuTable[l]);
    },
	
	ALERT: func {
		if(me.local.getNode("status").getValue()==7){
			me.local.getNode("status").setIntValue(2);
			me.goto(0);
			me.setENTsoftkeyAction("");
			return;
		}
		var warning = getprop("/instrumentation/zkv1000/alerts/warning");
		var caution = getprop("/instrumentation/zkv1000/alerts/caution");
		var advisory = getprop("/instrumentation/zkv1000/alerts/advisory");
		
		if(warning==1){
			setprop("/instrumentation/zkv1000/alerts/warning",0);
		}elsif(caution==1){
			setprop("/instrumentation/zkv1000/alerts/caution",0);
		}elsif(advisory==1){
			setprop("/instrumentation/zkv1000/alerts/advisory",0);
		}else{
			##affichage des alertes dans le MUD
			var title = me.mud.getTitle();
			if(title== "ALERTS"){
				me.closeMud();
			}else{
			
				me.mud.wipe();
				me.mud.setTitle("ALERTS");
			
				var alerts = alerts.getNode("alerts-list").getChildren();
				for(var i=0;i<size(alerts);i=i+1){
					if(getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/active")==1){
						if(getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/text1")!=nil and size(getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/text1"))>0){
							me.mud.add([getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/label"),getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/text0"),getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/text1")], void);
						}else{
							me.mud.add([getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/label"),getprop("/instrumentation/zkv1000/alerts/alerts-list/alert["~i~"]/text0")], void);
						}
					}
				}
				
				me.mud.open();
				me.setSmallFMSknobAction("select");
				me.setLargeFMSknobAction("select");
				me.mud.highlight();
			}
		}
	},
	
	LIGHT: func {
		var b = getprop("/instrumentation/zkv1000/emission");
		b = b + 0.2;
		if(b>1){
			b = 0;
		}
		setprop("/instrumentation/zkv1000/emission", b);
	},

	ADFDME: func {
		if(getprop("/instrumentation/adf/serviceable")==1 and getprop("/instrumentation/adf/power-btn")==1){
			ADFVOL = getprop("/instrumentation/adf[0]/volume-norm");
			ADFSTBY = getprop("/instrumentation/adf[0]/frequencies/standby-khz");
			ADFSEL = getprop("/instrumentation/adf[0]/frequencies/selected-khz");
			ADFMODE = 0;
			DMEMODE = 2;
			if(getprop("/instrumentation/adf[0]/mode")=="ant"){
				ADFMODE = 0; 
			}
			if(getprop("/instrumentation/adf[0]/mode")=="adf"){
				ADFMODE = 1; 
			}
			if(getprop("/instrumentation/adf[0]/mode")=="bfo"){
				ADFMODE = 2; 
			}
			
			if(getprop("/instrumentation/dme/frequencies/source")=="/instrumentation/nav[0]/frequencies/selected-mhz"){
				DMEMODE = 0; 
			}
			if(getprop("/instrumentation/dme/frequencies/source")=="/instrumentation/nav[1]/frequencies/selected-mhz"){
				DMEMODE = 1;
			}
			
			var title = me.mud.getTitle();
			if(title== "ADF/DME TUNING"){
				me.closeMud();
			}else{
				me.refeshADFDME();
				me.mud.highlight();
				
				me.setSmallFMSknobAction("changeAdfDmeValues");
				me.setLargeFMSknobAction("select");
				me.setENTsoftkeyAction("apply");
			}
		}
	},

	refeshADFDME: func {
		if(getprop("/instrumentation/adf/serviceable")==1 and getprop("/instrumentation/adf/power-btn")==1){
			me.mud.wipe();
			me.mud.setTitle("ADF/DME TUNING");
			var adfvolume = ADFVOL * 100;
			
			var adfmode = "ANT";
			if(ADFMODE==1){
				adfmode = "ADF";
			}
			if(ADFMODE==2){
				adfmode = "BFO";
			}
			
			var dmemode = "HOLD";
			if(DMEMODE==0){
				dmemode = "NAV1";
			}
			if(DMEMODE==1){
				dmemode = "NAV2";
			}
			
			me.mud.add([sprintf("ADF   SEL %03i -- %03i STBY",ADFSEL,ADFSTBY)],me.swapAdfFreq);
			me.mud.add([sprintf("        FREQ   %03i",ADFSTBY)],me.applyAdfFreq);
			me.mud.add([sprintf("        VOL    %3i",adfvolume)],me.applyAdfVol);
			me.mud.add([sprintf("        MODE   %s",adfmode)],me.applyAdfMode);
			me.mud.add(["",sprintf("DME   MODE   %s",dmemode)],me.applyDmeMode);
			
			me.mud.open();
		}
	},
	
	changeAdfDmeValues: func (noligne,dir){
		if(getprop("/instrumentation/adf/serviceable")==1 and getprop("/instrumentation/adf/power-btn")==1){
			if(noligne==0){
				var tmp = ADFSEL;
				ADFSEL = ADFSTBY;
				ADFSTBY = tmp;
			}
			if(noligne==1){
				if(ADFSTBY + dir>=190 and ADFSTBY + dir<=1799.5){
					ADFSTBY = ADFSTBY + dir;
				}
			}
			if(noligne==2){
				if(ADFVOL>0.05 and dir==-1){
					ADFVOL = ADFVOL - 0.05;
				}elsif(ADFVOL<1 and dir==1){
					ADFVOL = ADFVOL + 0.05;
				}
			}
			if(noligne==3){
				if(ADFMODE + dir>=0 and ADFMODE + dir<=2){
					ADFMODE = ADFMODE + dir;
				}
			}
			
			if(noligne==4){
				if(DMEMODE + dir>=0 and DMEMODE + dir<=2){
					DMEMODE = DMEMODE + dir;
				}
			}
			me.refeshADFDME();
			me.mud.highlight(noligne);
		}
	},
	
	swapAdfFreq: func {
		if(getprop("/instrumentation/adf/serviceable")==1 and getprop("/instrumentation/adf/power-btn")==1){
			setprop("/instrumentation/adf[0]/frequencies/selected-khz",ADFSEL);
			setprop("/instrumentation/adf[0]/frequencies/standby-khz",ADFSTBY);
		}
	},
	
	applyAdfFreq: func {
		if(getprop("/instrumentation/adf/serviceable")==1 and getprop("/instrumentation/adf/power-btn")==1){
			setprop("/instrumentation/adf[0]/frequencies/standby-khz",ADFSTBY);
		}
	},
	
	applyAdfVol: func () {
		if(getprop("/instrumentation/adf/serviceable")==1 and getprop("/instrumentation/adf/power-btn")==1){
			setprop("/instrumentation/adf[0]/volume-norm",ADFVOL);
		}
	},
	
	applyAdfMode: func {
		if(getprop("/instrumentation/adf/serviceable")==1 and getprop("/instrumentation/adf/power-btn")==1){
			if(ADFMODE==0){
				setprop("/instrumentation/adf[0]/mode","ant");
			}
			if(ADFMODE==1){
				setprop("/instrumentation/adf[0]/mode","adf");
			}
			if(ADFMODE==2){
				setprop("/instrumentation/adf[0]/mode","bfo");
			}
		}
	},
	
	applyDmeMode: func () {
		if(getprop("/instrumentation/dme/serviceable")==1 and getprop("/instrumentation/dme/power-btn")==1){
			if(DMEMODE<2){
				setprop("/instrumentation/dme/frequencies/source","/instrumentation/nav["~DMEMODE~"]/frequencies/selected-mhz");
				setprop("/instrumentation/zkv1000/infos/dme-line[0]","NAV"~(DMEMODE+1));
			}else{
				setprop("/instrumentation/dme/frequencies/source","/instrumentation/dme/frequencies/selected-mhz");
				setprop("/instrumentation/dme/frequencies/selected-mhz",0);
				setprop("/instrumentation/zkv1000/infos/dme-line[0]","HOLD");
			}
		}
	},

	NRST: func {
		var title = me.mud.getTitle();
		me.closeMud();
		if (substr(title, 0, 8) == "NEAREST ") {
            me.closeMud();
			me.NRSTFREQTAB = [];
			me.NRSTIDTAB = [];
        }else{
			lockSearches();
            searchNearestNavaid("airport", 10);
            me.showSearchResults("NEAREST AIRPORTS");
            unlockSearches();
			me.setLargeFMSknobAction("selectSearchType");
			me.setSmallFMSknobAction("changeNRST");
			me.setENTsoftkeyAction("enterNRST");
        }
    },

	selectSearchType: func (dir) {
		if(dir>0){
			lockSearches();
			var title = me.mud.getTitle();
			if (title == "NEAREST AIRPORTS") {
				searchNearestNavaid("vor",     5);
				me.showSearchResults("NEAREST VOR");
			}
			elsif (title == "NEAREST VOR") {
				searchNearestNavaid("ndb",     5);
				me.showSearchResults("NEAREST NDB");
			}
			elsif (title == "NEAREST NDB" or title=="NEAREST AIRPORT DETAILS") {
				searchNearestNavaid("airport", 10);
				me.showSearchResults("NEAREST AIRPORTS");
			}
			unlockSearches();
		}else{
			lockSearches();
			var title = me.mud.getTitle();
			if (title == "NEAREST VOR" or title=="NEAREST AIRPORT DETAILS") {
				searchNearestNavaid("airport", 10);
				me.showSearchResults("NEAREST AIRPORTS");
			}
			elsif (title == "NEAREST NDB") {
				searchNearestNavaid("vor",     5);
				me.showSearchResults("NEAREST VOR");
			}
			elsif (title == "NEAREST AIRPORTS") {
				searchNearestNavaid("ndb",     5);
				me.showSearchResults("NEAREST NDB");
			}
			unlockSearches();
		}
    },
	
    showSearchResults: func (title) {
		me.closeMud();
        me.mud.setTitle(title);
		NRSTFREQTAB = [];
		NRSTIDTAB = [];
        while (getprop('/instrumentation/gps/scratch/has-next')) {
			append(NRSTIDTAB,getprop('/instrumentation/gps/scratch/ident'));
			if(title == "NEAREST AIRPORTS"){
				append(NRSTFREQTAB,0.0);
				me.mud.add([getprop('/instrumentation/gps/scratch/name'),
					sprintf("%s -- DST %.1fNM BRG %03i", 
					getprop('/instrumentation/gps/scratch/ident'),
					getprop('/instrumentation/gps/scratch/distance-nm'), 
					getprop('/instrumentation/gps/scratch/mag-bearing-deg')),
				], void);
			}else{
				if(title == "NEAREST VOR"){
					append(NRSTFREQTAB,getprop('/instrumentation/gps/scratch/frequency-mhz'));
					me.mud.add([getprop('/instrumentation/gps/scratch/name'),
						sprintf("%s -- DST %.1fNM BRG %03i FRQ %03.2f", 
						getprop('/instrumentation/gps/scratch/ident'),
						getprop('/instrumentation/gps/scratch/distance-nm'), 
						getprop('/instrumentation/gps/scratch/mag-bearing-deg'),
						getprop('/instrumentation/gps/scratch/frequency-mhz')),
					], void);
				}elsif(title == "NEAREST NDB"){
					append(NRSTFREQTAB,getprop('/instrumentation/gps/scratch/frequency-khz'));
					me.mud.add([getprop('/instrumentation/gps/scratch/name'),
						sprintf("%s -- DST %.1fNM BRG %03i FRQ %04.0f", 
						getprop('/instrumentation/gps/scratch/ident'),
						getprop('/instrumentation/gps/scratch/distance-nm'), 
						getprop('/instrumentation/gps/scratch/mag-bearing-deg'),
						getprop('/instrumentation/gps/scratch/frequency-khz')),
					], void);
				}else{
					append(NRSTFREQTAB,0.0);
				}
			}
            setprop("/instrumentation/gps/command", "next");
        }
        me.mud.open();
        me.mud.highlight();
		NRSTFREQ = NRSTFREQTAB[me.mud.getSelectedBlock()];
		NRSTID = NRSTIDTAB[me.mud.getSelectedBlock()];
		me.setLargeFMSknobAction("selectSearchType");
		me.setSmallFMSknobAction("changeNRST");
		me.setENTsoftkeyAction("enterNRST");
    },

	changeNRST: func(dir){
		me.mud.select(me.mud, dir);
		NRSTFREQ = NRSTFREQTAB[me.mud.getSelectedBlock()];
		NRSTID = NRSTIDTAB[me.mud.getSelectedBlock()];
	},
	
	enterNRST: func{
		var title = me.mud.getTitle();
		if (title == "NEAREST AIRPORTS") {
			NRSTFREQTAB = [];
			NRSTIDTAB = [];
			me.mud.wipe();
			me.mud.setTitle("NEAREST AIRPORT DETAILS");
			var airport = airportinfo(NRSTID);
			me.mud.add([airport.name,sprintf("LON %3.2f LAT %3.2f ELE %3.f", 
					airport.lon,
					airport.lat,
					airport.elevation)], void);
			append(NRSTFREQTAB,0.0);
			append(NRSTIDTAB,airport.id);
			
			me.mud.add(["","----------------RADIOS---------------",""], void);
			append(NRSTFREQTAB,0.0);
			append(NRSTIDTAB,"");
			
			props.globals.getNode("/instrumentation/zkv1000/airport_radios/airports/id_"~NRSTID~"/name",1);
			if(props.globals.getNode("/instrumentation/zkv1000/airport_radios/airports/id_"~NRSTID~"/name").getType()=="STRING"){
				var radio = props.globals.getNode("/instrumentation/zkv1000/airport_radios/airports/id_"~NRSTID~"/radios").getChildren("radio");
				for(var i=0; i<size(radio);i=i+1) {
					var frequence = getprop("/instrumentation/zkv1000/airport_radios/airports/id_"~NRSTID~"/radios/radio["~i~"]/frequence");
					var freq_name = getprop("/instrumentation/zkv1000/airport_radios/airports/id_"~NRSTID~"/radios/radio["~i~"]/id");
					me.mud.add([sprintf("%s   %3.2f",freq_name,frequence)], void);
					append(NRSTFREQTAB,frequence);
					append(NRSTIDTAB,"comm");
				}
			}else{
				props.globals.getNode("/instrumentation/zkv1000/airport_radios/airports/").removeChild("id_"~NRSTID);
			}
			
			me.mud.add(["","---------------RUNWAYS---------------",""], void);
			append(NRSTFREQTAB,0.0);
			append(NRSTIDTAB,"");
			foreach (var r; keys(airport.runways)) {
				var runway = airport.runways[r];
				
				var id = "";
				var freq = 0.0;
				var ligne = sprintf("RWY %s HED %3.f LEN %3.f", runway.id,	runway.heading,runway.length);
				foreach(var airwaykeys ; keys(runway)){
					if(airwaykeys=="ils_frequency_mhz"){
						ligne = sprintf("%s ILS %3.2f",ligne,runway.ils_frequency_mhz);
						id = "ils";
						freq = runway.ils_frequency_mhz;
					}
				}
				me.mud.add([ligne], void);
				append(NRSTFREQTAB,freq);
				append(NRSTIDTAB,id);
			}
			me.mud.open();
			me.mud.highlight();
			NRSTID = airport.id;
			NRSTFREQ = 0.0;
		}elsif (title == "NEAREST VOR") {
			radios.getNode("nav-freq-mhz").setDoubleValue(NRSTFREQ);
		}elsif (title == "NEAREST NDB") {
			setprop("/instrumentation/adf[0]/frequencies/standby-khz",NRSTFREQ);
		}elsif(title == "NEAREST AIRPORT DETAILS"){
			if(NRSTID=="ils"){
				radios.getNode("nav-freq-mhz").setDoubleValue(NRSTFREQ);
			}elsif(NRSTID=="comm"){
				radios.getNode("comm-freq-mhz").setDoubleValue(NRSTFREQ);
			}elsif(size(NRSTID)>0){
				me.local.getNode("status").setIntValue(4);
				me.RANGEknob = func(dir) {me.changeAirportRange(dir)};
				var airport = airportinfo(NRSTID);
				me.local.getNode("groundradar").getNode("id").setValue(NRSTID);
				me.local.getNode("airport_id").setValue(airport.id);
				me.local.getNode("airport_name").setValue(airport.name);
				me.closeMud();
			}
		}
	},
	
	changeAirportRange: func(dir){
		var range = me.local.getNode("groundradar").getNode("range").getValue();
		range = range + dir * 0.2;
		if(range<0.4){
			range = 0.4;
		}
		if(range>2){
			range = 2;
		}
		me.local.getNode("groundradar").getNode("range").setValue(range);
	},
	
	DISPLAYXPDR: func{
		if(getprop("/instrumentation/transponder/serviceable")==1){
			me.goto(10);
		}
	},
	
	IDENTRESET: func{
		setprop("/instrumentation/zkv1000/radios/xpdr-mode",XPDR_MODE);
	},
	
    IDENT: func {
		if(getprop("/instrumentation/zkv1000/radios/xpdr-mode")!="STBY" and getprop("/instrumentation/transponder/serviceable")==1){
			XPDR_MODE = getprop("/instrumentation/zkv1000/radios/xpdr-mode");
			setprop("/instrumentation/zkv1000/radios/xpdr-mode","IDNT");
			settimer(me.IDENTRESET,18);
			me.goto(0);
		}
	},

	TMRREF: func {
		var title = me.mud.getTitle();
		if(title=="REFERENCES"){
			me.closeMud();
		}else{
			me.mud.wipe();
			me.mud.setTitle("REFERENCES");
				
			me.mud.add(["VA    120KT MANEUVERING SPEED"],void);
			me.mud.add(["VFE   111KT FLAPS LDG"],void);
			me.mud.add(["VFE   137KT FLAPS APP"],void);
			me.mud.add(["VLOE 194KT GEAR EXTENSION"],void);
			me.mud.add(["VLOR 156KT GEAR RETRACTION"],void);
			me.mud.add(["VLE   194KT GEAR EXTENDED"],void);
			me.mud.add(["VMCA  68KT MIN SPEED 1 EGN"],void);
			me.mud.add(["VNO  155KT MAX CRUISE SPEED"],void);
			me.mud.add(["VNE  194KT DO NOT EXCEED"],void);
			me.mud.add(["VY     82KT BEST CLIMB SPEED"],void);
			me.mud.add(["VR     72KT ROTATION SPEED"],void);

			me.mud.open();
			me.mud.highlight();
			me.setSmallFMSknobAction("select");
			me.setLargeFMSknobAction("void");
			me.setENTsoftkeyAction("void");
		}
	},

	FUEL: func (v) {
		if(getprop("/instrumentation/enginstr/serviceable")==1){
			var fuel = getprop("/consumables/fuel/fuel-gest/fuel-remaining");
			if(fuel==nil){
				fuel = 0;
			}
			if(v==1){
				if(fuel>1){
					fuel = fuel - 1;
					setprop("/consumables/fuel/fuel-gest/fuel-remaining",fuel);
				}
			}elsif(v==2){
				if(fuel<76){
					fuel = fuel + 1;
					setprop("/consumables/fuel/fuel-gest/fuel-remaining",fuel);
				}
			}elsif(v==3){
				setprop("/consumables/fuel/fuel-gest/fuel-used",0);
			}
		}
	},

	VOR1: func {
		radios.getNode("nav2-selected").setIntValue(0);
		radios.getNode("nav1-selected").setIntValue(1);
		me.CDIfromNAV(0);
	},

	VOR2: func {
		radios.getNode("nav1-selected").setIntValue(0);
		radios.getNode("nav2-selected").setIntValue(1);
		me.CDIfromNAV(1);
	},

    GPS: func { 
        cdi.getNode("in-range").unalias();
        cdi.getNode("course").unalias();
        cdi.getNode("course-deflection").unalias();
        cdi.getNode("pointer-type").setIntValue(0);
        cdi.getNode("from-flag").unalias();
		cdi.getNode("has-gs").unalias();
		cdi.getNode("gs-needle-deflection-norm").unalias();
		
		cdi.getNode("visible").setBoolValue(1);
		cdi.getNode("in-range").setBoolValue(1);
		cdi.getNode("has-gs").setBoolValue(0);##gs from gps ?
		#cdi.getNode("gs-needle-deflection-norm").alias(nav ~ "gs-needle-deflection-norm");
		cdi.getNode("gs-needle-deflection-norm").setDoubleValue(1);## trouver la deflexion du glidescope
		if(cdi.getNode("has-gs").getValue()==1){
			cdi.getNode("course").alias("/orientation/heading-magnetic-deg");
			#cdi.getNode("course").alias(nav ~ "radials/actual-deg");
		}else{
			cdi.getNode("course").alias("/instrumentation/gps/selected-course-deg");
		}
		cdi.getNode("course-deflection").alias("/instrumentation/zkv1000/gps/heading-needle-deflexion");
		cdi.getNode("pointer-type").setIntValue(4);
		cdi.getNode("from-flag").alias("/instrumentation/gps/wp/wp[1]/from-flag");
		#cdi.getNode("radial").alias(nav ~ "radials/reciprocal-radial-deg");
		
        me.goto(0);
    },

	CDIfromNAV: func (n) {
		nav = "/instrumentation/nav[" ~ n ~ "]/";
		cdi.getNode("in-range").unalias();
        cdi.getNode("course").unalias();
        cdi.getNode("course-deflection").unalias();
        cdi.getNode("pointer-type").setIntValue(0);
        cdi.getNode("from-flag").unalias();
		cdi.getNode("has-gs").unalias();
		cdi.getNode("gs-needle-deflection-norm").unalias();
		
		cdi.getNode("visible").setBoolValue(1);
		cdi.getNode("in-range").alias(nav ~ "in-range");
		cdi.getNode("has-gs").alias(nav ~ "has-gs");
		cdi.getNode("gs-needle-deflection-norm").alias(nav ~ "gs-needle-deflection-norm");
		if(cdi.getNode("has-gs").getValue()==1){
			cdi.getNode("course").alias("/orientation/heading-magnetic-deg");
		}else{
			cdi.getNode("course").alias(nav ~ "radials/selected-deg");
		}
		cdi.getNode("course-deflection").alias(nav ~ "heading-needle-deflection");
		cdi.getNode("pointer-type").setIntValue(n * 2);
		cdi.getNode("from-flag").alias(nav ~ "from-flag");
		cdi.getNode("radial").alias(nav ~ "radials/reciprocal-radial-deg");
		me.goto(0);
	},

    CDIOFF: func {
        cdi.getNode("visible").setBoolValue(0);
        radios.getNode("nav1-selected").setIntValue(0);
        radios.getNode("nav2-selected").setIntValue(0);
        cdi.getNode("in-range").unalias();
        cdi.getNode("course").unalias();
        cdi.getNode("course-deflection").unalias();
        cdi.getNode("pointer-type").setIntValue(0);
        cdi.getNode("from-flag").unalias();
        var mode = nil;
        mode = getprop("/autopilot/locks/roll");
        if (mode == "NAV" or mode == "APR") AFCS.ROLL();
        mode = getprop("/autopilot/locks/pitch");
        if (mode == "GS" or mode == "APR") AFCS.PIT();
        me.goto(0);
    },

    INSETOFF: func { 
        #ALTknob = _ALTknob;
        #HDGknob = _HDGknob;
        #CRSknob = _CRSknob;
        #BAROknob = _BAROknob;
        animeCursors = pfdCursors;
        joystick = void;
        me.RANGEknob = void;
        Dsoftkey = void;
        me.local.getNode("status").setIntValue(1);
        me.local.getNode("terrain").setBoolValue(0);
        #init_main_loop();
        me.goto(0);
	},

	SYMB: func { 
        me.local.getNode("status").setIntValue(6);
		me.RANGEknob = func(dir) {me.changeSynbRange(dir)};
        me.goto(14);
    },
	
	changeSynbRange: func (dir) {
		var ranges = [2,6,10,20,50,100,200,500];
		var selectedIndex = -1;
		
		var range = getprop("/instrumentation/zkv1000/symbmap-range");
		for(var i=0;i<size(ranges);i=i+1){
			if(range==ranges[i]){
				selectedIndex = i;
			}
		}
		selectedIndex = selectedIndex + dir;
		if(selectedIndex<0){
			selectedIndex = 0;
		}
		if(selectedIndex>size(ranges)-1){
			selectedIndex = size(ranges)-1;
		}
		setprop("/instrumentation/zkv1000/symbmap-range",ranges[selectedIndex]);
	},
	
	TGLSYMB: func(x){
		if(x==0){
			var b = "/instrumentation/zkv1000/symbols/airport";
			setprop(b, getprop(b) < 0.5 ? 1 : 0.0);
		}elsif(x==1){
			var b = "/instrumentation/zkv1000/symbols/vor";
			setprop(b, getprop(b) < 0.5 ? 1 : 0.0);
		}elsif(x==2){
			var b = "/instrumentation/zkv1000/symbols/ndb";
			setprop(b, getprop(b) < 0.5 ? 1 : 0.0);
		}elsif(x==3){
			var b = "/instrumentation/zkv1000/symbols/fix";
			setprop(b, getprop(b) < 0.5 ? 1 : 0.0);
		}
	},
	
    TRAFFIC: func { 
        me.local.getNode("status").setIntValue(3);
		me.local.getNode("traffic").setBoolValue(1);
		me.RANGEknob = func(dir) {me.changeTrafficRange(dir)};
        #me.goto(0);
    },
	
	changeTrafficRange: func (dir) {
		var ranges = [2,6,12,50,100];
		#var ranges = [2,6,12]; ##ranges tis
		var selectedIndex = -1;
		var range = getprop("/instrumentation/radar/range");
		for(var i=0;i<size(ranges);i=i+1){
			if(range==ranges[i]){
				selectedIndex = i;
			}
		}
		selectedIndex = selectedIndex + dir;
		if(selectedIndex<0){
			selectedIndex = 0;
		}
		if(selectedIndex>size(ranges)-1){
			selectedIndex = size(ranges)-1;
		}
		setprop("/instrumentation/radar/range",ranges[selectedIndex]);
	},
	
    TOPO: func { 
        animeCursors = moveMap;
        Dsoftkey = fromMapDirectTo;
        #ALTknob = void;
        #HDGknob = void;
        #CRSknob = void;
        #BAROknob = void;
        me.local.getNode("status").setIntValue(2);
        me.local.getNode("topo").setBoolValue(1);
        #init_main_loop();
        #me.goto(0);
    },
	
	TERRAIN: func { 
		me.local.getNode("status").setIntValue(5);
		me.local.getNode("terrain").setBoolValue(1);
		me.RANGEknob = func(dir) {me.changeTerrainRange(dir)};
        me.goto(7);
    },

	TERRAINLORES: func{
		setprop("/instrumentation/zkv1000/moving-map/terrain-elevation/use-high-resolution",0);
	},
	
	TERRAINHIRES: func{
		setprop("/instrumentation/zkv1000/moving-map/terrain-elevation/use-high-resolution",1);
	},
	
	changeTerrainRange: func (dir) {
		#var ranges = [25,50,100,200];
		var ranges = [2,6,10,20,50,100];
		var selectedIndex = -1;
		var range = getprop("/instrumentation/zkv1000/moving-map/controls/range-nm");
		for(var i=0;i<size(ranges);i=i+1){
			if(range==ranges[i]){
				selectedIndex = i;
			}
		}
		selectedIndex = selectedIndex + dir;
		if(selectedIndex<0){
			selectedIndex = 0;
		}
		if(selectedIndex>size(ranges)-1){
			selectedIndex = size(ranges)-1;
		}
		setprop("/instrumentation/zkv1000/moving-map/controls/range-nm",ranges[selectedIndex]);
	},
	
    STRMSCP: func { 
        nyi("STRMSCP softkey");
        me.goto(0);
    },

    NEXRAD: func { 
        nyi("NEXRAD softkey");
        me.goto(0);
    },
	
	XMLTNG: func { 
        nyi("XMLTNG softkey");
        me.goto(0);
    },

    DCLTROFF: func { 
        nyi("DCLTROFF softkey");
        me.goto(2);
    },

    DCLTR: func (x) { 
        nyi("DCLTR" ~ x ~ " softkey");
        me.goto(2);
    },

    DFLTS: func { 
        nyi("DEFAULTS softkey");
        me.goto(0);
    },

    DME: func { 
		if(me.local.getNode("dme").getValue()==0){
			me.local.getNode("dme").setValue(1);
		}else{
			me.local.getNode("dme").setValue(0);
		}
        me.goto(0);
    },

    STDBARO: func { 
        setprop("/instrumentation/altimeter/setting-inhg", 29.92);
        me.goto(0);
    },

    BRG1: func (x) { 
		if(x==1){
			brg1.getNode("course").unalias();
			brg1.getNode("course").alias("/instrumentation/nav[0]/radials/reciprocal-radial-deg");
			brg1.getNode("frequence").unalias();
			brg1.getNode("frequence").alias("/instrumentation/nav[0]/frequencies/selected-mhz");
			brg1.getNode("visible").setBoolValue(1);
			brg1.getNode("nav-distance").unalias();
			brg1.getNode("nav-distance").alias("/instrumentation/nav[0]/nav-distance");
			brg1.getNode("in-range").unalias();
			brg1.getNode("in-range").alias("/instrumentation/nav[0]/in-range");
			brg1.getNode("type").setValue("NAV1");
			brg1.getNode("name").unalias();
			brg1.getNode("name").alias("/instrumentation/nav[0]/nav-id");
		}elsif(x==2){
			brg1.getNode("course").unalias();
			brg1.getNode("course").alias("/instrumentation/gps/wp/wp[1]/bearing-mag-deg");
			brg1.getNode("frequence").unalias();
			brg1.getNode("frequence").setDoubleValue(0.0);
			brg1.getNode("visible").setBoolValue(1);
			brg1.getNode("nav-distance").unalias();
			brg1.getNode("nav-distance").alias("/instrumentation/gps/wp/wp[1]/distance-nm");
			brg1.getNode("in-range").unalias();
			brg1.getNode("in-range").setBoolValue(1);
			brg1.getNode("type").setValue("GPS");
			brg1.getNode("name").unalias();
			brg1.getNode("name").alias("/instrumentation/zkv1000/gps/id");
		}elsif(x==3){
			brg1.getNode("course").unalias();
			brg1.getNode("course").alias("/instrumentation/adf[0]/indicated-bearing-deg");
			brg1.getNode("frequence").unalias();
			brg1.getNode("frequence").alias("/instrumentation/adf[0]/frequencies/selected-khz");
			brg1.getNode("visible").setBoolValue(1);
			brg1.getNode("nav-distance").unalias();
			brg1.getNode("nav-distance").setDoubleValue(0);
			brg1.getNode("in-range").unalias();
			brg1.getNode("in-range").alias("/instrumentation/adf[0]/in-range");
			brg1.getNode("type").setValue("ADF");
			brg1.getNode("name").unalias();
			brg1.getNode("name").alias("/instrumentation/adf[0]/ident");
		}
        me.goto(0);
    },

    BRG2: func (x) { 
        if(x==1){
			brg2.getNode("course").unalias();
			brg2.getNode("course").alias("/instrumentation/nav[1]/radials/reciprocal-radial-deg");
			brg2.getNode("frequence").unalias();
			brg2.getNode("frequence").alias("/instrumentation/nav[1]/frequencies/selected-mhz");
			brg2.getNode("visible").setBoolValue(1);
			brg2.getNode("nav-distance").unalias();
			brg2.getNode("nav-distance").alias("/instrumentation/nav[1]/nav-distance");
			brg2.getNode("in-range").unalias();
			brg2.getNode("in-range").alias("/instrumentation/nav[1]/in-range");
			brg2.getNode("type").setValue("NAV2");
			brg2.getNode("name").unalias();
			brg2.getNode("name").alias("/instrumentation/nav[1]/nav-id");
		}elsif(x==2){
			brg2.getNode("course").unalias();
			brg2.getNode("course").alias("/instrumentation/gps/wp/wp[1]/bearing-mag-deg");
			brg2.getNode("frequence").unalias();
			brg2.getNode("frequence").setDoubleValue(0.0);
			brg2.getNode("visible").setBoolValue(1);
			brg2.getNode("nav-distance").unalias();
			brg2.getNode("nav-distance").alias("/instrumentation/gps/wp/wp[1]/distance-nm");
			brg2.getNode("in-range").unalias();
			brg2.getNode("in-range").setBoolValue(1);
			brg2.getNode("type").setValue("GPS");
			brg2.getNode("name").unalias();
			brg2.getNode("name").alias("/instrumentation/zkv1000/gps/id");
		}elsif(x==3){
			brg2.getNode("course").unalias();
			brg2.getNode("course").alias("/instrumentation/adf[0]/indicated-bearing-deg");
			brg2.getNode("frequence").unalias();
			brg2.getNode("frequence").alias("/instrumentation/adf[0]/frequencies/selected-khz");
			brg2.getNode("visible").setBoolValue(1);
			brg2.getNode("nav-distance").unalias();
			brg2.getNode("nav-distance").setDoubleValue(0);
			brg2.getNode("in-range").unalias();
			brg2.getNode("in-range").alias("/instrumentation/adf[0]/in-range");
			brg2.getNode("type").setValue("ADF");
			brg2.getNode("name").unalias();
			brg2.getNode("name").alias("/instrumentation/adf[0]/ident");
		}
        me.goto(0);
    },

    BRGOFF: func (x) { 
		if(x==1){
			brg1.getNode("course").unalias();
			brg1.getNode("name").unalias();
			brg1.getNode("visible").setBoolValue(0);
			brg1.getNode("nav-distance").unalias();
			brg1.getNode("in-range").unalias();
			brg1.getNode("frequence").unalias();
		}elsif(x==2){
			brg2.getNode("course").unalias();
			brg2.getNode("name").unalias();
			brg2.getNode("visible").setBoolValue(0);
			brg2.getNode("nav-distance").unalias();
			brg2.getNode("in-range").unalias();
			brg2.getNode("frequence").unalias();
		}
        me.goto(0);
    },

    HSI360: func { 
        me.local.getNode("hsi-360").setBoolValue(1);
        me.goto(0);
    },

    HSIARC: func { 
        me.local.getNode("hsi-360").setBoolValue(0);
        me.goto(0);
    },

    OPTN: func (x) { 
        me.local.getNode("wind-data").setBoolValue(1);
        if (x == 1) wind_infos = wind_opt1;
        elsif (x == 2) wind_infos = wind_opt2;
        elsif (x == 3) wind_infos = wind_opt3;
        me.goto(0);
    },

    WINDOFF: func { 
        wind_infos = void;
        me.local.getNode("wind-data").setBoolValue(1);
        setprop("/instrumentation/zkv1000/infos/wind-line", "");
        setprop("/instrumentation/zkv1000/infos/wind-line[1]", "");
        me.goto(0);
    },

    METERS: func { 
        nyi("METERS softkey");
        me.goto(0);
    },

    IN: func { 
        me.local.getNode("baro-hpa").setBoolValue(0);
        me.goto(0);
    },

    HPA: func { 
        me.local.getNode("baro-hpa").setBoolValue(1);
        me.goto(0);
    },

    XPDR: func (x) {
		if(getprop("/instrumentation/transponder/serviceable")==1){
			if (x <= 7) {
				if (XPDR_n == 3) {
					XPDR_old = getprop("/instrumentation/transponder/id-code");
					setprop("/instrumentation/transponder/id-code",0);
				}elsif (XPDR_n < 0) {
					me.goto(10);
					XPDR_n = 3;
					return;
				}
				if(XPDR_n>=0){
					setprop("/instrumentation/transponder/id-code", getprop("/instrumentation/transponder/id-code") + x * math.pow(10, XPDR_n));
					XPDR_n -= 1;
				}
			} else {
				if (x == 9) setprop("/instrumentation/transponder/id-code", XPDR_old);
				XPDR_n = 3;
				me.goto(0);
			}
		}
    },

	XPDRSTDBY: func { 
		if(getprop("/instrumentation/transponder/serviceable")==1){
			setprop("/instrumentation/zkv1000/radios/xpdr-mode", "STBY");
			XPDR_MODE = "STBY";
		}
	},

	XPDRON: func {
		if(getprop("/instrumentation/transponder/serviceable")==1){
			setprop("/instrumentation/zkv1000/radios/xpdr-mode", "ON");
			XPDR_MODE = "ON";
		}
	},

	XPDRALT: func { 
		if(getprop("/instrumentation/transponder/serviceable")==1){
			setprop("/instrumentation/zkv1000/radios/xpdr-mode", "ALT");
			XPDR_MODE = "ALT";
		}
	},

	XPDRGND: func { 
		if(getprop("/instrumentation/transponder/serviceable")==1){
			setprop("/instrumentation/zkv1000/radios/xpdr-mode", "GND");
			XPDR_MODE = "GND";
		}
	},

	XPDRVFR: func { 
		if(getprop("/instrumentation/transponder/serviceable")==1){
			XPDR_old = getprop("/instrumentation/transponder/id-code");
			if(getprop("/instrumentation/transponder/id-code")==1200){
				setprop("/instrumentation/transponder/id-code", 7000);# vfr code for Europe
			}else{
				setprop("/instrumentation/transponder/id-code", 1200);# vfr code for US
			}
		}
	},

	XPDRBKSP: func { 
		if(getprop("/instrumentation/transponder/serviceable")==1){
			if (XPDR_n < 3) XPDR_n += 1;
		}
	},

    CODE: func {
		if(getprop("/instrumentation/transponder/serviceable")==1){
			#getprop("/instrumentation/zkv1000/radios/xpdr-mode") == "STBY" or return;
			me.closeMud();
			me.setLargeFMSknobAction("XPDR_change_cursor_position");
			me.setSmallFMSknobAction("XPDR_enter_digits");
			me.setENTsoftkeyAction("XPDR_activate_code");
			me.goto(11);
		}
    },
	
	TGLEIS: func (x) {
		if(x==1){
			if(me.local.getNode("eis-display").getValue()==1 and (me.local.getNode("menu-level").getValue()==12 or me.local.getNode("menu-level").getValue()==13)){
				x=0;
			}
			me.goto(12);
		}elsif(x==2){
			me.goto(12);
		}elsif(x==3){
			me.goto(13);
		}
		me.local.getNode("eis-display").setIntValue(x);
	},

	##Flightplan display
	
	FPL: func {
		var title = me.mud.getTitle();
		me.closeMud();
		if(substr(title, 0, 11) == "FLIGHT PLAN"){
			me.closeMud();
			#me.MENUsoftkey = void;
			me.setMENUsoftkeyAction("void");
			FPLLINE = [];
		}else{
			me.mud.wipe();
			FPLLINE = [];
			#setprop("/autopilot/route-manager/input","@ACTIVATE");##to have all the wp
			#setprop("/autopilot/route-manager/active",1);
			
			var num_wp = getprop("/autopilot/route-manager/route/num");
			if(num_wp==0){
				me.mud.setTitle("FLIGHT PLAN : NO FLIGHT PLAN");
				me.setLargeFMSknobAction("void");
				me.setSmallFMSknobAction("void");
				me.setENTsoftkeyAction("void");
				me.setMENUsoftkeyAction("void");
			}else{
				var departure = getprop("/autopilot/route-manager/wp[0]/id");
				var arrival = getprop("/autopilot/route-manager/wp[1]/id");
				me.mud.setTitle("FLIGHT PLAN : "~departure~" TO "~arrival);
				var last_coord = geo.Coord.new().set_latlon(getprop("/position/latitude-deg"),getprop("/position/longitude-deg"));
				for(var i=0;i<num_wp;i=i+1){
					var actual_coord = geo.Coord.new().set_latlon(getprop("/autopilot/route-manager/route/wp["~i~"]/latitude-deg"),getprop("/autopilot/route-manager/route/wp["~i~"]/longitude-deg"));
					var wp_id = getprop("/autopilot/route-manager/route/wp["~i~"]/id");
					var wp_spaces = "                                          ";
					if(size(wp_id)<15){
						wp_spaces = substr(wp_spaces,0,30-size(wp_id)*2);
					}else{
						wp_spaces = "";
					}
					var wp_distance = last_coord.distance_to(actual_coord) * 0.000539;
					var wp_bearing = last_coord.course_to(actual_coord);
					me.mud.add([sprintf("%s %s %03i  %3.0fNM",wp_id,wp_spaces,wp_bearing,wp_distance)],void);
					last_coord = actual_coord;
					append(FPLLINE,wp_id);
				}
				me.setSmallFMSknobAction("select");
				me.setLargeFMSknobAction("void");
				me.setENTsoftkeyAction("void");
				me.setMENUsoftkeyAction("displayMenu");
			}
				
			me.mud.open();
			#setprop("/autopilot/route-manager/active",0);
			me.mud.highlight();
		}
	},
	
	displayMenu: func{
		FPLNOLINE = me.mud.getSelectedBlock();
		var wp_id = FPLLINE[me.mud.getSelectedBlock()];
		me.mud.wipe();
		me.mud.setTitle("FLIGHT PLAN : SELECT OPTION");
		
		me.mud.add(["ACTIVATE FLIGHT PLAN"],void);
		me.mud.add(["DEACTIVATE FLIGHT PLAN"],void);
		me.mud.add(["JUMP TO LEG TO WP "~wp_id],void);
		me.mud.add(["REMOVE LEG TO WP "~wp_id],void);
		me.mud.add(["EXIT"],void);
		me.mud.open();
		me.mud.highlight();
		me.setENTsoftkeyAction("enterMenu");
		me.setSmallFMSknobAction("select");
		me.setLargeFMSknobAction("void");
		me.setMENUsoftkeyAction("displayMenu");
	},
	
	enterMenu: func(FPLNOLINE){
		var no_choix = me.mud.getSelectedBlock();
		if(no_choix==0){
			setprop("/autopilot/route-manager/input","@ACTIVATE");
			setprop("/instrumentation/gps/selected-course-deg",getprop("/instrumentation/gps/wp/wp[1]/bearing-mag-deg"));
		}elsif(no_choix==1){
			#setprop("/autopilot/route-manager/input","@ACTIVATE");
			setprop("/autopilot/route-manager/active",0);
		}elsif(no_choix==2){
			setprop("/autopilot/route-manager/input","@JUMP"~FPLNOLINE);
			setprop("/instrumentation/gps/selected-course-deg",getprop("/instrumentation/gps/wp/wp[1]/bearing-mag-deg"));
		}elsif(no_choix==3){
			setprop("/autopilot/route-manager/input","@REMOVE"~FPLNOLINE);
			setprop("/instrumentation/gps/selected-course-deg",getprop("/instrumentation/gps/wp/wp[1]/bearing-mag-deg"));
		}elsif(no_choix==4){

		}
		me.closeMud();
	},
	
	D: func {
		var title = me.mud.getTitle();
		me.closeMud();
		if(substr(title, 0, 9) == "DIRECT TO"){
			me.closeMud();
			DLINE = [];
		}else{
			var nb_results = 100;
			me.mud.wipe();
			DLINE = [];
			me.mud.setTitle("DIRECT TO");
			
			var points = [];
			var searchTypes = [ "airport","fix","vor","ndb" ];
			
			for(var i=0;i<size(searchTypes);i=i+1){
				lockSearches();
				searchNearestNavaid(searchTypes[i], nb_results);
				unlockSearches();
				
				while (getprop('/instrumentation/gps/scratch/has-next')) {
					var ident = getprop('/instrumentation/gps/scratch/ident');
					var distance = getprop('/instrumentation/gps/scratch/distance-nm');
					var bearing = getprop('/instrumentation/gps/scratch/mag-bearing-deg');
					var type = searchTypes[i];
					var point = {ident:ident,distance:distance,bearing:bearing,type:type};
					append(points,point);
					setprop("/instrumentation/gps/command", "next");
				}
            }
			
			var points_sorted = sort (points, func (a,b) a.distance - b.distance);
			
			for(var i=0;i<nb_results;i=i+1){
				append(DLINE,points_sorted[i].ident ~ "," ~ points_sorted[i].type);
				me.mud.add([sprintf("%s -- DST %.1fNM BRG %03i %s",points_sorted[i].ident,points_sorted[i].distance,points_sorted[i].bearing,points_sorted[i].type)], void);
			}
			me.mud.open();
			me.setSmallFMSknobAction("select");
			me.setLargeFMSknobAction("select10");
			me.setENTsoftkeyAction("selectD");
			me.mud.highlight();
		}
	},
	
	selectD: func {
		lockSearches();
		var id = split(",",DLINE[me.mud.getSelectedBlock()])[0];
		var type = split(",",DLINE[me.mud.getSelectedBlock()])[1];
		searchGPSpoint(id,type);
		setprop("/instrumentation/gps/command", "obs");
		#setprop("/instrumentation/gps/command", "dto");
		unlockSearches();
		setprop("/instrumentation/zkv1000/gps/mode", "obs");
		setprop("/instrumentation/zkv1000/gps/id", id);
		setprop("/instrumentation/gps/obs-mode",1);
		setprop("/autopilot/route-manager/active",0);
		setprop("/instrumentation/gps/selected-course-deg",getprop("/instrumentation/gps/wp/wp[1]/bearing-mag-deg"));
		me.closeMud();
	},
	
	closeMud: func{
		me.mud.close();
		me.setSmallFMSknobAction("void");
		me.setLargeFMSknobAction("void");
		me.setENTsoftkeyAction("void");
	},
	
    softkeyActionTable: [],

    set_softkeyActionTable: func {
        me.softkeyActionTable = [
            [func{me.TGLEIS(1)},               func{me.goto(2)},void,             func{me.goto(4)},  void,              func{me.goto(1)},  func{me.ADFDME()},            func{me.DISPLAYXPDR()},func{me.IDENT()},            func{me.TMRREF()},            func{me.NRST()}],
            [void,               func{me.VOR1()},            func{me.VOR2()},             func{me.GPS()},    func{me.CDIOFF()},              void,              void,              void,             void,             void,              func{me.goto(0)}],
            [func{me.INSETOFF()},func{me.goto(3)},func{me.SYMB()},  func{me.TRAFFIC()},func{me.TOPO()},   func{me.TERRAIN()},func{me.STRMSCP()},func{me.NEXRAD()},func{me.XMLTNG()},void,              func{me.goto(0)}],
            [func{me.DCLTROFF()},func{me.DCLTR(1)},func{me.DCLTR(2)}, func{me.DCLTR(3)},void,            ,void,              void,              void,             void,              void,             func{me.goto(2)}],
            [func{me.LIGHT()},              func{me.DFLTS()},func{me.goto(8)}, func{me.DME()},    func{me.goto(5)},   func{me.HSI360()}, func{me.HSIARC()},  func{me.goto(6)},             func{me.goto(9)}, func{me.STDBARO()},func{me.goto(0)}],
            [func{me.BRG1(1)},   func{me.BRG1(2)},func{me.BRG1(3)}, void,              func{me.BRGOFF(1)},void,              void,              void,             void,             void,              func{me.goto(4)}],
            [func{me.BRG2(1)},   func{me.BRG2(2)},func{me.BRG2(3)}, void,              func{me.BRGOFF(2)},void,              void,              void,             void,             void,              func{me.goto(4)}],
            [void,               void,            void,             void,              void,              func{me.TERRAINLORES()}, func{me.TERRAINHIRES()}, void,             void,             void,              func{me.goto(2)}],
            [void,               void,            func{me.OPTN(1)}, func{me.OPTN(2)},  func{me.OPTN(3)},  void,              func{me.WINDOFF()},void,             void,             void,              func{me.goto(4)}],
            [void,               void,            void,             void,              void,              func{me.METERS()}, void,              func{me.IN()},    func{me.HPA()},   void,              func{me.goto(4)}],
            [void,               void,            func{me.XPDRSTDBY()},func{me.XPDRON()},    func{me.XPDRALT()},   func{me.XPDRGND()},   func{me.XPDRVFR()},   func{me.CODE()},  func{me.IDENT()},            void,              func{me.goto(0)}],
            [func{me.XPDR(0)},   func{me.XPDR(1)},func{me.XPDR(2)}, func{me.XPDR(3)},  func{me.XPDR(4)},  func{me.XPDR(5)},  func{me.XPDR(6)},  func{me.XPDR(7)}, func{me.XPDR(8)}, func{me.XPDRBKSP()},              func{me.XPDR(9)}],
            [func{me.TGLEIS(1)},  func{me.TGLEIS(2)},func{me.TGLEIS(3)},       void,              void,              void,              void,           void,          void,          void,              func{me.goto(0)}],
			[func{me.TGLEIS(1)},  func{me.TGLEIS(2)},func{me.TGLEIS(3)},       void,              void,              void,              void,          func{me.FUEL(1)},           func{me.FUEL(2)},          func{me.FUEL(3)},          func{me.goto(0)}],
			[void,  void  , void,        func{me.TGLSYMB(0)},              func{me.TGLSYMB(1)},              func{me.TGLSYMB(2)},              func{me.TGLSYMB(3)},          void,           void,          void,          func{me.goto(2)}],
			[void,  void  , void,        void,              void,              void,              void,          void,           void,          void,          void],
        ];
    }
};

var menuTable = [
    'ENGN    MAP             PFD              CDI    ADF   XPDR  IDENT   TMR   NRST',
    '         VOR1   VOR2   GPS    OFF                                                 BACK',
    ' OFF   DCLTR SYMB  TRAFF  TOPO  TERR  STRM   NEXR XMLTG           BACK',
    ' OFF   DCLT1 DCLT2 DCLT3                                                        BACK',
    'LIGHT DFLTS  WIND   DME   BRG1  360 H  ARC H BRG2  ALT U  BARO  BACK',
    'VOR1    GPS    ADF             OFF                                                BACK',
    'VOR2    GPS    ADF             OFF                                                BACK',
    '                                              LORES HIRES                            BACK',
    '                  OPT1   OPT2   OPT3            OFF                              BACK',
    '                                             METER             IN     HPA            BACK',
    '                   STBY    ON     ALT    GND    VFR   CODE  IDENT          BACK',
    '   0        1       2        3       4        5       6        7    ENT    BKSP  BACK',
    'ENGN   SYST   FUEL                                                                 BACK',
	'ENGN   SYST   FUEL                                      DECF   INCF   RSTF   BACK',
	'                             AIRP   VOR    NDB    FIX                               BACK',
	'                                                                                         '
];

