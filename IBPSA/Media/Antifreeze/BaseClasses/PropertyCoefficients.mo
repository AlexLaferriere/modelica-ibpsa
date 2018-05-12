within IBPSA.Media.Antifreeze.BaseClasses;
record PropertyCoefficients
  "Polynomial coefficients to evaluate fluid properties"
  extends Modelica.Icons.Record;

  Modelica.SIunits.MassFraction X_a_ref "Reference mass fraction";
  Modelica.SIunits.Temperature T_ref "Reference temperature";
  Integer nX_a "Order of polynomial in x";
  Integer nT[nX_a] "Order of polynomial in y";
  Integer nTot "Total numnber of coefficients";
  Real a_d[nTot] "Polynomial coefficients for density";
  Real a_eta[nTot] "Polynomial coefficients for dynamic viscosity";
  Real a_Tf[nTot] "Polynomial coefficients for fusion temperature";
  Real a_cp[nTot] "Polynomial coefficients for specific heat capacity";
  Real a_lambda[nTot] "Polynomial coefficients for thermal conductivity";

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p>
Record that is used by
to implement the thermophysical properties
based on Melinder (2010).
</p>
<h4>References</h4>
<p>
Melinder, &#197;ke. 2010. Properties of Secondary Working Fluids (Secondary
Refrigerants or Coolants, Heat Transfer Fluids) for Indirect Systems. Paris:
IIR/IIF.
</p>
</html>", revisions="<html>
<ul>
<li>
May 11, 2018, by Michael Wetter:
Added documentation.
</li>
</ul>
</html>"));
end PropertyCoefficients;
