***************************************************************************************
*  	Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman								  
*  	program: analysis_3_eventstudy.do		
* 	Task: Examines outcomes after liberalization events
***************************************************************************************


***************************************************************************************
/* 
	This master file runs the full analysis and produce all outputs for the synthetic
	control event studies. Below we structured the analysis in two broad sections. 
	
	Section A takes focuses on trade liberalization events, section B coveres the 
	capital liberalization events. 
	
	In each section, we loop over a set of variables to construct one dataset for 
	each outcome that carries all the results. These datasets are then used to construct
	all outputs.
	
	At the end of each section (A8 and B7) we perform the analysis where we use a 
	several outcomes to match on simoultaniously (see paper for details). Due to the
	complexity of the code those steps done seperatly to improve the robustness and
	clarity.

*/
***************************************************************************************

* Setting paths

	global usedata "${root}/data/archive"
	global outputs "${root}/output/synthetic_ES"
	global permutation "${root}/permutation"
	global dofile "${root}/do/synthetic_ES"

		/* Commands to install:
		{
		 ssc install synth
		 ssc install boottest
		 ssc install did_imputation
		 ssc install reghdfe
		 ssc install asgen
		}
		****/
	
		
* Data and variables to use in analysis		
	global data 				= "master_CHN_$dateyear.dta" // "master_CHN_`dateyear'.dta"
	global trade_variables 		= "ETR_L_prime ETR_K_prime Ksh_ndp Ksh_corp trade va_corp cit_rate_winz selfemployed os_corp os_hh ce_hh mi_hh industry_va services_va agric_va"
	global capital_variables 	= "lg_open lg_eq ETR_K_prime ETR_L_prime Ksh_ndp Ksh_corp va_corp cit_rate_winz selfemployed os_corp os_hh ce_hh mi_hh industry_va services_va agric_va"

	cd "$usedata"
	use "${usedata}/${data}", clear
		
************************************************
*** A: Trade Liberalization Event Studies		
************************************************
		
* We loop over all variables: 
	
	foreach var in $trade_variables {
				
		global var="`var'"	

					
		cd "$usedata"
		use "${usedata}/${data}", clear
				
		*** A1/A2: Data prep 
		
		cd "$dofile"
			do A1_event_setup.do
		cd "$dofile"
			do A2_sample.do

		*** A3: Synthetic Matching
		
		cd "$dofile"
			do A3_synthetic_matching.do

		*** A4: Build Regression Sample
		
		cd "$dofile"
			do A4_regression_sample.do
			
		*** A5/A6: Regression
		
		cd "$dofile"
			do A5_regression.do
		cd "$dofile"	
			if "`var'"=="ETR_L_prime" | "`var'"=="ETR_K_prime" | "`var'"=="Ksh_ndp" | "`var'"=="Ksh_corp" | "`var'"=="trade" {  	
			do A6_regression_robustness.do
			}	
	
	}
	
	*** A7: Outputs
	
		cd "$dofile"
			do A7_1_main_analysis_outputs.do
		cd "$dofile"
			do A7_2_mechanism_outputs.do
		cd "$dofile"
			do A7_3_robustness_check_outputs.do
	
	
	*** A8: Joint weights analysis
	
	cd "$usedata"
	use "${usedata}/${data}", clear
		
		foreach var of varlist Ksh_ndp Ksh_corp ETR_K_prime ETR_L_prime trade {

			global var="`var'"
			
			cd "$usedata"
			use "${usedata}/${data}", clear
			
			cd "$dofile"
				do A8_1_setup_joint_weights.do
			cd "$dofile"
				do A8_2_synthetic_matching_joint_weights.do
			cd "$dofile"	
				do A8_3_regression_joint_weights
		}
		****
	
			cd "$dofile"	
			do A8_4_joint_weights_outputs

************************************************************
*** B: Capital Liberalization Event Studies		
************************************************************


cd "$usedata"
use "${usedata}/${data}", clear

* We loop over all variables: 

	foreach var in $capital_variables {
	
		global var="`var'"	
		
		cd "$usedata"
		use "${usedata}/${data}", clear
				
		*** B1/B2: Data prep 
		cd "$dofile"
			do B1_event_setup.do
		cd "$dofile"
			do B2_sample.do

		*** B3: Synthetic Matching
		cd "$dofile"
			do B3_synthetic_matching.do

		*** B4: Build Regression Sample
		cd "$dofile"
			do B4_regression_sample.do
			
		*** B5: Regression
		cd "$dofile"
			do B5_regression.do
			
	}

	*** B6: Outputs
	cd "$dofile"
		do B6_1_main_analysis_outputs.do
	cd "$dofile"
		do B6_2_mechanism_outputs.do

	cd "$usedata"
	use "${usedata}/${data}", clear
	
	cd "$dofile"
		do B6_3_weight_table.do

	*** B7: Joint weights analysis
		
	cd "$usedata"
	use "${usedata}/${data}", clear
	
		foreach var of varlist lg_open lg_eq ETR_K_prime ETR_L_prime Ksh_ndp Ksh_corp {

			global var="`var'"	
			
			cd "$usedata"
			use "${usedata}/${data}", clear
			
			cd "$dofile"
				do B7_1_setup_joint_weights.do
			cd "$dofile"
				do B7_2_synthetic_matching_joint_weights.do
			cd "$dofile"	
				do B7_3_regression_joint_weights
		}
		****

			cd "$dofile"	
			do B7_4_joint_weights_outputs


		





