	*ILO imputation
		
pause on
	
		u data/misc/temp/merge2, clear
		keep cid country year Lsh_ndp* /*Ksh_ndp**/ /*Lsh_gdp_ilo_unadj - */ ilo_imputed - Ksh_ndp_ilo /*Ksh_ndp_ilo*/ /*imputed*/ ce_hh mi_hh gdp ndp nit nni_ppp nnipc_ppp
		
		gen log_nnipc = log(nnipc_ppp) //will need this in imputations below
				format %9.2fc log_nnipc
			order nnipc_ppp log_nnipc gdp-nit, after(nni_ppp)
			order Lsh_ndp_ilo, after(Lsh_ndp)
			br if employees!=. //4379 of 6927 obs have info on employees vs. self-employed
		
		replace selfemployed_family = .00001 if selfemployed_family==0 //7 country-years
		
			
			
****************************************
	///run imputation///
****************************************	
		// Estimate random effect model with AR(1) error term for varlist
				*at each step of a nested three-level model
					*(see varlist above)
					*Level 1: workforce shares of employees vs. selfemployed 						//adds to 100% of workforce
					*Level 2: workforce shares of selfemployed_* employers ownaccount family 		//adds to 100% of selfemployed from step 1
					*Level 3: coefficients (ratio to employee salary) of selfemployed				//include imputed employee/selfemployed shares? (and imputed ce_hh?)
					*imputation proceeds as follows:	
						*xtregar y X, re twostep
								*y is varlist to impute (above, employment proportions within workforce & salary ratios relative to employee salary)
								*X is log(NNIpc_ppp)
								
								
		global x1 "employees selfemployed"
		global x2 "selfemployed_employers selfemployed_ownaccount selfemployed_family"
		global x3 "coef_employers coef_ownaccount coef_family"
		
								
		//level 1: employees vs. self-employed 
					gen check = employees + selfemployed //only run for non-missing
				foreach var in $x1 {
					replace `var' = `var' / check //s.t. = 100%
				}
					drop check	
			do do/auxiliary/ilo_imputation_x1.do
			
				*data quality control
					*no imputed values below or above observed values: assign min or max value
						foreach var in $x1 {
							sum `var' if `var'_imputed==1, det
		*pause					
							sum `var' if `var'_imputed==0, det
							scalar `var'_min = `r(min)'
							scalar `var'_max = `r(max)'
							
							replace `var' = `var'_min if `var'_imputed==1 & `var' < `var'_min & `var'!=.
							replace `var' = `var'_max if `var'_imputed==1 & `var' > `var'_max & `var'!=.
							sum `var' if `var'_imputed==1, det
		*pause
						}
						
				*re-scale imputed obs to add to 100%
					*scale factor s.t. employees + selfemployed  = 100%
							gen check = employees + selfemployed //never missing
						foreach var in $x1 {
							replace `var' = `var' / check if `var'_imputed==1 //
						}
							drop check
							
				*won't need these later		
					drop *pred *ub *lb *flag
					
					
					foreach var in $x1 {
						gen log_`var' = log(`var') //for use in the regression here below
					}
		//level 2: shares of workforce, by types of selfemployed
					gen temp = selfemployed_employers + selfemployed_ownaccount + selfemployed_family //only run for non-missing
					gen check = temp / selfemployed
				foreach var in $x2 {
					replace `var' = `var' / check if check!=. //s.t. = 100%
				}
					drop temp check	
			do do/auxiliary/ilo_imputation_x2.do
				
				*data quality control
					*no imputed values below or above observed values: assign min or max value
						foreach var in $x2 {
							sum `var' if `var'_imputed==1, det
		*pause					
							sum `var' if `var'_imputed==0, det
							scalar `var'_min = `r(min)'
							scalar `var'_max = `r(max)'
							
							replace `var' = `var'_min if `var'_imputed==1 & `var' < `var'_min & `var'!=.
							replace `var' = `var'_max if `var'_imputed==1 & `var' > `var'_max & `var'!=.
							sum `var' if `var'_imputed==1, det
		*pause
						}	
				
				*re-scale imputed obs to add to 100%
					*scale factor s.t. sum of shares of types of selfemployed  = 100% of selfemployed
							gen temp = selfemployed_employers + selfemployed_ownaccount + selfemployed_family //never missing
							gen check = temp / selfemployed	//never missing
						foreach var in $x2 {
							replace `var' = `var' / check if check!=. //s.t. = 100%
						}
							drop temp check	
							
				*won't need these later		
					drop *pred *ub *lb *flag
					
					foreach var in $x2 {
						gen log_`var' = log(`var') //for use in the regression here below
					}
		//level 3: coef_selfemployed* employers ownaccount family
				*coef_ is ratio of self-employed (by type) salary, to employee salary
					*NB unlike above, there is no accounting identity against which to check these coefficients
			do do/auxiliary/ilo_imputation_x3.do
				
				*data quality control
					*no imputed values below or above observed values: assign min or max value
						foreach var in $x3 {
							sum `var' if `var'_imputed==1, det
		*pause					
							sum `var' if `var'_imputed==0, det
							scalar `var'_min = `r(min)'
							scalar `var'_max = `r(max)'
							
							replace `var' = `var'_min if `var'_imputed==1 & `var' < `var'_min & `var'!=.
							replace `var' = `var'_max if `var'_imputed==1 & `var' > `var'_max & `var'!=.
							sum `var' if `var'_imputed==1, det
		*pause
						}	
							
				*won't need these later		
					drop *pred *ub *lb *flag
					
			
			
	*now calculate the factor share a la ILO
		*percentage of national income accruing to the workforce, by type of worker:
			*employee average
				gen salary_employees = ce_hh / employees
					
				/*coef across all types of self-employed
					gen coef_selfemployed = coef_employers * (selfemployed_employers / selfemployed) + ///
											coef_ownaccount * (selfemployed_ownaccount / selfemployed) + ///
											coef_family * (selfemployed_family / selfemployed)	*/
					
			*self-employed workers average (by type), using their ratio to employee salary
				foreach i in employers ownaccount family /*selfemployed*/	{
					gen salary_`i' = coef_`i' * salary_employees
				}
					order salary_*
					format %9.2fc salary_*
				
		*ILO labor share: add salaries of types of workers
			gen Lsh_ilo = salary_employees*employees + ///
					salary_employers*selfemployed_employers + ///
					salary_ownaccount*selfemployed_ownaccount + ///
					salary_family*selfemployed_family
						/*gen check1 = salary_employees*employees + ///
								salary_selfemployed*selfemployed
							*replace check1 = salary_employees*employees +  0.210834 * selfemployed if country=="NER"
						*/
						
							gen diff = (abs(Lsh_ndp_ilo - Lsh_ilo)) / Lsh_ndp_ilo
							*gen diff1 = (abs(Lsh_ndp_ilo - check1)) / Lsh_ndp_ilo
								*replace diff1 = (abs(Lsh_ndp_ilo - check1)) / Lsh_ndp_ilo
							
							format %9.2fc Lsh_ilo diff
							order Lsh_ilo, before(Lsh_ndp_ilo)
								order diff*
					
							br if diff>.01 & diff<. //NER
							*br if diff1>.01 & diff<.

					*OK, the approach works
			
			*ILO estimates: let no imputed values go below or above what we found for 'our' (SNA) labor shares
					sum Lsh_ilo Lsh_ndp, det
						scalar Lsh_min = `r(min)'
						scalar Lsh_max = `r(max)'
							
					replace Lsh_ilo = Lsh_min if Lsh_ilo < Lsh_min & Lsh_ilo!=.
					replace Lsh_ilo = Lsh_max if Lsh_ilo > Lsh_max & Lsh_ilo!=.
							
					sum Lsh_ilo Lsh_ndp, det
			
		
		gen coef_ilo_imputed = 1 if ilo_imputed!=0
		gen emp_ilo_imputed = 1 if employees_imputed==1
		
		*save
		preserve
			keep country year Lsh_ilo coef_employers - selfemployed_family coef_ilo_imputed emp_ilo_imputed
			save data/misc/temp/Lsh_ilo.dta, replace
			save data/misc/rhs/Lsh_ilo.dta, replace
*pause			
		restore

				
					