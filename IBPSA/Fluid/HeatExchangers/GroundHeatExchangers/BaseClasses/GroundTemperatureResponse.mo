within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses;
model GroundTemperatureResponse "Model calculating discrete load aggregation"
  parameter Integer p_max(min=1) = 5 "Number of cells per aggregation level";
  parameter Boolean forceGFunCalc = false
    "Set to true to force the thermal response to be calculated at the start";
  replaceable parameter
    IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.Records.BorefieldData
    bfData constrainedby
    IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.Records.BorefieldData
    "Record containing all the parameters of the borefield model" annotation (
     choicesAllMatching=true, Placement(transformation(extent={{-90,-88},{-70,
            -68}})));

  Modelica.Blocks.Interfaces.RealInput Tg
    "Temperature input for undisturbed ground conditions"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a Tb
    "Heat port for resulting borehole wall conditions"
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));

protected
  parameter Integer nbTimSho = 26 "Number of time steps in short time region";
  parameter Integer nbTimLon = 50 "Number of time steps in long time region";
  parameter Real ttsMax = exp(5) "Maximum adimensional time for gfunc calculation";
  parameter String SHAgfun = IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.ThermalResponseFactors.shaGFunction(
    nbBor=bfData.gen.nbBh,
    cooBor=bfData.gen.cooBh,
    hBor=bfData.gen.hBor,
    dBor=bfData.gen.dBor,
    rBor=bfData.gen.rBor,
    alpha=bfData.soi.alp) "String with encrypted g-function arguments";
  parameter Integer nrow = nbTimSho+nbTimLon-1
    "Length of g-function matrix";
  parameter Real lvlBas = 2 "Base for exponential cell growth between levels";
  parameter Modelica.SIunits.Time timFin=
    (bfData.gen.hBor^2/(9*bfData.soi.alp))*ttsMax;
  parameter Integer i = IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.countAggPts(
    lvlBas=lvlBas,
    p_max=p_max,
    timFin=timFin,
    lenAggSte=bfData.gen.tStep) "Number of aggregation points";
  parameter Real timSer[nrow+1, 2]=
    IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.timSerMat(
    nbBor=bfData.gen.nbBh,
    cooBor=bfData.gen.cooBh,
    hBor=bfData.gen.hBor,
    dBor=bfData.gen.dBor,
    rBor=bfData.gen.rBor,
    as=bfData.soi.alp,
    ks=bfData.soi.k,
    nrow=nrow,
    sha=SHAgfun,
    forceGFunCalc=forceGFunCalc,
    nbTimSho=nbTimSho,
    nbTimLon=nbTimLon,
    ttsMax=ttsMax)
    "g-function input from mat, with the second column as temperature Tstep";

  final parameter Modelica.SIunits.Time t0(fixed=false) "Simulation start time";
  final parameter Modelica.SIunits.Time[i] nu(fixed=false)
    "Time vector for load aggregation";
  final parameter Real[i] kappa(fixed=false)
    "Weight factor for each aggregation cell";
  final parameter Real[i] rCel(fixed=false) "Cell widths";
  Modelica.SIunits.HeatFlowRate[i] Q_i "Q_bar vector of size i";
  Modelica.SIunits.HeatFlowRate[i] Q_shift
    "Shifted Q_bar vector of size i";
  Integer curCel "Current occupied cell";
  Modelica.SIunits.TemperatureDifference deltaTb "Tb-Tg";
  Real delTbs "Wall temperature change from previous time steps";
  Real derDelTbs
    "Derivative of wall temperature change from previous time steps";
  Real delTbOld "Tb-Tg at previous time step";
  final parameter Real dhdt(fixed=false)
    "Time derivative of g/(2*pi*H*ks) within most recent cell";

initial equation
  Q_i = zeros(i);
  curCel = 1;
  deltaTb = 0;
  Q_shift = Q_i;
  delTbs = 0;

  (nu,rCel) = IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.timAgg(
    i=i,
    lvlBas=lvlBas,
    p_max=p_max,
    lenAggSte=bfData.gen.tStep,
    timFin=timFin);

  t0 = time;

  kappa = IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.kapAgg(
    i=i,
    nrow=nrow,
    TStep=timSer,
    nu=nu);

  dhdt = kappa[1]/bfData.gen.tStep;

equation
  der(deltaTb) = dhdt*Tb.Q_flow + derDelTbs;
  deltaTb = Tb.T-Tg;

  when (sample(t0, bfData.gen.tStep)) then
    (curCel,Q_shift) = IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.nextTimeStep(
      i=i,
      Q_i=pre(Q_i),
      rCel=rCel,
      nu=nu,
      curTim=(time - t0));

    Q_i = IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.setCurLoa(
      i=i,
      Qb=Tb.Q_flow,
      Q_shift=Q_shift);

    delTbs = IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.tempSuperposition(
      i=i,
      Q_i=Q_shift,
      kappa=kappa,
      curCel=curCel);

    delTbOld = Tb.T-Tg;

    derDelTbs = (delTbs-delTbOld)/bfData.gen.tStep;
  end when;

  assert((time - t0) <= timFin,
    "The simulation is too lengthy for the thermal response factor
    calculations");

  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,30},{100,-100}},
          lineColor={0,0,0},
          fillColor={127,127,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{100,30},{58,-100}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Line(
          points={{72,-4},{-66,-4}},
          color={255,0,0},
          arrow={Arrow.None,Arrow.Filled}),
        Rectangle(
          extent={{94,30},{100,-100}},
          lineColor={0,0,0},
          fillColor={0,128,255},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-151,147},{149,107}},
          lineColor={0,0,255},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={0,127,255},
            textString="%name")}),                      Diagram(
        coordinateSystem(preserveAspectRatio=false)),
        defaultComponentName="groTem",
Documentation(info="<html>
<p>
This model calculates the ground temperature response to obtain the temperature
at the borehole wall in a geothermal system where heat is being injected into or
extracted from the ground.
</p>
<p>
A load-aggregation scheme based on that developped by Claesson and Javed (2012) is
used to calculate the borehole wall temperature response with the temporal superposition
of ground thermal loads. In its base form, the
load-aggregation scheme involves using fixed-length aggregation cells to agglomerate
thermal load history together, with more distant cells (denoted with a higher cell and vector index)
representing more distant thermal history. The more distant the thermal load, the
less impactful it is on the borehole wall temperature change at the current time step.
Each cell has an <i>aggregation time</i> associated to it denoted by <code>nu</code>,
which corresponds to the simulation time (since the beginning of heat injection or
extraction) at which the cell will begin shifting its thermal load to more distant
cells. To determine <code>nu</code>, cells have a temporal size <code>rcel</code>
which follows an exponential growth as shown in the equation below.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/GroundHeatExchangers/LoadAggregation_02.png\" />
</p>
<p>
where <code>p<sub>max</sub></code> is the number of consecutive cells which can have the same size.
Decreasing its value will generally decrease calculation times, at the cost of some
precision in the temporal superposition. <code>rcel</code> is thus expressed in multiples
of whatever aggregation step time is used (via the parameter <code>lenAggSte</code>).
Then, <code>nu</code> may be expressed as the sum of all <code>rcel</code> values
(multiplied by the aggregation step time) up to and including that cell in question.
</p>
<p>
To determine the weighting factors <code>kappa</code> (<code>&kappa;</code> in the equation below), the borefield's temperature
step response at the borefield wall must be determined as follows.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/GroundHeatExchangers/LoadAggregation_03.png\" />
</p>
<p>
where <code>g(t)</code> is the thermal response factor known as the <i>g-function</i>,
<code>H</code> is the total length of all boreholes and <code>k<sub>s</sub></code> is the thermal
conductivity of the soil. The weighting factors <code>kappa</code> (<code>&kappa;</code> in the equation below)
for a given cell <code>i</code> are then expressed as follows.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/GroundHeatExchangers/LoadAggregation_04.png\" />
</p>
<p>
where <code>&nu;</code> refers to the vector <code>nu</code> in this model and <code>T<sub>step</sub>(&nu;<sub>0</sub>)=0</code>.
</p>
<p>
At every aggregation time step, an event is generated to perform the load aggregation steps.
First, the thermal load is shifted. When shifting between cells of different size, total
energy is conserved. This operation is illustred in the figure below by Cimmino (2014).
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/GroundHeatExchangers/LoadAggregation_01.png\" />
</p>
<p>
When performing the shifting operation, the first cell (which
is always the most recent in the simulation) is set to zero. After the shifting, its
value is set with the current load value. Finally, temporal superposition is applied by means
of a scalar product between the aggregated thermal loads <code>Q_i</code> and the
weighting factors <code>kappa</code>. 
</p>
<p>
Due to Modelica's variable time steps, the load aggregation scheme is modified by separating
the thermal response between the current aggregation time step and everything preceding it.
This is shown in the following equation. 
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/GroundHeatExchangers/LoadAggregation_05.png\" />
<br/>
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/GroundHeatExchangers/LoadAggregation_06.png\" />
</p>
<p>
where <code>T<sub>b</sub></code> is the borehole wall temperature, <code>T<sub>g</sub></code>
is the undisturbed ground temperature equal to the <code>Tg</code> input in this model, 
<code>Q</code> is the ground thermal load per borehole length and <code>h = g/(2*&pi;*k<sub>s</sub>)</code>
is a temperature response factor based on the g-function. <code>t<sub>k</sub></code>
is the last discrete aggregation time step, meaning that the current time <code>t</code> is
defined as <code>t<sub>k</sub>&le;t&le;t<sub>k+1</sub></code>.
</p>
<p>
<code>&Delta;T<sub>b</sub>*(t)</code>
is thus the borehole wall temperature change due to the thermal history prior to the current
aggregation step. At every aggregation time step, load aggregation and temporal superposition
are used to calculate its discrete value. This term is assumed to have a linear
time derivative, which is given by the difference between <code>&Delta;T<sub>b</sub>*(t<sub>k+1</sub>)</code>
(the temperature change from load history at the next discrete aggregation time step, which
is constant over the duration of the ongoing aggregation time step) and the total
temperature change at the last aggregation time step, <code>&Delta;T<sub>b</sub>(t)</code>.
</p>
<p>
The second term <code>&Delta;T<sub>b,q</sub>(t)</code> concerns the ongoing aggregation time step.
To obtain the time derivative of this term, the thermal response factor <code>h</code> is assumed
to vary linearly over the course of a aggregation time step. Therefore, because
the ongoing aggregation time step always concerns the first aggregation cell, its derivative (denoted
by the final parameter <code>dhdt</code> in this model) can be calculated as <code>
kappa[1]</code>, the first value in the <code>kappa</code> vector, divided by
the aggregation time step <code>&Delta;t</code>. The derivative of the temperature change at the borehole wall is then expressed
as the multiplication of <code>dhdt</code> (which only needs to be
calculated once at the start of the simulation) and the heat flow <code>Q</code> at
the borehole wall.
</p>
<p>
With the two terms in the expression of <code>&Delta;T<sub>b</sub>(t)</code> expressed
as time derivatives, <code>&Delta;T<sub>b</sub>(t)</code> can itself also be
expressed as its time derivative and implemented as such directly in the Modelica
equations block with the <code>der()</code> operator.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/GroundHeatExchangers/LoadAggregation_07.png\" />
<br/>
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/GroundHeatExchangers/LoadAggregation_08.png\" />
</p>
<p>
This load aggregation scheme is validated in
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.Validation.LoadAggregation_PrescribedQ\">
IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation.Validation.LoadAggregation_PrescribedQ</a>.
</p>
<h4>References</h4>
<p>
Cimmino, M. 2014. <i>D&eacute;veloppement et validation exp&eacute;rimentale de facteurs de r&eacute;ponse
thermique pour champs de puits g&eacute;othermiques</i>,
Ph.D. Thesis, &Eacute;cole Polytechnique de Montr&eacute;al.
</p>
<p>
Claesson, J. and Javed, S. 2012. <i>A load-aggregation method to calculate extraction temperatures of borehole heat exchangers</i>. ASHRAE Transactions 118(1): 530-539.
</p>
</html>", revisions="<html>
<ul>
<li>
April 5, 2018, by Alex Laferriere:<br/>
First implementation.
</li>
</ul>
</html>"));
end GroundTemperatureResponse;
