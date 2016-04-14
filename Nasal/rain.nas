var splash_vec_loop = func(){
    var airspeed = getprop("/velocities/airspeed-kt");
    airspeed = airspeed + getprop("/engines/engine/rpm")*0.0037;

    var splash_x = -0.71 - 0.0071 * airspeed;
    var splash_y =  0.0;
    var splash_z =  0.71 + 0.0071 * airspeed;

    setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
    setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
    setprop("/environment/aircraft-effects/splash-vector-z", splash_z);

    settimer(func(){
        splash_vec_loop();
    }, 0.01);
}

splash_vec_loop();