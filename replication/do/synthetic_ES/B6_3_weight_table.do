


*** 5.3 Extract weight for synrthetic control from pool of countries that form control for K liberalization Events
	
* In this code, we run synthetic matching again but only extract the country
* names and respective weights of the three most important countries that 
* contribute to the synthetic control for each event we consider. 
		

			local k=1

			foreach var of varlist  lg_open lg_eq ETR_K_prime ETR_L_prime Ksh_ndp Ksh_corp {

				local i=1

				foreach x in ARG BRA CHL COL EGY ESP GRC IDN IND ISR JOR KOR MEX MYS NGA PAK PHL PRT THA TUR TWN VEN ZAF ZWE { 


					* 5.3.1 Data prep 
					{
					cd "$usedata"
					use "${usedata}/${data}", clear


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


					}
					****
					{

						bysort country: ipolate `var' year, gen(`var'_ipo)		// linearily interpolate outcomes for synth control
						replace `var'=`var'_ipo if `var'==.

						bysort country: ipolate `var' year if (country=="GRC"	| country=="PHL" | country=="TWN" | country=="ARG"), gen(`var'_expo) epolate
						replace `var'=`var'_expo if `var'==. & (country=="GRC"	| country=="PHL" | country=="TWN" | country=="ARG")		// need to extrapolate for Vietnam to get all 10 pre years

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

						merge m:1 country using `control', nogen
						keep if treat==1 | control==1

						xtset cid year
						levelsof country if treat==1, local(country)

					}
					****

					* 5.3.2 Synthetic Control part
					{
					drop if treat==0 & `var'==.
					qui sum cid if country=="`x'"
					local id=`r(mean)'
					qui sum year_firstoutc if country=="`x'"
					local y=`r(mean)'

					drop if year<`y'-10
					drop if year>`y'+10

					keep if control==1 | country=="`x'"


					local a1="`var'(1976) `var'(1977) `var'(1978) `var'(1979) `var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985)"
					local a2="`var'(1977) `var'(1978) `var'(1979) `var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986)"
					local a3="`var'(1978) `var'(1979) `var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987)"
					local a4="`var'(1979) `var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987) `var'(1988)"
					local a5="`var'(1980) `var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987) `var'(1988) `var'(1989)"
					local a6="`var'(1981) `var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987) `var'(1988) `var'(1989) `var'(1990)"
					local a7="`var'(1982) `var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987) `var'(1988) `var'(1989) `var'(1990) `var'(1991)"
					local a8="`var'(1983) `var'(1984) `var'(1985) `var'(1986) `var'(1987) `var'(1988) `var'(1989) `var'(1990) `var'(1991) `var'(1992)"
					local a9="`var'(1984) `var'(1985) `var'(1986) `var'(1987) `var'(1988) `var'(1989) `var'(1990) `var'(1991) `var'(1992) `var'(1993)"
					local a10="`var'(1985) `var'(1986) `var'(1987) `var'(1988) `var'(1989) `var'(1990) `var'(1991) `var'(1992) `var'(1993) `var'(1994)"


					if "`y'"=="1986" {
					synth `var' `a1' ///
						, trunit(`id') trperiod(`y') xperiod(1976(1)`y') 
					}
					if "`y'"=="1987" {
					synth `var' `a2' ///
						, trunit(`id') trperiod(`y') xperiod(1977(1)`y') 
					}
					if "`y'"=="1988" {
					synth `var' `a3' ///
						, trunit(`id') trperiod(`y') xperiod(1978(1)`y') 
					}
					if "`y'"=="1989" {
					synth `var' `a4' ///
						, trunit(`id') trperiod(`y') xperiod(1979(1)`y') 
					}
					if "`y'"=="1990" {
					synth `var' `a5' ///
						, trunit(`id') trperiod(`y') xperiod(1980(1)`y') 
					}
					if "`y'"=="1991" {
					synth `var' `a6' ///
						, trunit(`id') trperiod(`y') xperiod(1981(1)`y') 
					}
					if "`y'"=="1992" {
					synth `var' `a7' ///
						, trunit(`id') trperiod(`y') xperiod(1982(1)`y') 
					}
					if "`y'"=="1993" {
					synth `var' `a8' ///
						, trunit(`id') trperiod(`y') xperiod(1983(1)`y') 
					}
					if "`y'"=="1994" {
					synth `var' `a9' ///
						, trunit(`id') trperiod(`y') xperiod(1984(1)`y') 
					}
					if "`y'"=="1995" {
					synth `var' `a10' ///
						, trunit(`id') trperiod(`y') xperiod(1985(1)`y') 
					}

					preserve
					matrix define A=e(W_weights)
					clear
					svmat A, names(c) 	
					drop if c2==0
					tempfile x1
					save `x1'
					restore

					keep cty_id country_name
					gen country ="`x'"
					gen event_year="`y'"
					bysort cty_id: keep if _n==1
					rename cty_id c1
					rename country_name synthetic_match_`var'
					merge 1:1 c1 using `x1', nogen
					keep if c2>0
					drop if c2==.
					gsort - c2
					rename c2 `var'
					drop c1
					order country synthetic_match `var' event_year

					count if `var'>0 & `var'!=.
					local a=`r(N)'
					drop if _n>4


					if "`a'"=="1" {
					set obs 4
					replace country=country[1]
					replace synthetic_match="..." in 2/4
					}
					if "`a'"=="2" {
					set obs 4
					replace country=country[1]
					replace synthetic_match="..." in 3/4
					}
					if "`a'"=="3" {
					set obs 4
					replace country=country[1]
					replace synthetic_match="..." in 4
					}
					if "`a'"!="3" & "`a'"!="2" & "`a'"!="1" {
					replace synthetic_match="..." in 4
					replace `var'=. in 4
					}

					gen id=_n

					tempfile c`i'
					save `c`i''

					local i=`i'+1

						}
					}
					****
						
				
					* 5.3.3 Append all countries
					{
					use `c1', clear
					append using `c2' `c3' `c4' `c5' `c6' `c7' `c8' `c9' `c10' `c11' `c12' `c13' `c14' `c15' `c16' `c17' `c18' `c19' `c20' `c21' `c22' `c23' `c24' 

					tempfile q`k'
					save `q`k''


					local k=`k'+1

				} 
				****
				
				} 
				****
		
			* 5.3.4 Merge all variables to construct one table
			{
			use `q1', clear
			merge 1:1 country id using `q2', nogen 
			merge 1:1 country id using `q3', nogen 
			merge 1:1 country id using `q4', nogen 
			merge 1:1 country id using `q5', nogen 
			merge 1:1 country id using `q6', nogen 


			* use `q2', clear	

			drop id synthetic_match_lg_open lg_open synthetic_match_Ksh_corp Ksh_corp

			tostring lg_eq ETR_K_prime ETR_L_prime Ksh_ndp, replace force 


				replace lg_eq=substr(lg_eq,2,3)
				replace lg_eq=substr(lg_eq,1,2)+"."+substr(lg_eq,3,3)
				replace lg_eq=substr(lg_eq,2,4) if substr(lg_eq,1,1)=="0"
				replace lg_eq=lg_eq + " \%"
				replace lg_eq="..." if lg_eq==". \%"
				
				replace ETR_K_prime=substr(ETR_K_prime,2,3)
				replace ETR_K_prime=substr(ETR_K_prime,1,2)+"."+substr(ETR_K_prime,3,3)
				replace ETR_K_prime=substr(ETR_K_prime,2,4) if substr(ETR_K_prime,1,1)=="0"
				replace ETR_K_prime=ETR_K_prime + " \%"
				replace ETR_K_prime="..." if ETR_K_prime==". \%"

				replace ETR_L_prime=substr(ETR_L_prime,2,3)
				replace ETR_L_prime=substr(ETR_L_prime,1,2)+"."+substr(ETR_L_prime,3,3)
				replace ETR_L_prime=substr(ETR_L_prime,2,4) if substr(ETR_L_prime,1,1)=="0"
				replace ETR_L_prime=ETR_L_prime + " \%"
				replace ETR_L_prime="..." if ETR_L_prime==". \%"
				
				replace Ksh_ndp=substr(Ksh_ndp,2,3)
				replace Ksh_ndp=substr(Ksh_ndp,1,2)+"."+substr(Ksh_ndp,3,3)
				replace Ksh_ndp=substr(Ksh_ndp,2,4) if substr(Ksh_ndp,1,1)=="0"
				replace Ksh_ndp=Ksh_ndp + " \%"
				replace Ksh_ndp="..." if Ksh_ndp==". \%"
				
			order country event_year synthetic_match_Ksh_ndp Ksh_ndp synthetic_match_ETR_K_prime ///
				ETR_K_prime synthetic_match_ETR_L_prime ETR_L_prime synthetic_match_lg_eq lg_eq

			cd "$outputs/tables"
			dataout, save(k_lib_events_weights) tex head replace 

			}
			****







