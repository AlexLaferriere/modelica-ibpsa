within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.Validation;
model LoadAggregation_PrescribedQ
  "Load aggregation model with a constant prescribed load"
  extends Modelica.Icons.Example;

  GroundTemperatureResponse groTem(
    p_max=5,
    forceGFunCalc=true,
    nbBh=1,
    cooBh=[0,0],
    hBor=100,
    dBor=4,
    rBor=0.05,
    alp=1e-6,
    k=1,
    tStep=3600)
    "Load Aggregation in borehole"
    annotation (Placement(transformation(extent={{-20,0},{0,20}})));

  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow
    "Prescribed heat injected into borehole"
    annotation (Placement(transformation(extent={{40,0},{20,20}})));
  Modelica.Blocks.Sources.CombiTimeTable timTabQ(
    tableOnFile=true,
    tableName="tab1",
    columns={2},
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    fileName=Modelica.Utilities.Files.loadResource(
        "modelica://IBPSA/Resources/Fluid/HeatExchangers/GroundHeatExchangers/BaseClasses/LoadAggregation/Validation/LoadAggregation_20y_validation.txt"))
                 "Table for heat injected, using constant segments"
    annotation (Placement(transformation(extent={{80,0},{60,20}})));

  Modelica.Blocks.Math.Add add(k2=-1)
    "Difference between FFT method and load aggregation method"
                                      annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={50,-70})));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor temperatureSensor
    "Borehole wall temperature"
    annotation (Placement(transformation(extent={{20,-40},{40,-20}})));
  Modelica.Blocks.Sources.CombiTimeTable timTabT(
    tableOnFile=true,
    tableName="tab1",
    columns={3},
    smoothness=Modelica.Blocks.Types.Smoothness.LinearSegments,
    fileName=Modelica.Utilities.Files.loadResource(
        "modelica://IBPSA/Resources/Fluid/HeatExchangers/GroundHeatExchangers/BaseClasses/LoadAggregation/Validation/LoadAggregation_20y_validation.txt"))
    "Table for resulting wall temperature using FFT and linearly interpolated"
    annotation (Placement(transformation(extent={{80,-40},{60,-20}})));

  Modelica.Blocks.Sources.Constant const(k=273.15)
    annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
  Modelica.Blocks.Sources.Constant const1(k=100)
    annotation (Placement(transformation(extent={{20,40},{40,60}})));
equation
  connect(prescribedHeatFlow.port, groTem.Tb)
    annotation (Line(points={{20,10},{0,10}}, color={191,0,0}));
  connect(temperatureSensor.port, groTem.Tb) annotation (Line(points={{20,-30},
          {10,-30},{10,10},{0,10}}, color={191,0,0}));
  connect(temperatureSensor.T, add.u2)
    annotation (Line(points={{40,-30},{44,-30},{44,-58}}, color={0,0,127}));
  connect(timTabT.y[1], add.u1)
    annotation (Line(points={{59,-30},{56,-30},{56,-58}}, color={0,0,127}));
  connect(groTem.Tg, const.y)
    annotation (Line(points={{-22,10},{-39,10}}, color={0,0,127}));

  connect(const1.y, prescribedHeatFlow.Q_flow) annotation (Line(points={{41,50},
          {50,50},{50,10},{40,10}}, color={0,0,127}));
  annotation (experiment(StopTime=630720000),
    Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
__Dymola_Commands(file="modelica://IBPSA/Resources/Scripts/Dymola/Fluid/HeatExchangers/GroundHeatExchangers/BaseClasses/LoadAggregation/Validation/LoadAggregation_PrescribedQ.mos"
        "Simulate and plot"),
              Documentation(info="<html>
<p>
This validation case applies the assymetrical synthetic load profile developed
by Pinel (2003) over a 20 year period by directly injecting the heat at the
borehole wall in the
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.GroundTemperatureResponse\">
ground temperature response model</a>. The difference between
the resulting borehole wall temperature calculated in real time during the simulation
and the same temperature presolved in the spectral domain
by using a fast Fourier transform is then shown with the <code>add</code>
component. The fast Fourier transform calculation was done using a
g-function calculated independently of the functions present in the
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.ThermalResponseFactors\">
IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.ThermalResponseFactors</a> package,
though the same formulas for the FLS, ILS and CHS solutions were used.
</p>
<p>
The single borehole used in this validation case has the following key characteristics:
<ul>
<li>
<code>H = 100 m</code> <i>(borehole length)</i>
</li>
<li>
<code>r<sub>b</sub> = 0.05 m</code> <i>(borehole radius)</i>
</li>
<li>
<code>k<sub>s</sub> = 1 W/m-K</code> <i>(ground thermal conductivity)</i>
</li>
<li>
<code>&alpha;<sub>s</sub> = 1e-06 m<sup>2</sup>/s</code> <i>(ground thermal diffusivity)</i>
</li>
</ul>
</p>
<h4>References</h4>
<p>
Pinel, P. 2003. <i>Am&eacute;lioration, validation et implantation d’un algorithme de calcul
pour &eacute;valuer le transfert thermique dans les puits verticaux de syst&egrave;mes de pompes &agrave; chaleur g&eacute;othermiques</i>,
M.A.Sc. Thesis, &Eacute;cole Polytechnique de Montr&eacute;al.
</p>
</html>", revisions="<html>
<ul>
<li>
April 5, 2018, by Alex Laferriere:<br/>
First implementation.
</li>
</ul>
</html>"));
end LoadAggregation_PrescribedQ;
