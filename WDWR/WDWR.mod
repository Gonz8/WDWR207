/*********************************************
 * OPL 12.5.1.0 Model
 * Author: Dominik
 * Creation Date: 10-05-2016 at 20:31:37
 *********************************************/

 //Parametry
{string} Components = ...;
{string} Resources = ...;
int NbMonths   = ...;
range Months = 1..NbMonths;
float Supply[Resources][Months] = ...;

int N = ...;
range NbScenarios = 1..N;
{int} Scenarios = asSet(NbScenarios);
float CostProd[NbScenarios][Components][Months] = ...;

//Zmienne decyzyjne
dvar int+ Production[Components][Months];
dvar float+ Use[Resources][Components][Months];
dvar int+ Storage[Months];
dvar boolean BinVar[Months];
dvar float cDiff[Scenarios][Scenarios];
dvar float+ cD1[Scenarios][Scenarios];
dvar float+ cD2[Scenarios][Scenarios];

//Kryteria
dexpr float Cost[t in Scenarios] = sum( m in Months ) 
		(	
			sum( c in Components ) ( CostProd[t][c][m] * Production[c][m] )
			+ (1 - BinVar[m]) * 2500
			//+ BinVar[m] * 0.15 * ( sum ( c in Components ) CostProd[t][c][m] * Production[c][m] )
	   	);
	   	
dexpr float AvgCost = (sum( t in Scenarios ) Cost[t]) / N;

dexpr float AvgCost2 = (sum( t in Scenarios ) abs(Cost[t])) / N;

//dexpr float cDiff[t1 in Scenarios, t2 in Scenarios] = Cost[t1] - Cost[t2];

dexpr float Risk = sum (t1 in Scenarios, t2 in Scenarios ) (
			0.5 * abs(cD1[t1][t2] + cD2[t1][t2]) * 1/N * 1/N
		);

//Funkcja celu	  	
minimize 
  Risk;
  
//Ograniczenia  
subject to {

  o1:
    sum( m in Months ) Production["A"][m] == 1100;
  o2:
    sum( m in Months ) Production["B"][m] == 1200;
	forall( t in Scenarios ) {
 		oCost:
 		  Cost[t] >= 0;
 	}	  
  
  forall( t1 in Scenarios ) {
  	forall( t2 in Scenarios ) {
  	  oabs:
  	    cDiff[t1][t2] == Cost[t1] - Cost[t2];
  	  oabs1:
  	    cDiff[t1][t2] == cD1[t1][t2] - cD2[t1][t2];
    }  	   
  }    
      
  forall( m in Months ) {
    o3a:
      0.2 * Production["A"][m] == Use["Z1"]["A"][m];
    o3b:
      0.8 * Production["A"][m] == Use["Z2"]["A"][m];
    o4a:
      0.7 * Production["B"][m] == Use["Z1"]["B"][m];
    o4b:
      0.3 * Production["B"][m] == Use["Z2"]["B"][m];
    o5:
      sum ( n in 1..m ) ( 
      	sum ( c in Components ) Production[c][n] 
      ) == Storage[m];
    o6:
      Storage[m] <= 300 + 2000 * BinVar[m];
    o6a:
      Storage[m] >= 300 * BinVar[m];

  }
  
  forall( r in Resources )
    forall( m in Months ) {
      o7:
        Use[r]["A"][m] + Use[r]["B"][m] <= Supply[r][m];
  	}

};    