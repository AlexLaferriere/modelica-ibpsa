within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.Examples;
model GFUNCT_CALC
  extends Modelica.Icons.Example;

  //import IBPSA;
  package Medium = Modelica.Media.Water.ConstantPropertyLiquidWater;

protected
  IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.BoreholeOneUTube
    borehole(
    redeclare package Medium = Medium,
    borFieDat=borFieDat,
    m_flow_nominal=borFieDat.conDat.m_flow_nominal_bh,
    dp_nominal=borFieDat.conDat.dp_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=283.15)
             annotation (Placement(transformation(extent={{0,0},{20,20}})));

public
  parameter IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.BorefieldData.SandBox_validation
                                        borFieDat(soiDat=
        IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.SoilData.SandBox_validation(
        k=3.2),
    filDat=
        IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.FillingData.SandBox_validation(),
    conDat=
        IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.ConfigurationData.SandBox_validation(
        T_start=283.15,
        m_flow_nominal_bh=0.5,
        dp_nominal=0,
        hBor=100,
        rBor=0.05,
        dBor=4))                                  "Borefield parameters"
    annotation (Placement(transformation(extent={{-100,-100},{-80,-80}})));

  Modelica.Thermal.HeatTransfer.Components.ThermalCollector therCol1(m=
        borFieDat.conDat.nVer) "Thermal collector" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-10,50})));

protected
  IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.GroundHeatTransfer.GroundTemperatureResponse
    groTemRes(         borFieDat=borFieDat,
    forceGFunCalc=true,
    tLoaAgg=1800)                           "Ground temperature response"
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
public
  Modelica.Blocks.Sources.Constant const(k=283.15)
    "Cosntant ground temperature"
    annotation (Placement(transformation(extent={{-100,70},{-80,90}})));
  IBPSA.Fluid.Sensors.TemperatureTwoPort TBorAnaOut(m_flow_nominal=borFieDat.conDat.m_flow_nominal_bh,
      redeclare package Medium = Medium,
    T_start=283.15)                      "Outlet borehole temperature"
    annotation (Placement(transformation(extent={{40,0},{60,20}})));
  IBPSA.Fluid.Sensors.TemperatureTwoPort TBorAnaIn(m_flow_nominal=borFieDat.conDat.m_flow_nominal_bh,
      redeclare package Medium = Medium,
    T_start=283.15)                      "Outlet borehole temperature"
    annotation (Placement(transformation(extent={{-30,0},{-10,20}})));
  Modelica.Blocks.Sources.RealExpression Tfluid(y=((TBorAnaIn.T + TBorAnaOut.T)
        /2))
           annotation (Placement(transformation(extent={{-20,-80},{0,-60}})));
//protected
  IBPSA.Fluid.HeatExchangers.HeaterCooler_u hea(
    redeclare package Medium = Medium,
    m_flow_nominal=borFieDat.conDat.m_flow_nominal_bh,
    dp_nominal=0,
    tau=0.5,
    Q_flow_nominal=1,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=283.15)
    annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
public
  IBPSA.Fluid.Sources.Boundary_pT sin1(
    redeclare package Medium = Medium,
    use_p_in=false,
    p(displayUnit="kPa") = 101330,
    nPorts=1,
    T(displayUnit="degC") = 283.15)
              "Sink" annotation (Placement(transformation(extent={{-100,0},{-80,
            20}}, rotation=0)));
  IBPSA.Fluid.Movers.FlowControlled_m_flow fan(
    redeclare package Medium = Medium,
    m_flow_nominal=borFieDat.conDat.m_flow_nominal_bh,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=283.15)
    annotation (Placement(transformation(extent={{40,-40},{20,-20}})));
  Modelica.Blocks.Sources.Constant const2(k=borFieDat.conDat.m_flow_nominal_bh)
    "Cosntant ground temperature"
    annotation (Placement(transformation(extent={{80,-60},{60,-40}})));
  Modelica.Blocks.Sources.RealExpression heatin(y=2*Modelica.Constants.pi*
        borFieDat.soiDat.k*borFieDat.conDat.hBor)
    annotation (Placement(transformation(extent={{-100,30},{-80,50}})));
  Modelica.Blocks.Sources.CombiTimeTable combiTimeTable(
    tableOnFile=true,
    fileName=
        "//apollon.meca.polymtl.ca/usagers/allafg/profiles/Desktop/validation_gfunct.txt",
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    tableName="tab1",
    extrapolation=Modelica.Blocks.Types.Extrapolation.HoldLastPoint,
    timeScale(displayUnit="s") = 1800)
    annotation (Placement(transformation(extent={{-96,-60},{-76,-40}})));

equation
  connect(therCol1.port_a, borehole.port_wall)
    annotation (Line(points={{0,50},{4,50},{10,50},{10,20}}, color={191,0,0}));
  connect(groTemRes.Tb, therCol1.port_b)
    annotation (Line(points={{-40,50},{-30,50},{-20,50}}, color={191,0,0}));
  connect(groTemRes.Tg, const.y) annotation (Line(points={{-62,50},{-70,50},{
          -70,80},{-79,80}}, color={0,0,127}));
  connect(borehole.port_b, TBorAnaOut.port_a)
    annotation (Line(points={{20,10},{30,10},{40,10}}, color={0,127,255}));
  connect(borehole.port_a, TBorAnaIn.port_b)
    annotation (Line(points={{0,10},{-6,10},{-10,10}}, color={0,127,255}));
  connect(hea.port_b, TBorAnaIn.port_a)
    annotation (Line(points={{-40,10},{-40,10},{-30,10}}, color={0,127,255}));
  connect(TBorAnaOut.port_b, fan.port_a) annotation (Line(points={{60,10},{70,
          10},{70,-30},{40,-30}}, color={0,127,255}));
  connect(fan.port_b, hea.port_a) annotation (Line(points={{20,-30},{-24,-30},{
          -72,-30},{-72,10},{-60,10}}, color={0,127,255}));
  connect(hea.port_a, sin1.ports[1])
    annotation (Line(points={{-60,10},{-60,10},{-80,10}}, color={0,127,255}));
  connect(const2.y, fan.m_flow_in) annotation (Line(points={{59,-50},{54,-50},{
          50,-50},{50,-10},{30,-10},{30,-18}}, color={0,0,127}));
  connect(combiTimeTable.y[1], hea.u) annotation (Line(points={{-75,-50},{-68,
          -50},{-68,16},{-62,16}}, color={0,0,127}));
  annotation (experiment(stopTime=51300, numberOfIntervals=0, outputInterval=300),Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end GFUNCT_CALC;
