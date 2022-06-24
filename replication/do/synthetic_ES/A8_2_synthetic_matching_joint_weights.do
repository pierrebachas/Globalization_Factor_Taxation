

	
* Synthetic matching
	
local var="$var"

	xtset cty_id year
	levelsof country if treat==1, local(country)

	local i = 1
	
	foreach x of local country {
		preserve	

		sum cty_id if country=="`x'"
		local id=`r(mean)'
		sum year_firstoutc if country=="`x'"
		local y=`r(mean)'


		keep if control==1 | country=="`x'"

		if "`x'"=="VNM" {
			drop if year<1994
		}

		drop if year==1975

		if "`x'"=="CHN"  {
			drop if year<1990
		}

		* Now we use outcomes simultaniously to predict the synthetic control
		local a1="ETR_L_prime(1976) ETR_L_prime(1977) ETR_L_prime(1978) ETR_L_prime(1979) ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1976) ETR_K_prime(1977) ETR_K_prime(1978) ETR_K_prime(1979) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) Ksh_ndp(1976) Ksh_ndp(1977) Ksh_ndp(1978) Ksh_ndp(1979) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) trade(1976) trade(1977) trade(1978) trade(1979) trade(1980) trade(1981) trade(1982) trade(1983) trade(1984)"
		local a2="ETR_L_prime(1977) ETR_L_prime(1978) ETR_L_prime(1979) ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_K_prime(1977) ETR_K_prime(1978) ETR_K_prime(1979) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) Ksh_ndp(1977) Ksh_ndp(1978) Ksh_ndp(1979) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) trade(1977) trade(1978) trade(1979) trade(1980) trade(1981) trade(1982) trade(1983) trade(1984) trade(1985) trade(1986)"
		local a22="ETR_L_prime(1978) ETR_L_prime(1979) ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_K_prime(1978) ETR_K_prime(1979) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1987) Ksh_ndp(1978) Ksh_ndp(1979) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1987) trade(1978) trade(1979) trade(1980) trade(1981) trade(1982) trade(1983) trade(1984)  trade(1985) trade(1986) trade(1987)"
		local a3="ETR_L_prime(1979) ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987)  ETR_L_prime(1988) ETR_K_prime(1979) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1978) ETR_K_prime(1988) Ksh_ndp(1979) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1978) Ksh_ndp(1988) trade(1979) trade(1980) trade(1981) trade(1982) trade(1983) trade(1984) trade(1985) trade(1986) trade(1978) trade(1988)"
		local a4="ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_L_prime(1988) ETR_L_prime(1989) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1978) ETR_K_prime(1988) ETR_K_prime(1989) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1978) Ksh_ndp(1988) Ksh_ndp(1989) trade(1980) trade(1981) trade(1982) trade(1983) trade(1984) trade(1985) trade(1986) trade(1978) trade(1988) trade(1989)"
		local a5="ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_L_prime(1988) ETR_L_prime(1989) ETR_L_prime(1990) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1978) ETR_K_prime(1988) ETR_K_prime(1989) ETR_K_prime(1990) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1978) Ksh_ndp(1988) Ksh_ndp(1989) Ksh_ndp(1990) trade(1981) trade(1982) trade(1983) trade(1984) trade(1985) trade(1986) trade(1978) trade(1988) trade(1989) trade(1990)"
		local a6="ETR_L_prime(1991) ETR_L_prime(1992) ETR_L_prime(1993) ETR_L_prime(1994) ETR_L_prime(1995) ETR_L_prime(1996) ETR_L_prime(1997) ETR_L_prime(1998) ETR_L_prime(1999) ETR_L_prime(2000) ETR_K_prime(1991) ETR_K_prime(1992) ETR_K_prime(1993) ETR_K_prime(1994) ETR_K_prime(1995) ETR_K_prime(1996) ETR_K_prime(1997) ETR_K_prime(1998) ETR_K_prime(1999) ETR_K(2000) Ksh_ndp(1991) Ksh_ndp(1992) Ksh_ndp(1993) Ksh_ndp(1994) Ksh_ndp(1995) Ksh_ndp(1996) Ksh_ndp(1997) Ksh_ndp(1998) Ksh_ndp(1999) Ksh_ndp(2000) trade(1991) trade(1992) trade(1993) trade(1994) trade(1995) trade(1996) trade(1997) trade(1998) trade(1999) trade(2000)"
		local a7="ETR_L_prime(1994) ETR_L_prime(1995) ETR_L_prime(1996) ETR_L_prime(1997) ETR_L_prime(1998) ETR_L_prime(1999) ETR_L_prime(2000) ETR_K_prime(1994) ETR_K_prime(1995) ETR_K_prime(1996) ETR_K_prime(1997) ETR_K_prime(1998) ETR_K_prime(1999) ETR_K_prime(2000) Ksh_ndp(1994) Ksh_ndp(1995) Ksh_ndp(1996) Ksh_ndp(1997) Ksh_ndp(1998) Ksh_ndp(1999) Ksh_ndp(2000) trade(1994) trade(1995) trade(1996) trade(1997) trade(1998) trade(1999) trade(2000)"


		if "`y'"=="1985"  {
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
		if "`x'"=="CHN"  {
		synth `var' `a6' ///
			, trunit(`id') trperiod(`y') xperiod(1991(1)`y') 
		}
		if "`x'"=="VNM"  {
		synth `var' `a7' ///
			, trunit(`id') trperiod(`y') xperiod(1994(1)`y') 
		}
		clear
		matrix define A=e(Y_synthetic)
		matrix define B=e(Y_treated)
		matrix define C=e(RMSPE)
		svmat A, names(synth_`i'_) 	
		svmat B, names(c_`i'_) 
		svmat C, names(rmspe_`i'_) 		
		replace rmspe_`i'_1=rmspe_`i'_1[1]


		gen year=(`y'-11)+_n

		gen rel_year=year-`y'

		*drop year
		rename year year_`i'_

		cd "$usedata/synthetic_ES_tempfiles"
		save sample`i', replace 

		local i=`i'+1
		restore

		}
		****

		

