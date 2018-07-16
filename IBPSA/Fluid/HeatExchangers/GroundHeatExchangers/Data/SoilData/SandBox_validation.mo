within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.SoilData;
record SandBox_validation
  "Soil data record for the Beier et al. (2011) experiment"
  extends
    IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.SoilData.Template(
      kSoi=2.8,
      cSoi=1600,
      dSoi=2000);
  annotation (
  defaultComponentPrefixes="parameter",
  defaultComponentName="soiDat",
Documentation(
info="<html>
<p>
This record contains the soil data of the Beier et al. (2011) experiment.
</p>
<h4>References</h4>
<p>
Beier, R.A., Smith, M.D. and Spitler, J.D. 2011. <i>Reference data sets for
vertical borehole ground heat exchanger models and thermal response test
analysis</i>. Geothermics 40: 79-85.
</p>
</html>",
revisions="<html>
<ul>
<li>
July 15, 2018, by Michael Wetter:<br/>
Revised implementation, added <code>defaultComponentPrefixes</code> and
<code>defaultComponentName</code>.
</li>
<li>
June 28, 2018, by Damien Picard:<br/>
First implementation.
</li>
</ul>
</html>"));
end SandBox_validation;