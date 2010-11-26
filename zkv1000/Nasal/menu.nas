var ADFDME = func { 
    nyi("AFDME softkey"); 
}

var IDENT = func { 
    nyi("IDENT softkey"); 
}

var TMRREF = func { 
    nyi("TIMER/REF softkey"); 
}

var NRST = func {
    if (getprop("/instrumentation/zkv1000/mud/title") == "NEAREST AIRPORTS") {
        closeMUD();
    }
    else {
        props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(10);
        setprop("/instrumentation/gps/scratch/type", "airport");
        setprop("/instrumentation/gps/command", "nearest");
        wipeMUD();
        setMUDTitle("NEAREST AIRPORTS");
        while (getprop('/instrumentation/gps/scratch/has-next')) {
            addToMUD([getprop('/instrumentation/gps/scratch/name'),
                      sprintf("%s -- DST %.1fNM BRG %03i", 
                          getprop('/instrumentation/gps/scratch/ident'),
                          getprop('/instrumentation/gps/scratch/distance-nm'), 
                          getprop('/instrumentation/gps/scratch/mag-bearing-deg')),
                     ], void);
            setprop("/instrumentation/gps/command", "next");
        }
        openMUD();
        highlightSelectedMUDblock();
    }
}

var VOR1 = func {
    radios.getNode("nav2-selected").setIntValue(0);
    radios.getNode("nav1-selected").setIntValue(1);
    CDIfromNAV(0);
}

var VOR2 = func {
    radios.getNode("nav1-selected").setIntValue(0);
    radios.getNode("nav2-selected").setIntValue(1);
    CDIfromNAV(1);
}

var STDBY = func { 
    setprop("/instrumentation/zkv1000/radios/xpdr-mode", "STBY");
}

var ON = func { 
    setprop("/instrumentation/zkv1000/radios/xpdr-mode", "ON");
}

var ALT = func { 
    setprop("/instrumentation/zkv1000/radios/xpdr-mode", "ALT");
}

var GND = func { 
    setprop("/instrumentation/zkv1000/radios/xpdr-mode", "GND");
}

var VFR = func { 
    XPDR_old = getprop("/instrumentation/transponder/id-code");
    setprop("/instrumentation/transponder/id-code", 1200);
}

var BKSP = func { 
    if (XPDR_n < 3) XPDR_n += 1;
}

var LIGHT = func {
    var b = "/instrumentation/zkv1000/body-emission";
    setprop(b, getprop(b) < 0.1 ? 0.5 : 0.0);
}

var CHECKLIST = func {
}

var LEAN = func {
}

var FUEL = func (v) {
}

var XPDR_n = 3;
var XPDR_old = 0;

var menuClass = {
    new: func (node) {
        var m = { parents: [ menuClass ] };
        m.local = node;
        m.set_softkeyActionTable();
        return m;
    },

    local: nil,

    goto: func (l) {
        me.level = l;
        me.local.getNode("menu-level").setIntValue(l);
        me.local.getNode("menu-text").setValue(menuTable[l]);
    },

    GPS: func { 
        nyi("GPS softkey");
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
        ALTknob = _ALTknob;
        HDGknob = _HDGknob;
        CRSknob = _CRSknob;
        BAROknob = _BAROknob;
        animeCursors = pfdCursors;
        joystick = void;
        RANGEknob = void;
        Dsoftkey = void;
        me.local.getNode("status").setIntValue(1);
        me.local.getNode("terrain").setBoolValue(0);
        init_main_loop();
        me.goto(0);
    },

    TRAFFIC: func { 
        nyi("TRAFFIC softkey");
        me.goto(0);
    },

    TOPO: func { 
        nyi("TOPO softkey");
        me.goto(0);
    },

    TERRAIN: func {
        animeCursors = moveMap;
        Dsoftkey = fromMapDirectTo;
        ALTknob = void;
        HDGknob = void;
        CRSknob = void;
        BAROknob = void;
        me.local.getNode("status").setIntValue(2);
        me.local.getNode("terrain").setBoolValue(1);
        init_main_loop();
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
        me.goto(0);
    },

    DCLTR: func (x) { 
        nyi("DCLTR" ~ x ~ " softkey");
        me.goto(0);
    },

    DFLTS: func { 
        nyi("DEFAULTS softkey");
        me.goto(0);
    },

    DME: func { 
        nyi("DME softkey");
        me.goto(0);
    },

    STDBARO: func { 
        setprop("/instrumentation/altimeter/setting-inhg", 29.92);
        me.goto(0);
    },

    BRG1: func (x) { 
        nyi("BRG1" ~ x ~ " softkey");
        me.goto(0);
    },

    BRG2: func (x) { 
        nyi("BRG2" ~ x ~ " softkey");
        me.goto(0);
    },

    BRGOFF: func (x) { 
        nyi("BRGOFF" ~ x ~ " softkey");
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
        nyi("IN softkey");
        me.goto(0);
    },

    HPA: func { 
        nyi("HPA softkey");
        me.goto(0);
    },

    XPDR: func (x) {
        if (x <= 7) {
            if (XPDR_n == 3) {
                XPDR_old = getprop("/instrumentation/transponder/id-code");
            }
            elsif (XPDR_n < 0) {
                me.goto(10);
                XPDR_n = 3;
                return;
            }
            else {
                setprop("/instrumentation/transponder/id-code", x * math.pow(10, XPDR_n));
                XPDR_n -= 1;
            }
        }
        else {
            if (x == 9) setprop("/instrumentation/transponder/id-code", XPDR_old);
            XPDR_n = 3;
            me.goto(0);
        }
    },

    CODE: func {
        getprop("/instrumentation/zkv1000/radios/xpdr-mode") == "STBY" or return;
        largeFMSknob = XPDR_change_cursor_position;
        smallFMSknob = XPDR_enter_digits;
        ENTsoftkey   = XPDR_activate_code;
        me.goto(11);
    },

    softkeyActionTable: [],

    set_softkeyActionTable: func {
        me.softkeyActionTable = [
            [void,               func{me.goto(2)},void,             func{me.goto(4)},  void,              func{me.goto(1)},  ADFDME,            func{me.goto(10)},IDENT,            TMRREF,            NRST],
            [void,               VOR1,            VOR2,             func{me.GPS()},    void,              void,              func{me.CDIOFF()}, void,             void,             void,              func{me.goto(0)}],
            [func{me.INSETOFF()},func{me.goto(3)},void,             func{me.TRAFFIC()},func{me.TOPO()},   func{me.TERRAIN()},func{me.STRMSCP()},func{me.NEXRAD()},func{me.XMLTNG()},void,              func{me.goto(0)}],
            [func{me.DCLTROFF()},void,            func{me.DCLTR(1)},func{me.DCLTR(2)}, func{me.DCLTR(3)}, void,              void,              void,             void,              void,             func{me.goto(2)}],
            [LIGHT,              func{me.DFLTS()},func{me.goto(8)}, func{me.DME()},    func{me.goto(5)},  func{me.goto(7)},  func{me.goto(6)},  void,             func{me.goto(9)}, func{me.STDBARO()},func{me.goto(0)}],
            [func{me.BRG1(1)},   func{me.BRG1(2)},func{me.BRG1(3)}, void,              func{me.BRGOFF(1)},void,              void,              void,             void,             void,              func{me.goto(4)}],
            [func{me.BRG2(1)},   func{me.BRG2(2)},func{me.BRG2(3)}, void,              func{me.BRGOFF(2)},void,              void,              void,             void,             void,              func{me.goto(4)}],
            [void,               void,            void,             void,              void,              func{me.HSI360()}, func{me.HSIARC()}, void,             void,             void,              func{me.goto(4)}],
            [void,               void,            func{me.OPTN(1)}, func{me.OPTN(2)},  func{me.OPTN(3)},  void,              func{me.WINDOFF()},void,             void,             void,              func{me.goto(4)}],
            [void,               void,            void,             void,              void,              func{me.METERS()}, void,              func{me.IN()},    func{me.HPA()},   void,              func{me.goto(4)}],
            [void,               void,            STDBY,            ON,                ALT,               GND,               VFR,               func{me.CODE()},  IDENT,            void,              func{me.goto(0)}],
            [func{me.XPDR(0)},   func{me.XPDR(1)},func{me.XPDR(2)}, func{me.XPDR(3)},  func{me.XPDR(4)},  func{me.XPDR(5)},  func{me.XPDR(6)},  func{me.XPDR(7)}, func{me.XPDR(8)}, BKSP,              func{me.XPDR(9)}],
            [void,               func{me.goto(15)},void,            func{me.goto(14)}, void,              func{me.goto(13)}, void,              CHECKLIST,        void,             void,              void],
            [void,               void,             func{me.DCLTR(1)},void,             func{me.DCLTR(2)}, void,              func{me.DCLTR(3)}, void,             void,             void,              func{me.goto(12)}],
            [void,               void,             void,            func{me.TRAFFIC()},func{me.TOPO()},   func{me.TERRAIN()},func{me.STRMSCP()},func{me.NEXRAD()},func{me.XMLTNG()},void,              func{me.goto(12)}],
            [func{me.goto(12)},  void,             LEAN,            void,              void,              void,              FUEL(1),           FUEL(2),          FUEL(3),          void,              void]
        ];
    }
};

var menuTable = [
    '         INSET            PFD              CDI    ADF   XPDR  IDENT   TMR   NRST',
    '         VOR1   VOR2   GPS    OFF                                                 BACK',
    ' OFF   DCLTR          TRAFF  TOPO  TERR  STRM   NEXR XMLTG           BACK',
    ' OFF   DCLT1 DCLT2 DCLT3                                                        BACK',
    'LIGHT DFLTS  WIND   DME   BRG1   HSI    BRG2           ALT U  BARO  BACK',
    'VOR1    GPS    ADF             OFF                                                BACK',
    'VOR2    GPS    ADF             OFF                                                BACK',
    '                                               360    ARC                              BACK',
    '                  OPT1   OPT2   OPT3            OFF                              BACK',
    '                                             METER             IN     HPA            BACK',
    '                   STBY    ON     ALT    GND    VFR   CODE  IDENT          BACK',
    '   0        1       2        3       4        5       6        7    IDENT  BKSP  BACK',
    '          ENG             MAP           DCLTR          CHKLS',
    '                 DCLT1           DCLT2          DCLT3                             BACK',
    '                          TRAFF  TOPO   TERR  STRM  NEXR  XMLTG          BACK',
    'ENGN           LEAN                              DECF   INCF   RSTF'
];


