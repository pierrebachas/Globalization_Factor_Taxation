

***************************************************************************************
*   Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman - December 2020								  
*  	program: ETR_0_master.do			
* 	Task: Run all do-files to generate revenue series										  
***************************************************************************************														
	
	clear all
	set more off
	set max_memory .	
	
		*directories and globals																				
			if "`c(username)'" == "mhf221" { 
				global root "/Users/mhf221/Dropbox/Progressivity and Development/replication"		//	Matt HKS computer
			}
			else if "`c(username)'" == "Matthew Fisher-Post" {
				global root "D:/Dropbox/Progressivity and Development/replication"					//	Matt computer
			}
			else if "`c(username)'"=="pierrebachas" { 												// Pierre's Mac
				global root "/Users/pierrebachas/Dropbox/Progressivity_Development/replication"									
			}
			else if "`c(username)'"=="...[Anders computer name]..." { 								// Anders
				global root "/Users/...[Anders P&D Dropbox name].../replication"									
			}
			else if "`c(username)'"=="...[Gabriel computer name]..." { 								// Gabriel
				global root "/Users/...[Gabriel P&D Dropbox name].../replication"									
			}

		cd "$root"
			
		*readme on raw data
		*import raw data
			//NB this is raw data after pre-cleaning (pre-cleaning included currency conversion and WID data transformation)
			// note the dates and places of download in the readme file above
	
		do do/ETR_1_revenue_source	
		* Function: Select the sources of revenue data to be used and harmonize across sources. 
		* Note this is done on a country by country basis and saves one data file with the complete revenue series of a country.
		* Input: "data/revenue_raw.dta"   			   --> dataset of country-year tax revenue data combining all availabe sources
		* Output: "data/harmonized/`country_name'.dta" --> selected and harmonized country time series of tax revenue 

		do do/ETR_2_merge_factor_shares			
		* Function: Append revenue data & merge with factor shares at the country-year level		
		* Input: "data/harmonized/`country_name'.dta" --> selected and harmonized country time series of tax revenue 
		* Input: "data/factor_shares.dta" --> country-year data on factor shares 		
		* Output: "data/misc/revenue_FS_combined.dta" --> combined dataset of tax revenue and factor shares 
			
		do do/ETR_3_covariates
		* Function: merge other data sources at the country-year level used for the analysis (e.g. population, statutory tax rates, etc.)	
		* Input: "data/misc/revenue_FS_combined.dta" --> combined dataset of tax revenue and factor shares 
		* Input: "data/misc/rhs/"dataset_name" --> Series of datasest at the country-year
		* Output: "data/misc/merged" 	--> Dataset with merged covariates
			
		do do/ETR_4_construction
		* Function: computes the Effective Tax Rates	
		* Input: "data/misc/merged" 	--> Dataset with merged covariates
		* Output: "data/ETR.dta"		--> Full dataset toward analysis
		* Output: "data/globalETR_bfjz.dta"	--> Minimal dataset for public use
			
		do do/ETR_5_preanalysis
		* Function: Prepare panel data for descriptives and analysis, prepares dimensions for heterogeneity (income groups), IV for trade, other-covariates and controls
		* Input: "data/ETR.dta"
		* Output: "data/master.dta" 			--> Main dataset for analysis 
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
			

