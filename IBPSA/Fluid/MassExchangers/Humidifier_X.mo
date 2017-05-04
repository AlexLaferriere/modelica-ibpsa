within IBPSA.Fluid.MassExchangers;
model Humidifier_X
  "Adiabatic humidifier (or dehumidifier) with leaving water mass fraction as input"
  extends IBPSA.Fluid.HeatExchangers.BaseClasses.PartialPrescribedOutlet(
    outCon(
      final T_start=293.15,
      final X_start=X_start,
      final use_TSet = false,
      final use_X_wSet = true,
      final QMax_flow = 0,
      final QMin_flow = 0,
      final mWatMax_flow = mWatMax_flow,
      final mWatMin_flow = 0,
      final energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState,
      final massDynamics = massDynamics));

  parameter Modelica.SIunits.MassFlowRate mWatMax_flow(min=0) = Modelica.Constants.inf
    "Maximum water mass flow rate addition (positive)"
    annotation (Evaluate=true);

  parameter Modelica.SIunits.MassFraction X_start[Medium.nX] = Medium.X_default
    "Start value of mass fractions m_i/m"
    annotation (Dialog(tab="Initialization"));

  // Dynamics
  parameter Modelica.Fluid.Types.Dynamics massDynamics=Modelica.Fluid.Types.Dynamics.SteadyState
    "Type of mass balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true, Dialog(tab = "Dynamics", group="Equations"));


  // Set maximum to a high value to avoid users mistakenly entering relative humidity.
  Modelica.Blocks.Interfaces.RealInput X_w(unit="1", min=0, max=0.03)
    "Set point for water vapor mass fraction in kg/kg total air of the fluid that leaves port_b"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}})));

  Modelica.Blocks.Interfaces.RealOutput mWat_flow(unit="kg/s")
    "Water added to the fluid (if flow is from port_a to port_b)"
    annotation (Placement(transformation(extent={{100,50},{120,70}})));

equation
  connect(X_w, outCon.X_wSet)
    annotation (Line(points={{-120,60},{0,60},{0,4},{19,4}}, color={0,0,127}));
  connect(outCon.mWat_flow, mWat_flow) annotation (Line(points={{41,4},{80,4},{80,
          60},{110,60}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics={
        Rectangle(
          extent={{-102,5},{99,-5}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,60},{-70,58}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-102,104},{-58,76}},
          lineColor={0,0,127},
          textString="X_w"),
        Rectangle(
          extent={{60,60},{100,58}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{34,118},{100,64}},
          lineColor={0,0,127},
          textString="mWat_flow"),
        Rectangle(
          extent={{-70,80},{70,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={85,170,255},
          fillPattern=FillPattern.Solid)}),
defaultComponentName="hea",
Documentation(info="<html>
<p>
Model for an adiabatic humidifier with a prescribed outlet water vapor mass fraction
in kg/kg total air.
</p>
<p>
This model forces the outlet water mass fraction at <code>port_b</code> to be
not lower than the
input signal <code>X_wSet</code>, subject to optional limits on the
maximum water vapor mass flow rate that is added, as
described by the parameters
<code>mWatMax_flow</code>.
By default, the model has unlimited capacity.
</p>
<p>
The output signal <code>mWat_flow</code> is the moisture added
to the medium if the flow rate is from <code>port_a</code> to <code>port_b</code>.
If the flow is reversed, then <code>mWat_flow=0</code>.
</p>
<p>
The outlet conditions at <code>port_a</code> are not affected by this model.
</p>
<p>
If the parameter <code>energyDynamics</code> is not equal to
<code>Modelica.Fluid.Types.Dynamics.SteadyState</code>,
the component models the dynamic response using a first order differential equation.
The time constant of the component is equal to the parameter <code>tau</code>.
This time constant is adjusted based on the mass flow rate using
</p>
<p align=\"center\" style=\"font-style:italic;\">
&tau;<sub>eff</sub> = &tau; |m&#775;| &frasl; m&#775;<sub>nom</sub>
</p>
<p>
where
<i>&tau;<sub>eff</sub></i> is the effective time constant for the given mass flow rate
<i>m&#775;</i> and
<i>&tau;</i> is the time constant at the nominal mass flow rate
<i>m&#775;<sub>nom</sub></i>.
This type of dynamics is equal to the dynamics that a completely mixed
control volume would have.
</p>
<p>
Optionally, this model can have a flow resistance.
If no flow resistance is requested, set <code>dp_nominal=0</code>.
</p>
<p>
For a model that uses a control signal <i>u &isin; [0, 1]</i> and multiplies
this with the nominal water mass flow rate, use
<a href=\"modelica://IBPSA.Fluid.MassExchangers.Humidifier_u\">
IBPSA.Fluid.MassExchangers.Humidifier_u</a>

</p>
<h4>Limitations</h4>
<p>
This model only adds water vapor for the flow from
<code>port_a</code> to <code>port_b</code>.
The water vapor of the reverse flow is not affected by this model.
</p>
<p>
This model does not affect the enthalpy of the air. Therefore,
if water is added, the temperature will decrease, e.g., the humidification
is adiabatic.
</p>
</html>",
revisions="<html>
<ul>
<li>
May 3, 2017, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end Humidifier_X;
