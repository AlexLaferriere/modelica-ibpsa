within Annex60.Fluid.Chillers.BaseClasses;
partial model Carnot

  parameter Modelica.SIunits.HeatFlowRate QEva_flow_nominal(max=0)
    "Nominal cooling heat flow rate (QEva_flow_nominal < 0)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.HeatFlowRate QCon_flow_nominal(min=0)
    "Nominal heating flow rate";

  parameter Annex60.Fluid.Types.EfficiencyInput effInpEva
    "Temperatures of evaporator fluid used to compute Carnot efficiency"
    annotation (Dialog(tab="Advanced", group="Temperature dependence"),
                evaluate=True);
  parameter Annex60.Fluid.Types.EfficiencyInput effInpCon
    "Temperatures of condenser fluid used to compute Carnot efficiency"
    annotation (Dialog(tab="Advanced", group="Temperature dependence"),
                evaluate=True);

  parameter Modelica.SIunits.TemperatureDifference dTEva_nominal(
    final max=0) = -10 "Temperature difference evaporator outlet-inlet"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference dTCon_nominal(
    final min=0) = 10 "Temperature difference condenser outlet-inlet"
    annotation (Dialog(group="Nominal condition"));

  // Efficiency
  parameter Boolean use_eta_Carnot_nominal = true
    "Set to true to use Carnot effectiveness etaCar_nominal rather than COP_nominal"
    annotation(Dialog(group="Efficiency"));
  parameter Real etaCar_nominal(
    unit="1") = COP_nominal / (TUse_nominal/(TCon_nominal-TEva_nominal))
    "Carnot effectiveness (=COP/COP_Carnot) used if use_eta_Carnot_nominal = true"
    annotation (Dialog(group="Efficiency", enable=use_eta_Carnot_nominal));

  parameter Real COP_nominal(
    unit="1") = etaCar_nominal * TUse_nominal/(TCon_nominal-TEva_nominal)
    "Coefficient of performance at TEva_nominal and TCon_nominal, used if use_eta_Carnot_nominal = false"
    annotation (Dialog(group="Efficiency", enable=not use_eta_Carnot_nominal));

  parameter Modelica.SIunits.Temperature TCon_nominal = 303.15
    "Condenser temperature used to compute COP_nominal if use_eta_Carnot_nominal=false"
    annotation (Dialog(group="Efficiency", enable=not use_eta_Carnot_nominal));
  parameter Modelica.SIunits.Temperature TEva_nominal = 278.15
    "Evaporator temperature used to compute COP_nominal if use_eta_Carnot_nominal=false"
    annotation (Dialog(group="Efficiency", enable=not use_eta_Carnot_nominal));

  parameter Real a[:] = {1}
    "Coefficients for efficiency curve (need p(a=a, yPL=1)=1)"
    annotation (Dialog(group="Efficiency"));

  Modelica.SIunits.Temperature TCon(start=TCon_nominal)
    "Condenser temperature used to compute efficiency";
  Modelica.SIunits.Temperature TEva(start=TEva_nominal)
    "Evaporator temperature used to compute efficiency";

  Modelica.Blocks.Interfaces.RealOutput QCon_flow(
    final quantity="HeatFlowRate",
    final unit="W") "Actual heating heat flow rate added to fluid 1"
    annotation (Placement(transformation(extent={{100,80},{120,100}}),
        iconTransformation(extent={{100,80},{120,100}})));

  Modelica.Blocks.Interfaces.RealOutput P(
    final quantity="Power",
    final unit="W") "Electric power consumed by compressor"
    annotation (Placement(transformation(extent={{100,-10},{120,10}}),
        iconTransformation(extent={{100,-10},{120,10}})));

  Modelica.Blocks.Interfaces.RealOutput QEva_flow(
    final quantity="HeatFlowRate",
    final unit="W") "Actual cooling heat flow rate removed from fluid 2"
    annotation (Placement(transformation(extent={{100,-100},{120,-80}}),
        iconTransformation(extent={{100,-100},{120,-80}})));

  Real yPL(final unit="1") = if COP_is_for_cooling
     then QEva_flow/QEva_flow_nominal
     else QCon_flow/QCon_flow_nominal "Part load ratio";

  Real etaPL(final unit = "1")=
    if evaluate_etaPL
      then 1
      else Annex60.Utilities.Math.Functions.polynomial(
               a=a,
               x=yPL) "Efficiency due to part load (etaPL(yPL=1)=1)";

  Real COP(min=0, final unit="1") = etaCar_nominal_internal * COPCar * etaPL
    "Coefficient of performance";

  Real COPCar(min=0) = TUse / Annex60.Utilities.Math.Functions.smoothMax(
    x1=1,
    x2=TCon-TEva,
    deltaX=0.25) "Carnot efficiency";

protected
  constant Boolean COP_is_for_cooling
    "Set to true if the specified COP is for cooling";

  parameter Real etaCar_nominal_internal(
    unit="1") = if use_eta_Carnot_nominal then
      etaCar_nominal
    else
      COP_nominal / (TUse_nominal/(TCon_nominal-TEva_nominal))
    "Carnot effectiveness (=COP/COP_Carnot) used to compute COP";

  // For Carnot_y, computing etaPL = f(yPL) introduces a nonlinear equation.
  // The parameter below avoids this if a = {1}.
  final parameter Boolean evaluate_etaPL=
    (size(a, 1) == 1 and abs(a[1] - 1)  < Modelica.Constants.eps)
    "Flag, true if etaPL should be computed as it depends on yPL"
    annotation(Evaluate=true);

  final parameter Modelica.SIunits.Temperature TUse_nominal=
   if COP_is_for_cooling then TEva_nominal else TCon_nominal
    "Nominal evaporator temperature for chiller or condenser temperature for heat pump";
  Modelica.SIunits.Temperature TUse = if COP_is_for_cooling then TEva else TCon
    "Temperature of useful heat (evaporator for chiller, condenser for heat pump";

initial equation
  assert(dTEva_nominal < 0,
    "Parameter dTEva_nominal must be negative.");
  assert(dTCon_nominal > 0,
    "Parameter dTCon_nominal must be positive.");

  assert(abs(Annex60.Utilities.Math.Functions.polynomial(
         a=a, x=1)-1) < 0.01, "Efficiency curve is wrong. Need etaPL(y=1)=1.");
  assert(etaCar_nominal_internal < 1,   "Parameters lead to etaCar_nominal > 1. Check parameters.");

  annotation (
  Icon(coordinateSystem(preserveAspectRatio=false,extent={{-100,-100},
            {100,100}}),       graphics={
        Rectangle(
          extent={{-70,80},{70,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-56,68},{58,50}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-56,-52},{58,-70}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-103,64},{98,54}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-2,54},{98,64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-101,-56},{100,-66}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,-66},{0,-56}},
          lineColor={0,0,127},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-42,0},{-52,-12},{-32,-12},{-42,0}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-42,0},{-52,10},{-32,10},{-42,0}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-44,50},{-40,10}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-44,-12},{-40,-52}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{38,50},{42,-52}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{18,22},{62,-20}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{40,22},{22,-10},{58,-10},{40,22}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(points={{0,68},{0,90},{90,90},{100,90}},
                                                 color={0,0,255}),
        Line(points={{0,-70},{0,-90},{100,-90}}, color={0,0,255}),
        Line(points={{62,0},{100,0}},                 color={0,0,255})}),
      Documentation(info="<html>
<p>
This is the base class for the Carnot chiller and the Carnot heat pump
whose coefficient of performance COP changes
with temperatures in the same way as the Carnot efficiency changes.
</p>
<p>
The COP at the nominal conditions can be specified by a parameter, or
it can be computed by the model based on the Carnot effectiveness, in which
case
</p>
<p align=\"center\" style=\"font-style:italic;\">
  COP<sub>0</sub> = &eta;<sub>car</sub> COP<sub>car</sub>
= &eta;<sub>car</sub> T<sub>use</sub> &frasl; (T<sub>con</sub>-T<sub>eva</sub>),
</p>
<p>
where
<i>T<sub>use</sub></i> is the temperature of the the useful heat,
e.g., the evaporator temperature for a chiller or the condenser temperature
for a heat pump,
<i>T<sub>eva</sub></i> is the evaporator temperature
and <i>T<sub>con</sub></i> is the condenser temperature.
</p>
<p>
The chiller COP is computed as the product
</p>
<p align=\"center\" style=\"font-style:italic;\">
  COP = &eta;<sub>car</sub> COP<sub>car</sub> &eta;<sub>PL</sub>,
</p>
<p>
where <i>&eta;<sub>car</sub></i> is the Carnot effectiveness,
<i>COP<sub>car</sub></i> is the Carnot efficiency and
<i>&eta;<sub>PL</sub></i> is the part load efficiency, expressed using
a polynomial.
This polynomial has the form
</p>
<p align=\"center\" style=\"font-style:italic;\">
  &eta;<sub>PL</sub> = a<sub>1</sub> + a<sub>2</sub> y + a<sub>3</sub> y<sup>2</sup> + ...
</p>
<p>
where <i>y &isin; [0, 1]</i> is
either the part load for cooling in case of a chiller, or the part load of heating in
case of a heat pump, and the coefficients <i>a<sub>i</sub></i>
are declared by the parameter <code>a</code>.
</p>
<h4>Implementation</h4>
<p>
To make this base class applicable to chiller or heat pumps, it uses
the boolean constant <code>COP_is_for_cooling</code>.
Depending on its value, the equations for the coefficient of performance
and the part load ratio are set up.
</p>
</html>", revisions="<html>
<ul>
<li>
January 26, 2016, by Michael Wetter:<br/>
First implementation of this base class.
</li>
</ul>
</html>"));
end Carnot;
