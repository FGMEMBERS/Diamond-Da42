# ------------------------------------
# ---- Thanks to 5H1N0B1 for help ----
# ------------------------------------

var pfdCursors = func {

  # -------------------- prop-thrust
  if(getprop('/engines/engine[0]/prop-thrust')!=nil) {
    setprop('/instrumentation/zkv1000/mfd/thrust0', getprop('/engines/engine[0]/prop-thrust') / 400);
  }
  if(getprop('/engines/engine[1]/prop-thrust')!=nil) {
    setprop('/instrumentation/zkv1000/mfd/thrust1', getprop('/engines/engine[1]/prop-thrust') / 400);
  }
  # -------------------- rpm
  if(getprop('/engines/engine[0]/rpm')!=nil) {
    setprop('/instrumentation/zkv1000/mfd/rpm0', getprop('/engines/engine[0]/rpm') / 2700);
  }
  if(getprop('/engines/engine[1]/rpm')!=nil) {
    setprop('/instrumentation/zkv1000/mfd/rpm1', getprop('/engines/engine[1]/rpm') / 2700);
  }
  # -------------------- oil-temperature-degf
  if(getprop('/engines/engine[0]/oil-temperature-degf')!=nil){
    setprop('/instrumentation/zkv1000/mfd/oilt0', getprop('/engines/engine[0]/oil-temperature-degf') / 250);
  }
  if(getprop('/engines/engine[1]/oil-temperature-degf')!=nil){
    setprop('/instrumentation/zkv1000/mfd/oilt1', getprop('/engines/engine[1]/oil-temperature-degf') / 250);
  }
  # -------------------- egt-degf
  if(getprop('/engines/engine[0]/egt-degf')!=nil){
    setprop('/instrumentation/zkv1000/mfd/egt0', getprop('/engines/engine[0]/egt-degf') / 80);
  }
  if(getprop('/engines/engine[1]/egt-degf')!=nil){
    setprop('/instrumentation/zkv1000/mfd/egt1', getprop('/engines/engine[1]/egt-degf') / 80);
  }
  # -------------------- left-main-bus / right-main-bus
  if(getprop('/systems/electrical/bus/left-main-bus')!=nil){
    setprop('/instrumentation/zkv1000/mfd/volt0', getprop('/systems/electrical/bus/left-main-bus') / 32);
  }
  if(getprop('/systems/electrical/bus/right-main-bus')!=nil){
    setprop('/instrumentation/zkv1000/mfd/volt1', getprop('/systems/electrical/bus/right-main-bus') / 32);
  }
  
  settimer(pfdCursors, 0.08);
}

pfdCursors();
print("zkv1000 loaded");
