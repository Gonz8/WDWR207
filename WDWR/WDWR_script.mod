/*********************************************
 * OPL 12.5.1.0 Model
 * Author: Dominik
 * Creation Date: 20-05-2016 at 22:26:50
 *********************************************/
main {
  
	var ResultsFile = new IloOplOutputFile();
	ResultsFile.open("results.csv");

    //var FSDFile = new IloOplOutputFile();
    //FSDFile.open("FSDdata.csv");

  	//// modele jednokryterialne - minimalnego ryzyka i minimalnego kosztu (nadir i utopia) ////
	var ConfigMinAvgCost_Risk = new IloOplRunConfiguration(
			"WDWR_minCostOrRisk.mod",
			"bscData.dat",
			"Scenariusze.dat",
			"CostRiskFlag.dat");
			
	var ModelCostRisk  =  ConfigMinAvgCost_Risk.oplModel;
    var DefCostRisk  = ModelCostRisk.modelDefinition;
    var DataCostRisk = ModelCostRisk.dataElements;
 	
 	DataCostRisk.IsMinCost = 1; //najpierw minimalny koszt
 	
 	ModelCostRisk = new IloOplModel (DefCostRisk, cplex);
   	ModelCostRisk.addDataSource(DataCostRisk);
   	ModelCostRisk.generate();
   		  
	cplex.solve();
 	
  	var UtopiaAvgCost = ModelCostRisk.AvgCost.solutionValue;
  	var NadirRisk = ModelCostRisk.Risk.solutionValue;
  	
  	
  	//
  	DataCostRisk.IsMinCost = 0; //minimalne ryzyko
 	
 	ModelCostRisk = new IloOplModel (DefCostRisk, cplex);
   	ModelCostRisk.addDataSource(DataCostRisk);
   	ModelCostRisk.generate();
   		  
	cplex.solve();
  	
  	var UtopiaRisk = ModelCostRisk.Risk.solutionValue;
  	var NadirAvgCost = ModelCostRisk.AvgCost.solutionValue;
  	
  	
 	
  	var lambdaAvgCost = 1/(NadirAvgCost - UtopiaAvgCost);
  	var lambdaRisk = 1/(NadirRisk - UtopiaRisk);
  	//dbg
  	writeln("Koszt: Utopia - ", UtopiaAvgCost, " Nadir - ", NadirAvgCost);
  	writeln("Ryzyko: Utopia - ", UtopiaRisk, " Nadir - ", NadirRisk);
  	writeln("Lambda: AvgCost - ", lambdaAvgCost, " Risk - ", lambdaRisk);
  	
  	ResultsFile.writeln("lambdaAvgCost;", lambdaAvgCost);
  	ResultsFile.writeln("lambdaRisk;", lambdaRisk);
  	ResultsFile.writeln("UtopiaAvgCost;", UtopiaAvgCost);
  	ResultsFile.writeln("NadirAvgCost;", NadirAvgCost);
  	ResultsFile.writeln("UtopiaRisk;", UtopiaRisk);
  	ResultsFile.writeln("NadirRisk;", NadirRisk);
  	
  	//// Obraz zbioru rozwiazan ////
  
  	var NbSteps = 4;
  	var minAspCost = UtopiaAvgCost;
  	var maxAspCost = NadirAvgCost;

  	var minAspRisk = UtopiaRisk;
  	var maxAspRisk = NadirRisk;
  	
  	var CostStep = (maxAspCost - minAspCost) / NbSteps;
  	var RiskStep = (maxAspRisk - minAspRisk) / NbSteps;
  	
	var ConfigMPO = new IloOplRunConfiguration(
			"WDWR_mpo.mod",
			"bscData.dat",
			"Scenariusze.dat",
			"DataMPO.dat");
			
 	var ModelMPO  =  ConfigMPO.oplModel;
    var DefMPO  = ModelMPO.modelDefinition;
    var DataMPO = ModelMPO.dataElements;
 	
 	DataMPO.lambdaAvgCost = lambdaAvgCost;
 	DataMPO.lambdaRisk = lambdaRisk;
 	
 	ResultsFile.writeln(";;Koszt; Ryzyko; AspiracjaKoszt; AspiracjaRyzyko; KomponentA miesiac 1; KomponentA miesiac 2; KomponentA miesiac 3; KomponentB miesiac 1; KomponentB miesiac 2; KomponentB miesiac 3"); 
 	
 	var lp = 1;
  	for (var i = 0; i <= NbSteps; i++) {
	    for (var j = 0; j <= NbSteps; j++) {
	  	  	var AspCost = minAspCost + i * CostStep;
			var AspRisk = minAspRisk + j * RiskStep;
			
	  	  	DataMPO.AspAvgCost = AspCost;
	  	  	DataMPO.AspRisk = AspRisk;
 	  	
	   	 	ModelMPO = new IloOplModel (DefMPO, cplex);
   		  	ModelMPO.addDataSource(DataMPO);
   		 	ModelMPO.generate();
   		  
			cplex.solve();
			//dbg
			writeln("Punkt",lp,": AvgCost - ", ModelMPO.AvgCost, ", Risk - ", ModelMPO.Risk);
			lp = lp + 1;
		
		 	ResultsFile.writeln(
		 		";;",
		 		ModelMPO.AvgCost, ";",
		 	 	ModelMPO.Risk, ";",
		 	 	DataMPO.AspAvgCost, ";",
			 	DataMPO.AspRisk, ";",
		 	 	ModelMPO.Production["A"][1], ";", 
		 	 	ModelMPO.Production["A"][2], ";",
		 	 	ModelMPO.Production["A"][3], ";", 
		 	 	ModelMPO.Production["B"][1], ";", 
		 	 	ModelMPO.Production["B"][2], ";", 
		 	 	ModelMPO.Production["B"][3]
		 	 ); 
//		 	 	
//		 	 	
//			for(var t = 1; t < ModelMPO.N; t++){
//		   		FSDFile.write(ModelMPO.Cost[t].solutionValue, ",");
//		   	}			  		 	 	
//		   	
//		   	FSDFile.writeln(ModelMPO.Cost[ModelMPO.N].solutionValue);

		}		
	}
	
	ResultsFile.close();  	  
//	FSDFile.close();
  
}  