*ilo_imputation_x2: shares of selfemployed_ employers vs. ownaccount vs. family

foreach var in $x2 {
		preserve
						gen log_`var' = log(`var')
									label var log_`var' "log of `var'"
									format %9.1fc log_`var'
						xtregar log_`var' log_nnipc log_selfemployed, re twostep
					// Store parameters
						local rho = e(rho_ar)
						local sigma_u = e(sigma_u)
							// Stata is quite confusing here: "e" refers to the error term that follows the
							// AR(1) process, but "sigma_e" refers to the residual of the AR(1) process
						local sigma_eta = e(sigma_e)
					// Random effect and error term
						predict u, u
					// Extend the random effect to the whole country when some years have missing values (hence no prediction)
							egen u2 = mode(u), by(cid)
							drop u
							rename u2 u
							generate varu = cond(u < ., 0, `sigma_u'^2)
							replace u = 0 if (u >= .)
						predict xb, xb
						generate e = log_`var' - xb - u
					// Zero conditional variance when the var is observed
								generate vare = 0 								if (e < .)
						// When `var' is never observed, we impute the value of the stationary process
							egen has_`var' = total(log_`var' < .), by(cid)
								replace e = 0 									if (!has_`var')
							replace vare = `sigma_eta'^2/(1 - `rho'^2) 			if (!has_`var')
							replace varu = `sigma_u'^2 							if (!has_`var')
						
					// When some values are observed, divide time in segments of contiguous observations with or without observed `var'
						sort cid year
							by cid: generate segment = sum((log_`var' < .) != (log_`var'[_n - 1] < .))
								egen minseg = min(segment), by(cid)
								egen maxseg = max(segment), by(cid)
								egen seghas_`var'= total(`var' < .), by(cid segment)
										sort cid segment year
									by cid segment: generate t = _n
									by cid segment: generate T = _N
									by cid: generate e0 = e[_n - 1]
									by cid: generate eF = e[_n + 1]
									by cid segment: replace e0 = e0[1]
									by cid segment: replace eF = eF[_N]
						
				// Extrapolate e into the future
					replace e = `rho'^t*e0 													if (has_`var') & (segment == maxseg) & (!seghas_`var')
					replace vare = `sigma_eta'^2*(1 - `rho'^(2*t))/(1 - `rho'^2) 			if (has_`var') & (segment == maxseg) & (!seghas_`var')
				// Extrapolate e into the past
					replace e = `rho'^(T + 1 - t)*eF 										if (has_`var') & (segment == minseg) & (!seghas_`var')
					replace vare = `sigma_eta'^2*(1 - `rho'^(2*(T + 1 - t)))/(1 - `rho'^2) 	if (has_`var') & (segment == minseg) & (!seghas_`var')
				// Interpolate in the gaps
						sort cid segment year
					replace e = `rho'^t*e0 + (eF - `rho'^(T+1)*e0)*`rho'^(T + 1 - t)*(1 - `rho'^(2*t))/(1 - `rho'^(2*(T+1))) 			if (has_`var') & !inlist(segment, minseg, maxseg) & (!seghas_`var')
					replace vare = `sigma_eta'^2*(1 - `rho'^(2*t))*(1 - `rho'^(2*(T + 1 - t)))/((1 - `rho'^2)*(1 - `rho'^(2*(T + 1)))) 	if (has_`var') & !inlist(segment, minseg, maxseg) & (!seghas_`var')
							drop has_`var' segment minseg maxseg seghas_`var' t T e0 eF	
						
				// Predict actual value (best prediction, 80% prediction interval)
						*this was originally with the hp filter, and gets NIT as a pct of gdp
						generate `var'_pred = exp(xb + u + e + 0.5*(varu + vare))
							label var `var'_pred  "predicted value of `var'" 
						generate `var'_lb = exp(xb + u + e - 1.281551565545*sqrt(varu + vare))
							label var `var'_lb "lower bound of `var' (80% CI)" 
						generate `var'_ub = exp(xb + u + e + 1.281551565545*sqrt(varu + vare))
							label var `var'_ub "upper bound of `var' (80% CI)" 
				//finally put values on the varlist, and note if imputed
						gen `var'_imputed=0
								label var `var'_imputed "`var' is imputed"
						replace `var'_imputed=1 if `var'==. & `var'_pred!=.
						replace `var' = `var'_pred if `var' == .
						gen `var'_flag = 1 if `var'==. & nnipc_ppp!=. //still missing
							label var `var'_flag "flag: failed to impute (despite nnipc_ppp!=.)"
			//save unique data for merge		
				keep country year `var' `var'_pred `var'_lb `var'_ub `var'_imputed `var'_flag
						format %9.2fc *lb *ub *pred
					save data/misc/temp/`var'.dta, replace
		restore
			//merge imputed varlist to rescale
			merge 1:1 country year using data/misc/temp/`var'.dta, update nogen
*pause			
		}
