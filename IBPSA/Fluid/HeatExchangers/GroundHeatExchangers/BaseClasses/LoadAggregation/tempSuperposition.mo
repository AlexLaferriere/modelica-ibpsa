within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation;
function tempSuperposition "Performs temporal superposition"
  extends Modelica.Icons.Function;

  input Integer i "Number of aggregation cells";
  input Integer i_cst;
  input Modelica.SIunits.HeatFlowRate Q_i[i_cst]
    "Shifted Q_bar vector of size i";
  input Modelica.SIunits.Temperature kappa[i_cst]
    "Weight factor for each aggregation cell";
  input Integer curCel "Current occupied aggregation cell";

  output Modelica.SIunits.TemperatureDifference deltaTb "Delta T at wall";

algorithm
  deltaTb := (Q_i[1:curCel]*kappa[1:curCel]);

  annotation (Documentation(info="<html>
<p>
Performs the temporal superposition operation to obtain the temperature change
at the borehole wall at the current timestep, which is the scalar product of the
aggregated load vector <code>Q_i</code> and the <code>kappa</code> weighting factor vector. To
avoid unnecessary calculations, the current aggregation cell in the simulation
is used to trunkate the values from the vectors which are not required in the
scalar product.
</p>
</html>", revisions="<html>
<ul>
<li>
April 5, 2018, by Alex Laferriere:<br/>
First implementation.
</li>
</ul>
</html>"));
end tempSuperposition;
