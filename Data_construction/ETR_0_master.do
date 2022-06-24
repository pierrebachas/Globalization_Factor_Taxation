

***************************************************************************************
*   Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman							  
*  	Program: ETR_0_master.do			
*	Date: November 2021
* 	Task: Run all do-files to Effectiev Tax Rate Series									  
***************************************************************************************

														
* Install required packages
local install_packages 	0
if `install_packages' {
	ssc install	mipolate
	} 	
	
	clear all
	set more off
	set max_memory .	
	
		do do/ETR_1_revenue_source	
		* Function: Select the sources of revenue data to be used and harmonize across sources. 
		* Note this is done on a country by country basis and saves one data file with the complete revenue series of a country.
		* Input: "data/revenue_raw.dta"   			   --> dataset of country-year tax revenue data combining all availabe sources
		* Output: "data/harmonized/`country_name'.dta" --> selected and harmonized country time series of tax revenue 

		do do/ETR_2_merge_factor_shares			
		* Function: Append revenue data & merge with factor shares at the country-year level		
		* Input: "data/harmonized/`country_name'.dta" --> selected and harmonized country time series of tax revenue 
		* Input: "data/factor_shares.dta" --> country-year data on factor shares 
		* Output: "data/misc/revenue_FS_combined_tmp.dta" --> combined dataset of tax revenue and factor shares 
			
		do do/ETR_3_covariates
		* Function: merge other data sources at the country-year level used for the analysis (e.g. population, statutory tax rates, etc.)	
		* Input: "data/misc/revenue_FS_combined_tmp.dta" --> combined dataset of tax revenue and factor shares 
		* Input: "data/misc/rhs/"dataset_name" --> Series of datasest at the country-year
		* Output: "data/misc/merged" 	--> Dataset with merged covariates
			
		do do/ETR_4_construction
		* Function: computes the Effective Tax Rates	
		* Input: "data/misc/merged" 	--> Dataset with merged covariates
		* Output: "data/ETR_`dateyear'.dta"	--> Full dataset used for analysis
		* Output: "data/globalETR_bfjz.dta	--> Minimal dataset for public use
			

