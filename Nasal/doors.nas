# =====
# Doors
# =====

Doors = {};

Doors.new = func {
   obj = { parents : [Doors],
           crew : aircraft.door.new("instrumentation/doors/crew", 8.0),
           passenger : aircraft.door.new("instrumentation/doors/passenger", 8.0),
		       leftbagage : aircraft.door.new("instrumentation/doors/leftbagage", 3.0),
		       rightbagage : aircraft.door.new("instrumentation/doors/rightbagage", 3.0)
         };
   return obj;
};

Doors.crewexport = func {
   me.crew.toggle();
}

Doors.passengerexport = func {
   me.passenger.toggle();
}

Doors.leftbagageexport = func {
   me.leftbagage.toggle();
}

Doors.rightbagageexport = func {
   me.rightbagage.toggle();
}

# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
doorsystem = Doors.new();

