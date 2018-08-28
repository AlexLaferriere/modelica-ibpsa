within IBPSA.Fluid.HeatExchangers.Ground;
package UsersGuide "User's Guide"
  extends Modelica.Icons.Information;

  annotation (preferredView="info",
  Documentation(info="<html>
<p>
This package contains borefield models. These models are able to simulate any arbitrary configuration of boreholes with both short and
long-term accuracy with an aggregation method to speed up the calculations of the ground heat transfer. Examples
of how to use the borefield models and validation cases can be found in
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.Examples\">
IBPSA.Fluid.HeatExchangers.Ground.Examples</a>
and
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.Validation\">
IBPSA.Fluid.HeatExchangers.Ground.Validation</a>,
respectively.
</p>
<p>
The major features and configurations currently supported are:
<ul>
<li> User-defined borefield characteristics and geometry (borehole radius, pipe radius, shank spacing, etc.),
including single U-tube, double U-tube in parallel and double U-tube in series configurations.
</li>
<li> The resistances <i>R<sub>b</sub></i> and <i>R<sub>a</sub></i> are
either automatically calculated using the multipole method,
or they can be directly provided by the user.
</li>
<li>
User-defined vertical discretization of boreholes. However, the borehole wall temperature
is identical for each borehole and along the
depth, as the ground temperature response model only computes the average borehole wall temperature.
</li>
<li>
Borefields can have one or many boreholes. Each borehole can be positioned arbitrarily in the field.
</li>
<li>
The resolution and precision of the load aggregation method for the ground heat transfer can be adapted.
</li>
<li>
The thermal response of the ground heat transfer can be stored locally to avoid
having to recalculate it for future simulations with the same borefield configuration.
</li>
<li>
Pressure losses can be calculated if the <code>dp_nominal</code> parameter is set to a non-zero value.
</li>
</ul>

<h4>How to use the borefield models</h4>
<h5>Borefield data record</h5>
<p>
Most of the parameter values of the model are contained in the record called <code>borFieDat</code>.
This record is composed of three subrecords:
<code>filDat</code> (containing the thermal characteristics of the borehole filling material),
<code>soiDat</code> (containing the thermal characteristics of the surrounding soil),
and <code>conDat</code> (containing all others parameters, namely parameters
defining the configuration of the borefield).
The structure and default values of the record are in the package:
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.Data\">IBPSA.Fluid.HeatExchangers.Ground.Data</a>.
The <code>borFieDat</code> record
can be found in the <a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.Data.BorefieldData\">
IBPSA.Fluid.HeatExchangers.Ground.Data.BorefieldData</a> subpackage therein.
Examples of the subrecords <code>conDat</code>, <code>filDat</code> and <code>soiDat</code>
can be found in
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.Data.ConfigurationData\">
IBPSA.Fluid.HeatExchangers.Ground.Data.ConfigurationData</a>,
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.Data.FillingData\">
IBPSA.Fluid.HeatExchangers.Ground.Data.FillingData</a> and
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.Data.SoilData\">
IBPSA.Fluid.HeatExchangers.Ground.Data.SoilData</a>, respectively.
</p>
<p>
It is important to make sure that the <code>borCon</code> parameter within
the <code>conDat</code> subrecord is compatible with the chosen borefield model.
For example, if a double U-tube
borefield model is chosen, the <code>borCon</code> parameter could be set
to both a parallel double U-tube configuration and a double U-tube configuration in series,
but could not be set to a single U-tube configuration. An incompatible borehole
configuration will stop the simulation.
</p>
<h5>Ground heat transfer parameters</h5>
<p>
Other than the parameters contained in the <code>borFieDat</code> record,
the borefield models have other parameters which can be modified by the user.
The <code>tLoaAgg</code> parameter is the time resolution of the load aggregation
for the calculation of the ground heat transfer. It represents the
frequency at which the load aggregation procedure is performed in the simulation.
Therefore, lower values of <code>tLoaAgg</code>  will improve
the accuracy of the model, at the cost of increased simulation times
due to a higher number of events occuring in the simulation. While a default value
is provided for this parameter, it is advisable to ensure that it is lower
than a fraction (e.g. half) of the time required for the fluid to completely circulate
through the borefield,
as increasing the value of <code>tLoaAgg</code> beyond this will result
in the borehole wall temperature profile becoming decreasingly physical.
<!-- fixme: should this be 'will result in non-physical borehole wall temperatures'?
            Can we compute tLoaAgg = f(diameter, length, m_flow_nominal) as default.
            and warn for bad values? -->
</p>
<p>
The <code>nCel</code> parameter also affects the accuracy and simulation time
of the ground heat transfer calculations. As this parameter sets the number
of consecutive equal-size aggregation cells before increasing the size of cells,
increasing its value will result in less load aggregation, which will increase
accuracy at the cost of computation time. On the other hand,
decreasing the value of <code>nCel</code> (down to a minimum of 1)
will decrease accuracy but improve
computation time. The default value is chosen as a compromise between the two.
</p>
<p>
Further information on the <code>tLoaAgg</code> and <code>nCel</code> parameters can
be found in the documentation of
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.HeatTransfer.GroundTemperatureResponse\">
IBPSA.Fluid.HeatExchangers.Ground.HeatTransfer.GroundTemperatureResponse</a>.
</p>
<h5>Other parameters</h5>
<p>
Other parameters which can be modified include the dynamics, initial conditions,
and further information regarding the fluid flow, for example whether the flow is reversible.
It is worth noting that regardless of the <code>energyDynamics</code> chosen,
the <code>dynFil</code> parameter can be set to <code>false</code>
to remove the effect of the thermal capacitance
of the filling material in the borehole(s).
<!-- fixme: fine with me, but is there a use case for dynFil = false? Maybe we can simplify the model
            by setting dynFil to a constant so that the user has one less decision to make? -->
The <code>nSeg</code> parameter specifies the number of segments for the vertical discretization of the borehole(s).
Further information on this discretization can be found in the &#34;Model description&#34; section below.
</p>
<h5>Running simulations</h5>
<p>
When running simulations using the borefield models,
the <code>tmp/temperatureResponseMatrix</code> directory within the current directory
will be checked to see if any of the
borefield configurations used in the simulation have already
had their ground temperature response calculated previously
If the data doesn't exist in the <code>tmp/temperatureResponseMatrix</code> folder,
it will be calculated during the initialization of the model
and will be saved there for future use.
</p>
<h4>Model description</h4>
<p>
The borefield models rely on the following key assumptions:
<ul>
<li>The thermal properties of the soil (conductivity and diffusivity) are constant,
homogenous and isotropic.
</li>
<li>
The conductivity, capacitance and density of the grout and pipe material are constant, homogenous and isotropic.
</li>
<li>
There is no heat extraction or injection prior to the simulation start.
</li>
<li>
The undisturbed ground temperature <code>TSoi</code> is the same all along the length of the boreholes.
</li>
<li>
All of the boreholes in the borefield have uniform dimensions (including the pipe dimensions).
</li>
<li>
Inside the boreholes, the non-advective heat transfer is only in the radial direction.
</li>
</ul>
<p>
The borefield models are constructed in two main parts: the borehole(s) and the ground heat transfer.
The former is modeled as a vertical discretization of borehole segments, all of them sharing a common
uniform borehole wall temperature. The thermal effects of the circulating fluid (including the convection resistance),
of the pipes and of the filling material are all taken into consideration, which allows modeling
short-term thermal effects in the borehole. The borehole segments do not take into account axial effects,
thus only radial (horizontal) effects are considered within the borehole(s). The thermal
behavior between the pipes and borehole wall are modeled as a resistance-capacitance network, with
the grout capacitance being split in the number of pipes present in a borehole section.
The capacitance is only present if the <code>dynFil</code> parameter is set to <code>true</code>.
The figure below shows an example for a borehole section within a single U-tube configuration.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/Ground/BoreholeResistances_01.png\" />
</p>
<p>
The second main part of the borefield models is the ground heat transfer, which shares a thermal boundary
condition at the uniform borehole wall with all of the borehole segments. The heat transfer in the ground
is modeled analytically as a convolution integral between the heat flux at the borehole wall
and the borefield's thermal response factor <code>h</code>.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/HeatExchangers/Ground/LoadAggregation_12.png\" />
</p>
<p>
The model uses a load aggregation technique to reduce the time required to calculate
the borehole wall temperature changes resulting from heat injection or extraction.
</p>
<p>
The ground heat transfer takes into account both the borehole axial effects and
the borehole radial effects which are a result of its cylindrical geometry. The borefield's
thermal response to a constant load, also known as its <em>g-function</em>, is used
to calculate the thermal response in the simulation. This g-function
is stored in the <code>tmp/temperatureResponseMatrix</code> subdirectory,
as discussed previously in the
&#34;How to use the borefield models&#34; section. Further information on the
ground heat transfer model and the thermal temperature response calculations can
be found in
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.HeatTransfer.GroundTemperatureResponse\">
IBPSA.Fluid.HeatExchangers.Ground.HeatTransfer.GroundTemperatureResponse</a>
and
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Ground.HeatTransfer.ThermalResponseFactors.gFunction\">
IBPSA.Fluid.HeatExchangers.Ground.HeatTransfer.ThermalResponseFactors.gFunction</a>.
</p>
<h4>References</h4>
<p>
D. Picard, L. Helsen.
<i>Advanced Hybrid Model for Borefield Heat
Exchanger Performance Evaluation, an Implementation in Modelica</i>
Proc. of the 10th Intertional ModelicaConference, p. 857-866. Lund, Sweden. March 2014.
</p>
</html>"));

end UsersGuide;
