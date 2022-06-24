		
		
		*** Set up Sample

	local var="$var"

		* In this section, we have to drop all countries that have missing values in the relevant period we consider (the relevant period
		* varies depending on the event. As our earliest events are in 1985, we drop all countries that are unbalanced in the relevant
		* outcome between 1976 (10 years of pre trends) and 2013. 
		
		bysort country: ipolate `var' year, gen(`var'_ipo)		// linearily interpolate outcomes for synth control. We have to ensure to 								
		replace `var' =`var'_ipo if `var' ==.						// have as many 

		bysort country: ipolate `var' year if country=="VNM", gen(`var'_expo) epolate
		replace `var' =`var'_expo if `var' ==. & country=="VNM"			// need to extrapolate for Vietnam to get all 10 pre years
		drop `var'_expo
		
		* We need to fill in some variablesso that we get 10 pre periods of coverage for
		* our treated countries, else the synth command will not work. 
		replace cit_rate_winz=0 if country=="ARG" & year==1979
		replace cit_rate_winz=0 if country=="BRA" & year>=1978 & year<=1979		
		replace cit_rate_winz=0 if country=="COL" & year>=1976 & year<=1979	
		replace cit_rate_winz=0 if country=="MEX" & year>=1976 & year<=1980	


		if "`var'"=="cit_rate_winz" {
		foreach c in ARG BRA COL MEX {
			bysort country: ipolate `var' year if country=="`c'", gen(`var'_expo) epolate
			replace `var' =`var'_expo if `var' ==. & country=="`c'"			// need to extrapolate for countries to get all 10 pre years
			drop `var'_expo
		}
		}
		
		sort country year 

		preserve
		drop if treat==1
		drop if `var' ==.
		tab year 
		drop if year <1975
		drop if year >2013

		gen x=1 if year==1976
		bysort country: egen y=max(x)
		drop if y==.
		drop x y

		gen x=1 if year==2013
		bysort country: egen y=max(x)
		drop if y==.
		drop x y

		drop if country=="LBR"

		gen control=1
		keep country control
		bysort country: keep if _n==1
		tempfile control
		save `control'
		restore

		drop if year<1975
		drop if year>2013

		merge m:1 country using `control', nogen
		keep if treat==1 | control==1

		
