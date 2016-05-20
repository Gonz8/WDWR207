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
float RequestRC[Resources][Components] = ...;
int M = ...;

int N = ...;
range NbScenarios = 1..N;
{int} Scenarios = asSet(NbScenarios);
float CostProd[NbScenarios][Components][Months] = ...;

//Zmienne decyzyjne
dvar int+ Production[Components][Months];
dvar float+ Use[Resources][Components][Months];
dvar int+ Storage[Months];
dvar boolean BinVar[Months];
dvar float+ StoreCostP[NbScenarios][Months];


//Kryteria
dexpr float Cost[t in Scenarios] = sum( m in Months ) 
		(	
			sum( c in Components ) ( CostProd[t][c][m] * Production[c][m] )
			+ (1 - BinVar[m]) * 2500
			+ StoreCostP[t][m]
	   	);
	   	
dexpr float AvgCost = (sum( t in Scenarios ) Cost[t]) / N;

dexpr float Risk = sum (t1 in Scenarios, t2 in Scenarios ) (
			0.5 * abs(Cost[t1] - Cost[t2]) * 1/N * 1/N
		);

//Funkcja celu	  	
minimize 
  Risk;
  
//Ograniczenia  
subject to {

  oUmowaA:
    sum( m in Months ) Production["A"][m] == 1100;
  oUmowaB:
    sum( m in Months ) Production["B"][m] == 1200; 
      
  forall( m in Months ) {
    forall( r in Resources ) {
      forall( c in Components ) {
        oRequest:
          RequestRC[r][c] * Production[c][m] == Use[r][c][m]; 
      }             
    }        
//    o3a:
//      0.2 * Production["A"][m] == Use["Z1"]["A"][m];
//    o3b:
//      0.8 * Production["A"][m] == Use["Z2"]["A"][m];
//    o4a:
//      0.7 * Production["B"][m] == Use["Z1"]["B"][m];
//    o4b:
//      0.3 * Production["B"][m] == Use["Z2"]["B"][m];
    oStorageState:
      sum ( n in 1..m ) ( 
      	sum ( c in Components ) Production[c][n] 
      ) == Storage[m];
    oStorageSt1:
      Storage[m] <= 300 + M * BinVar[m];
    oStorageSt2:
      Storage[m] >= 300 * BinVar[m];
      
    forall (t in Scenarios) {
      oLin1:
        StoreCostP[t][m] <= M * BinVar[m];
      oLin2:
        StoreCostP[t][m] <= 0.15 * ( sum ( c in Components ) CostProd[t][c][m] * Production[c][m] );
      oLin3:
        0.15 * ( sum ( c in Components ) CostProd[t][c][m] * Production[c][m] ) - StoreCostP[t][m] + M * BinVar[m] <= M;
    }      
  }
  
  forall( r in Resources )
    forall( m in Months ) {
      oSupplyLimit:
        Use[r]["A"][m] + Use[r]["B"][m] <= Supply[r][m];
  	}

};    



execute DISPLAY {
         writeln("Risk = ",Risk,", AvgCost = ",AvgCost);
}