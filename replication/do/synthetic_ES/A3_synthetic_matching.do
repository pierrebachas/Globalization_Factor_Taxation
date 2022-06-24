		
		
*** 2. Synthetic Control part: 

			* With the sample of treated countries and the pool of possible control countries, we now construct the synthetic
			* control for each treated country. 
		
		local var="$var"
		
		xtset cty_id year
		levelsof country if treat==1, local(country)
	
		local i=1
			foreach x of local country {
				preserve	
				
				* We extract macros for the treated country and the year of the event
				sum cty_id if country=="`x'"
				local id=`r(mean)'
				sum year_firstoutc if country=="`x'"
				local y=`r(mean)'
		
				* Only keep the treated country and control pool (i.e. drop the other treated countries)
				keep if control==1 | country=="`x'"
				
				drop if year<`y'-10

				* Depending on which country we consider, drop the years more than 10 years before the event

				if "`x'"=="VNM" & "`var'"=="ETR_K_prime" {
					drop if year<1995				
				}
				if ("`x'"=="VNM") & ("`var'"=="Ksh_ndp" | "`var'"=="ETR_L_prime" | "`var'"=="Ksh_ndp" | "`var'"=="Ksh_corp" | "`var'"=="va_corp" | "`var'"=="selfemployed")  {
					drop if year<1991 
				}
				* All other outcomes for Vietname
				if "`x'"=="VNM" & "`var'"!="Ksh_ndp" & "`var'"!="ETR_L_prime" & "`var'"!="Ksh_ndp" & "`var'"!="Ksh_corp" & "`var'"!="va_corp" & "`var'"!="selfemployed" & "`var'"!="ETR_K_prime" {
					drop if year<1994 
				}

				
				* Here, we have to drop the countries from the control pool that have missing values for selfemployed in 1975
				if "$var"=="selfemployed" {
					levelsof country if selfemployed==., local(p)
					foreach q of local p {
						drop if country=="`q'"
					}
				}
				
				if "`x'"!="COL" {
					drop if year==1975
				}
				if "`var'"!="Ksh_corp" & "`var'"!="selfemployed" {
					drop if year==1975
				}
				if ("`x'"=="COL") & ("`var'"=="Ksh_corp" | "`var'"=="selfemployed") {
					gen y=1 if year==1975 & `var'==.
					bysort country: egen q=max(y)
					drop if q==1						// We do this for colombia to obtain a fully balanced panel for the event Ksh_corp and selfemployed
				}
									
			
				* Set regressors for matching
				local a1="`var'(1976) `var'(1977) `var'(1978) `var'(1979) `var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984)"
				local a11="`var'(1975) `var'(1976) `var'(1977) `var'(1978) `var'(1979) `var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984)"
				local a2="`var'(1977) `var'(1978) `var'(1979) `var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986)"
				local a22="`var'(1978) `var'(1979) `var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987)"
				local a3="`var'(1979) `var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987) `var'(1988)"
				local a4="`var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987) `var'(1988) `var'(1989)"
				local a5="`var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987) `var'(1988) `var'(1989) `var'(1990)"
				local a6="`var'(1991) `var'(1992) `var'(1993) `var'(1994) `var'(1995) `var'(1996) `var'(1997) `var'(1998) `var'(1999) `var'(2000)"
				local a7="`var'(1994) `var'(1995) `var'(1996) `var'(1997) `var'(1998) `var'(1999) `var'(2000)"
				local a8="`var'(1995) `var'(1996) `var'(1997) `var'(1998) `var'(1999) `var'(2000)"
				
				* Do the synthetic matching
				if "`x'"=="COL" & "`var'"!="Ksh_corp" {
				synth `var' `a1' ///
					, trunit(`id') trperiod(`y') xperiod(1976(1)`y') 
				}
				if "`x'"=="COL" & "`var'"=="Ksh_corp" {
				synth `var' `a11' ///
					, trunit(`id') trperiod(`y') xperiod(1975(1)`y') 
				}
				if "`y'"=="1985" & "`x'"!="COL" {
				synth `var' `a1' ///
					, trunit(`id') trperiod(`y') xperiod(1976(1)`y') 
				}
				if "`y'"=="1987" {
				synth `var' `a2' ///
					, trunit(`id') trperiod(`y') xperiod(1977(1)`y') 
				}
				if "`y'"=="1988" {
				synth `var' `a22' ///
					, trunit(`id') trperiod(`y') xperiod(1978(1)`y') 
				}
				if "`y'"=="1989" {
				synth `var' `a3' ///
					, trunit(`id') trperiod(`y') xperiod(1979(1)`y') 
				}
				if "`y'"=="1990" {
				synth `var' `a4' ///
					, trunit(`id') trperiod(`y') xperiod(1980(1)`y') 
				}
				if "`y'"=="1991" {
				synth `var' `a5' ///
					, trunit(`id') trperiod(`y') xperiod(1981(1)`y') 
				}
				
				* China and Vietnam haven their events in 2001. However, we had to make special accomodations for Vietname and depending
				* on the outcome, use different time horizons to match on. 
				if "`x'"=="CHN"  {
				synth `var' `a6' ///
					, trunit(`id') trperiod(`y') xperiod(1991(1)`y') 
				}	
				if "`x'"=="VNM" & "`var'"=="ETR_K_prime" {
				synth `var' `a8' ///
					, trunit(`id') trperiod(`y') xperiod(1995(1)`y') 
				}
				if ("`x'"=="VNM") & ("`var'"=="Ksh_ndp" | "`var'"=="ETR_L_prime" | "`var'"=="Ksh_ndp" | "`var'"=="Ksh_corp" | "`var'"=="va_corp" | "`var'"=="selfemployed")  {
				synth `var' `a6' ///
					, trunit(`id') trperiod(`y') xperiod(1991(1)`y') 	// We need to balance the sample for the outcome selfemployed. Else, we get large jumps that are attributed to the fact that countries with different levels enter the sample. 
				}
				* All other outcomes for Vietname
				if "`x'"=="VNM" & "`var'"!="Ksh_ndp" & "`var'"!="ETR_L_prime" & "`var'"!="Ksh_ndp" & "`var'"!="Ksh_corp" & "`var'"!="va_corp" & "`var'"!="selfemployed" & "`var'"!="ETR_K_prime" {
				synth `var' `a7' ///
					, trunit(`id') trperiod(`y') xperiod(1994(1)`y') 
				}
					
				* Clear data, construct new data set of the outcomes (Y_synthetic and Y_treated), as well as the root mean squared error.
				clear
				matrix define A=e(Y_synthetic)
				matrix define B=e(Y_treated)
				matrix define C=e(RMSPE)
				svmat A, names(synth_`i'_) 	
				svmat B, names(c_`i'_) 
				svmat C, names(rmspe_`i'_) 		
				replace rmspe_`i'_1=rmspe_`i'_1[1]

				* Extract last year from matrix
				local year: rownames A
				local year substr("`year'",1,4)
				gen p = `year'
				destring p, replace
				
				* Generate absolute and relative year variables
				gen year = p-1+_n
				gen rel_year=year-`y'

				rename year year_`i'_
				
				cd "$usedata/synthetic_ES_tempfiles"
				save sample`i', replace 

				local i=`i'+1
				restore

			}
			****

