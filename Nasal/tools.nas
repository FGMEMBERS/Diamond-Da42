var time_deice_max = 0;
var last_time = 0.0;

## from senecaII
# throttle, feather and condition with mouse
var MouseHandler = {
  new : func() {
    var obj = { parents : [ MouseHandler ] };

    obj.propertyX = nil;
    obj.factorX = 1.0;
    obj.propertyY = nil;
    obj.factorY = 1.0;
    obj.minY = 0.0;
    obj.maxY = 1.0;
    obj.minX = 0.0;
    obj.maxX = 1.0;

    obj.YListenerId = setlistener( "devices/status/mice/mouse/accel-y", 
    func(n) { obj.YListener(n); }, 1, 0 );
    
    obj.XListenerId = setlistener( "devices/status/mice/mouse/accel-x", 
    func(n) { obj.XListener(n); }, 1, 0 );

    return obj;
  },

  YListener : func(n) {
    me.propertyY == nil and return;
    me.factorY == 0 and return;
    n == nil and return;
    var v = n.getValue();
    v == nil and return;

    if(getprop(me.propertyY)!=nil){
      if(getprop(me.propertyY) > me.maxY){
        setprop(me.propertyX,me.maxX);
      }
      if(getprop(me.propertyY) < me.minY){
        setprop(me.propertyY,me.minY);
      }
    }
    if(getprop(me.propertyY)==nil or (getprop(me.propertyY) < me.maxY and getprop(me.propertyY) > me.minY) or (getprop(me.propertyY) >= me.maxY and v < 0) or (getprop(me.propertyY) <= me.minY and v > 0)){
      fgcommand("property-adjust", props.Node.new({ 
        "offset" : v,
        "factor" : me.factorY,
        "property" : me.propertyY
      }));
    }
  },
  
  XListener : func(n) {
    me.propertyX == nil and return;
    me.factorX == 0 and return;
    n == nil and return;
    var v = n.getValue();
    v == nil and return;
    
    if(getprop(me.propertyX)!=nil){
      if(getprop(me.propertyX) > me.maxX){
        setprop(me.propertyX,me.maxX);
      }
      if(getprop(me.propertyX) < me.minX){
        setprop(me.propertyX,me.minX);
      }
    }
    if(getprop(me.propertyX)==nil or (getprop(me.propertyX) < me.maxX and getprop(me.propertyX) > me.minX) or (getprop(me.propertyX) >= me.maxX and v < 0) or (getprop(me.propertyX) <= me.minX and v > 0)){
      fgcommand("property-adjust", props.Node.new({ 
        "offset" : v,
        "factor" : me.factorX,
        "property" : me.propertyX
      }));
    }
  },

  setX : func( propertyX = nil, factorX = 1.0 , minX = 0.0, maxX = 1.0) {
    me.propertyX = propertyX;
    me.factorX = factorX;
    me.minX = minX;
    me.maxX = maxX;
  },
  
  setY : func( propertyY = nil, factorY = 1.0 , minY = 0.0, maxY = 1.0) {
    me.propertyY = propertyY;
    me.factorY = factorY;
    me.minY = minY;
    me.maxY = maxY;
  },

};

var mouseHandler = MouseHandler.new();

var TankSelection = func{
  var no_moteur_tank_0 = getprop("/controls/fuel/tank[0]/position");
  var no_moteur_tank_1 = getprop("/controls/fuel/tank[1]/position");

  var tank0_selected = 0;
  var tank1_selected = 0;
  #choix du reservoir utilise
  if(no_moteur_tank_0==2 or no_moteur_tank_1==1){
    tank0_selected = 1;
  }
  if(no_moteur_tank_1==2 or no_moteur_tank_0==1){
    tank1_selected = 1;
  }
  
  var tank0_mixture = 0;
  var tank1_mixture = 0;
  #le moteur est il alimente
  if((no_moteur_tank_0==2 and getprop("/consumables/fuel/tank[0]/empty")==0) or (no_moteur_tank_0==1 and getprop("/consumables/fuel/tank[1]/empty")==0)){
    tank0_mixture = 1;
    setprop("/engines/engine[0]/out-of-fuel",0);
  }
  if((no_moteur_tank_1==2 and getprop("/consumables/fuel/tank[1]/empty")==0) or (no_moteur_tank_1==1 and getprop("/consumables/fuel/tank[0]/empty")==0)){
    tank1_mixture = 1;
    setprop("/engines/engine[1]/out-of-fuel",0);
  }
  
  setprop("/consumables/fuel/tank[0]/selected",tank0_selected);
  setprop("/consumables/fuel/tank[1]/selected",tank1_selected);
  setprop("/controls/engines/engine[0]/mixture",tank0_mixture);
  setprop("/controls/engines/engine[1]/mixture",tank1_mixture);
}
setlistener("/controls/fuel/tank[0]/position", TankSelection);
setlistener("/controls/fuel/tank[1]/position", TankSelection);

#on reprend les fonctions gear et flaps parce qu'ils sont dirigés par electricité
controls.gearDown = func(v) {

  ##emergency gear down
  if(getprop("/controls/gear/emergency")!=nil and getprop("/controls/gear/emergency")==1){
    return;
  }
  
  #verification de l electricite
  if(getprop("/controls/electric/alimentation/gear")==nil or getprop("/controls/electric/alimentation/gear")==0){
    return;
  }
  
    if (v < 0) {
        if(!getprop("gear/gear[1]/wow")){
      setprop("/controls/gear/gear-down", 0);
      setprop("/controls/switches/geardown",0);
    }
    } elsif (v > 0) {
    setprop("/controls/gear/gear-down", 1);
    setprop("/controls/switches/geardown",1);
    }
}

var positionGear = func(){
  var position = getprop("/controls/switches/geardown");
  if(position!=nil){
    if(position==1){
      controls.gearDown(1);
    }else{
      controls.gearDown(-1);
    }
  }
}
setlistener("/controls/switches/geardown", positionGear);

var emergencyGearDown = func{
  if(getprop("/controls/gear/emergency")!=nil and getprop("/controls/gear/emergency")==1){
    setprop("/controls/gear/gear-down", 1);
  }
}
setlistener("/controls/gear/emergency",emergencyGearDown);

controls.flapsDown = func(step) {
  if(step==-1 and getprop("/controls/switches/flaplever-switch")>0){
    setprop("/controls/switches/flaplever-switch",getprop("/controls/switches/flaplever-switch")-1);
  }
  
  if(step==1 and getprop("/controls/switches/flaplever-switch")<2){
    setprop("/controls/switches/flaplever-switch",getprop("/controls/switches/flaplever-switch")+1);
  }
}

var lastFlapStep=0;
var positionFlaps = func(){
  position = getprop("/controls/switches/flaplever-switch");
  if(position!=nil){
    if(getprop("/controls/electric/alimentation/flap")!=nil and getprop("/controls/electric/alimentation/flap")==1){
      while(position!=lastFlapStep){
        if(position<lastFlapStep){
          controls.stepProps("/controls/flight/flaps", "/sim/flaps", -1);
          lastFlapStep = lastFlapStep - 1;
        }else if(position>lastFlapStep){
          controls.stepProps("/controls/flight/flaps", "/sim/flaps", 1);
          lastFlapStep = lastFlapStep + 1;
        }
      }
    }
  }
}
setlistener("/controls/switches/flaplever-switch", positionFlaps);
setlistener("/controls/electric/alimentation/flap", positionFlaps);

controls.startEngine = func(v = 1, which...) {
    if (!v and !size(which))
        return props.setAll("/controls/engines/engine", "starter", 0);
    if(size(which)) {
        foreach(var i; which)
            foreach(var e; engines)
                if(e.index == i and getprop("/controls/electric/alimentation/engines/engine["~e.index~"]/starter")==1){
                    e.controls.getNode("starter").setBoolValue(v);
        }
    } else {
        foreach(var e; engines)
            if(e.selected.getValue() and getprop("/controls/electric/alimentation/engines/engine["~e.index~"]/starter")==1){
                e.controls.getNode("starter").setBoolValue(v);
      }
    }
}

controls.stepMagnetos = func(change) {
  #do nothing now ...
}

##calcul si le moteur peut fonctionner en fonction des ecu (simulation via les magnetos)
var controlEngine = func(no_engine){
  setprop("/controls/electric/alimentation/engines/engine["~no_engine~"]/ecus/ecu[0]/selected",0);
  setprop("/controls/electric/alimentation/engines/engine["~no_engine~"]/ecus/ecu[1]/selected",0);
  var no_ecu = -1;
  var positionSwitchEcu = getprop("/controls/switches/ecu["~no_engine~"]/switch");
  if(positionSwitchEcu==0){
    if(getprop("/controls/electric/alimentation/engines/engine["~no_engine~"]/ecus/ecu[1]/serviceable")==1){#ecu b selected
      setprop("/controls/electric/alimentation/engines/engine["~no_engine~"]/ecus/ecu[1]/selected",1);
      no_ecu = 1;
    }
  }else{
    if(getprop("/controls/electric/alimentation/engines/engine["~no_engine~"]/ecus/ecu[0]/serviceable")==1){#ecu a
      setprop("/controls/electric/alimentation/engines/engine["~no_engine~"]/ecus/ecu[0]/selected",1);
      no_ecu = 0;
    }elsif(getprop("/controls/electric/alimentation/engines/engine["~no_engine~"]/ecus/ecu[1]/serviceable")==1){#ecu b
      setprop("/controls/electric/alimentation/engines/engine["~no_engine~"]/ecus/ecu[1]/selected",1);
      no_ecu = 1;
    }
  }
  if(no_ecu!=-1){
    setprop("/controls/engines/engine["~no_engine~"]/magnetos",3);
  }else{
    setprop("/controls/engines/engine["~no_engine~"]/magnetos",0);
  }
}

var controlEngineEcu = func(m){
  var no_engine = m.getParent().getParent().getParent().getIndex();
  controlEngine(no_engine);
}

var controlEcu = func(m){
  var no_engine = m.getParent().getIndex();
  controlEngine(no_engine);
}

setlistener("/controls/electric/alimentation/engines/engine[0]/ecus/ecu[0]/serviceable",controlEngineEcu);
setlistener("/controls/electric/alimentation/engines/engine[0]/ecus/ecu[1]/serviceable",controlEngineEcu);
setlistener("/controls/switches/ecu[0]/switch",controlEcu);
setlistener("/controls/electric/alimentation/engines/engine[1]/ecus/ecu[0]/serviceable",controlEngineEcu);
setlistener("/controls/electric/alimentation/engines/engine[1]/ecus/ecu[1]/serviceable",controlEngineEcu);
setlistener("/controls/switches/ecu[1]/switch",controlEcu);

var nyi = func (x) { gui.popupTip(x ~ ": not (yet ?) implemented", 3); }

##
# Initialization.
#
var engines = [];
_setlistener("/sim/signals/fdm-initialized", func {
    var sel = props.globals.getNode("/sim/input/selected", 1);
    var engs = props.globals.getNode("/controls/engines").getChildren("engine");

    foreach(var e; engs) {
        var index = e.getIndex();
        var s = sel.getChild("engine", index, 1);
        if(s.getType() == "NONE") s.setBoolValue(1);
        append(engines, { index: index, controls: e, selected: s });
    }
});

#activation de la stall horn (non gerer par yasim)
var stall_horn = func{
  var alert = 0;
  var kias = getprop("velocities/airspeed-kt");
  var wow0 = getprop("gear/gear[0]/wow");
  var wow1 = getprop("gear/gear[1]/wow");
  var wow2 = getprop("gear/gear[2]/wow");
  #var button_click = getprop("/controls/switches/stall_annunciator-click");
  if(getprop("/controls/electric/alimentation/stallwrn")){
    var stall_speed = 62 - (getprop("/controls/flight/flaps")*6);
    if(kias<stall_speed and !wow1 and !wow2 and !wow0){
      alert=1;
    }
  }
  
  setprop("/sim/alarms/stall-warning",alert);
}

var init = func {
  #print("Initialising urban effect and sone things else");
  #setprop("/sim/rendering/quality-level",2);
  #setprop("/sim/rendering/urban-shader",1);
  #setprop("/sim/rendering/transition-shader",1);
  #setprop("/sim/rendering/random-vegetation",1);

  
  print("Inititialisation DA42 ...done");
  
  main_loop();
}

# Setup listener call to start update loop once the fdm is initialized
setlistener("sim/signals/fdm-initialized", init);

#main loop
var main_loop = func {
  
  var time = getprop("/sim/time/elapsed-sec");
    var dt = time - last_time;
    last_time = time;
  
  stall_horn();
  deice_system(dt);
  
  ##failures
  #check_g_load();
  #check_vne_flaps();
  #check_vne_gears();
  #check_vne_structure();
  
  settimer(main_loop, 0);
}

var deice_system = func(dt){
  var deice_mode = getprop("/controls/deice/mode");
  var deice_alimentation = getprop("/controls/electric/alimentation/deice");
  var deice_lightcone = getprop("/controls/switches/deice/icelight");
  var deice_speed = getprop("/controls/switches/deice/speed");
  var liquid_level = getprop("/consumables/deice");
  
  #allumage ice light cone
  if(deice_alimentation==1 and deice_lightcone==1){
    setprop("/controls/lighting/antiicelight",1);
  }else{
    setprop("/controls/lighting/antiicelight",0);
  }
  
  #changement de mode
  if(deice_alimentation==1 and liquid_level>0){##pour l'instant , on gere les lumieres en fonction de la presence de liquide
    if(deice_mode!=2){
      setprop("/controls/deice/mode",deice_speed);
      deice_mode = deice_speed;
      if(deice_mode == -1){
        time_deice_max = 0;
      }
    }else{
      time_deice_max = time_deice_max + dt;
      if(time_deice_max>120){# 2 minutes de fonctionnement
        time_deice_max = 0;
        setprop("/controls/deice/mode",deice_speed);
      }
    }
    
    #consommation 
    if(liquid_level!=nil and liquid_level>0){
      if(deice_mode==0){#mode normal, conso en 2h30
        liquid_level = liquid_level - dt;
      }elsif(deice_mode==1){#mode high, conso en 1h00
        liquid_level = liquid_level - dt*2.5;
      }elsif(deice_mode==2){#mode max, conso en 0h30
        liquid_level = liquid_level - dt*5;
      }
      if(liquid_level<0){
        liquid_level = 0;
      }
      setprop("/consumables/deice",liquid_level);
    }
  }else{
    setprop("/controls/deice/mode",-1);
  }
}

var deice_system_max_toggle = func{
  if(getprop("/controls/electric/alimentation/deice")!=nil and getprop("/controls/electric/alimentation/deice")==1 and getprop("/controls/deice/mode")!=nil and getprop("/controls/deice/mode")>-1){
    setprop("/controls/deice/mode",2);
    time_deice_max = 0;
  }
}
setlistener("/controls/switches/deice/max",deice_system_max_toggle);

## a faire
var check_g_load = func{
  var g_load = getprop("/accelerations/pilot-g");
  if(g_load!=nil and (g_load>3.58 or g_load<-1.43)){
    g_dt = g_dt + 1;
  }else{
    g_dt = 0;
  }

  if(g_dt>5){
    setprop("/controls/flight/wing_destroyed",1);
    setprop("/sim/sound/crash",1);
    setprop("/sim/messages/copilot","Too much G load !!!!!!!!!!!!!");
  }
}

var check_vne_flaps = func{
  var kias = getprop("velocities/airspeed-kt");
  var flaps = getprop("/controls/flight/flaps");
  if(kias!=nil and kias>95 and flaps!=nil and flaps>0){
    setprop("/sim/failure-manager/controls/flight/flaps/serviceable",0);
#   setprop("/sim/sound/crash",1);
    setprop("/sim/messages/copilot","VNE for flaps exceed !!!!!!!!!!!!!");
  }
}

var check_vne_structure = func{
  var kias = getprop("velocities/airspeed-kt");
  if(kias!=nil and kias>151){
    setprop("/controls/flight/wing_destroyed",1);
    setprop("/sim/sound/crash",1);
    setprop("/sim/messages/copilot","VNE exceed !!!!!!!!!!!!!");
  }
}
