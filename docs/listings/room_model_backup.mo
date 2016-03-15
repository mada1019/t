within ;
package room_model_backup
  connector Temperature
  Modelica.SIunits.Conversions.NonSIunits.Temperature_degC t;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
              {100,100}}), graphics={Ellipse(
            extent={{98,-98},{-98,98}},
            lineColor={0,0,255},
            fillColor={0,128,255},
            fillPattern=FillPattern.Solid)}));
  end Temperature;

  connector HeatFlow
  Modelica.SIunits.HeatFlowRate qdot;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
              {100,100}}), graphics={Ellipse(
            extent={{98,-98},{-98,98}},
            lineColor={0,0,255},
            fillColor={255,85,85},
            fillPattern=FillPattern.Solid)}));
  end HeatFlow;

  model CV_Radiator "control volume for a discretized radiator"

    /** parameter **/

    /* central parameter */
    outer parameter Modelica.SIunits.CoefficientOfHeatTransfer u_radiator
      "heat transfer coefficient of the radiator";
    outer parameter Modelica.SIunits.SpecificHeatCapacity cp_water
      "specific heat capacity of water";
    outer Modelica.SIunits.Mass cv_m "mass within one control volume";
    outer Modelica.SIunits.Area exchange_surface
      "surface of one control volume at which heat transfer takes place";
    /* calculated parameter*/
    Modelica.SIunits.Energy cv_u "inner energy of the control volume";
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
    outer Modelica.SIunits.MassFlowRate mdot "massflowrate within the radiator";

    Temperature inlet
      annotation (Placement(transformation(extent={{-434,-12},{-414,8}}),
          iconTransformation(extent={{-434,-12},{-414,8}})));
    Temperature outlet
      annotation (Placement(transformation(extent={{408,-8},{428,12}}),
          iconTransformation(extent={{408,-8},{428,12}})));
  equation
    /* calculate inner energy */
    cv_u = cv_m * cp_water * cv_temperature_out;
    /* calculate derival of the inner energy */
    der(cv_u) = mdot * cp_water * (cv_temperature_in - cv_temperature_out) - cv_qdot;
    /* calculate heatflowrate */
    cv_qdot = u_radiator * exchange_surface * (cv_temperature_out - room_temperature_cv);
    /* commit calculated temperature */
    outlet.t = cv_temperature_out;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-460,
              -440},{460,440}}),
                           graphics={Rectangle(
            extent={{-418,340},{416,-330}},
            lineColor={0,0,0},
            lineThickness=1),
          Text(
            extent={{-192,422},{232,200}},
            lineColor={0,0,0},
            lineThickness=1,
            textStyle={TextStyle.Bold},
            textString="control volume - cv"),
          Text(
            extent={{-406,42},{-296,-4}},
            lineColor={0,0,255},
            lineThickness=1,
            textString="inlet.t"),
          Text(
            extent={{280,40},{390,-6}},
            lineColor={0,0,255},
            lineThickness=1,
            textString="outlet.t"),
          Polygon(
            points={{-102,-274},{98,-274},{2,-418},{-102,-274}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None)}),       Diagram(coordinateSystem(
            preserveAspectRatio=false, extent={{-460,-440},{460,440}}), graphics));
  end CV_Radiator;

  model Radiator "model for a discretized radiator within a room"

    /** parameter **/

    /* parameter of the radiator */
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
    parameter Modelica.SIunits.Density rho_water = 1000 "density of water";
    parameter Modelica.SIunits.Mass radiator_element_mass=0.35
      "mass within one element of the radiator depending on type (Recknagel 2013/2014: Heizung und Klimatechnik S.815ff.)";

    inner parameter Modelica.SIunits.CoefficientOfHeatTransfer u_radiator = 12.9872
      "heat transfer coefficient of the radiator";
    inner parameter Modelica.SIunits.SpecificHeatCapacity cp_water = 4182
      "specific heat capacity of water";                                          // Etvl Modelica aus Grundgleichung berechnet in Abh?nigkeit von Temperatur
    CV_Radiator[cv_number] cv_radiator
      "array of control volumes to discretize the radiator";

    /* calculated parameter */
    Modelica.SIunits.HeatFlowRate radiator_qdot_out
      "heatflow which is leaving the radiator";
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC radiator_temperature_out
      "calculated(predicted) temperature of the water leaving the radiator";
    //Modelica.SIunits.Volume cv_v "volume within one control volume";

    /* parameter of the control volumes */
    inner Modelica.SIunits.Mass cv_m "mass within one control volume";
    inner Modelica.SIunits.Area exchange_surface
      "surface of one control volume at which h";

    /** states **/

    /* states of the radiator variable */
    inner Modelica.SIunits.Conversions.NonSIunits.Temperature_degC room_temperature_cv
      "temperature within the room for the control volume";
    outer Modelica.SIunits.Conversions.NonSIunits.Temperature_degC room_temperature
      "temperature within the room from the room";

    /** controls **/
    inner Modelica.SIunits.MassFlowRate mdot=inlet.mdot
      "massflowrate within the radiator";
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC radiator_inlet = inlet.t
      "temperature of the inflowing fluid";

    MassTemperature inlet
      annotation (Placement(transformation(extent={{-430,-10},{-410,10}})));

    MassTemperature outlet
      annotation (Placement(transformation(extent={{408,-10},{428,10}})));
  equation
    /* calculate surface of one control volume */
    exchange_surface = (radiator_element_number * radiator_element_length * 2 * Modelica.Constants.pi * tube_diameter_horizontal + radiator_element_number * radiator_tubes_element * tube_length_vertical * Modelica.Constants.pi * tube_diameter_vertical)/cv_number;
    /* calculate mass within one control volume */
    cv_m = (radiator_element_mass * radiator_element_number)/cv_number;
    /* calculate volume within one control volume */
    //cv_v = (radiator_element_number * radiator_element_volume) / cv_number;
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
       annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-440,
              -320},{440,320}}), graphics), Icon(coordinateSystem(
            preserveAspectRatio=false, extent={{-440,-320},{440,320}}),
                                                 graphics={
          Rectangle(
            extent={{-300,92},{358,-88}},
            lineColor={0,0,0},
            lineThickness=0.5,
            fillPattern=FillPattern.Solid,
            fillColor={175,175,175}),
          Rectangle(
            extent={{-420,300},{422,-300}},
            lineColor={0,0,0},
            lineThickness=1),
          Text(
            extent={{-122,312},{128,214}},
            lineColor={0,0,0},
            lineThickness=1,
            textStyle={TextStyle.Bold},
            textString="radiator"),
          Rectangle(
            extent={{-282,38},{-202,-40}},
            lineColor={0,0,0},
            lineThickness=1),
          Rectangle(
            extent={{-180,38},{-100,-40}},
            lineColor={0,0,0},
            lineThickness=1),
          Text(
            extent={{-404,22},{-294,-24}},
            lineColor={0,0,255},
            lineThickness=1,
            textString="inlet.t
inlet.mdot",horizontalAlignment=TextAlignment.Left),
          Rectangle(
            extent={{262,40},{342,-38}},
            lineColor={0,0,0},
            lineThickness=1),
          Rectangle(
            extent={{160,40},{240,-38}},
            lineColor={0,0,0},
            lineThickness=1),
          Line(
            points={{-350,164}},
            color={0,0,0},
            thickness=1,
            smooth=Smooth.None),
          Line(
            points={{-412,0},{-280,0}},
            color={0,128,255},
            thickness=0.5,
            smooth=Smooth.None),
          Line(
            points={{-202,0},{-178,0}},
            color={0,128,255},
            thickness=0.5,
            smooth=Smooth.None),
          Line(
            points={{-100,0},{160,0}},
            color={0,128,255},
            smooth=Smooth.None,
            thickness=0.5,
            pattern=LinePattern.Dot),
          Line(
            points={{240,0},{262,0}},
            color={0,128,255},
            thickness=0.5,
            smooth=Smooth.None),
          Line(
            points={{342,0},{380,0},{380,240}},
            color={0,128,255},
            thickness=0.5,
            smooth=Smooth.None,
            pattern=LinePattern.Dash),
          Text(
            extent={{228,228},{406,286}},
            lineColor={0,128,255},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="radiator_temperature_out"),
          Rectangle(
            extent={{224,278},{422,240}},
            lineColor={0,128,255},
            pattern=LinePattern.Dash,
            lineThickness=0.5),
          Ellipse(
            extent={{408,244},{436,272}},
            lineColor={0,128,255},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillPattern=FillPattern.CrossDiag),
          Text(
            extent={{-264,44},{-224,12}},
            lineColor={0,0,0},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillColor={0,0,255},
            fillPattern=FillPattern.CrossDiag,
            textString="cv_1",
            textStyle={TextStyle.Bold}),
          Text(
            extent={{-162,44},{-122,12}},
            lineColor={0,0,0},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillColor={0,0,255},
            fillPattern=FillPattern.CrossDiag,
            textStyle={TextStyle.Bold},
            textString="cv_2"),
          Text(
            extent={{284,44},{324,12}},
            lineColor={0,0,0},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillColor={0,0,255},
            fillPattern=FillPattern.CrossDiag,
            textStyle={TextStyle.Bold},
            textString="cv_n"),
          Text(
            extent={{172,52},{226,8}},
            lineColor={0,0,0},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillColor={0,0,255},
            fillPattern=FillPattern.CrossDiag,
            textStyle={TextStyle.Bold},
            textString="cv_n-1"),
          Ellipse(
            extent={{-288,-6},{-276,6}},
            lineColor={0,0,255},
            lineThickness=0.5,
            fillColor={0,128,255},
            fillPattern=FillPattern.Solid),
          Ellipse(
            extent={{-208,-6},{-196,6}},
            lineColor={0,0,255},
            lineThickness=0.5,
            fillColor={0,128,255},
            fillPattern=FillPattern.Solid),
          Ellipse(
            extent={{-186,-6},{-174,6}},
            lineColor={0,0,255},
            lineThickness=0.5,
            fillColor={0,128,255},
            fillPattern=FillPattern.Solid),
          Ellipse(
            extent={{-106,-6},{-94,6}},
            lineColor={0,0,255},
            lineThickness=0.5,
            fillColor={0,128,255},
            fillPattern=FillPattern.Solid),
          Ellipse(
            extent={{154,-6},{166,6}},
            lineColor={0,0,255},
            lineThickness=0.5,
            fillColor={0,128,255},
            fillPattern=FillPattern.Solid),
          Ellipse(
            extent={{234,-6},{246,6}},
            lineColor={0,0,255},
            lineThickness=0.5,
            fillColor={0,128,255},
            fillPattern=FillPattern.Solid),
          Ellipse(
            extent={{256,-6},{268,6}},
            lineColor={0,0,255},
            lineThickness=0.5,
            fillColor={0,128,255},
            fillPattern=FillPattern.Solid),
          Ellipse(
            extent={{336,-6},{348,6}},
            lineColor={0,0,255},
            lineThickness=0.5,
            fillColor={0,128,255},
            fillPattern=FillPattern.Solid),
          Polygon(
            points={{-150,-32},{-130,-32},{-140,-52},{-150,-32}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{-250,-32},{-230,-32},{-240,-52},{-250,-32}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{188,-30},{208,-30},{198,-50},{188,-30}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{290,-30},{310,-30},{300,-50},{290,-30}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{-40,-272},{40,-272},{0,-336},{-40,-272}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Line(
            points={{-240,-50},{-2,-240}},
            smooth=Smooth.None,
            color={255,0,0},
            pattern=LinePattern.Dot,
            thickness=0.5),
          Text(
            extent={{-66,-240},{62,-268}},
            lineColor={255,0,0},
            pattern=LinePattern.Dot,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="radiator_qdot_out"),
          Line(
            points={{-140,-50},{-2,-240},{200,-52}},
            color={255,0,0},
            pattern=LinePattern.Dot,
            thickness=0.5,
            smooth=Smooth.None),
          Line(
            points={{300,-50},{0,-242}},
            color={255,0,0},
            pattern=LinePattern.Dot,
            thickness=0.5,
            smooth=Smooth.None),
          Rectangle(
            extent={{-78,-240},{80,-270}},
            lineColor={255,0,0},
            pattern=LinePattern.Dash,
            lineThickness=0.5),
          Rectangle(
            extent={{-420,278},{-238,240}},
            lineColor={0,128,255},
            pattern=LinePattern.Dash,
            lineThickness=0.5),
          Ellipse(
            extent={{-434,246},{-406,274}},
            lineColor={0,128,255},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillPattern=FillPattern.CrossDiag),
          Text(
            extent={{-390,238},{-252,282}},
            lineColor={0,128,255},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="room_temperature"),
          Line(
            points={{-240,240},{-240,40}},
            smooth=Smooth.None,
            color={0,128,255},
            pattern=LinePattern.Dot,
            thickness=0.5),
          Line(
            points={{-240,240},{-140,40}},
            smooth=Smooth.None,
            color={0,128,255},
            pattern=LinePattern.Dot,
            thickness=0.5),
          Line(
            points={{-238,240},{200,42}},
            smooth=Smooth.None,
            color={0,128,255},
            pattern=LinePattern.Dot,
            thickness=0.5),
          Line(
            points={{-238,240},{302,42}},
            smooth=Smooth.None,
            color={0,128,255},
            pattern=LinePattern.Dot,
            thickness=0.5),
          Line(
            points={{-410,0},{-340,0},{-340,140}},
            color={0,255,0},
            pattern=LinePattern.Dot,
            thickness=0.5,
            smooth=Smooth.None),
          Rectangle(
            extent={{-378,178},{-306,140}},
            lineColor={0,255,0},
            pattern=LinePattern.Dash,
            lineThickness=0.5),
          Text(
            extent={{-394,144},{-290,174}},
            lineColor={0,255,0},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="mdot"),
          Line(
            points={{-306,140},{-242,40}},
            color={0,255,0},
            pattern=LinePattern.Dot,
            thickness=0.5,
            smooth=Smooth.None),
          Line(
            points={{-140,38},{-306,140},{200,42}},
            color={0,255,0},
            pattern=LinePattern.Dot,
            thickness=0.5,
            smooth=Smooth.None),
          Line(
            points={{-308,140},{306,42}},
            color={0,255,0},
            pattern=LinePattern.Dot,
            thickness=0.5,
            smooth=Smooth.None),
          Text(
            extent={{-88,114},{100,34}},
            lineColor={0,0,0},
            pattern=LinePattern.Dash,
            lineThickness=0.5,
            fillColor={0,0,255},
            fillPattern=FillPattern.CrossDiag,
            textStyle={TextStyle.Bold},
            textString="cv_radiator")}),
                Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{100,100}}), graphics), Icon(coordinateSystem(
            preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
          graphics(
          Text(
            extent={{-86,62},{-46,46}},
            lineColor={0,0,0},
            textString="rad"),
          Text(
            extent={{-22,56},{60,22}},
            lineColor={0,0,0},
            textString="radiator"))=
                   {
          Text(
            extent={{-80,58},{-40,42}},
            lineColor={0,0,0},
            textString="radiator"),
          Text(
            extent={{-72,60},{-32,44}},
            lineColor={0,0,0},
            textString="inlet")}),
                Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{100,100}}), graphics), Icon(coordinateSystem(
            preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics));
  end Radiator;

  model Room_radiator_window
    "model of a room for mpc purpose with JModelica.org"

      /** parameter p **/

      /* parameter of the room */
      parameter Modelica.SIunits.Length room_length=7.81 "length of the room";
      parameter Modelica.SIunits.Breadth room_breadth=5.78
      "breadth of the room";
      parameter Modelica.SIunits.Height room_height=2.99 "height of the room";
      parameter Modelica.SIunits.Length window_length=7 "length of the window";
      parameter Modelica.SIunits.Height window_height=2.08
      "height of the window";
      parameter Modelica.SIunits.Density rho_air = 1.2 "density of air";
      parameter Modelica.SIunits.CoefficientOfHeatTransfer u_glass=2.0
      "heat transfer coefficient for glass ";                                     //Aus Thesis Ander, Genauere Bestimmung folgt mit original Werten
      parameter Modelica.SIunits.CoefficientOfHeatTransfer u_wall=0.612986
      "heat transfer coefficient for the walls of the room";                      //Aus Thesis Ander, Genauere Bestimmung folgt mit original Werten
      parameter Modelica.SIunits.SpecificHeatCapacity cp_air=1005
      "specific heat capacity of air";
      parameter Modelica.SIunits.SpecificHeatCapacity cp_water=4182
      "specific heat capacity of water";
      Radiator heating "instance of a radiator";
      Window window "instance of a window";

      /* calculated parameter */
      Modelica.SIunits.Volume room_volume "volume of the room";
      Modelica.SIunits.Mass room_mass "mass of air within the room";
      Modelica.SIunits.Area building_surface
      "sum of contacting surfaces (walls) with other rooms of the building";
      Modelica.SIunits.Area environment_surface
      "sum of contacting surfaces (walls) with the environment";
      inner Modelica.SIunits.Area window_surface
      "sum of contacting surfaces (windows) with the environment";
      Modelica.SIunits.Energy room_u "inner energy of the system room";
      Modelica.SIunits.HeatFlowRate building_qdot
      "rate of heat flow with other rooms within the building";                   //Optional: Splitten in Decke und versch. W?nde!
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

    Temperature inlet_building
      annotation (Placement(transformation(extent={{-350,-230},{-330,-210}})));

    Temperature inlet_environment
      annotation (Placement(transformation(extent={{-350,210},{-330,230}})));
    MassTemperature inlet_radiator
      annotation (Placement(transformation(extent={{352,-232},{372,-212}}), iconTransformation(extent={{352,-232},{372,-212}})));
    HeatFlow inlet_other annotation (Placement(transformation(extent={{350,208},{370,
              228}}), iconTransformation(extent={{352,272},{372,292}})));
    RadiantEnergyFluenceRate inlet_sun
      annotation (Placement(transformation(extent={{350,172},{370,192}})));
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
   room_u = room_mass * cp_air * room_temperature; //?berpr?fen ob ?berhaupt n?tig?!?!?!
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
   /* connect radiator with the inlet */
   connect(heating.inlet, inlet_radiator);
   connect(inlet_sun, window.inlet_sun);
   qdot_sun = window.outlet_room.qdot;

    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-620,
              -440},{620,440}}), graphics), Icon(coordinateSystem(
            preserveAspectRatio=false, extent={{-620,-440},{620,440}}), graphics={
          Text(
            extent={{-292,240},{-66,144}},
            lineColor={0,0,255},
            textString="inlet_environment.t"),
          Text(
            extent={{184,198},{346,122}},
            lineColor={0,0,255},
            textString="inlet_sun.qdot"),
          Text(
            extent={{-310,-118},{-136,-260}},
            lineColor={0,0,255},
            textString="inlet_building.t"),
          Rectangle(
            extent={{-340,358},{362,-320}},
            lineColor={0,0,0},
            lineThickness=1),
          Text(
            extent={{-208,400},{246,244}},
            lineColor={0,0,0},
            lineThickness=1,
            textStyle={TextStyle.Bold},
            textString="room_radiator"),
          Text(
            extent={{178,-120},{352,-262}},
            lineColor={0,0,255},
            textString="inlet_radiator.t"),
          Text(
            extent={{134,-172},{346,-334}},
            lineColor={0,0,255},
            textString="inlet_radiator.mdot"),
          Rectangle(
            extent={{-220,140},{240,-160}},
            lineColor={0,0,0},
            lineThickness=0.5),
          Text(
            extent={{-60,150},{74,94}},
            lineColor={0,0,0},
            lineThickness=1,
            textStyle={TextStyle.Bold},
            textString="radiator"),
          Ellipse(
            extent={{-12,-148},{10,-170}},
            lineColor={0,255,0},
            lineThickness=1,
            fillColor={85,170,255},
            fillPattern=FillPattern.CrossDiag),
          Line(
            points={{0,-172},{0,-222},{348,-220}},
            color={0,255,0},
            thickness=0.5,
            smooth=Smooth.None),
          Polygon(
            points={{-260,0},{-182,40},{-182,-40},{-260,0}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{324,188},{402,228},{402,148},{324,188}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{-378,220},{-300,260},{-300,180},{-378,220}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{-398,-220},{-320,-180},{-320,-260},{-398,-220}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{-284,-220},{-360,-180},{-360,-260},{-284,-220}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Rectangle(
            extent={{-166,58},{196,-80}},
            lineColor={0,0,0},
            fillPattern=FillPattern.Solid,
            fillColor={212,212,212}),
          Text(
            extent={{-52,64},{60,28}},
            lineColor={0,0,0},
            lineThickness=1,
            textStyle={TextStyle.Bold},
            textString="cv_radiator"),
          Polygon(
            points={{-130,-72},{-110,-72},{-120,-92},{-130,-72}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{-90,-72},{-70,-72},{-80,-92},{-90,-72}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{90,-70},{110,-70},{100,-90},{90,-70}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{130,-70},{150,-70},{140,-90},{130,-70}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Line(
            points={{-64,-80},{2,-80},{86,-80}},
            color={255,0,0},
            pattern=LinePattern.Dot,
            thickness=1,
            smooth=Smooth.None),
          Polygon(
            points={{324,282},{402,322},{402,242},{324,282}},
            lineColor={255,0,0},
            lineThickness=1,
            smooth=Smooth.None),
          Text(
            extent={{168,292},{348,214}},
            lineColor={0,0,255},
            textString="inlet_other.qdot")}));
  end Room_radiator_window;



  connector MassTemperature
    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC t;
    Modelica.SIunits.MassFlowRate mdot;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
              {100,100}}), graphics={Ellipse(
            extent={{98,-98},{-98,98}},
            lineColor={0,255,0},
            fillColor={0,128,255},
            fillPattern=FillPattern.CrossDiag,
            lineThickness=1)}));
  end MassTemperature;

  model SourceTemp

    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC t=inlet;

    Modelica.Blocks.Interfaces.RealInput inlet annotation (Placement(
          transformation(extent={{-120,-30},{-80,10}}),
                                                      iconTransformation(extent={{-100,
              -10},{-80,10}})));
    Temperature outlet
      annotation (Placement(transformation(extent={{80,-10},{100,10}})));
  equation
    outlet.t=t;

    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{100,100}}), graphics), Icon(coordinateSystem(
            preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
            Ellipse(
            extent={{-90,90},{90,-90}},
            lineColor={0,0,0},
            lineThickness=1),
          Text(
            extent={{-66,90},{66,20}},
            lineColor={0,0,0},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textStyle={TextStyle.Bold},
            textString="environment_source"),
          Text(
            extent={{-88,12},{-48,0}},
            lineColor={0,0,255},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="inlet.t"),
          Text(
            extent={{52,12},{76,-2}},
            lineColor={0,0,255},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="outlet")}));
  end SourceTemp;

  model SourceHeat

    Modelica.SIunits.HeatFlowRate qdot=inlet;

    Modelica.Blocks.Interfaces.RealInput inlet annotation (Placement(
          transformation(extent={{-120,-30},{-80,10}}), iconTransformation(
            extent={{-100,-10},{-80,10}})));
    HeatFlow outlet
      annotation (Placement(transformation(extent={{78,-10},{98,10}})));
  equation
    outlet.qdot=qdot;

    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{100,100}}), graphics), Icon(coordinateSystem(
            preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
            Ellipse(
            extent={{-90,90},{90,-90}},
            lineColor={0,0,0},
            lineThickness=1),
          Text(
            extent={{-78,10},{-38,-2}},
            lineColor={0,0,255},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="inlet.qdot"),
          Text(
            extent={{48,12},{72,-2}},
            lineColor={0,0,255},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="outlet"),
          Text(
            extent={{-42,84},{44,46}},
            lineColor={0,0,0},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textStyle={TextStyle.Bold},
            textString="heat_source")}));
  end SourceHeat;

  model SourceTempMass

    Modelica.SIunits.Conversions.NonSIunits.Temperature_degC t=inlet_t;
    Modelica.SIunits.MassFlowRate mdot=inlet_mdot;
    Modelica.Blocks.Interfaces.RealInput inlet_t annotation (Placement(
          transformation(extent={{-108,10},{-68,50}}),iconTransformation(extent={{-88,30},
              {-68,50}})));
    room_model_backup.MassTemperature outlet annotation (Placement(
          transformation(extent={{82,-12},{102,8}}), iconTransformation(extent=
              {{82,-12},{102,8}})));
    Modelica.Blocks.Interfaces.RealInput inlet_mdot
      annotation (Placement(transformation(extent={{-108,-70},{-68,-30}}),
          iconTransformation(extent={{-88,-50},{-68,-30}})));
  equation
    outlet.t=t;
    outlet.mdot=mdot;

    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{100,100}}), graphics), Icon(coordinateSystem(
            preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
            Ellipse(
            extent={{-90,90},{90,-90}},
            lineColor={0,0,0},
            lineThickness=1),
          Text(
            extent={{-70,40},{-30,28}},
            lineColor={0,0,255},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="inlet_t.t"),
          Text(
            extent={{-66,-18},{2,-54}},
            lineColor={0,0,255},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="inlet_mdot.mdot"),
          Text(
            extent={{54,12},{78,-2}},
            lineColor={0,0,255},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="outlet"),
          Text(
            extent={{-52,92},{46,40}},
            lineColor={0,0,0},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textStyle={TextStyle.Bold},
            textString="radiator_source")}));
  end SourceTempMass;

  model RoomRadiator
    Modelica.Blocks.Sources.RealExpression realExpression1(y=0)
      annotation (Placement(transformation(extent={{94,70},{74,90}})));
    Modelica.Blocks.Sources.RealExpression realExpression2(y=0)
      annotation (Placement(transformation(extent={{-166,38},{-146,58}})));
    Modelica.Blocks.Sources.RealExpression realExpression4(y=20)
      annotation (Placement(transformation(extent={{-170,-8},{-150,12}})));
    Modelica.Blocks.Sources.RealExpression realExpression6(y=0.1)
      annotation (Placement(transformation(extent={{-40,-72},{-20,-52}})));
    Modelica.Blocks.Sources.RealExpression realExpression3(y=60)
      annotation (Placement(transformation(extent={{-50,-24},{-30,-4}})));
    SourceHeat Sonne
      annotation (Placement(transformation(extent={{46,68},{26,88}})));
    Modelica.Blocks.Sources.RealExpression realExpression5(y=800)
      annotation (Placement(transformation(extent={{98,36},{78,56}})));
    SourceTempMass Heizkorper
      annotation (Placement(transformation(extent={{20,-54},{58,-10}})));
    SourceTemp UmgebungA
      annotation (Placement(transformation(extent={{-114,42},{-94,62}})));
    SourceTemp Gebaude
      annotation (Placement(transformation(extent={{-120,-12},{-100,8}})));
    SourceSun sourceSun
      annotation (Placement(transformation(extent={{62,40},{42,60}})));
    Room_radiator_window room_radiator_window
      annotation (Placement(transformation(extent={{-94,-2},{30,86}})));
  equation
    connect(realExpression3.y, Heizkorper.inlet_t) annotation (Line(
        points={{-29,-14},{-2,-14},{-2,-23.2},{24.18,-23.2}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(realExpression6.y, Heizkorper.inlet_mdot) annotation (Line(
        points={{-19,-62},{4,-62},{4,-40.8},{24.18,-40.8}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(realExpression4.y, Gebaude.inlet) annotation (Line(
        points={{-149,2},{-134,2},{-134,-2},{-119,-2}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(realExpression2.y, UmgebungA.inlet) annotation (Line(
        points={{-145,48},{-130,48},{-130,52},{-113,52}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(realExpression1.y, Sonne.inlet) annotation (Line(
        points={{73,80},{64,80},{64,78},{45,78}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(room_radiator_window.inlet_other, Sonne.outlet) annotation (Line(
        points={{4.2,70.2},{15.1,70.2},{15.1,78},{27.2,78}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(room_radiator_window.inlet_sun, sourceSun.outlet) annotation (Line(
        points={{4,60.2},{24,60.2},{24,49},{44,49}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(UmgebungA.outlet, room_radiator_window.inlet_environment)
      annotation (Line(
        points={{-95,52},{-80,52},{-80,64},{-66,64}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(Gebaude.outlet, room_radiator_window.inlet_building) annotation (
        Line(
        points={{-101,-2},{-82,-2},{-82,20},{-66,20}},
        color={0,0,255},
        smooth=Smooth.None));
    connect(Heizkorper.outlet, room_radiator_window.inlet_radiator) annotation (
       Line(
        points={{56.48,-32.44},{30.24,-32.44},{30.24,19.8},{4.2,19.8}},
        color={0,255,0},
        thickness=1,
        smooth=Smooth.None));
    connect(realExpression5.y, sourceSun.inlet) annotation (Line(
        points={{77,46},{70,46},{70,50},{61,50}},
        color={0,0,127},
        smooth=Smooth.None));
    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{100,100}}),      graphics));
  end RoomRadiator;



  model Window

    Modelica.SIunits.DensityOfHeatFlowRate radiation_arriving=inlet_sun.radiation_sun;
    Modelica.SIunits.HeatFlowRate qdot_effective;
    parameter Real window_transmission = 0.00687213;
    outer Modelica.SIunits.Area window_surface
      "sum of contacting surfaces (windows) with the environment";
    HeatFlow outlet_room annotation (Placement(transformation(extent={{70,-10},{90,
              10}}), iconTransformation(extent={{70,-10},{90,10}})));

    RadiantEnergyFluenceRate inlet_sun annotation (Placement(transformation(
            extent={{-90,-10},{-70,10}}), iconTransformation(extent={{-90,-10},{-70,
              10}})));
  equation
    qdot_effective = radiation_arriving * window_transmission * window_surface;
    qdot_effective = outlet_room.qdot;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
              {100,100}}), graphics), Diagram(coordinateSystem(
            preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics));
  end Window;







  connector RadiantEnergyFluenceRate
  Modelica.SIunits.DensityOfHeatFlowRate radiation_sun;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
              {100,100}}), graphics={Ellipse(
            extent={{98,-98},{-98,98}},
            lineColor={0,0,255},
            fillColor={255,255,85},
            fillPattern=FillPattern.Solid)}));
  end RadiantEnergyFluenceRate;

  model SourceSun

    Modelica.SIunits.DensityOfHeatFlowRate radiation_sun = inlet;

    Modelica.Blocks.Interfaces.RealInput inlet annotation (Placement(
          transformation(extent={{-120,-30},{-80,10}}), iconTransformation(
            extent={{-100,-10},{-80,10}})));
    RadiantEnergyFluenceRate outlet
      annotation (Placement(transformation(extent={{70,-20},{90,0}})));
  equation
    outlet.radiation_sun = radiation_sun;

    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{100,100}}), graphics), Icon(coordinateSystem(
            preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
            Ellipse(
            extent={{-90,90},{90,-90}},
            lineColor={0,0,0},
            lineThickness=1),
          Text(
            extent={{-78,10},{-38,-2}},
            lineColor={0,0,255},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="inlet"),
          Text(
            extent={{48,12},{72,-2}},
            lineColor={0,0,255},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textString="outlet"),
          Text(
            extent={{-42,84},{44,46}},
            lineColor={0,0,0},
            lineThickness=1,
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textStyle={TextStyle.Bold},
            textString="heat_source")}));
  end SourceSun;
  annotation (uses(Modelica(version="3.2.1")));
end room_model_backup;
