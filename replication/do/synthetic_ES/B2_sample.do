


		*** Set up Sample

	local var="$var"

			bysort country: ipolate `var' year, gen(`var'_ipo)		// linearily interpolate outcomes for synth control
			replace `var'=`var'_ipo if `var'==.


			bysort country: ipolate `var' year if (country=="BRA" | country=="CHL" | country=="IDN" | country=="ISR" | country=="KOR" | country=="MEX" | country=="MYS" | country=="TUR" |  ///
			country=="THA"	| country=="TWN"	| country=="PRT"	| country=="ESP"	| country=="GRC"	| country=="PHL" | country=="TWN" | country=="ARG"), gen(`var'_expo) epolate
			replace `var'=`var'_expo if `var'==. & (country=="BRA" | country=="CHL" | country=="IDN" | country=="ISR" | country=="KOR" | country=="MEX" | country=="MYS" | country=="TUR" | 	///
			country=="THA"	| country=="TWN"	| country=="PRT"	| country=="ESP"	| country=="GRC"	| country=="PHL" | country=="TWN" | country=="ARG")		// need to extrapolateto get all 10 pre years

			sort country year 

			preserve
			drop if treat==1
			drop if `var'==.
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

			if "`var'"=="industry_va" | "`var'"=="services_va" | "`var'"=="agric_va" {
				drop if country=="TWN"
			}
			
			merge m:1 country using `control', nogen
			keep if treat==1 | control==1
