***************************************************************************************
*  	Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman								  
*  	program: analysis_0_master.do		
* 	Task: Uses master ETR dataset for several analyses on globalization and factor taxation
***************************************************************************************

*** DESCRIPTIVE ANALYSIS (SECTION 4 in Paper)

		* Setup for descriptive analysis 
		do do/descriptive_setup		
			
		* Figures on data coverage
		do do/descriptive_coverage  					//	Total coverage (cf. table_data_coverage)
		do do/descriptive_weights_pct 					//	shows the share of World GDP 
			
		* Figures for core paper 
		do do/descriptive_Figure1 						// Fig 1 in paper: evolution of tax revenue by source
			
		do do/descriptive_Figure2 						// Fig 2 in paper:  evoultion of capital share
			
		do do/descriptive_Figure3 						// Figs 3 and 4 in paper: evolution of ETR on K and on L 
			
		*for robustness, compare:
		do do/descriptive_Figure3_PITallocation			// Fig 3 equivalent but varying PIT allocation 
		do do/descriptive_Figure3_ilo					// Fig 3 equivalent but varying ilo mixed income		
	
		* Figures for appendix
		do do/descriptive_ETR_country							// Country specific ETR figures
		*do do/draft/descriptive_imputations					// Imputes missing years based on f.e. model 
		*do do/draft/descriptive_selection_correction.do		// Showing the impact of imputations 

***  ANALYSIS of GLOBALIZATION on FACTOR TAXATION (SECTIONS 5 & 6 in Paper)	
	
		do do/analysis_1_binscatter
		*Function: runs binned scatterplots
			*produces Figures 5 and 6	

		do do/analysis_2_ivreg
		*Function: runs IV regressions
			*produces Tables 1-5; and Appendix Figures A8, A9, A12 and Tables A3-A9
		
		do do/analysis_3_eventstudy
		*Function: runs event-study graphs
			*produces Figures 7 and 9; and Appendix Figures A10, A11, A15-A17 and Tables A1 and C1-C2
