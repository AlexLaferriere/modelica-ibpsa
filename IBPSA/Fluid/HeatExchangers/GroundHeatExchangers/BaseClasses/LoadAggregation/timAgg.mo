within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.LoadAggregation;
function timAgg
  "Function which builds the time and cell width vectors for aggregation"
  extends Modelica.Icons.Function;

  input Integer i "Size of time vector";
  input Integer i_cst;
  input Real lvlBas "Base for growth between each level, e.g. 2";
  input Integer p_max "Number of cells of same size per level";
  input Modelica.SIunits.Time lenAggSte "Aggregation step";
  input Modelica.SIunits.Time timFin "Total simulation max length";

  output Modelica.SIunits.Time nu[i_cst] "Time vector nu of size i";
  output Real rCel[i_cst] "Cell width vector of size i";

protected
  Real width_j;

algorithm
  width_j := 0;
  nu := zeros(i_cst);
  rCel := ones(i_cst);

  for j in 1:i loop
    width_j := width_j + lenAggSte*lvlBas^floor((j-1)/p_max);
    nu[j] := width_j;

    rCel[j] := lvlBas^floor((j-1)/p_max);
  end for;

  if nu[i]>timFin then
    nu[i] := timFin;
    rCel[i] := (nu[i]-nu[i-1])/lenAggSte;
  end if;

  if i_cst>i then
    for jj in (i+1):i_cst loop
      nu[jj] := 10000*8760*3600;
    end for;
  end if;

  annotation (Documentation(info="<html>
<p>Simultaneously constructs both the <code>nu</code> vector, which is the
aggregation time of each cell, and the <code>rcel</code> vector, which
is the temporal size of each cell normalized with the aggregation step
length (the <code>lenAggSte</code> parameter).
</p>
<p>If, for example, the value of <code>lenAggSte</code> is 3600 seconds (1 hour),
then any value <code>rcel[x]</code> will be measured in hours.
</p>
</html>", revisions="<html>
<ul>
<li>
April 5, 2018, by Alex Laferriere:<br/>
First implementation.
</li>
</ul>
</html>"));
end timAgg;
