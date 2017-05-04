within IBPSA.Fluid.MassExchangers.Validation;
model Humidifier_X_dynamic
  "Model that demonstrates the ideal humidifier model, configured as dynamic model"
  extends Humidifier_X(
    hum(massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial));

annotation (
    __Dymola_Commands(file= "modelica://IBPSA/Resources/Scripts/Dymola/Fluid/MassExchangers/Validation/Humidifier_X_dynamic.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
Model that demonstrates the use of an adiabatic humidifier.
</p>
</html>", revisions="<html>
<ul>
<li>
May 3, 2017, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
    experiment(
      StopTime=1080,
      Tolerance=1e-6));
end Humidifier_X_dynamic;
