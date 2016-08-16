within Annex60.Experimental.Pipe.BaseClasses.SinglePipeConfig;
partial record IsoPlusSingle
  "Basic data structure for single pipes by manufacturer IsoPlus"
  extends SinglePipeData(lambdaI=0.024);

  final parameter Real hInvers=lambdaI/lambdaG*Modelica.Math.log(2*Heff/ro) +
      Modelica.Math.log(ro/ri);
end IsoPlusSingle;
