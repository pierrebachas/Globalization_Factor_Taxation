


* Synthetic matching
	
local var="$var"

	xtset cty_id year
	levelsof country if treat==1, local(country)

	local i = 1

	foreach x of local country {
		preserve	


		drop if treat==0 & `var'==.
		sum cid if country=="`x'"
		local id=`r(mean)'
		sum year_firstoutc if country=="`x'"
		local y=`r(mean)'

		drop if year<`y'-10
		drop if year>`y'+10

		keep if control==1 | country=="`x'"

		local a1="lg_eq(1976) lg_eq(1977) lg_eq(1978) lg_eq(1979) lg_eq(1980) lg_eq(1981) lg_eq(1982) lg_eq(1983) lg_eq(1984) lg_eq(1985) ETR_K_prime(1976) ETR_K_prime(1977) ETR_K_prime(1978) ETR_K_prime(1979) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_L_prime(1976) ETR_L_prime(1977) ETR_L_prime(1978) ETR_L_prime(1979) ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) Ksh_ndp(1976) Ksh_ndp(1977) Ksh_ndp(1978) Ksh_ndp(1979) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_corp(1976) Ksh_corp(1977) Ksh_corp(1978) Ksh_corp(1979) Ksh_corp(1980) Ksh_corp(1981) Ksh_corp(1982) Ksh_corp(1983) Ksh_corp(1984) Ksh_corp(1985)"

		local a2="lg_eq(1977) lg_eq(1978) lg_eq(1979) lg_eq(1980) lg_eq(1981) lg_eq(1982) lg_eq(1983) lg_eq(1984) lg_eq(1985) lg_eq(1986) ETR_K_prime(1977) ETR_K_prime(1978) ETR_K_prime(1979) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_L_prime(1977) ETR_L_prime(1978) ETR_L_prime(1979) ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) Ksh_ndp(1977) Ksh_ndp(1978) Ksh_ndp(1979) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_corp(1977) Ksh_corp(1978) Ksh_corp(1979) Ksh_corp(1980) Ksh_corp(1981) Ksh_corp(1982) Ksh_corp(1983) Ksh_corp(1984) Ksh_corp(1985) Ksh_corp(1986)"

		local a3="lg_eq(1978) lg_eq(1979) lg_eq(1980) lg_eq(1981) lg_eq(1982) lg_eq(1983) lg_eq(1984) lg_eq(1985) lg_eq(1986) lg_eq(1987) ETR_K_prime(1978) ETR_K_prime(1979) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1987) ETR_L_prime(1978) ETR_L_prime(1979) ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) Ksh_ndp(1978) Ksh_ndp(1979) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1987) Ksh_corp(1978) Ksh_corp(1979) Ksh_corp(1980) Ksh_corp(1981) Ksh_corp(1982) Ksh_corp(1983) Ksh_corp(1984) Ksh_corp(1985) Ksh_corp(1986) Ksh_corp(1987)"

		local a4="lg_eq(1979) lg_eq(1980) lg_eq(1981) lg_eq(1982) lg_eq(1983) lg_eq(1984) lg_eq(1985) lg_eq(1986) lg_eq(1987) lg_eq(1988) ETR_K_prime(1979) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1987) ETR_K_prime(1988) ETR_L_prime(1979) ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_L_prime(1988) Ksh_ndp(1979) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1987) Ksh_ndp(1988) Ksh_corp(1979) Ksh_corp(1980) Ksh_corp(1981) Ksh_corp(1982) Ksh_corp(1983) Ksh_corp(1984) Ksh_corp(1985) Ksh_corp(1986) Ksh_corp(1987) Ksh_corp(1988)"

		local a5="lg_eq(1980) lg_eq(1981) lg_eq(1982) lg_eq(1983) lg_eq(1984) lg_eq(1985) lg_eq(1986) lg_eq(1987) lg_eq(1988) lg_eq(1989) ETR_K_prime(1980) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1987) ETR_K_prime(1988) ETR_K_prime(1989) ETR_L_prime(1980) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_L_prime(1988) ETR_L_prime(1989) Ksh_ndp(1980) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1987) Ksh_ndp(1988) Ksh_ndp(1989) Ksh_corp(1980) Ksh_corp(1981) Ksh_corp(1982) Ksh_corp(1983) Ksh_corp(1984) Ksh_corp(1985) Ksh_corp(1986) Ksh_corp(1987) Ksh_corp(1988) Ksh_corp(1989)"

		local a6="lg_eq(1981) lg_eq(1982) lg_eq(1983) lg_eq(1984) lg_eq(1985) lg_eq(1986) lg_eq(1987) lg_eq(1988) lg_eq(1989) lg_eq(1990) ETR_K_prime(1981) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1987) ETR_K_prime(1988) ETR_K_prime(1989) ETR_K_prime(1990) ETR_L_prime(1981) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_L_prime(1988) ETR_L_prime(1989) ETR_L_prime(1990) Ksh_ndp(1981) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1987) Ksh_ndp(1988) Ksh_ndp(1989) Ksh_ndp(1990) Ksh_corp(1981) Ksh_corp(1982) Ksh_corp(1983) Ksh_corp(1984) Ksh_corp(1985) Ksh_corp(1986) Ksh_corp(1987) Ksh_corp(1988) Ksh_corp(1989) Ksh_corp(1990)"

		local a7="lg_eq(1982) lg_eq(1983) lg_eq(1984) lg_eq(1985) lg_eq(1986) lg_eq(1987) lg_eq(1988) lg_eq(1989) lg_eq(1990) lg_eq(1991) ETR_K_prime(1982) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1987) ETR_K_prime(1988) ETR_K_prime(1989) ETR_K_prime(1990) ETR_K_prime(1991) ETR_L_prime(1982) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_L_prime(1988) ETR_L_prime(1989) ETR_L_prime(1990) ETR_L_prime(1991) Ksh_ndp(1982) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1987) Ksh_ndp(1988) Ksh_ndp(1989) Ksh_ndp(1990) Ksh_ndp(1991) Ksh_corp(1982) Ksh_corp(1983) Ksh_corp(1984) Ksh_corp(1985) Ksh_corp(1986) Ksh_corp(1987) Ksh_corp(1988) Ksh_corp(1989) Ksh_corp(1990) Ksh_corp(1991)"

		local a8="lg_eq(1983) lg_eq(1984) lg_eq(1985) lg_eq(1986) lg_eq(1987) lg_eq(1988) lg_eq(1989) lg_eq(1990) lg_eq(1991) lg_eq(1992) ETR_K_prime(1983) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1987) ETR_K_prime(1988) ETR_K_prime(1989) ETR_K_prime(1990) ETR_K_prime(1991) ETR_K_prime(1992) ETR_L_prime(1983) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_L_prime(1988) ETR_L_prime(1989) ETR_L_prime(1990) ETR_L_prime(1991) ETR_L_prime(1992) Ksh_ndp(1983) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1987) Ksh_ndp(1988) Ksh_ndp(1989) Ksh_ndp(1990) Ksh_ndp(1991) Ksh_ndp(1992) Ksh_corp(1983) Ksh_corp(1984) Ksh_corp(1985) Ksh_corp(1986) Ksh_corp(1987) Ksh_corp(1988) Ksh_corp(1989) Ksh_corp(1990) Ksh_corp(1991) Ksh_corp(1992)"

		local a9="lg_eq(1984) lg_eq(1985) lg_eq(1986) lg_eq(1987) lg_eq(1988) lg_eq(1989) lg_eq(1990) lg_eq(1991) lg_eq(1992) lg_eq(1993) ETR_K_prime(1984) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1987) ETR_K_prime(1988) ETR_K_prime(1989) ETR_K_prime(1990) ETR_K_prime(1991) ETR_K_prime(1992) ETR_K_prime(1993) ETR_L_prime(1984) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_L_prime(1988) ETR_L_prime(1989) ETR_L_prime(1990) ETR_L_prime(1991) ETR_L_prime(1992) ETR_L_prime(1993) Ksh_ndp(1984) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1987) Ksh_ndp(1988) Ksh_ndp(1989) Ksh_ndp(1990) Ksh_ndp(1991) Ksh_ndp(1992) Ksh_ndp(1993) Ksh_corp(1984) Ksh_corp(1985) Ksh_corp(1986) Ksh_corp(1987) Ksh_corp(1988) Ksh_corp(1989) Ksh_corp(1990) Ksh_corp(1991) Ksh_corp(1992) Ksh_corp(1993)"

		local a10="lg_eq(1985) lg_eq(1986) lg_eq(1987) lg_eq(1988) lg_eq(1989) lg_eq(1990) lg_eq(1991) lg_eq(1992) lg_eq(1993) lg_eq(1994) ETR_K_prime(1985) ETR_K_prime(1986) ETR_K_prime(1987) ETR_K_prime(1988) ETR_K_prime(1989) ETR_K_prime(1990) ETR_K_prime(1991) ETR_K_prime(1992) ETR_K_prime(1993) ETR_K_prime(1994) ETR_L_prime(1985) ETR_L_prime(1986) ETR_L_prime(1987) ETR_L_prime(1988) ETR_L_prime(1989) ETR_L_prime(1990) ETR_L_prime(1991) ETR_L_prime(1992) ETR_L_prime(1993) ETR_L_prime(1994) Ksh_ndp(1985) Ksh_ndp(1986) Ksh_ndp(1987) Ksh_ndp(1988) Ksh_ndp(1989) Ksh_ndp(1990) Ksh_ndp(1991) Ksh_ndp(1992) Ksh_ndp(1993) Ksh_ndp(1994) Ksh_corp(1985) Ksh_corp(1986) Ksh_corp(1987) Ksh_corp(1988) Ksh_corp(1989) Ksh_corp(1990) Ksh_corp(1991) Ksh_corp(1992) Ksh_corp(1993) Ksh_corp(1994)"

		dis "THIS IS `var' in `x'!!!"

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
