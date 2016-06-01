within Annex60.Experimental.ThermalZones.ReducedOrder.Validation.VDI6007;
model TestCase10 "VDI 6007 Test Case 10 model"
  extends Modelica.Icons.Example;

  ReducedOrderZones.ThermalZoneTwoElements thermalZoneTwoElements(
    redeclare final package Medium = Modelica.Media.Air.SimpleAir,
    gWin=1,
    nExt=1,
    alphaRad=5,
    nInt=1,
    RWin=0.00000001,
    ratioWinConRad=0.09,
    AInt=58,
    alphaWin=2.7,
    VAir=0,
    nOrientations=1,
    AWin={0},
    ATransparent={7},
    AExt={28},
    RExtRem=0.011638548,
    RExt={0.00171957697767797},
    CExt={4338751.41},
    RInt={0.000779671554640369},
    CInt={12333949.4129606},
    intWallRC(thermCapInt(each T(fixed=true))),
    extWallRC(thermCapExt(each T(fixed=true))),
    alphaInt=2.398,
    T_start=290.75,
    alphaExt=2.4)
    annotation (Placement(transformation(extent={{44,-2},{92,34}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature preTem
    "Outdoor air temperature"
    annotation (Placement(transformation(extent={{8,-6},{20,6}})));
  Modelica.Blocks.Sources.CombiTimeTable intGai(
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    table=[0,0,0,0; 3600,0,0,0; 7200,0,0,0; 10800,0,0,0; 14400,0,0,0; 18000,0,0,
        0; 21600,0,0,0; 25200,0,0,0; 25200,80,80,200; 28800,80,80,200; 32400,80,
        80,200; 36000,80,80,200; 39600,80,80,200; 43200,80,80,200; 46800,80,80,
        200; 50400,80,80,200; 54000,80,80,200; 57600,80,80,200; 61200,80,80,200;
        61200,0,0,0; 64800,0,0,0; 72000,0,0,0; 75600,0,0,0; 79200,0,0,0; 82800,
        0,0,0; 86400,0,0,0],
    columns={2,3,4}) "Table with internal gains"
    annotation (Placement(transformation(extent={{6,-60},{22,-44}})));
  Modelica.Blocks.Sources.CombiTimeTable reference(
    tableOnFile=false,
    columns={2},
    extrapolation=Modelica.Blocks.Types.Extrapolation.HoldLastPoint,
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    table=[0,17.6; 3600,17.6; 7200,17.5; 10800,17.5; 14400,17.6; 18000,17.8;
        21600,18; 25200,20; 28800,19.7; 32400,20; 36000,20.3; 39600,20.5; 43200,
        20.6; 46800,20.7; 50400,20.8; 54000,21.5; 57600,21.4; 61200,19.8; 64800,
        19.7; 68400,19.6; 72000,19.6; 75600,19.5; 79200,19.5; 82800,19.5; 86400,
        24.7; 781200,24.6; 784800,24.5; 788400,24.4; 792000,24.4; 795600,24.5;
        799200,24.6; 802800,26.6; 806400,26.2; 810000,26.4; 813600,26.6; 817200,
        26.8; 820800,26.9; 824400,26.9; 828000,26.9; 831600,27.5; 835200,27.4;
        838800,25.7; 842400,25.5; 846000,25.3; 849600,25.3; 853200,25.2; 856800,
        25.1; 860400,25; 864000,25.5; 5101200,25.3; 5104800,25.2; 5108400,25.1;
        5112000,25.1; 5115600,25.2; 5119200,25.3; 5122800,27.3; 5126400,26.9;
        5130000,27.1; 5133600,27.3; 5137200,27.4; 5140800,27.5; 5144400,27.5;
        5148000,27.5; 5151600,28.1; 5155200,28; 5158800,26.3; 5162400,26.1;
        5166000,26; 5169600,25.9; 5173200,25.8; 5176800,25.7; 5180400,25.6])
    "Reference results"
    annotation (Placement(transformation(extent={{76,72},{96,92}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow macConv(T_ref=
        290.75) "Convective heat flow machines"
    annotation (Placement(transformation(extent={{48,-66},{68,-46}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow perRad(T_ref=
        290.75) "Radiative heat flow persons"
    annotation (Placement(transformation(extent={{48,-102},{68,-82}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow perCon(T_ref=
        290.75) "Convective heat flow persons"
    annotation (Placement(transformation(extent={{48,-84},{68,-64}})));
  Modelica.Blocks.Sources.CombiTimeTable tableSolRadWindow(
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    tableOnFile=false,
    table=[0,0; 3600,0; 10800,0; 14400,0; 14400,17; 18000,17; 18000,38; 21600,
        38; 21600,59; 25200,59; 25200,98; 28800,98; 28800,186; 32400,186; 32400,
        287; 36000,287; 36000,359; 39600,359; 39600,385; 43200,385; 43200,359;
        46800,359; 46800,287; 50400,287; 50400,186; 54000,186; 54000,98; 57600,
        98; 57600,59; 61200,59; 61200,38; 64800,38; 64800,17; 68400,17; 68400,0;
        72000,0; 82800,0; 86400,0],
    columns={2}) "Solar radiation"
    annotation (Placement(transformation(extent={{-84,66},{-70,80}})));
  Modelica.Blocks.Sources.Constant g_sunblind(k=0.15)
    "g value for sunblind closed"
    annotation (Placement(
    transformation(
    extent={{-3,-3},{3,3}},
    rotation=-90,
    origin={-19,57})));
  Modelica.Blocks.Sources.Constant sunblind_open(k=1)
    "g value for sunblind open" annotation (Placement(
    transformation(
    extent={{-3,-3},{3,3}},
    rotation=-90,
    origin={-33,57})));
  Modelica.Blocks.Logical.GreaterThreshold greaterThreshold1(threshold=100)
    "Threshold for sunblind for one direction"
    annotation (Placement(transformation(
    extent={{-5,-5},{5,5}},
    rotation=-90,
    origin={-59,59})));
  Modelica.Blocks.Math.Product product1
    "Solar radiation times g value for sunblind (open or closed) for one
    direction"
    annotation (Placement(transformation(extent={{-6,65},{4,75}})));
  Modelica.Blocks.Logical.Switch switch1
    "Determines g value for sunblind (open or closed) for one direction"
    annotation (Placement(transformation(
    extent={{-6,-6},{6,6}},
    rotation=-90,
    origin={-26,38})));
  Modelica.Blocks.Sources.CombiTimeTable outdoorTemp(
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    columns={2},
    table=[0,291.95; 3600,291.95; 3600,290.25; 7200,290.25; 7200,289.65; 10800,
        289.65; 10800,289.25; 14400,289.25; 14400,289.65; 18000,289.65; 18000,
        290.95; 21600,290.95; 21600,293.45; 25200,293.45; 25200,295.95; 28800,
        295.95; 28800,297.95; 32400,297.95; 32400,299.85; 36000,299.85; 36000,
        301.25; 39600,301.25; 39600,302.15; 43200,302.15; 43200,302.85; 46800,
        302.85; 46800,303.55; 50400,303.55; 50400,304.05; 54000,304.05; 54000,
        304.15; 57600,304.15; 57600,303.95; 61200,303.95; 61200,303.25; 64800,
        303.25; 64800,302.05; 68400,302.05; 68400,300.15; 72000,300.15; 72000,
        297.85; 75600,297.85; 75600,296.05; 79200,296.05; 79200,295.05; 82800,
        295.05; 82800,294.05; 86400,294.05]) "Outdoor air temperature"
    annotation (Placement(transformation(extent={{-90,-8},{-74,8}})));
  EquivalentAirTemperature.VDI6007 eqAirTemp(
    aExt=0.7,
    alphaWallOut=20,
    alphaRadWall=5,
    eExt=0.9,
    withLongwave=false,
    n=1,
    wfWall={0.04646093176283288},
    wfWin={0.32441554918476245},
    wfGro=0.6291235190524047,
    TGro=288.15) "Equivalent air temperature"
    annotation (Placement(transformation(extent={{-24,-4},{-4,14}})));
  Modelica.Blocks.Sources.Constant const(k=273.15)
    "Dummy black body sky temperature"
    annotation (Placement(transformation(extent={{-56,4},{-50,10}})));
  Modelica.Blocks.Sources.Constant HSol(k=0) "Solar radiation on walls"
    annotation (Placement(transformation(extent={{-84,22},{-78,28}})));
  Modelica.Blocks.Sources.Constant sunblind(k=0)
    "Dummy for g value of sunblinds (open)"
    annotation (Placement(
    transformation(
    extent={{-3,-3},{3,3}},
    rotation=-90,
    origin={-15,23})));
  Modelica.Thermal.HeatTransfer.Components.Convection theConWall
    "Outdoor convective heat transfer"
    annotation (Placement(transformation(extent={{34,5},{24,-5}})));
  Modelica.Blocks.Sources.Constant alphaWall(k=28*9.75)
    "Outdoor coefficient of heat transfer for walls"
    annotation (Placement(
    transformation(
    extent={{-4,-4},{4,4}},
    rotation=90,
    origin={28,-19})));
    
equation
  connect(perRad.port, thermalZoneTwoElements.intGainsRad)
    annotation (Line(
    points={{68,-92},{68,-92},{98,-92},{98,24},{92.2,24}}, color={191,0,0}));
  connect(intGai.y[1], perRad.Q_flow)
    annotation (Line(points={{22.8,
    -52},{30,-52},{38,-52},{38,-92},{48,-92}}, color={0,0,127}));
  connect(intGai.y[2], perCon.Q_flow)
    annotation (Line(points={{
    22.8,-52},{38,-52},{38,-74},{48,-74}}, color={0,0,127}));
  connect(intGai.y[3], macConv.Q_flow)
    annotation (Line(points={{
    22.8,-52},{38,-52},{38,-56},{48,-56}}, color={0,0,127}));
  connect(tableSolRadWindow.y[1],greaterThreshold1. u)
    annotation (Line(points={{-69.3,73},{-59,73},{-59,65}}, color={0,0,127}));
  connect(sunblind_open.y, switch1.u3)
    annotation (Line(points={{-33,53.7},{-33,
    48},{-30.8,48},{-30.8,45.2}}, color={0,0,127}));
  connect(g_sunblind.y, switch1.u1)
    annotation (Line(points={{-19,53.7},{-19,48},
    {-21.2,48},{-21.2,45.2}}, color={0,0,127}));
  connect(tableSolRadWindow.y[1], product1.u1)
    annotation (Line(points={{-69.3,
    73},{-37.65,73},{-7,73}}, color={0,0,127}));
  connect(greaterThreshold1.y, switch1.u2)
    annotation (Line(points={{-59,53.5},
    {-59,46},{-40,46},{-40,64},{-26,64},{-26,45.2}}, color={255,0,255}));
  connect(switch1.y, product1.u2)
    annotation (Line(points={{-26,31.4},{-26,28},
    {-10,28},{-10,67},{-7,67}}, color={0,0,127}));
  connect(outdoorTemp.y[1], eqAirTemp.TDryBul)
    annotation (Line(points={{-73.2,0},{-26,0},{-26,-0.4}},  color={0,0,127}));
  connect(const.y,eqAirTemp. TBlaSky)
    annotation (Line(points={{-49.7,7},{-28.85,7},{-28.85,5},{-26,5}},
    color={0,0,127}));
  connect(eqAirTemp.TEqAir, preTem.T)
    annotation (Line(points={{-3,5},{0.9,5},{0.9,0},{6.8,0}},
    color={0,0,127}));
  connect(HSol.y, eqAirTemp.HSol[1])
    annotation (Line(points={{-77.7,25},{-32,25},{-32,10.4},{-26,10.4}},
    color={0,0,127}));
  connect(sunblind.y, eqAirTemp.sunblind[1])
    annotation (Line(points={{-15,19.7},{-15,15.85},{-14,15.85},{-14,15.8}},
    color={0,0,127}));
  connect(alphaWall.y,theConWall. Gc)
    annotation (Line(points={{28,-14.6},{29,-14.6},{29,-5}}, color={0,0,127}));
  connect(preTem.port, theConWall.fluid)
    annotation (Line(points={{20,0},{24,0}}, color={191,0,0}));
  connect(theConWall.solid, thermalZoneTwoElements.extWall)
    annotation (Line(points={{34,0},{40,0},{40,12},{43.8,12}}, color={191,0,0}));
  connect(perCon.port, thermalZoneTwoElements.intGainsConv)
    annotation (
    Line(points={{68,-74},{82,-74},{96,-74},{96,20},{92,20}}, color={191,
    0,0}));
  connect(macConv.port, thermalZoneTwoElements.intGainsConv)
    annotation (
    Line(points={{68,-56},{96,-56},{96,20},{92,20}}, color={191,0,0}));
  connect(product1.y, thermalZoneTwoElements.solRad[1])
    annotation (Line(points=
    {{4.5,70},{14,70},{28,70},{28,31},{43,31}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
  -100},{100,100}})), Documentation(info="<html>
  <p>Test Case 10 of the VDI 6007 Part 1: Calculation of indoor air temperature
  excited by a radiative and convective heat source for room version S. It is
  based on Test Case 5, but with a non-adiabatic floor plate to an adjacent room
  with a fixed temperature.</p>
  <p>Boundary Condtions:</p>
  <ul>
  <li>daily profile for outdoor air temperature in hourly steps</li>
  <li>no solar or short-wave radiation on the exterior wall</li>
  <li>daily profile for solar radiation through the windows in hourly steps</li>
  <li>sunblind closes at &GT;100 W/m2</li>
  <li>no long-wave radiation exchange between exterior wall, windows and ambient
  environment</li>
  </ul>
  <p><br>This test case is thought to test linking to ajdacent rooms with fixed
  temperature.</p>
  </html>", revisions="<html>
  <ul>
  <li>
  January 11, 2016, by Moritz Lauster:<br/>
  Implemented.
  </li>
  </ul>
  </html>"),
  __Dymola_Commands(file=
  "modelica://Annex60/Resources/Scripts/Dymola/Experimental/ThermalZones/ReducedOrder/Validation/VDI6007/TestCase10.mos"
        "Simulate and plot"));
end TestCase10;
