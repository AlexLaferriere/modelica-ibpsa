within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation;
function nextTimeStep
  "Performs the shifting operation for load aggregation"
  extends Modelica.Icons.Function;

  input Integer i "Number of aggregation cells";
  input Integer i_cst;
  input Modelica.SIunits.HeatFlowRate Q_i[i_cst] "Q_bar vector of size i";
  input Real rCel[i_cst] "Aggregation cell widths";
  input Modelica.SIunits.Time nu[i_cst] "Cell aggregation times";
  input Modelica.SIunits.Time curTim "Current simulation time";

  output Integer curCel "Current occupied aggregation cell";
  output Modelica.SIunits.HeatFlowRate Q_i_shift[i_cst] "Shifted Q_bar vector";

algorithm
  curCel := 1;
  Q_i_shift := zeros(i_cst);
  for j in (i-1):-1:1 loop
    if curTim>=nu[j+1] then
      Q_i_shift[j+1] :=((rCel[j+1] - 1)*Q_i[j+1] + Q_i[j])/rCel[j+1];
    elseif curTim>=nu[j] then
      Q_i_shift[j+1] :=(rCel[j+1]*Q_i[j+1] + Q_i[j])/rCel[j+1];
      curCel := j+1;
    end if;
  end for;

  Q_i_shift[1] := 0;



  annotation (Documentation(info="<html>
<p>Performs the shifting operation which propagates the thermal load history
towards the more distant aggregation cells, and then sets the current cell's
value at 0.
</p>
</html>", revisions="<html>
<ul>
<li>
April 5, 2018, by Alex Laferriere:<br/>
First implementation.
</li>
</ul>
</html>"));
end nextTimeStep;
