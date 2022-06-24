



*** 2. Synthetic Control part: 

			* With the sample of treated countries and the pool of possible control countries, we now construct the synthetic
			* control for each treated country. 
		
		local var="$var"

			xtset cid year
			levelsof country if treat==1, local(country)


			local i=1
			foreach x of local country {
				preserve	
				
				drop if treat==1 & country!="`x'"		// drop the other treated countries
				drop if treat==0 & `var'==.
				sum cid if country=="`x'"
				local id=`r(mean)'
				sum year_firstoutc if country=="`x'"
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

				rename year year_`i'_
				
				cd "$usedata/synthetic_ES_tempfiles"
				save sample`i', replace 

				local i=`i'+1
				restore

			}
			****
