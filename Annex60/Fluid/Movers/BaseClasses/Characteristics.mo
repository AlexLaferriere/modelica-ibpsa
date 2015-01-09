within Annex60.Fluid.Movers.BaseClasses;
package Characteristics "Functions for fan or pump characteristics"

  record flowParameters "Record for flow parameters"
    extends Modelica.Icons.Record;

    parameter Modelica.SIunits.VolumeFlowRate V_flow[:](each min=0)
      "Volume flow rate at user-selected operating points";
    parameter Modelica.SIunits.Pressure dp[:](
       each min=0, each displayUnit="Pa")
      "Fan or pump total pressure at these flow rates";

    // This is needed for OpenModelica.
    // fixme: Check if this can be put into FlowMachineInterface instead of here.
    final parameter Integer n = size(V_flow,1)
      "Number of data points for flow rate in V_flow vs. pressure data";

    annotation (Documentation(info="<html>
<p>
Data record for performance data that describe volume flow rate versus
pressure rise.
The volume flow rate <code>V_flow</code> must be increasing, i.e.,
<code>V_flow[i] &lt; V_flow[i+1]</code>.
Both vectors, <code>V_flow</code> and <code>dp</code>
must have the same size.
</p>
</html>",
  revisions="<html>
<ul>
<li>
September 28, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
  end flowParameters;

  record flowParametersInternal
    "Record for flow parameters with prescribed size"
    extends Modelica.Icons.Record;
    parameter Integer n "Number of elements in each array"
     annotation(Evaluate=true);
    parameter Modelica.SIunits.VolumeFlowRate V_flow[n](each min=0)
      "Volume flow rate at user-selected operating points";
    parameter Modelica.SIunits.Pressure dp[n](
       each min=0, each displayUnit="Pa")
      "Fan or pump total pressure at these flow rates";
    annotation (Documentation(info="<html>
<p>
Data record for performance data that describe volume flow rate versus
pressure rise.
The volume flow rate <code>V_flow</code> must be increasing, i.e.,
<code>V_flow[i] &lt; V_flow[i+1]</code>.
Both vectors, <code>V_flow</code> and <code>dp</code>
must have the same size.
</p>
<p>
This record is identical to
<a href=\"modelica://Annex60.Fluid.Movers.BaseClasses.Characteristic.flowParameters\">
Annex60.Fluid.Movers.BaseClasses.Characteristic.flowParameters</a>,
except that it takes the size of the array as a parameter. This is required
in Dymola 2014. Otherwise, the array size would need to be computed in
<a href=\"modelica://Annex60.Fluid.Movers.BaseClasses.FlowMachineInterface\">
Annex60.Fluid.Movers.BaseClasses.FlowMachineInterface</a>
in the <code>initial algorithm</code> section, which is not supported.
</p>
</html>",
  revisions="<html>
<ul>
<li>
March 22, 2013, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
  end flowParametersInternal;

  record efficiencyParameters "Record for efficiency parameters"
    extends Modelica.Icons.Record;
    parameter Modelica.SIunits.VolumeFlowRate V_flow[:](
      each min=0) "Volumetric flow rate at user-selected operating points";
    parameter Real eta[size(V_flow,1)](
       each min=0,
       each max=1,
       each displayUnit="1") "Fan or pump efficiency at these flow rates";
    annotation (Documentation(info="<html>
<p>
Data record for performance data that describe volume flow rate versus
efficiency.
The volume flow rate <code>r_V</code> must be increasing, i.e.,
<code>r_V[i] &lt; r_V[i+1]</code>.
Both vectors, <code>r_V</code> and <code>eta</code>
must have the same size.
</p>
</html>",
  revisions="<html>
<ul>
<li>
September 28, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
  end efficiencyParameters;

  record powerParameters "Record for electrical power parameters"
    extends Modelica.Icons.Record;
    parameter Modelica.SIunits.VolumeFlowRate V_flow[:](each min=0)
      "Volume flow rate at user-selected operating points";
    parameter Modelica.SIunits.Power P[size(V_flow,1)](each min=0)
      "Fan or pump electrical power at these flow rates";
    annotation (Documentation(info="<html>
<p>
Data record for performance data that describe volume flow rate versus
electrical power.
The volume flow rate <code>V_flow</code> must be increasing, i.e.,
<code>V_flow[i] &lt; V_flow[i+1]</code>.
Both vectors, <code>V_flow</code> and <code>P</code>
must have the same size.
</p>
</html>",
  revisions="<html>
<ul>
<li>
October 10, 2012, by Michael Wetter:<br/>
Fixed wrong <code>displayUnit</code> and
<code>max</code> attribute for power.
</li>
<li>
September 28, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
  end powerParameters;

  function pressure
    "Flow vs. head characteristics for fan or pump pressure raise"
    extends Modelica.Icons.Function;
    input
      Annex60.Fluid.Movers.BaseClasses.Characteristics.flowParametersInternal
                                                                                per
      "Pressure performance data";
    input Modelica.SIunits.VolumeFlowRate V_flow "Volumetric flow rate";
    input Real r_N(unit="1") "Relative revolution, r_N=N/N_nominal";
    input Modelica.SIunits.VolumeFlowRate VDelta_flow "Small volume flow rate";
    input Modelica.SIunits.Pressure dpDelta "Small pressure";

    input Modelica.SIunits.VolumeFlowRate V_flow_max
      "Maximum volume flow rate at r_N=1 and dp=0";
    input Modelica.SIunits.Pressure dpMax(min=0)
      "Maximum pressure at r_N=1 and V_flow=0";

    input Real d[:] "Derivatives at support points for spline interpolation";
    input Real delta "Small value used to transition to other fan curve";
    input Real cBar[2]
      "Coefficients for linear approximation of pressure vs. flow rate";
    input Real kRes(unit="kg/(s.m4)")
      "Linear coefficient for fan-internal pressure drop";
    output Modelica.SIunits.Pressure dp "Pressure raise";

  protected
     Integer dimD(min=2)=size(per.V_flow, 1) "Dimension of data vector";

    function performanceCurve "Performance curve away from the origin"
      input Modelica.SIunits.VolumeFlowRate V_flow "Volumetric flow rate";
      input Real r_N(unit="1") "Relative revolution, r_N=N/N_nominal";
      input Real d[dimD]
        "Coefficients for polynomial of pressure vs. flow rate";
      input
        Annex60.Fluid.Movers.BaseClasses.Characteristics.flowParametersInternal
                                                                                  per
        "Pressure performance data";
      input Integer dimD "Dimension of data vector";

      output Modelica.SIunits.Pressure dp "Pressure raise";

    protected
      Modelica.SIunits.VolumeFlowRate rat "Ratio of V_flow/r_N";
      Integer i "Integer to select data interval";
    algorithm
      rat := V_flow/r_N;
      i :=1;
      // Since the coefficients for the spline were evaluated for
      // rat_nominal = V_flow_nominal/r_N_nominal = V_flow_nominal/1, we use
      // V_flow_nominal below
      for j in 1:dimD-1 loop
         if rat > per.V_flow[j] then
           i := j;
         end if;
      end for;
      // Extrapolate or interpolate the data
      dp:=r_N^2*Annex60.Utilities.Math.Functions.cubicHermiteLinearExtrapolation(
                  x=rat,
                  x1=per.V_flow[i],
                  x2=per.V_flow[i + 1],
                  y1=per.dp[i],
                  y2=per.dp[i + 1],
                  y1d=d[i],
                  y2d=d[i+1]);
      annotation(smoothOrder=1);
    end performanceCurve;

  algorithm
    if r_N >= delta then
       dp := performanceCurve(V_flow=V_flow, r_N=r_N, d=d,
                              per=per, dimD=dimD);
    elseif r_N <= delta/2 then
      dp := flowApproximationAtOrigin(r_N=r_N, V_flow=V_flow,
                                      VDelta_flow=  VDelta_flow, dpDelta=dpDelta,
                                      delta=delta, cBar=cBar);
    else
      dp := Modelica.Fluid.Utilities.regStep(x=r_N-0.75*delta,
                                             y1=performanceCurve(V_flow=V_flow, r_N=r_N, d=d,
                                                                 per=per, dimD=dimD),
                                             y2=flowApproximationAtOrigin(r_N=r_N, V_flow=V_flow,
                                                     VDelta_flow=VDelta_flow, dpDelta=dpDelta,
                                                     delta=delta, cBar=cBar),
                                             x_small=delta/4);
    end if;
    // linear equation for being able to handle r_N=0, see
    // Annex60/Resources/Images/Fluid/Movers/UsersGuide/2013-IBPSA-Wetter.pdf
    dp := dp - V_flow*kRes;
    annotation(smoothOrder=1,
                Documentation(info="<html>
<p>
This function computes the fan static
pressure raise as a function of volume flow rate and revolution in the form
</p>
<p align=\"center\" style=\"font-style:italic;\">
  &Delta;p = r<sub>N</sub><sup>2</sup> &nbsp; s(V&#775;/r<sub>N</sub>, d)
  - &Delta;p<sub>r</sub> ,
</p>
<p>
where
<i>&Delta;p</i> is the pressure rise,
<i>r<sub>N</sub></i> is the normalized fan speed,
<i>V&#775;</i> is the volume flow rate and
<i>d</i> are performance data for fan or pump power consumption at <i>r<sub>N</sub>=1</i>.
The term
</p>
<p align=\"center\" style=\"font-style:italic;\">
&Delta;p<sub>r</sub> = V&#775; &nbsp; &Delta;p<sub>max</sub> &frasl; V&#775;<sub>max</sub> &nbsp; &delta;
</p>
<p>
where <i>&delta; &gt; 0</i> is a pressure that is small compared to pressure raise of the
fan at the nominal conditions,
models the flow resistance of the fan, approximated using a linear equation.
This is done for numerical reasons to avoid a singularity at <i>r<sub>N</sub>=0</i>.
Since <i>&delta;</i> is small, the contribution of this term is small.
The fan and pump models in
<a href=\"modelica://Annex60.Fluid.Movers\">
Annex60.Fluid.Movers</a> modify the user-supplied performance data to add the term
<i>&Delta;p<sub>r</sub></i> prior to computing the performance curve.
Thus, at full speed, the fan or pump can operate exactly at the user-supplied performance data.
</p>
<h4>Implementation</h4>
<p>
The function <i>s(&middot;, &middot;)</i> is a cubic hermite spline.
If the data <i>d</i> define a monotone decreasing sequence, then
<i>s(&middot;, d)</i> is a monotone decreasing function.
</p>
<p>
For <i>r<sub>N</sub> &lt; &delta;</i>, the polynomial is replaced with an other model to avoid
a singularity at the origin. The composite model is once continuously differentiable
in all input variables.
</p>
</html>", revisions="<html>

<ul>
<li>
April 22, by Filip Jorissen:<br/>
Added more documentation references to paper
</li>
<li>
August 25, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),     smoothOrder=1);
  end pressure;

  function flowApproximationAtOrigin
    "Approximation for fan or pump pressure raise at origin"
    extends Modelica.Icons.Function;
    input Modelica.SIunits.VolumeFlowRate V_flow "Volumetric flow rate";
    input Real r_N(unit="1") "Relative revolution, r_N=N/N_nominal";
    input Modelica.SIunits.VolumeFlowRate VDelta_flow "Small volume flow rate";
    input Modelica.SIunits.Pressure dpDelta "Small pressure";
    input Real delta "Small value used to transition to other fan curve";
    input Real cBar[2]
      "Coefficients for linear approximation of pressure vs. flow rate";
    output Modelica.SIunits.Pressure dp "Pressure raise";
  algorithm

    // see equation 20 in  Annex60/Resources/Images/Fluid/Movers/UsersGuide/2013-IBPSA-Wetter.pdf
    // this equation satisfies the constraints detailed in the paper
    // the first term is added for having a faster convergence
    // the last term in the paper is absent here because it can be found in
    // Annex60.Fluid.Movers.BaseClasses.Characteristics.pressure
    dp := r_N * dpDelta + r_N^2 * (cBar[1] + cBar[2]*V_flow);
    annotation (Documentation(info="<html>
<p>
This function computes the fan static
pressure raise as a function of volume flow rate and revolution near the origin.
It is used to avoid a singularity in the pump or fan curve if the revolution
approaches zero.
</p>
</html>", revisions="<html>
<ul>
<li>
August 25, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),     smoothOrder=100);
  end flowApproximationAtOrigin;

  function power "Flow vs. electrical power characteristics for fan or pump"
    extends Modelica.Icons.Function;
    input Annex60.Fluid.Movers.BaseClasses.Characteristics.powerParameters per
      "Pressure performance data";
    input Modelica.SIunits.VolumeFlowRate V_flow "Volumetric flow rate";
    input Real r_N(unit="1") "Relative revolution, r_N=N/N_nominal";
    input Real d[:] "Derivatives at support points for spline interpolation";
    input Real delta "Small value for switching implementation around zero rpm";
    output Modelica.SIunits.Power P "Power consumption";

  protected
     Integer n=size(per.V_flow, 1) "Dimension of data vector";

     Modelica.SIunits.VolumeFlowRate rat "Ratio of V_flow/r_N";
     Integer i "Integer to select data interval";

  algorithm
    if n == 1 then
      P := r_N^3*per.P[1];
    else
      i :=1;
      // The use of the max function to avoids problems for low speeds
      // and turned off pumps
      rat:=V_flow/
              Annex60.Utilities.Math.Functions.smoothMax(
                x1=r_N,
                x2=0.1,
                deltaX=delta);
      for j in 1:n-1 loop
         if rat > per.V_flow[j] then
           i := j;
         end if;
      end for;
      // Extrapolate or interpolate the data
      P:=r_N^3*Annex60.Utilities.Math.Functions.cubicHermiteLinearExtrapolation(
                  x=rat,
                  x1=per.V_flow[i],
                  x2=per.V_flow[i + 1],
                  y1=per.P[i],
                  y2=per.P[i + 1],
                  y1d=d[i],
                  y2d=d[i+1]);
    end if;
    annotation(smoothOrder=1,
                Documentation(info="<html>
<p>
This function computes the fan power consumption for given volume flow rate,
speed and performance data. The power consumption is
</p>
<p align=\"center\" style=\"font-style:italic;\">
  P = r<sub>N</sub><sup>3</sup> &nbsp; s(V&#775;/r<sub>N</sub>, d),
</p>
<p>
where
<i>P</i> is the power consumption,
<i>r<sub>N</sub></i> is the normalized fan speed,
<i>V&#775;</i> is the volume flow rate and
<i>d</i> are performance data for fan or pump power consumption at <i>r<sub>N</sub>=1</i>.
</p>
<h4>Implementation</h4>
<p>
The function <i>s(&middot;, &middot;)</i> is a cubic hermite spline.
If the data <i>d</i> define a monotone decreasing sequence, then
<i>s(&middot;, d)</i> is a monotone decreasing function.
</p>
</html>", revisions="<html>
<ul>
<li>
February 26, 2014, by Filip Jorissen:<br/>
Changed polynomial to be evaluated at <code>V_flow/r_N</code>
instead of <code>V_flow</code> to properly account for the
scaling law. See
<a href=\"https://github.com/lbl-srg/modelica-buildings/pull/202\">#202</a>
for a discussion and validation.
</li>
<li>
September 28, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),     smoothOrder=1);
  end power;

  function efficiency "Flow vs. efficiency characteristics for fan or pump"
    extends Modelica.Icons.Function;
    input
      Annex60.Fluid.Movers.BaseClasses.Characteristics.efficiencyParameters
      per "Efficiency performance data";
    input Modelica.SIunits.VolumeFlowRate V_flow "Volumetric flow rate";
    input Real d[:] "Derivatives at support points for spline interpolation";
    input Real r_N(unit="1") "Relative revolution, r_N=N/N_nominal";
    input Real delta "Small value for switching implementation around zero rpm";
    output Real eta(min=0, unit="1") "Efficiency";

  protected
    Integer n = size(per.V_flow, 1) "Number of data points";
    Real rat "Ratio of V_flow/r_N";
    Integer i "Integer to select data interval";
  algorithm
    if n == 1 then
      eta := per.eta[1];
    else
      // The use of the max function to avoids problems for low speeds
      // and turned off pumps
      rat:=V_flow/
              Annex60.Utilities.Math.Functions.smoothMax(
                x1=r_N,
                x2=0.1,
                deltaX=delta);
      i :=1;
      for j in 1:n-1 loop
         if rat > per.V_flow[j] then
           i := j;
         end if;
      end for;
      // Extrapolate or interpolate the data
      eta:=Annex60.Utilities.Math.Functions.cubicHermiteLinearExtrapolation(
                  x=rat,
                  x1=per.V_flow[i],
                  x2=per.V_flow[i + 1],
                  y1=per.eta[i],
                  y2=per.eta[i + 1],
                  y1d=d[i],
                  y2d=d[i+1]);
    end if;

    annotation(smoothOrder=1,
                Documentation(info="<html>
<p>
This function computes the fan or pump efficiency for given normalized volume flow rate
and performance data. The efficiency is
</p>
<p align=\"center\" style=\"font-style:italic;\">
  &eta; = s(V&#775;/r<sub>N</sub>, d),
</p>
<p>
where
<i>&eta;</i> is the efficiency,
<i>r<sub>N</sub></i> is the normalized fan speed,
<i>V&#775;</i> is the volume flow rate, and
<i>d</i> are performance data for fan or pump efficiency.
</p>
<h4>Implementation</h4>
<p>
The function <i>s(&middot;, &middot;)</i> is a cubic hermite spline.
If the data <i>d</i> define a monotone decreasing sequence, then
<i>s(&middot;, d)</i> is a monotone decreasing function.
</p>
</html>",
  revisions="<html>
<ul>
<li>
November 22, 2014, by Michael Wetter:<br/>
Corrected documentation as curve uses <i>V&#775;</i>
as an independent variable.
</li>
<li>
September 30, 2014, by Filip Jorissen:<br/>
Changed polynomial to be evaluated at <code>V_flow</code>
instead of <code>r_V</code>.
</li>
<li>
April 19, 2014, by Filip Jorissen:<br/>
Changed polynomial to be evaluated at <code>r_V/r_N</code>
instead of <code>r_V</code> to properly account for the
scaling law. See
<a href=\"https://github.com/lbl-srg/modelica-buildings/pull/202\">#202</a>
for a discussion and validation.
</li>
<li>
September 28, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),     smoothOrder=1);
  end efficiency;

  annotation (Documentation(info="<html>
<p>
This package implements performance curves for fans and pumps,
and records for parameter that can be used with these performance
curves.
</p>
<p>
See the
<a href=\"modelica://Annex60.Fluid.Movers.UsersGuide\">
User's Guide</a> for information about these performance curves.
</p>
</html>",
revisions="<html>
<ul>
<li>
September 29, 2011, by Michael Wetter:<br/>
New implementation due to changes from polynomial to cubic hermite splines.
</li>
</ul>
</html>"));
end Characteristics;
