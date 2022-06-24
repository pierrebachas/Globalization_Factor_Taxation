
***************************************************************************************
*  Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman - December 2020								  
*  	program: ETR_2_merge_factor_shares.do			
* 	Task: Merges tax revenue data and factor shares	data									  
***************************************************************************************

	clear all
	set more off
		
	*append all harmonized countries to a panel
		cd "${root}/data/harmonized"
			local files: dir . files "*.dta"
			foreach file in `files' {
				append using "`file'"
			}
		cd "${root}"
		
		*most recent year can actually be missing
			drop if pct_tax==.
		
		*true zeros were occasionally left coded as missing in previous (esp. in OECD)
			foreach var of varlist pct* {
				replace `var' = 0 if `var'==.
			}

		*  Merge with factor share

		merge 1:1 country year using data/factor_shares 		
		drop if _merge==1 //drop if revenue without factor shares (i.e., without GDP)
							//note: rare, approx 20 country-years have tax revenue without factor share data
			*drop if country with factor share data never has tax data
				egen hastax = max(pct_tax), by(country)
				replace hastax = 1 if hastax!=. & hastax!=.
				drop if hastax != 1
				drop _merge hastax
				cap drop cid //re-generate below
				
	*panel xtset
		sort country year
		encode country, gen(cid)
		tsset cid year	
				
	*save
		save data/misc/revenue_FS_combined , replace		
