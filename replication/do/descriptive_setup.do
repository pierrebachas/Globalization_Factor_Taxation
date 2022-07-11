****************************************************************************	
** 				Setup of data for Figures								  **
****************************************************************************
		
		use "data/master.dta", clear
			*use "data/master_$dateyear.dta", clear		// use "data/master_15 Jun 2022.dta", clear 
		
			drop if year==2019
			
		
		*put NNI compo in terms of NDP
			foreach var in ce_hh mi_hh os_hh os_corp va_corp ce_gov {
				replace `var' = `var' / (ndp - nit - os_gov) 
			}
				
		*set pct_1300 to zero where missing, so that average is not biased upward later
			replace pct_1300 = 0 if pct_1300==. &  ( ETR_L!=. | ETR_K!=. )
		
		*large population
			bysort country: egen tmp_max_pop = max(pop)
			gen large = 0
			replace large = 1 if tmp_max_pop >= 40000000 & tmp_max_pop != . 
			drop tmp_max_pop
	
		**outlier
			drop if country == "MMR" 
		
		*For figures y-axis, multiply all by 100:
			foreach var in pct_tax pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 {
				replace  `var' = `var' * 100
			}
			foreach var in ce_hh mi_hh os_hh os_corp va_corp ce_gov {
				replace `var' = `var' * 100
			}
			
			foreach f in L K	{ 
			foreach var in `f'sh_ndp `f'sh_corp `f'sh_ilo `f'sh_psz {
				replace `var' = `var' * 100
			}
			}
			foreach var in ETR_L_ndp ETR_K_ndp ETR_cit ETR_L_alpha ETR_K_alpha ETR_L_dual ETR_K_dual ETR_L_prime ETR_K_prime /*ETR_noncorpK*/ ETR_L_0 ETR_K_0  ETR_L_30 ETR_K_30  { 
				replace `var' = `var' * 100
			}
			
			
		* Here obtain the  share_Y_CIT =  Y_CIT/ndp	 , same with T_CIT/ndp
			*gen Tau_cit_prime = pct_1200 //expressed as % ndp
			gen citsh_ndp = ( os_corp ) // * (1 - nit - os_gov) )  //if os_corp is expressed as a share of fpNDP (see above); we want share of NDP (so that Tau_cit and citsh are both expressed in terms of same denominator
			
		save output/figs1-3_imputations, replace		// This file will be used for imputations 
		
	
	***********************************************
	* Selection to make into quasi-balanced panel 
	***********************************************	
		
		** Only keep countries with defined tax revenue:
		keep if ETR_K != .
		
		** Define communist countries: and force them to start in 1994
		drop if year< 1994 & excomm == 1 

		save output/figs1-3, replace
		
		
		
		
		
		
