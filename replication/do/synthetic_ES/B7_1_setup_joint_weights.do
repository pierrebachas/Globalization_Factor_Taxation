		
		
		
* Data setup 


		encode country, gen(cty_id)
		drop if country=="COD"			// DRC makes lots of problem in synthetic control, it ends up 
										// as with a large weight in the counterfactual for China for
										// ETR_K, but in 2000, the rate has a 50 percentage point jump
										// Anders suggested to justdrop it. 

		
		gen K_libyear=.
		replace K_libyear=1989 if country_name=="Argentina"
		replace K_libyear=1988 if country_name=="Brazil"
		replace K_libyear=1987 if country_name=="Chile"
		replace K_libyear=1991 if country_name=="Colombia"
		replace K_libyear=1991 if country_name=="Egypt"
		replace K_libyear=1994 if country_name=="Greece"
		replace K_libyear=1986 if country_name=="India"
		replace K_libyear=1989 if country_name=="Indonesia"
		replace K_libyear=1989 if country_name=="Israel"
		replace K_libyear=1995 if country_name=="Jordan"
		replace K_libyear=1987 if country_name=="Malaysia"
		replace K_libyear=1989 if country_name=="Mexico"
		replace K_libyear=1992 if country_name=="Morocco"
		replace K_libyear=1995 if country_name=="Nigeria"
		replace K_libyear=1991 if country_name=="Pakistan"
		replace K_libyear=1986 if country_name=="Philippines"
		replace K_libyear=1993 if country_name=="Portugal"
		replace K_libyear=1995 if country_name=="South Africa"
		replace K_libyear=1987 if country_name=="Republic of Korea"
		replace K_libyear=1993 if country_name=="Spain"
		replace K_libyear=1986 if country_name=="Taiwan"
		replace K_libyear=1987 if country_name=="Thailand"
		replace K_libyear=1989 if country_name=="Turkey"
		replace K_libyear=1990 if country_name=="Venezuela (Bolivarian Republic of)"
		replace K_libyear=1993 if country_name=="Zimbabwe"
		

		gen treat=0
		replace treat=1 if K_libyear!=.

		rename K_libyear year_firstoutc

		drop if country=="MAR"		// openess only exists for 3 year




		foreach var2 of varlist  lg_open lg_eq ETR_K_prime ETR_L_prime Ksh_ndp Ksh_corp {

		bysort country: ipolate `var2' year, gen(`var2'_ipo)		// linearily interpolate outcomes for synth control
		replace `var2'=`var2'_ipo if `var2'==.

		bysort country: ipolate `var2' year if (country=="GRC"	| country=="PHL" | country=="TWN" | country=="ARG"), gen(`var2'_expo) epolate
		replace `var2'=`var2'_expo if `var2'==. & (country=="GRC"	| country=="PHL" | country=="TWN" | country=="ARG")		// need to extrapolate for Vietnam to get all 10 pre years
		}
		****
		sort country year 

		preserve
		drop if treat==1
		drop if lg_open==.
		drop if lg_eq==.
		drop if ETR_K_prime==.
		drop if ETR_L_prime==.
		drop if Ksh_ndp==.
		drop if Ksh_corp==.

		tab year 
		drop if year <1975
		drop if year >2005

		gen x=1 if year==1976
		bysort country: egen y=max(x)
		drop if y==.
		drop x y

		gen x=1 if year==2005
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
		drop if year>2005

		merge m:1 country using `control', nogen
		keep if treat==1 | control==1

