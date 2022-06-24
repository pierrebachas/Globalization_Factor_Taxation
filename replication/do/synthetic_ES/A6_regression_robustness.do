		

*** 5. Robustness Check Regression 

	local var="$var"
	
		cd "$usedata/synthetic_ES_tempfiles"
		use sample`var', clear 

		* Averages over groups
		bysort rel_year treat: egen avg_`var'=mean(`var')
		gen x=avg_`var' if treat==1
		gen z=avg_`var' if treat==0
		bysort rel_year: egen avg_`var'_t=mean(x)
		bysort rel_year: egen avg_`var'_nt=mean(z)
		drop x z avg_`var'

		* Time dummies
		gen post_treat=0
		replace post_treat=1 if treat==1 & rel_year>=0

		forvalues i=1/10 {
			gen pre`i'=0 
			replace pre`i'=1 if rel_year==-`i' & treat==1
		}
		gen zero=0
		replace zero=1 if rel_year==0 & treat==1
		forvalues i=1/10 {
			gen post`i'=0 
			replace post`i'=1 if rel_year==`i' & treat==1
		}

		eststo pt_`var': reghdfe `var' post_treat /// 
			i.year ,abs(i.id i.rel_year) vce(cluster id)
			
		gen est_`var'=round(_b[post_treat],0.0001)
		gen est_pval_`var'=round(_se[post_treat],0.0001)
			
		eststo es_`var': reghdfe `var' pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 ///
			zero post1 post2 post3 post4 post5 post6 post7 post8 post9 post10 pre1 /// 
			i.year ,abs(i.id i.rel_year) vce(cluster id)

		gen est_es_`var'=.
		forvalues i=1/10 {
			replace est_es_`var'=_b[pre`i'] if rel_year==-`i'
			replace est_es_`var'=_b[post`i'] if rel_year==`i'
		}
		replace est_es_`var'=_b[zero] if rel_year==0

		* This is the significant difference to section B: We loop over all 7 events and exclude them from the regression one by one. 
		
		foreach y of numlist 1/7 {
		gen x=0
		replace x=1 if id==`y' | id==`y'+7

			eststo pt_`var'_`y': reghdfe `var' post_treat i.year if x==0  /// 
				 ,abs(i.id i.rel_year) vce(cluster id)
				
			gen est_`var'_`y'=round(_b[post_treat],0.0001)
			gen est_pval_`var'_`y'=round(_se[post_treat],0.0001)
							
			eststo es_`var'_`y': reghdfe `var' pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 ///
				zero post1 post2 post3 post4 post5 post6 post7 post8 post9 post10 i.year pre1 if x==0  /// 
				,abs(i.id i.rel_year) vce(cluster id)

			gen est_es_`var'_`y'=.
			forvalues i=1/10 {
				replace est_es_`var'_`y'=_b[pre`i'] if rel_year==-`i'
				replace est_es_`var'_`y'=_b[post`i'] if rel_year==`i'
			}
			replace est_es_`var'_`y'=_b[zero] if rel_year==0
		drop x
		}
		****
		bysort rel_year: keep if _n==1
		keep est_`var'* est_es_`var'* rel_year est_pval_`var'* 

		cd "$usedata"
		save "synthetic_ES_intermediat_data/exclude_one/`var'.dta", replace

