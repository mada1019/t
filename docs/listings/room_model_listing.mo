package room_model_backup

  connector Temperature
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC t;
  end Temperature;

  connector HeatFlow
    Modelica.SIunits.HeatFlowRate qdot;
  end HeatFlow;

  connector MassTemperature
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC t;
    Modelica.SIunits.MassFlowRate mdot;
  end MassTemperature;

  connector RadiantEnergyFluenceRate
    Modelica.SIunits.DensityOfHeatFlowRate radiation_sun;
  end RadiantEnergyFluenceRate;

  model CV_Radiator "control volume for a discretized radiator"
    
    /** parameter **/
    outer parameter Modelica.SIunits.CoefficientOfHeatTransfer u_radiator 
      "heat transfer coefficient of the radiator";
    outer parameter Modelica.SIunits.SpecificHeatCapacity cp_water 
      "specific heat capacity of water";
    outer Modelica.SIunits.Mass cv_m 
      "mass within one control volume";
    outer Modelica.SIunits.Area exchange_surface 
      "surface of one control volume at which heat transfer takes place";
    Modelica.SIunits.Energy cv_u 
      "inner energy of the control volume";
    Modelica.SIunits.HeatFlowRate cv_qdot 
      "heatflowrate over the borders of the control volume";
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC cv_temperature_out(start=21.2, fixed=true) 
      "temperature of the fluid leaving the control volume";
    
    /** states **/
    outer Modelica.SIunits.Conversions.NonSIunits.Temperature_degC room_temperature_cv 
      "temperature within the room";

    /** controls **/
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC cv_temperature_in=inlet.t 
      "temperature of the fluid streaming in the control volume";
    outer Modelica.SIunits.MassFlowRate mdot 
      "massflowrate within the radiator";

  equation
    /* calculate inner energy */
    cv_u = cv_m * cp_water * cv_temperature_out;
    /* calculate derival of the inner energy */
    der(cv_u) = mdot * cp_water * (cv_temperature_in - cv_temperature_out) - cv_qdot;
    /* calculate heatflowrate */
    cv_qdot = u_radiator * exchange_surface * (cv_temperature_out - room_temperature_cv);
    /* commit calculated temperature */
    outlet.t = cv_temperature_out;
  end CV_Radiator;

  model Radiator "model for a discretized radiator within a room"

    /** parameter **/
    parameter Real radiator_element_number=106
      "number of normed elements of which the radiator consists";
    parameter Real radiator_tubes_element=2
      "number of parallel tubes in one element";
    parameter Integer cv_number = 20
      "number of control volumes in which the radiator is discretized";
    parameter Modelica.SIunits.Length radiator_element_length=0.045
      "length of one element depending on type (Recknagel 2013/2014: Heizung und Klimatechnik S.815ff.)";
    parameter Modelica.SIunits.Height tube_length_vertical=0.4
      "height of one element depending on type (Recknagel 2013/2014: Heizung und Klimatechnik S.815ff.)";
    parameter Modelica.SIunits.Diameter tube_diameter_horizontal=0.05
      "diameter of the horizontal tubes depending on type (Recknagel 2013/2014: Heizung und Klimatechnik S.815ff.)";
    parameter Modelica.SIunits.Diameter tube_diameter_vertical=0.0255
      "diameter of the vertical tubes depending on type (Recknagel 2013/2014: Heizung und Klimatechnik S.815ff.)";
    parameter Modelica.SIunits.Density rho_water = 1000 
      "density of water";
    parameter Modelica.SIunits.Mass radiator_element_mass=0.35
      "mass within one element of the radiator depending on type (Recknagel 2013/2014: Heizung und Klimatechnik S.815ff.)";
    inner parameter Modelica.SIunits.CoefficientOfHeatTransfer u_radiator = 12.9872
      "heat transfer coefficient of the radiator";
    inner parameter Modelica.SIunits.SpecificHeatCapacity cp_water = 4200
      "specific heat capacity of water";                                        
    CV_Radiator[cv_number] cv_radiator
      "array of control volumes to discretize the radiator";
    Modelica.SIunits.HeatFlowRate radiator_qdot_out
      "heatflow which is leaving the radiator";
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC radiator_temperature_out
      "calculated(predicted) temperature of the water leaving the radiator";
    inner Modelica.SIunits.Mass cv_m 
      "mass within one control volume";
    inner Modelica.SIunits.Area exchange_surface
      "surface of one control volume at which h";

    /** states **/
    inner Modelica.SIunits.Conversions.NonSIunits.Temperature_degC room_temperature_cv
      "temperature within the room for the control volume";
    outer Modelica.SIunits.Conversions.NonSIunits.Temperature_degC room_temperature
      "temperature within the room from the room";

    /** controls **/
    inner Modelica.SIunits.MassFlowRate mdot=inlet.mdot
      "massflowrate within the radiator";
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC radiator_inlet = inlet.t
      "temperature of the inflowing fluid";

  equation
    /* calculate surface of one control volume */
    exchange_surface = (radiator_element_number * radiator_element_length * 2 * Modelica.Constants.pi * tube_diameter_horizontal + radiator_element_number * radiator_tubes_element * tube_length_vertical * Modelica.Constants.pi * tube_diameter_vertical)/cv_number;
    /* calculate mass within one control volume */
    cv_m = (radiator_element_mass * radiator_element_number)/cv_number;
    /* commit temperature of radiator fluid inlet to the first control volume */
    cv_radiator[1].inlet.t = radiator_inlet;
    /* commit fluid temperatures within the radiator control volumes */
    for i in 1 : (cv_number-1) loop
     connect( cv_radiator[i].outlet, cv_radiator[i+1].inlet);
    end for;
    /* save fluid temperature of the last radiator control volumes */
    radiator_temperature_out=cv_radiator[cv_number].outlet.t;
    /* calculate and save the heatflowrate which is leaving the radiator*/
    radiator_qdot_out = sum(cv_radiator.cv_qdot);
    /* commit roomtemperature*/
    room_temperature=room_temperature_cv;
    outlet.mdot = mdot;
    outlet.t = radiator_temperature_out;
  end Radiator;

  model Room_radiator_window "model of a room for mpc purpose with JModelica.org"

      /** parameter p **/
      parameter Modelica.SIunits.Length room_length=7.81 
        "length of the room";
      parameter Modelica.SIunits.Breadth room_breadth=5.78
        "breadth of the room";
      parameter Modelica.SIunits.Height room_height=2.99 
        "height of the room";
      parameter Modelica.SIunits.Length window_length=7 
        "length of the window";
      parameter Modelica.SIunits.Height window_height=2.08
        "height of the window";
      parameter Modelica.SIunits.Density rho_air = 1.2 
        "density of air";
      parameter Modelica.SIunits.CoefficientOfHeatTransfer u_glass=2.0
        "heat transfer coefficient for glass ";                                    
      parameter Modelica.SIunits.CoefficientOfHeatTransfer u_wall=0.612986
        "heat transfer coefficient for the walls of the room";                     
      parameter Modelica.SIunits.SpecificHeatCapacity cp_air=1000
        "specific heat capacity of air";
      Radiator heating 
        "instance of a radiator";
      Window window 
        "instance of a window";
      Modelica.SIunits.Volume room_volume 
        "volume of the room";
      Modelica.SIunits.Mass room_mass 
        "mass of air within the room";
      Modelica.SIunits.Area building_surface
        "sum of contacting surfaces (walls) with other rooms of the building";
      Modelica.SIunits.Area environment_surface
        "sum of contacting surfaces (walls) with the environment";
      inner Modelica.SIunits.Area window_surface
        "sum of contacting surfaces (windows) with the environment";
      Modelica.SIunits.Energy room_u 
        "inner energy of the system room";
      Modelica.SIunits.HeatFlowRate building_qdot
        "rate of heat flow with other rooms within the building";                  
      Modelica.SIunits.HeatFlowRate environment_qdot
        "rate of heat flow with the environment";
      Modelica.SIunits.HeatFlowRate environment_qdot_wall
        "rate of heat flow with the environment through the wall";
      Modelica.SIunits.HeatFlowRate environment_qdot_window
        "rate of heat flow with the environment through the window";
      Modelica.SIunits.HeatFlowRate qdot_loss
        "summed up rate of heatflow leaving the system";
      Modelica.SIunits.HeatFlowRate radiator_qdot
        "heat flow rate at the radiator surfaces streaming into the room";

      /** states x **/
      inner Modelica.SIunits.Conversions.NonSIunits.Temperature_degC room_temperature(start=24, fixed=true)
        "temperature within the room (Initially about 24 degree celsius)";

      /** controls u **/
      Modelica.SIunits.MassFlowRate mdot=inlet_radiator.mdot
        "commitment of the massflowrate to the radiator";
      Modelica.SIunits.Conversions.NonSIunits.Temperature_degC environment_temperature=inlet_environment.t
        "temperature of the environment";
      Modelica.SIunits.Conversions.NonSIunits.Temperature_degC building_temperature=inlet_building.t
        "temperature of the rest of the building";
      Modelica.SIunits.HeatFlowRate qdot_sun
        "rate of heat flow brought in by the sun";
      Modelica.SIunits.HeatFlowRate qdot_otherfactors=inlet_other.qdot
        "rate of heat flow brought in by other factors (e.g. people, computer)";

  equation
   /* calculate room volume */
   room_volume=room_length*room_height*room_breadth;
   /* calculate room mass */
   room_mass=room_volume*rho_air;
   /* calculate surface of the room with other rooms of the building */
   building_surface=(room_length*room_breadth*2)+(room_length*room_height*2);
   /* calculate wall surface of the room with the environment */
   environment_surface=(room_length*room_height)+(room_breadth*room_height)-window_surface;
   /* calculate window surface of the room with the environment */
   window_surface=(window_length*window_height);
   /* calculate inner energy*/
   room_u = room_mass * cp_air * room_temperature;
   /* calculate derival of the inner energy */
   der(room_u) = radiator_qdot + qdot_loss + qdot_sun + qdot_otherfactors;
   /* sum up the lost heat flow */
   qdot_loss = building_qdot+environment_qdot;
   /* calculate lost heatflow with other rooms of the building */
   building_qdot = u_wall * building_surface * (building_temperature-room_temperature);
   /* sum up the lost heatflow with the environment */
   environment_qdot = environment_qdot_window + environment_qdot_wall;
   /* calculate lost heatflow with the environment through the window */
   environment_qdot_window = u_glass * window_surface * (environment_temperature - room_temperature);
   /* calculate lost heatflow with the environment through the wall */
   environment_qdot_wall = u_wall * environment_surface * (environment_temperature - room_temperature);
   /* commit the inflowing heat flow of the radiator */
   radiator_qdot=heating.radiator_qdot_out;
   /* connect radiator and sun with room */
   connect(heating.inlet, inlet_radiator);
   connect(inlet_sun, window.inlet_sun);
   qdot_sun = window.outlet_room.qdot;
  end Room_radiator_window;

  model SourceTemp
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC t=inlet;
    Modelica.Blocks.Interfaces.RealInput inlet;
  equation
    outlet.t=t;
  end SourceTemp;

  model SourceHeat
    Modelica.SIunits.HeatFlowRate qdot=inlet;
    Modelica.Blocks.Interfaces.RealInput inlet;
  equation
    outlet.qdot=qdot;
  end SourceHeat;

  model SourceTempMass
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC t=inlet_t;
    Modelica.SIunits.MassFlowRate mdot=inlet_mdot;
    Modelica.Blocks.Interfaces.RealInput inlet_t;
    Modelica.Blocks.Interfaces.RealInput inlet_mdot;
  equation
    outlet.t=t;
    outlet.mdot=mdot;
  end SourceTempMass;

  model Window
    Modelica.SIunits.DensityOfHeatFlowRate radiation_arriving=inlet_sun.radiation_sun;
    Modelica.SIunits.HeatFlowRate qdot_effective;
    parameter Real window_transmission = 0.00687213;
    outer Modelica.SIunits.Area window_surface;
  equation
    qdot_effective = radiation_arriving * window_transmission * window_surface;
    qdot_effective = outlet_room.qdot;
  end Window;


  model SourceSun
    Modelica.SIunits.DensityOfHeatFlowRate radiation_sun = inlet;
    Modelica.Blocks.Interfaces.RealInput inlet;
    RadiantEnergyFluenceRate outlet;
  equation
    outlet.radiation_sun = radiation_sun;
  end SourceSun;

end room_model_backup;
