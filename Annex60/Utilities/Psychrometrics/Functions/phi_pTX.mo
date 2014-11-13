within Annex60.Utilities.Psychrometrics.Functions;
function phi_pTX
  "Relative humidity for given pressure, dry bulb temperature and moisture mass fraction"
  extends Modelica.Icons.Function;
  input Modelica.SIunits.Pressure p "Absolute pressure of the medium";
  input Modelica.SIunits.Temperature T "Dry bulb temperature";
  input Modelica.SIunits.MassFraction X_w
    "Water vapor mass fraction per unit mass total air";
  output Real phi(unit="1") "Relative humidity";
protected
 Modelica.SIunits.AbsolutePressure p_steam_sat "Saturation pressure";
algorithm
  p_steam_sat :=Annex60.Utilities.Math.Functions.smoothMin(
    x1=  saturationPressure(T),
    x2=  0.999*p,
    deltaX=  0.0001*p);
  phi :=p/p_steam_sat*X_w/(X_w +
    Annex60.Utilities.Psychrometrics.Constants.k_mair*(1-X_w));
  annotation (
    smoothOrder=1,
    Documentation(info="<html>
<p>
Relative humidity of air for given
pressure, temperature and water vapor mass fraction.
</p>
<p>
Note that the water vapor mass fraction must be in <i>kg/kg</i>
total air, and not dry air.
</p>
</html>",
revisions="<html>
<ul>
<li>
November 13, 2014 by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end phi_pTX;
