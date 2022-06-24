



	* Drop Vietnam before 1991, so we can extrapolate its values from 1990 to 1994 later
	drop if country=="VNM" & year<1990

	encode country, gen(cty_id)
	drop if country=="COD"			// We have to drop the DRC. It causes sinificant problems in the synthetic matching, 
									// some of the outcoems (e.g. ETR_K) make no sense and jump from 0 to 50%

		* Colombia: 85
		* Mexico: 85
		* Argentina 89
		* Brazil: 88
		* India: 91
		* Vietnam: 01
		* China:01
		gen treat=0
		replace treat=1 if country=="BRA" | country=="COL" ///
			| country=="VNM" | country=="IND" | country=="MEX" | country=="ARG" | country=="CHN"

		gen year_firstoutc=.
		replace year_firstoutc=1985 if country=="COL" 
		replace year_firstoutc=1985 if country=="MEX"
		replace year_firstoutc=1989 if country=="ARG"
		replace year_firstoutc=1988 if country=="BRA"
		replace year_firstoutc=1991 if country=="IND" 
		replace year_firstoutc=2001 if country=="VNM"
		replace year_firstoutc=2001 if country=="CHN"



* We use trade here to restrict the sample as trade is the most frequent missing variable. 
* Fir the synth command to work later on, we cannot ahve any missing values in the control
* pool. It turns out that when dropping all observations with missing values in trade, 
* have no longer have any missing values in any other outcome. 
local var trade 
	
		bysort country: ipolate ETR_L_prime year, gen(ETR_L_prime_ipo)
		replace ETR_L_prime=ETR_L_prime_ipo if ETR_L_prime==.

		bysort country: ipolate ETR_K_prime year, gen(ETR_K_prime_ipo)
		replace ETR_K_prime=ETR_K_prime_ipo if ETR_K_prime==.

		bysort country: ipolate Ksh_ndp year, gen(Ksh_ndp_ipo)
		replace Ksh_ndp=Ksh_ndp_ipo if Ksh_ndp==.

		bysort country: ipolate trade year, gen(trade_ipo)
		replace trade=trade_ipo if trade==.

		drop ETR_L_prime_ipo ETR_K_prime_ipo Ksh_ndp_ipo trade_ipo
		
		* Extrapolate for Vietnam, but only the ones we can without generating outliers (i.e. ETR_L, Ksh_nni, Ksh_corp)
		bysort country: ipolate ETR_L_prime year if country=="VNM", gen(ETR_L_prime_expo) epolate
		replace ETR_L_prime=ETR_L_prime_expo if ETR_L_prime==. & country=="VNM"

		bysort country: ipolate Ksh_ndp year if country=="VNM", gen(Ksh_ndp_expo) epolate
		replace Ksh_ndp=Ksh_ndp_expo if Ksh_ndp==. & country=="VNM"

		bysort country: ipolate Ksh_corp year if country=="VNM", gen(Ksh_corp_expo) epolate
		replace Ksh_corp=Ksh_corp_expo if Ksh_corp==. & country=="VNM"

		sort country year 

		preserve
		drop if treat==1
		drop if `var'==.
		drop if ETR_L==. | ETR_K==. | Ksh_corp==. | Ksh_ndp==.
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
		drop if country=="LSO"

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

		xtset cty_id year
		levelsof country if treat==1, local(country)







