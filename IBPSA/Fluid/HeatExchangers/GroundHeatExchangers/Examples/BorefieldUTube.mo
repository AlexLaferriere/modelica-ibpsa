within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Examples;
model BorefieldUTube
  extends Modelica.Icons.Example;
  package Medium = Modelica.Media.Water.ConstantPropertyLiquidWater;

  replaceable borefieldUTube borFie(redeclare package Medium = Medium,
      borFieDat=borFieDat)
    annotation (Placement(transformation(extent={{-22,-18},{20,18}})));
  Sources.MassFlowSource_T             sou(
    redeclare package Medium = Medium,
    nPorts=1,
    use_T_in=false,
    m_flow=borFieDat.conDat.m_flow_nominal_bh,
    T=303.15) "Source" annotation (Placement(transformation(extent={{-100,-10},{
            -80,10}}, rotation=0)));
  Sensors.TemperatureTwoPort TBorFieIn(m_flow_nominal=borFieDat.conDat.m_flow_nominal_bh,
      redeclare package Medium = Medium) "Inlet borefield temperature"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Sources.Boundary_pT             sin(
    redeclare package Medium = Medium,
    use_p_in=false,
    use_T_in=false,
    p=101330,
    T=283.15,
    nPorts=1) "Sink" annotation (Placement(transformation(extent={{100,-10},{80,
            10}}, rotation=0)));
  Sensors.TemperatureTwoPort TBorFieOut(m_flow_nominal=borFieDat.conDat.m_flow_nominal_bh,
      redeclare package Medium = Medium) "Outlet borefield temperature"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Data.BorefieldData.ExampleBorefieldData borFieDat
    annotation (Placement(transformation(extent={{-100,-100},{-80,-80}})));
equation
  connect(sou.ports[1], TBorFieIn.port_a)
    annotation (Line(points={{-80,0},{-60,0}}, color={0,127,255}));
  connect(TBorFieIn.port_b, borFie.port_a)
    annotation (Line(points={{-40,0},{-32,0},{-22,0}}, color={0,127,255}));
  connect(TBorFieOut.port_a, borFie.port_b)
    annotation (Line(points={{40,0},{20,0}}, color={0,127,255}));
  connect(TBorFieOut.port_b, sin.ports[1])
    annotation (Line(points={{60,0},{70,0},{80,0}}, color={0,127,255}));
end BorefieldUTube;