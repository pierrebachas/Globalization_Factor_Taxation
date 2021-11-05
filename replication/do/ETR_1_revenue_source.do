
***************************************************************************************
*  Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman - December 2020								  
*  	program: ETR_1_revenue_source.do			
* 	Task: Harmonize all countries' raw tax revenue data sources										  
***************************************************************************************
	
		cd "${root}"
		
	*generate harmonized series by stitching across raw data sources
		*proceed roughly in order of country population (top 30 re-arranged as selected sample)
	
	*1. USA
		use data/revenue_raw, clear
		keep if country=="USA"				
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
			replace pct_4000 = . if year==2017
		ipolate pct_4000 year, gen(temp)
			replace pct_4000 = temp if year==2017
			drop temp
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/USA.dta, replace

		
	*2. MEX
		use data/revenue_raw, clear
		keep if country=="MEX"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(pct_`x'_HA)
				replace pct_`x' = pct_`x'_HA if inrange(year,1946,1979)
					replace source = "HA" if inrange(year,1946,1979)
				replace pct_`x' = pct_`x'_OECD if inrange(year,1980,2019)
					replace source = "OECD" if inrange(year,1980,2019)
				order pct_`x', before(gdp_HA)
			}
		*2000 series 1969-80
			replace pct_2000 = . if inrange(year,1970,1979)
			ipolate pct_2000 year if inrange(year,1969,1980), gen(tempvar_ipolate)
					order tempvar_ipolate, after(pct_2000)
				replace pct_2000 = tempvar_ipolate if pct_2000==.
					drop tempvar*
		*1000 series
			*1100 as a proportion of 1000, in 1979 and 2003
				gen ratio_1100 = pct_1100 / pct_1000
					order ratio_1100, after(pct_1000)
				gen ratio_1200 = pct_1200 / pct_1000
					order ratio_1200, after(ratio_1100)
				ipolate ratio_1100 year if inrange(year, 1979,2002), gen(tempvar_ratio_1100)
				ipolate ratio_1200 year if inrange(year, 1979,2002), gen(tempvar_ratio_1200)
					order tempvar_ratio*, after(ratio_1200)
				replace pct_1100 = tempvar_ratio_1100 * pct_1000 if inrange(year,1980,2001)
				replace pct_1200 = tempvar_ratio_1200 * pct_1000 if inrange(year,1980,2001)
				replace pct_1300 = pct_1000 - pct_1100 - pct_1200 if inrange(year,1980,2001)
			*1000 series in the 1960s, assume same ratio of 1100 and 1200 as had been the case in the 1970s
				egen avg_ratio_1100 = mean(ratio_1100) if inrange(year,1960,1979)
					replace ratio_1200 = . if inrange(year,1960,1969) //
				egen avg_ratio_1200 = mean(ratio_1200) if inrange(year,1960,1979)
				replace ratio_1100 = avg_ratio_1100 if inrange(year,1960,1969)
				replace ratio_1200 = avg_ratio_1200 if inrange(year,1960,1969)
					drop avg_ratio*				
				replace pct_1100 = ratio_1100 * pct_1000 if inrange(year,1960,1969)
				replace pct_1200 = ratio_1200 * pct_1000 if inrange(year,1960,1969)
				replace pct_1300 = . if inrange(year,1960,1969)
			drop ratio* tempvar*
		*ipolate 4000 series (NB from ~0 to =0 in 2017-18)
			ipolate pct_4000 year, gen(temp)
			replace pct_4000 = temp if inrange(year,1978,1979)
			drop temp
		*note the transition from HA to OECD: interpolate the last year of HA and first of OECD //reflects difficulty of labeling CIT vs. production tax
				replace pct_1300 = 0 if year==1978
				replace pct_5300 = 0 if year==1978
			foreach x in 1100 1200 1300 5100 5200 5300 {
				replace pct_`x' = . if inrange(year,1979,1980)
				ipolate pct_`x' year, gen(temp)
					replace pct_`x' = temp if inrange(year,1979,1980)
						drop temp
			}		
		*re-aggregate the 1000 and 5000
				egen tempvar = rowtotal(pct_1100 pct_1200 pct_1300), missing
			replace pct_1000 = tempvar
					drop tempvar
				egen tempvar = rowtotal(pct_5100 pct_5200 pct_5300), missing
			replace pct_5000 = tempvar
					drop tempvar
		*save
			replace stitch = 1 if inlist(year,1980)
			keep if year>=1965
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			save data/harmonized/MEX.dta, replace
					

	*3. FRA
		use data/revenue_raw, clear
		keep if country=="FRA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/FRA.dta, replace
		
		
	*4. GBR
		use data/revenue_raw, clear
		keep if country=="GBR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*1300 occasionally negative
			replace pct_1300 = 0 if pct_1300 < 0
			replace pct_1000 = pct_1100 + pct_1200 + pct_1300 if pct_1300==0
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/GBR.dta, replace
			

	*5. KOR
		use data/revenue_raw, clear	
		keep if country=="KOR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1972,2019) 
			replace pct_`x' = pct_`x'_HA if inrange(year,1959,1971)
			replace source = "OECD" if inrange(year,1972,2019)
			replace source = "HA" if inrange(year,1959,1971)
		}	
		*1968-71
		foreach x of local all_series {
				replace pct_`x' = . if inrange(year,1968,1971)
				replace pct_`x' = 0 if pct_`x'==. & year==1967
			ipolate pct_`x' year if inrange(year,1967,1972), gen(tempvar_ipolate_`x')
				replace pct_`x' = tempvar_ipolate_`x' if inrange(year,1967,1972)
				drop tempvar*
		}
		*re-aggregate the 1000 and 5000
			egen tempvar = rowtotal(pct_1100 pct_1200 pct_1300), missing
		replace pct_1000 = tempvar if inrange(year,1959,1971)
				drop tempvar
			egen tempvar = rowtotal(pct_5100 pct_5200 pct_5300), missing
		replace pct_5000 = tempvar if inrange(year,1959,1971)
				drop tempvar
		*2018 ICTD based on OECD ratio
		foreach x in 1000 1100 1200 2000 4000 5000 6000 {
			replace pct_`x' = ( pct_`x'_OECD[_n-1] / pct_`x'_ICTD[_n-1] ) * pct_`x'_ICTD if year==2018
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			replace interpolated = 1 if inrange(year,1968,1971)
			replace stitch = 1 if inlist(year,1972)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/KOR.dta, replace

			
	*6. COL		
		use data/revenue_raw, clear
		keep if country=="COL"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1990,2019)
			replace source = "OECD" if inrange(year,1990,2019)
			replace pct_`x' = pct_`x'_HA if inrange(year,1960,1989)
			replace source = "HA" if inrange(year,1960,1989)
		}	
		*1000 series 1960s-1980s, assume same ratio of 1100 and 1200 as is the case in 1990
			gen ratio_1100 = pct_1100 / pct_1000
				order ratio_1100, after(pct_1000)
			gen ratio_1200 = pct_1200 / pct_1000
				order ratio_1200, after(ratio_1100)
			*extrapolate ratio from 1990 backward
				replace ratio_1200 = . if year<1990
			egen avg_ratio_1100 = mean(ratio_1100) if inrange(year,1960,1990)
			egen avg_ratio_1200 = mean(ratio_1200) if inrange(year,1960,1990)
			*use that ratio for CIT/PIT split
			replace ratio_1100 = avg_ratio_1100 if inrange(year,1960,1989)
			replace ratio_1200 = avg_ratio_1200 if inrange(year,1960,1989)
				drop avg_ratio*	
			replace pct_1100 = ratio_1100 * pct_1000 if inrange(year,1960,1989)
			replace pct_1200 = ratio_1200 * pct_1000 if inrange(year,1960,1989)
			replace pct_1300 = . if inrange(year,1960,1989)
				cap drop ratio* 
				cap drop tempvar*
		*2000 series
			replace pct_2000 = pct_2000_RPC if year<1990
		*4000 series
			ipolate pct_4000 year, gen(temp)
				replace pct_4000 = temp if year<1990
				drop temp
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			replace stitch = 1 if inlist(year,1990)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/COL.dta, replace
			

	*7. DEU		
		use data/revenue_raw, clear
		keep if country=="DEU"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019)
		}	
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/DEU.dta, replace
				
					
	*8. ESP		
		use data/revenue_raw, clear
		keep if country=="ESP"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019)
		}	
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ESP.dta, replace
			
			
	*9. ITA		
		use data/revenue_raw, clear
		keep if country=="ITA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019)
		}
		*1300 occasionally negative
			replace pct_1300 = 0 if pct_1300 < 0
			replace pct_1000 = pct_1100 + pct_1200 + pct_1300 if pct_1300==0
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965 & pct_tax!=. //no 2019 data yet (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ITA.dta, replace
					
					
	*10. JPN		
		use data/revenue_raw, clear
		keep if country=="JPN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019)
		}
		replace pct_2000 = pct_2000[_n-1] if year==2018 & pct_2000==.
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/JPN.dta, replace
			
					
	*11. RUS		
		use data/revenue_raw, clear
		keep if country=="RUS"
		local all_series "1000	1100	1200	1300	2000	4000	5000		6000" //5100	5200	5300 7000
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
				replace pct_`x' = pct_`x'_NS if inrange(year,1994,1999) 
				replace source = "HA" if inrange(year,1994,1999) //scholarly sources (Keen et al)
				replace pct_`x' = pct_`x'_ICTD if inrange(year,2000,2019)
					replace source = "ICTD" if inrange(year,2000,2019)
			}	
		*see Chua (2003) and set property tax constant at 1%
			replace pct_4000 = .01
			replace pct_6000 = pct_6000 - pct_4000
		*1994-98 data from IMF (Keen et al) underestimates GDP volatility --> use 1998 values for 4-year interpolation
			//differences across sources in 'other taxes' during this period are also striking
			forval year = 1997 (-1) 1994 {
			foreach var of varlist pct_1000 - pct_6000 {
				replace `var' = `var'[_n+1] if year==`year'
			}
			}
		*/
		*save
			replace stitch = 1 if inlist(year,2000)
			replace interpolated = 1 if inrange(year,1994,1997)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1994 //first year of reliable post-Soviet data is 1994 (unreliable SNA until 1999, though)
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/RUS.dta, replace
		
		
	*12. ZAF		
		use data/revenue_raw, clear
		keep if country=="ZAF"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1990,2019)
			replace source = "OECD" if inrange(year,1990,2019)
			replace pct_`x' = pct_`x'_HA if inrange(year,1946,1989)
			replace source = "HA" if inrange(year,1946,1989)					
		}	
			*PIT vs CIT split for 1958, 68, 78, 88
				gen ratio_1100 = .
					order ratio_1100, after(pct_1100)
				gen ratio_1200 = .
					order ratio_1200, after(pct_1200)
				replace pct_1300 = pct_1000 if inrange(year,1945,1989)
				replace pct_1200 = . if inrange(year,1945,1989)
				replace pct_1100 = . if inrange(year,1945,1989)
				replace ratio_1100 = 0.393791991 if year == 1956
				replace ratio_1100 = 0.353761315 if year == 1961
				replace ratio_1100 = 0.370510556 if year == 1966
				replace ratio_1100 = 0.321478662 if year == 1971
				replace ratio_1100 = 0.407137699 if year == 1976
				replace ratio_1100 = 0.398852821 if year == 1981
				replace ratio_1100 = 0.51489696 if year == 1986
				replace ratio_1100 = pct_1100 / (pct_1100 + pct_1200) if year==1990
				replace ratio_1200 = 1 - ratio_1100 if inrange(year,1945,1990)
			*use 1956 ratio value back through 1946
				egen tempvar_1100 = mean(ratio_1100) if inrange(year,1946,1956)
				egen tempvar_1200 = mean(ratio_1200) if inrange(year,1946,1956)
				replace ratio_1100 = tempvar_1100 if inrange(year,1946,1956)
				replace ratio_1200 = tempvar_1200 if inrange(year,1946,1956)
				cap drop tempvar*
			*interpolate ratio 1956-90
				ipolate ratio_1100 year if inrange(year,1956,1990), gen(tempvar_1100)
				ipolate ratio_1200 year if inrange(year,1956,1990), gen(tempvar_1200)
				replace ratio_1100 = tempvar_1100 if inrange(year,1957,1989)
				replace ratio_1200 = tempvar_1200 if inrange(year,1957,1989)
			*use ratio to calculate the share of gdp for cit and pit, from 1946-89
				replace pct_1100 = ratio_1100 * pct_1000 if inrange(year,1946,1989)
				replace pct_1200 = ratio_1200 * pct_1000 if inrange(year,1946,1989)
				replace pct_1300 = . if inrange(year,1946,1989)
					cap drop ratio* tempvar*
			*4000 series
				ipolate pct_4000 year, gen(temp)
					replace pct_4000 = temp if inrange(year,1967,1972)
					drop temp
			*6000 series
				replace pct_6000 = 0 if pct_6000 < 0
		*save
			replace stitch = 1 if inlist(year,1990)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965 & pct_tax!=. //2019 is missing (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ZAF.dta, replace

					
	*13. CHN		
		use data/revenue_raw, clear
		keep if country=="CHN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000 7000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" //...="NS" for a version where some CIT 'business tax' is categorized as indirect tax (tax on production)--NB this stil does not address the conceptual issue of CIT on SOE revenue
		}	
		*note 4000<-->6000 in 2018-19
		forval year = 2018 / 2019 {
			replace pct_4000 = pct_6000 - pct_6000[_n-1] if year==`year'
			replace pct_6000 = pct_6000 - pct_4000 if year==`year'
		}
		*save
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			drop if year<1994	
			save data/harmonized/CHN.dta, replace
					
					
	*14. IND		
		use data/revenue_raw, clear
		keep if country=="IND"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA
			replace source = "HA" 
		}
		local list "2000	4000	6000	1200	1300	5100	5200	5300"
		foreach x of local list {
			ipolate pct_`x' year if inrange(year,1951,1956) | inrange(year,1956,1961) | inrange(year,1989,1991), gen(tempvar_`x')
			replace pct_`x' = tempvar_`x' if inrange(year,1952,1955) | inrange(year,1957,1960) | year==1990
			drop tempvar*
		}
		replace pct_1000 = /* pct_1100 + */ pct_1200 + pct_1300 if inrange(year,1952,1955) | inrange(year,1957,1960) | year==1990 
		replace pct_5000 = pct_5100 + pct_5200 if inrange(year,1952,1955) | inrange(year,1957,1960)  | year==1990
		*1300-->1100
		replace pct_1100 = pct_1300
		replace pct_1300 = .
		*save
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965 & pct_tax!=. //2018 is missing (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/IND.dta, replace		
					
					
	*15. IDN		
		use data/revenue_raw, clear	
		keep if country=="IDN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year,1952,1996)
			replace source = "HA" if inrange(year,1952,1996)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1997,2019)
			replace source = "OECD" if inrange(year,1997,2019)	
		}	
		*interpolate 1100 and 1200 proportions of the 1000 series 1985-2001)
			local 1000_disaggregates "1100 1200 1300"
				foreach x of local 1000_disaggregates {
					replace pct_`x' = . if inrange(year, 1985, 2001)
				gen ratio_`x' = pct_`x' / pct_1000 
						order ratio_`x', before (pct_2000)
				ipolate ratio_`x' year if inrange(year, 1984, 2002), gen(tempvar_`x')
						order tempvar_`x', after(ratio_`x')
					replace ratio_`x' = tempvar_`x' if ratio_`x'==.
				replace pct_`x' = ratio_`x' * pct_1000 if inrange(year, 1985, 2001)
			}
		*interpolate 1968-71 and 1994
			foreach x in 1000 1100 1200 1300 2000 4000 5000 5100 5200 5300 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inrange(year,1968,1971) | year==1994
			}
		*4000 series
			ipolate pct_4000 year, gen(temp)
					replace pct_4000 = temp if inrange(year,1972,1984)
					drop temp
		*save
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			replace stitch = 1 if year==1997
			replace interpolated = 1 if inrange(year,1968,1971) | year==1994
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/IDN.dta, replace

		
	*16. BRA		
		use data/revenue_raw, clear	
		keep if country=="BRA"
		local all_series "1000	1100	1200	1300	2000	4000	5000		6000" //5100	5200	5300 7000
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(pct_`x'_HA)
			replace pct_`x' = pct_`x'_NS if inrange(year,1960,2019)
			replace source = "HA" if inrange(year,1960,1989) //historical archive data
			replace source = "CIAT-IDB" if inrange(year,1990,2019)					
		}
		*save
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965 & country=="BRA"
			replace stitch = 1 if year==1990
			replace interpolated = 1 if inrange(year,1968,1975) //indirect taxes are known, direct are interpolated
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BRA.dta, replace
				

	*17. PAK
		use data/revenue_raw, clear
		keep if country=="PAK"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA
			replace source = "HA"
		}	
		*1973-80 IMF has PIT/CIT split, and then again we observe this from 1994-2004: use HA 1953-1979, interpolate within 1000 series 1984-94, extrapolate pre-1953 and post-2004
			local 1000_disaggregates "1100 1200 1300"
				foreach x of local 1000_disaggregates {
					gen ratio_`x' = pct_`x'_IMF / pct_1000_IMF if inrange(year,1994,2004) //we trust IMF ratios 1994-2004
						order ratio_`x', before (pct_2000)
				}
			replace	ratio_1100 = .1441641 if year>2004 //we assume this 2004 IMF ratio is constant 2004-14
			replace ratio_1200 = .8169174 if year>2004
			replace ratio_1300 = .0389186 if year>2004
			replace ratio_1100 = 0 if inrange(year,1949,1979) //we know nothing of a PIT in this time period
			replace ratio_1200=0.279596388078789 if year==1949
			replace ratio_1200=0.279596388078789 if year==1950
			replace ratio_1200=0.279596388078789 if year==1951
			replace ratio_1200=0.279596388078789 if year==1952
			replace ratio_1200=0.279596388078789 if year==1953
			replace ratio_1200=0.228549734244495 if year==1959
			replace ratio_1200=0.263990528782622 if year==1963
			replace ratio_1200=0.203028683053111 if year==1967
			replace ratio_1200=0.231065818129049 if year==1972
			replace ratio_1200=0.261616244045351 if year==1974
			replace ratio_1200=0.576198609457957 if year==1978
			replace ratio_1200=0.594115240964644 if year==1979
			replace ratio_1300 = 	0.720403611921211 if year==1949
			replace ratio_1300 = 	0.720403611921211 if year==1950
			replace ratio_1300 = 	0.720403611921211 if year==1951
			replace ratio_1300 = 	0.720403611921211 if year==1952
			replace ratio_1300 = 	0.720403611921211 if year==1953
			replace ratio_1300 = 	0.771450265755505 if year==1959
			replace ratio_1300 = 	0.736009471217378 if year==1963
			replace ratio_1300 = 	0.796971316946889 if year==1967
			replace ratio_1300 = 	0.768934181870951 if year==1972
			replace ratio_1300 = 	0.738383755954649 if year==1974
			replace ratio_1300 = 	0.423801390542043 if year==1978
			replace ratio_1300 = 	0.405884759035356 if year==1979
			local 1000_disaggregates "1100 1200 1300"
			foreach x of local 1000_disaggregates {
				ipolate ratio_`x' year if inrange(year, 1949, 1994), gen(tempvar_`x')
					order tempvar_`x', after(ratio_`x')
					replace ratio_`x' = tempvar_`x' if ratio_`x'==.
				replace pct_`x' = ratio_`x' * pct_1000 //for all years
			}
					cap drop ratio* tempvar*	
		*1300-->1100
			replace pct_1100 = pct_1100 + pct_1300
			replace pct_1300 = .
		*extend with growth rates of total tax revenue, per https://www.sbp.org.pk/reports/annual/arFY18/Stats/Eng/Chapter-4.pdf (see also 2019 and 2020 reports)
			forval year = 2016/2018 {
				set obs `=_N+1'
				replace year=`year' if _n==_N
				replace country="PAK"
				replace source="HA"
			}
		*use overall growth rates 
			foreach x in 1000 1100 1200 1300 2000 4000 5000 6000 {
				replace pct_`x' = pct_`x'[_n-1] + pct_`x'[_n-1] * -0.013793103 if year==2015
				replace pct_`x' = pct_`x'[_n-1] + pct_`x'[_n-1] * 0.048951049 if year==2016
				replace pct_`x' = pct_`x'[_n-1] + pct_`x'[_n-1] * 0.033333333 if year==2017
				replace pct_`x' = pct_`x'[_n-1] + pct_`x'[_n-1] * -0.019354839 if year==2018
			}
		*save																	
			replace interpolated = 1 if inrange(year,2015,2018) //we know the total tax revenue, interpolate the splits
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/PAK.dta, replace
	
					
	*18. BGD		
		use data/revenue_raw, clear	
		keep if country=="BGD"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year,1976,2019) 
			replace source = "HA" if inrange(year,1976,2019) 
			replace pct_`x' = pct_`x'_ICTD if year>2000 
			replace source = "ICTD" if year>2000 										
		}	
		*2000 series
			replace pct_2000 = pct_2000_RPC
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*1000 series in 2017-18
			forval year = 2017 / 2018 {
				foreach x in 1100 1200 {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_1000[_n-1] ) * pct_1000 if year==`year'
					replace pct_1300 = . if year==`year'
				}
			}
		*interpolate 1980-81 and 1200 in 1982
			foreach x in 1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000	 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inrange(year,1980,1982) & pct_`x'==.
			}					
		*save
			replace stitch = 1 if inlist(year,2001)
			replace interpolated = 1 if inrange(year,1980,1981)
			drop if year<1976 //1976 is the first post-independence year in which we have reliable data
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BGD.dta, replace	
					
					
	*19. NGA		
		use data/revenue_raw, clear
		keep if country=="NGA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000" 
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year,1960,1991) 
			replace source = "HA" if inrange(year,1960,1991)
			replace pct_`x' = pct_`x'_ICTD if inrange(year,1992,2007)  
			replace source = "ICTD" if inrange(year,1992,2009)	
			replace pct_`x' = pct_`x'_OECD if year>2009
			replace source = "OECD" if year>2009
		}
		*1000 series late 1980s
			local 1000_disaggregates "1100 1200 1300"
			foreach x of local 1000_disaggregates {
				replace pct_`x' = . if inrange(year, 1987, 1991)
				gen ratio_`x' = pct_`x' / pct_1000 if year==1986 | year==1992
				ipolate ratio_`x' year if inrange(year, 1986, 1992), gen(tempvar_`x')
					replace ratio_`x' = tempvar_`x' if ratio_`x'==.
				replace pct_`x' = ratio_`x' * pct_1000 if inrange(year, 1987, 1991)
			}
					cap drop ratio* tempvar*
		*2000 series
			replace pct_2000 = pct_2000_RPC if pct_2000==.
		*1300
			ipolate pct_1100 year, gen(temp)
				replace pct_1100 = temp if inrange(year,1971,1972)
					drop temp
				replace pct_1300 = pct_1300 - pct_1100 if inrange(year,1971,1972)
			replace pct_1200 = pct_1200 + pct_1300 if inrange(year,1970,2007)
			replace pct_1300 = . if inrange(year,1970,2007)
		*2008-09
			foreach x in 1100 1200 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
					replace pct_`x' = temp_`x' if inrange(year,2008,2009)
						drop temp_`x'
			}
				replace pct_1000 = pct_1100 + pct_1200 if inrange(year,2008,2009)
		*save
			replace stitch = 1 if inlist(year,1992,2010)
			replace interpolated = 1 if inlist(year,2008,2009)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/NGA.dta, replace

		
	*20. ETH		
		use data/revenue_raw, clear	
		keep if country=="ETH"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year, 1961, 2019)
			replace source = "HA" if inrange(year,1961,2019)
			replace pct_`x' = pct_`x'_ICTD if year>1992
			replace source = "ICTD" if year>1992				
		}	
		*1989 and 2005
			foreach x in 1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inlist(year,1989,2005)
			}
		*1000 series pre-75
			replace pct_1100 = . if year<1975
			replace pct_1200 = . if year<1975
			replace pct_1300 = . if year<1975
			foreach x in 1100 1200 {
				gen _`x'_1000 = pct_`x' / pct_1000
					forval year = 1974 (-1) 1961 {
						replace _`x'_1000 = _`x'_1000[_n+1] if year==`year'
					}
				replace pct_`x' = _`x'_1000 * pct_1000 if year<1975
			}
		*extend 1000 series split forward from 2007
			forval year = 2008 / 2019 {
				foreach x in 1100 1200 1300 {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_1000[_n-1] ) * pct_1000 if year==`year'
				}
			}
		*2000 series from RPC
			replace pct_2000 = pct_2000_RPC if year>1960
			forval year=2014/2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*4000 series from HA	after 2007, extrapolate forward from 2012 (2013 thru 2018)
			replace pct_4000 = pct_4000_HA if year>2007
			forval year=2013/2019 {
				replace pct_4000 = pct_4000[_n-1] if year==`year'
			}
		*save
			replace stitch = 1 if inlist(year,1993)
			replace interpolated = 1 if inlist(year,1989,2005)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ETH.dta, replace		
					

	*21. EGY		
		use data/revenue_raw, clear
		keep if country=="EGY"
		local all_series "1000	1100	1200	1300	2000	4000	5000		6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year < 1990 //inrange(year,1952,1960) | inrange(year,1975,1983) 
			replace source = "HA" if year<1990 // inrange(year,1952,1960) | inrange(year,1975,1983) 
			replace pct_`x' = pct_`x'_ICTD if inrange(year,1990,2001) 
			replace source = "ICTD" if inrange(year,1990,2001)
			replace pct_`x' = pct_`x'_OECD if inrange(year,2002,2019)  
			replace source = "OECD" if inrange(year,2002,2019)		
		}	
		*1000 series
			local 1000_disaggregates "1100 1200 1300"
				foreach x of local 1000_disaggregates {
					replace pct_`x' = . if year==1998
				gen ratio_`x' = pct_`x' / pct_1000 if year==1997 | year==1999
						order ratio_`x', before (pct_2000)
				ipolate ratio_`x' year if inrange(year, 1997, 1999), gen(tempvar_`x')
						order tempvar_`x', after(ratio_`x')
					replace ratio_`x' = tempvar_`x' if ratio_`x'==.
				replace pct_`x' = ratio_`x' * pct_1000 if year==1998
			}
					cap drop ratio* tempvar*	
		*2000 series
			replace pct_2000 = pct_2000_NS if year < 2002
		*interpolate 1965-69 and 70-71 and 73-74	
			foreach x in 1000 /*1100 1200 1300 2000*/ 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
					order temp_`x', after(pct_`x')
					format %9.2fc temp* pct*
				replace pct_`x' = temp_`x' if inrange(year,1965,1974) & !inlist(year,1969,1972)
					drop temp*
			}	
			foreach x in 1100 1200 {
				gen _`x'_1000 = pct_`x' / pct_1000
				ipolate _`x'_1000 year, gen(temp_`x')
				replace _`x'_1000 = temp_`x' if inrange(year,1965,1974) & year!=1969
					order _`x'_1000 temp_`x', after(pct_`x')
					format %9.2fc _* pct* temp*
				replace pct_`x' = _`x'_1000 * pct_1000 if inrange(year,1965,1974) & year!=1969
					drop _`x'* temp*
			}
		*save
			replace stitch = 1 if inlist(year,1987,2002)
			replace interpolated = 1 if inrange(year,1965,1968) | inrange(year,1970,1971) | inrange(year,1973,1974) //pre-68 is interpolation not extrapolation (see pre-1960 data)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/EGY.dta, replace	
					
					
	*22. COD		
		use data/revenue_raw, clear
		keep if country=="COD"
		local all_series "subtotal 1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			cap ren win_`x'* win_`x'_*
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year,1968,1990) 
			replace source = "HA" if inrange(year,1968,1990)
			replace pct_`x' = pct_`x'_ICTD if inrange(year,1991,2019)  
			replace source = "ICTD" if inrange(year,1991,2019)
		}	
		*subtotal from ICTD, and interpolate from HA to ICTD 1978-79 (inside from 77 to 80)					
			replace pct_subtotal = pct_subtotal_ICTD if inrange(year,1980,1990) & pct_subtotal==.
			ipolate pct_subtotal year if inrange(year,1977,1980), gen(tempvar)
				replace pct_subtotal = tempvar if inrange(year,1978,1979)
					drop tempvar
			*within-ratios --> pct of GDP levels
				*interpolate within proportions from 1990 (HA) to 1996 (ICTD; source: IMF Article IV) (skip 91-95)
					*skipping over hyperflation episode
			local list "1000	2000	4000	5000	6000	1100	1200	1300	5100	5200	5300"
			foreach x of local list {
				replace pct_`x' = win_`x'_HA * pct_subtotal if inrange(year,1978,1990)
				replace pct_`x' = . if inrange(year,1991,1995)
				*replace win_`x' = . if inrange(year,1991,1995)
				gen win_`x' = win_`x'_HA if year==1990
				replace win_`x' = win_`x'_ICTD if year==1996
				ipolate win_`x' year if inrange(year,1990,1996), gen(tempvar_`x')
				replace win_`x' = tempvar_`x' if inrange(year,1991,1995)
				replace pct_`x' = win_`x' * pct_subtotal if inrange(year,1991,1995)
				drop tempvar*
			}
		*1000 series in 1981 & 1982, impute from 1980 to 1983 the proportions					
			local 1000_disaggregates "1100 1200 1300"
				foreach x of local 1000_disaggregates {
					replace pct_`x' = . if year==1981 | year==1982
				gen ratio_`x' = pct_`x' / pct_1000 ==1984 | year==2002
						order ratio_`x', before (pct_2000)
				ipolate ratio_`x' year if inrange(year, 1980, 1983), gen(tempvar_`x')
						order tempvar_`x', after(ratio_`x')
					replace ratio_`x' = tempvar_`x' if ratio_`x'==.
				replace pct_`x' = ratio_`x' * pct_1000 if year==1981 | year==1982
				drop tempvar*
			}
		*interpolate 1973
			foreach x in 1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000 { 
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if year==1973
			}
		*replace 1200 series 2001-05 and 2008-13 (ICTD resource revenue does not add up within 1000 series-->exclude from CIT)
			replace pct_1000 = . if inrange(year,2001,2013)
				replace pct_1200 = 0.0050806984680 if year==2001
				replace pct_1200 = 0.0055239532683 if year==2002
				replace pct_1200 = 0.0029191664942 if year==2003
				replace pct_1200 = 0.0045425029408 if year==2004
				replace pct_1200 = 0.0053823774507 if year==2005
				replace pct_1200 = 0.0128171230771 if year==2008
				replace pct_1200 = 0.0103572035444 if year==2009
				replace pct_1200 = 0.0127246598401 if year==2010
				replace pct_1200 = 0.0112326684336 if year==2011
				replace pct_1200 = 0.0092443945031 if year==2012
				replace pct_1200 = 0.0099054027132 if year==2013
			replace pct_1000 = pct_1100 + pct_1200 if inrange(year,2001,2013) //NB pct_1300 = 0 in these years
		*save
			replace interpolated = 1 if inrange(year,1991,1995) | year==1973
			replace stitch = 1 if inlist(year,1991)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1968 //first year post-independence with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/COD.dta, replace
					
					
	*23. TZA		
		use data/revenue_raw, clear
		keep if country=="TZA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year,1956,1990)
			replace source = "HA" if inrange(year,1956,1995)
			replace pct_`x' = pct_`x'_NS if inrange(year,1996,2019)
			replace source = "NS" if inrange(year,1996,2019)			
		}							
		*extend via ICTD post-2015
			forval year=2016/2019 {
				foreach x in 1100 1200 1300 /*2000 4000*/ 5000 6000 {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_`x'_ICTD[_n-1] ) * pct_`x'_ICTD if year==`year'
				}
			}
		*for 1991-95, interpolate disaggregates from both sides and then fill in the aggregates
			local list "2000	4000	6000	1100	1200	1300	5100	5200	5300" // "1000 5000"
			foreach x of local list {
				ipolate pct_`x' year if inrange(year,1990,1996), gen(tempvar_`x')
				replace pct_`x' = tempvar_`x' if inrange(year,1991,1995)
				drop tempvar*
			}
			replace pct_1000 = pct_1100 + pct_1200 + pct_1300 if inrange(year,1991,1995) | year>2015
			replace pct_5000 = pct_5100 + pct_5200 if inrange(year,1991,1995)
		*for 1956-71, interpolate the 1300 series as it was from 1974-76
				*see raw data source calculations of these percentages
			replace pct_1100 = pct_1100 + (pct_1300 * 0.565962196) if inrange(year,1956,1971)
			replace pct_1200 = (pct_1300 * 0.391793851) if inrange(year,1956,1971)
			replace pct_1300 = (pct_1300 * 0.042243952) if inrange(year,1956,1971)
		*for 1973, interpolate entire 1000 series as it was from 1974
			local 1000_disaggregates "1100 1200 1300"
				foreach x of local 1000_disaggregates {
					gen ratio_`x' = pct_`x' / pct_1000 if year==1974
						order ratio_`x', before (pct_2000)
						egen tempvar_`x' = max(ratio_`x') if inrange(year,1973,1974)
							order tempvar_`x', after(ratio_`x')
						replace ratio_`x' = tempvar_`x' if year==1973
					replace pct_`x' = ratio_`x' * pct_1000 if year==1973
						drop ratio* tempvar*
				}
		*interpolate 1972 1977-78 and 1979
			foreach x in 1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inlist(year,1972,1977,1978,1979)
			}	
		*2000 series and 4000 series from ICTD	
			foreach x in 2000 4000 {
				replace pct_`x' = pct_`x'_ICTD if year>1990
				ipolate pct_`x' year, gen(t_`x')
					replace pct_`x' = t_`x' if year>1990 & pct_`x'==.
						drop t_`x'
			}
		*save
			replace stitch = 1 if inlist(year,1996)
			replace interpolated = 1 if inrange(year,1991,1995) | inlist(year,1972,1977,1978)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1970 //first post-independence year with data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/TZA.dta, replace
					
					
	*24. KEN		
		use data/revenue_raw, clear
		keep if country=="KEN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year,1958,2019)
			replace source = "HA" if inrange(year,1958,2019)
			replace pct_`x' = pct_`x'_OECD if year>2000
			replace source = "OECD" if year>2000
		}	
		*put 1967-73 PAYE ratio for 1300 series
			replace pct_1100 = (pct_1300 *	0.217791411	) if year == 	1967 
			replace pct_1200 = (pct_1300 *	0.782208589	) if year == 	1967					
			replace pct_1100 = (pct_1100 + pct_1300 *	0.218332503	) if year == 	1968
			replace pct_1200 = (pct_1300 *	0.781667497	) if year == 	1968					
			replace pct_1100 = (pct_1100 + pct_1300 *	0.245424621	) if year == 	1969
			replace pct_1200 = (pct_1300 *	0.754575379	) if year == 	1969				
			replace pct_1100 = (pct_1100 + pct_1300 *	0.219713249	) if year == 	1970
			replace pct_1200 = (pct_1300 *	0.780286751	) if year == 	1970						
			replace pct_1100 = (pct_1100 + pct_1300 *	0.235084141	) if year == 	1971
			replace pct_1200 = (pct_1300 *	0.764915859	) if year == 	1971
			replace pct_1100 = (pct_1100 + pct_1300 *	0.317190079	) if year == 	1972
			replace pct_1200 = (pct_1300 *	0.682809921	) if year == 	1972		
			replace pct_1100 = (pct_1100 + pct_1300 *	0.318008585	) if year == 	1973
			replace pct_1200 = (pct_1300 *	0.681991415	) if year == 	1973
		*assume all 1300 is surtax prior to 1966
			replace pct_1200 = pct_1300 if year<1967
			replace pct_1300=. if year<1974
		*fix 1965-66
			ipolate pct_1100 year, gen(tmp)
				replace pct_1100 = tmp if inrange(year,1965,1966)
					drop tmp
				replace pct_1000 = pct_1100 + pct_1200 if inrange(year,1965,1966)
		*fix 1000 series 1974-2001
		*fix OECD 1300: it is withholding tax 2001-2014 until 2015 when it includes capital gains tax (see OECD data sheets)
			replace pct_1100 = pct_1100 + pct_1300 if inrange(year,2001,2014)
			replace pct_1100 = pct_1100 +    0.9931863   * pct_1300 if year==2015
			replace pct_1200 = pct_1200 +  (1 - 0.9931863) * pct_1300 if year==2015
			replace pct_1100 = pct_1100 +      0.9559477 * pct_1300 if year==2016
			replace pct_1200 = pct_1200 +  (1 - 0.9559477 ) * pct_1300 if year==2016		
			replace pct_1100 = pct_1100 +      0.9756735 * pct_1300 if year==2017
			replace pct_1200 = pct_1200 +  (1 - 0.9756735 ) * pct_1300 if year==2017		
			replace pct_1100 = pct_1100 +    0.8580971   * pct_1300 if year==2018
			replace pct_1200 = pct_1200 +  (1 - 0.8580971 ) * pct_1300 if year==2018
			replace pct_1300 = . if year>2000	
			foreach x in 1100 1200 1300 {
					replace pct_`x' = . if inrange(year,1974,2000)
				gen ratio_`x' = pct_`x' / pct_1000 if year==1973 | year==2001
					ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = ratio_`x'_temp * pct_1000 if inrange(year,1974,2000)
					drop ratio_`x'*
			}
		*2000 series
			replace pct_2000 = pct_2000_UN if inrange(year,1996,2000)
			replace pct_2000 = pct_2000_RPC if year<1996
		*save
			replace stitch = 1 if inlist(year,2001)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/KEN.dta, replace

						
	*25. TUR		
		use data/revenue_raw, clear
		keep if country=="TUR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
			foreach x of local all_series {
					gen pct_`x' = .
					order pct_`x', before(gdp_HA)
				replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
				replace source = "OECD" if inrange(year,1965,2019) 
			}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/TUR.dta, replace
									
									
	*26. IRN		
		use data/revenue_raw, clear
		keep if country=="IRN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000 	7000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA 
			replace source = "HA" 
		}
		*fix 2010-12 5000 series
			replace pct_5100 = pct_5300 if pct_5100==.
			replace pct_5300 = .
		*fix 1969-71 6000 series-->7000 (travel fee?)
			replace pct_7000 = pct_7000 + pct_6000 if pct_6000!=.
			replace pct_6000 = .
		*interpolate missing years
			local list "2000	4000	6000	1100	1200	1300	5100	5200	5300" // "1000 5000"
			foreach x of local list {
				ipolate pct_`x' year if inrange(year,1969,2012), gen(tempvar_`x')
				replace pct_`x' = tempvar_`x' if inrange(year,1969,2014) & pct_`x'==.
				drop tempvar*
			}
		*replace 2000 series with UN value 
			replace pct_2000 = pct_2000_UN // if inrange(year,1996,2019)
			replace pct_2000 = pct_2000_RPC if year==1969
		*update 2013-16 via ICTD
			forval year = 2013 / 2018 {
				foreach x in 1000 4000 5000 {
					replace pct_`x' = (pct_`x'[_n-1] / pct_`x'_ICTD[_n-1]) * pct_`x'_ICTD if year==`year'
				}
			*carry forward 1000 series split
				foreach x in 1100 1200 {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_1000[_n-1] ) * pct_1000 if year==`year'
				}
			}
		*subtotals
			replace pct_1000 = pct_1100 + pct_1200 + pct_1300 if inrange(year,1969,1971)
			replace pct_1000 = pct_1100 + pct_1200 if year>1971
			replace pct_5000 = pct_5100 + pct_5200 if year<2013 //don't do anything with 5100 5200 5300 in later ICTD 
		*save
			replace interpolated = 1 if inlist(year,1972,1973,1975,1976,1979,1980,1982,1983,1985,1987,1988,1989,1990,1992,1993,1994,1996,1997,1999,2000,2002,2003,2008,2009)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1969 //first year with data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/IRN.dta, replace
					
									
	*27. VNM		
		use data/revenue_raw, clear
		keep if country=="VNM"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_IMF if inrange(year,1994,2013) //only IMF for now--but do we trust GFS??
			replace source = "IMF" if inrange(year,1994,2019)	
		}	
		*use IMF and ICTD in 2013 to bring forward through 2018 via ICTD						
			forval year=2014/2019 {
				foreach x in 1000 1100 1200 1300 /*2000 4000*/ 5000 /*6000*/ {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_`x'_ICTD[_n-1] ) * pct_`x'_ICTD if year==`year'
				}
			}
			replace pct_1000 = pct_1100 + pct_1200 + pct_1300 if year>2013
		*bring forward IMF 4000
			forval year = 2014/2019 {
				replace pct_4000 = pct_4000[_n-1] if year==`year'
			}
		*save
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1994 //first year of post-Soviet era with reliable data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/VNM.dta, replace
					
									
	*28. PHL		
		use data/revenue_raw, clear
		keep if country=="PHL"
		local all_series "subtotal subtotal_1245 subtotal_14 1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year,1959,1993) 
			replace source = "HA" if inrange(year,1959,1993)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1994,2019)  
			replace source = "OECD" if inrange(year,1994,2019)				
		}	
		*2000 series
			replace pct_2000 = pct_2000_UN if year<1994
		*use ratio of 1100 1200 1300 to interpolate from 1977 to 1999
			local 1000_disaggregates "1100 1200 1300"
				foreach x of local 1000_disaggregates {
					replace pct_`x' = . if inrange(year,1978,1998)
				gen ratio_`x' = pct_`x' / pct_1000 if inrange(year,1977,1999)
						order ratio_`x', before (pct_2000)
				ipolate ratio_`x' year if inrange(year,1977,1999), gen(tempvar_`x') //epolate
						order tempvar_`x', after(ratio_`x')
					replace ratio_`x' = tempvar_`x' if ratio_`x'==.
				replace pct_`x' = ratio_`x' * pct_1000 if inrange(year,1978,1998)
			}
					cap drop ratio* tempvar*	
		*save
			replace stitch = 1 if inlist(year,1994)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/PHL.dta, replace

			
	*29. THA		
		use data/revenue_raw, clear
		keep if country=="THA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year,1950,2004) 
			replace source = "HA" if inrange(year,1950,2004)
			replace pct_`x' = pct_`x'_OECD if inrange(year,2005,2019)
			replace source = "OECD" if inrange(year,2005,2019)		
		}	
		*interpolate 1971-2004 in HA (even though we will eventually use OECD from 2000-)
			*replace pct_2000 = 0 if year==1971 //it is non-zero in 1980 with ICTD
				local list "2000	4000	6000	1100	1200	1300	5100	5200	5300" // "1000 5000"
				foreach x of local list {
					ipolate pct_`x' year if inrange(year,1971,2004), gen(tempvar_`x')
					replace pct_`x' = tempvar_`x' if inrange(year,1972,2003) & pct_`x'==.
					drop tempvar*
				}
		*re-do all subtotals of when data adjusted [ie, inrange(year,1972,2003)]
			replace pct_1000 = pct_1100 + pct_1200  if (inrange(year,1972,1985) | inrange(year,1996,2003)) & pct_1000==. 
			replace pct_1000 = pct_1100 + pct_1200 + pct_1300  if inrange(year,1986,1995) & pct_1000==.
			replace pct_5000 = pct_5100 + pct_5200 if inrange(year,1972,2003) & pct_5000==.
		*finally now that we have interpolated HA up through 1999, bring back OECD for 2000-04
			local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
			foreach x of local all_series {
				replace pct_`x' = pct_`x'_OECD if inrange(year,2000,2004)
				replace source = "OECD" if inrange(year,2000,2004)		
			}
		*2000 series pre-OECD //per US SSA, Thai soc.sec. begins 1990, but UN has data from 1980, so we use that (miniscule magnitude in any case)
			replace pct_2000 = pct_2000_UN if year<2000
				ipolate pct_2000 year, gen(temp)
				replace pct_2000 = temp if inrange(year,1997,1999)
				drop temp				
		*4000 series pre-OECD
			replace pct_4000 = pct_4000_IMF if year<2000
			forval year = 1971 (-1) 1965 {
				replace pct_4000 = pct_4000[_n+1] if year==`year'
			}
		*save
			replace stitch = 1 if inlist(year,2000)
			replace interpolated = 1 if inrange(year,1972,1999) & !inlist(year,1976,1981,1986,1989,1992,1995,2000,2002)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/THA.dta, replace
		
										
	*30. MMR		
		use data/revenue_raw, clear
		keep if country=="MMR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if inrange(year,1951,1967) 
			replace source = "HA" //if inrange(year,1951,1967)
			replace pct_`x' = pct_`x'_IMF if inrange(year,1973,2003)
			replace source = "IMF" if inrange(year,1973,2003) //ie, until first year of NS
			replace pct_`x' = pct_`x'_NS if inrange(year,2004,2019)  
			replace source = "HA" if inrange(year,2004,2019)				
		}
			replace pct_1000 = pct_1100 + pct_1200 if year>2003
			replace pct_5100 = .  if year>2003
		*interpolate the sums from 1968-72
			replace pct_5300 = 0 if year==1973
			local list "2000	4000	6000	1100	1200	1300	5100	5200	5300" // "1000 5000"
			foreach x of local list {
				ipolate pct_`x' year if inrange(year,1967,1973), gen(tempvar_`x')
				replace pct_`x' = tempvar_`x' if inrange(year,1968,1972)
				drop tempvar*
			}
		*re-do all subtotals of when data adjusted
			replace pct_6000 = 0 if pct_6000==.
			replace pct_1000 = /* pct_1100 + pct_1200 + */ pct_1300 if inrange(year,1968,1972)  //no split (yet)
			replace pct_5000 = pct_5100 + pct_5200 + pct_5300 if inrange(year,1968,1972)  // no 5300 on HA side, yes on IMF...
		*impute/extrapolate the 2004 split of PIT - CIT all the way back to 1976, 
		*use ratio of 1100 1200 1300 to extrapolate backward from 2004 to 1973
			local 1000_disaggregates "1100 1200 1300"
				foreach x of local 1000_disaggregates {
				gen ratio_`x' = pct_`x' / pct_1000 if inrange(year,2004,2010)
						order ratio_`x', before (pct_2000)
				
				egen mean_ratio_`x' = mean(ratio_`x')
						order mean_ratio_`x', after(ratio_`x')
					replace ratio_`x' = mean_ratio_`x' if inrange(year,1976,2003)
					
				replace pct_`x' = ratio_`x' * pct_1000 if inrange(year,1976,2003)
			}
				cap drop ratio* mean*
		*see various sources, including 2019 national attempt to match GFS
			*we cannot observe the historical PIT/CIT split
			replace pct_1100=.
			replace pct_1200=.
			replace pct_1300=pct_1000
		*save
			replace stitch = 1 if inlist(year,1973,2004)
			replace interpolated = 1 if inrange(year,1968,1972)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/MMR.dta, replace
		
		
	*31. UKR	
		use data/revenue_raw, clear
		keep if country=="UKR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = . 
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_ICTD 
			replace source = "ICTD"
		}	
		*save
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1993 //post-Soviet (1992 has large soc.sec. series, perhaps spurious)
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/UKR.dta, replace
	
	
	*32. ARG
		use data/revenue_raw, clear	
		keep if country=="ARG"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
						gen pct_`x' = .  
							order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year<1990
			replace source = "HA" if year<1990	//1990 is first OECD year, use HA (Alvaredo) data before then (from 1950, not 1932)			
			replace pct_`x' = pct_`x'_OECD if year>1989 
			replace source = "OECD" if year>1989 
		}
		*use ICTD for 2000 series from 1985-89 because it is perfect match for OECD in 90-91. Matches HA in 86-87,
			ipolate pct_2000_ICTD year, gen(temp)
			replace pct_2000_ICTD = temp if year==1989
				cap drop temp
			replace pct_2000 = pct_2000_ICTD if inrange(year,1985,1989)			
		*interpolate 1100 vs 1200 for 1961-69 and 1974-89 when these are not given
				gen _1200_1000 = pct_1200 / pct_1000
						order _1200_1000, after(pct_1200)
						replace _1200_1000 = . if !inlist(year,1960,1970,1973,1990)
					ipolate _1200_1000 year, gen(temp)
							order temp, after (_1200_1000)
				replace pct_1200 = pct_1000 * temp if inrange(year,1960,1970) | inrange(year,1973,1990)
		*after interpolating 1200, assign everything else (ie incl 1300) to 1100
			replace pct_1100 = pct_1000 - pct_1200 if inrange(year,1960,1970) | inrange(year,1973,1990)
				drop _* temp	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ARG.dta, replace
				
			
	*33. UGA
		use data/revenue_raw, clear	
		keep if country=="UGA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year<1991
			replace source = "HA" if year<1992
			replace pct_`x' = pct_`x'_OECD if year>1991 
			replace source = "OECD" if year>1991
		}	
			replace pct_1200=0 if year==1990
			replace pct_5300=0 if year==1990
			replace pct_1300=0 if year==1992
		*now interpolate
			local all_series "1100	1200	1300	2000	4000	5100	5200	5300	6000"
			foreach x of local all_series {								
				ipolate pct_`x' year if inrange(year,1983,1992), gen(tempvar_`x')
					order tempvar_`x', after(pct_`x')
				replace pct_`x' = tempvar_`x' if pct_`x'==. & inlist(year,1984,1991)
					drop tempvar*
			}		
			replace pct_1000 = pct_1100 + pct_1300 if year==1984 //in order not to skip this year later...
		*use IMF hist for 1000 series 1972-86
			replace pct_1100 = . if year<1990
			replace pct_1200 = . if year<1990
				replace pct_1100 = pct_1100 + pct_1300 if inrange(year,1990,1991)
			replace pct_1300 = . if year<1990
			replace pct_1300 = 0 if inrange(year,1990,1991)
				gen temp_1100 = .
			replace temp_1100 = 0.22189349112426 if inrange(year,1963,1972) //extend 1972 value back to 1963
			replace temp_1100 = 0.340248962655602 if year==1973
			replace temp_1100 = 0.433155080213904 if year==1974
			replace temp_1100 = 0.422222222222222 if year==1975
			replace temp_1100 = 0.476439790575916 if year==1976
			replace temp_1100 = 0.0392857142857143 if year==1977
			replace temp_1100 = 0.228028503562945 if year==1978
			replace temp_1100 = 0.0369127516778524 if year==1979
			replace temp_1100 = 0.24 if year==1980
			replace temp_1100 = 0.293361884368308 if year==1981
			replace temp_1100 = 0.229111697449428 if year==1982
			replace temp_1100 = 0.104217356042174 if year==1983
			replace temp_1100 = 0.0512409927942354 if year==1984
			replace temp_1100 = 0.0908625281704569 if year==1985
			replace temp_1100 = 0.0839943705220061 if year==1986
			replace temp_1100 = pct_1100 / pct_1000 if year==1990
				ipolate temp_1100 year, gen(temp_1100_temp)
					replace temp_1100 = temp_1100_temp if inrange(year,1987,1989)
			replace pct_1100 = temp_1100 * pct_1000 if year<1990
			replace pct_1200 = pct_1000 - pct_1100 if year<1990
		*adjust 2000 using RPC (and extrapolate from 2013 through 2016)
			replace pct_2000 = pct_2000_RPC
				replace pct_2000 = 0.006 if inrange(year,2014,2019) //extrapolate, assume equal in 2014-16 to its share in 07-13 (which had been constant)
		*1300 is relatively prominent 1960-78 or so, but it seems there is no info for us to retrieve 1100 vs 1200
			*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1992)
			replace interpolated = 1 if inlist(year,1984,1991)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/UGA.dta, replace

		
	*34. DZA
		use data/revenue_raw, clear	
		keep if country=="DZA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA 
			replace source = "HA"	
		}
		*interpolate for missing years
			local tax_disagg "1100	1200	1300	2000	4000	5100	5200	5300	6000"
			foreach x of local tax_disagg {								
				ipolate pct_`x' year /*if inrange(year,1983,1992)*/, gen(tempvar_`x')
					order tempvar_`x', after(pct_`x')
				replace pct_`x' = tempvar_`x' if pct_`x'==. // & inlist(year,1984,1991)
					drop tempvar*
			}	
		*extrapolate and then scale by the ICTD tax/GDP number
				local tax_disagg "1100	1200	1300	2000	4000	5100	5200	5300	6000"
				foreach x of local tax_disagg {								
					mipolate pct_`x' year /*if inrange(year,1983,1992)*/, forward gen(tempvar_`x')
						order tempvar_`x', after(pct_`x')
					replace pct_`x' = tempvar_`x' if pct_`x'==. // & inlist(year,1984,1991)
						drop tempvar*
				}	
			*scale by ICTD tax/gdp ratio
				egen stitched_total = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000),missing
					local tax_disagg "1100	1200	1300	2000	4000	5100	5200	5300	6000"
						foreach x of local tax_disagg {
							replace pct_`x' = pct_`x' * (pct_taxICTD / stitched_total) if year>2012
						}
					cap drop stitched_total
		*adjust 2000 using RPC (and extrapolate from 2013 for 2014 through 2016)
			replace pct_2000 = pct_2000_RPC
				replace pct_2000 = 0.002 if inrange(year,2014,2019) //extrapolate, assume equal post-2014 to share in 06-13 (which had been constant)
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
				format %9.2fc pct*
				order country year source pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_5100 pct_5200 pct_5300 pct_6000
		*1300 put in 1100 
			replace pct_1100 = pct_1300
			replace pct_1300 = .
		*save
			replace interpolated = 1 if inlist(year,1967,1970,1971,1974) | year>2012
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/DZA.dta, replace

	
	*35. SDN 
		use data/revenue_raw, clear	
		keep if country=="SDN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if inrange(year,1972,1980)
			replace source = "HA" if inrange(year,1972,1980)
			replace pct_`x' = pct_`x'_ICTD if year>1980
			replace source = "ICTD" if year>1980
		}
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100	pct_1200	pct_1300	pct_2000	pct_4000	pct_5000	pct_6000), missing
		*interpolate the ratio of 1000-within-tax, and 5000-within-tax, from 1972 to 1981 (via the interpolation to 1990, then apply it to ICTD 1981, interpolate that to the values of ICTD 1990
			gen _1000_tax = pct_1000_HA / pct_tax_HA if year==1990
				replace _1000_tax = pct_1000 / pct_tax if year==1980
			gen _5000_tax = pct_5000_HA / pct_tax_HA if year==1990
				replace _5000_tax = pct_5000 / pct_tax if year==1980
			foreach var of varlist _* {
				ipolate `var' year, gen(temp_`var')
					order temp_`var', after(`var')
				replace `var' = temp_`var' if `var'==. & inlist(year,1981)
					drop temp*
			}
			replace pct_1000 = _1000_tax * pct_tax if year==1981
			replace pct_5000 = _5000_tax * pct_tax if year==1981
			drop if year<1972 // IMF start year
		*now interpolate the pct_1000 and pct_5000 ICTD 1982-2016 missing years, based on within ratios, but ICTD only.
			foreach x in 1000 5000 {
				replace _`x'_tax = pct_`x'/pct_tax
				ipolate _`x'_tax year, gen(temp_`x')
				replace temp_`x' = temp_`x'[_n-1] if temp_`x'==. //forward extrapolate 1000 within tax ratio from 2010
				replace _`x'_tax = temp_`x' if _`x'_tax==.
					drop temp*
				replace pct_`x' = _`x'_tax * pct_tax
					drop _`x'*
			}
		*use the info on 11 12, interpolate the (1100 and) 1200, forward and backward, assign everything else (ie 1300) to 1100 //assign 1 to 13 and 5 to 53
			foreach x in 11 12 {
				gen _`x'00_1000 = pct_`x'00 / pct_1000
				ipolate _`x'00_1000 year, gen(temp_`x')
				replace temp_`x' = temp_`x'[_n-1] if temp_`x'==.
					forval year = 1994 (-1) 1981 {
						replace temp_`x' = temp_`x'[_n+1] if temp_`x'==. & year==`year'
					}
				replace _`x'00_1000 = temp_`x'
					drop temp_`x'
				replace pct_`x'00 = _`x'00_1000 * pct_1000 if pct_`x'00==.
					drop _`x'00_1000
			}
			replace pct_1100 = pct_1000 - pct_1200
			replace pct_1300 = .
		*fix the pct_6000 now that we have moved from other to 1 and 5
			egen non6 = rowtotal(pct_1000 pct_4000 pct_5000), missing
			replace pct_6000 = pct_tax - non6 if inrange(year,1981,1990)
					drop non6
				replace pct_6000 = 0 if pct_5000 < 0
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
				replace pct_2000 = 0.004 if inrange(year,2014,2019) //extrapolate value as same from preceding years
		*replace the aggregates after stitching
				cap drop pct_tax
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inrange(year,1983,1990)
			replace stitch = 1 if inlist(year,1981)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1972 & country=="SDN" //first post-independence year with data; through 2016
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SDN.dta, replace
		
		
	*36. IRQ
		*skip for now

			
	*37. POL
		use data/revenue_raw, clear	
		keep if country=="POL"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019)
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1991 //first post-Soviet year with data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/POL.dta, replace
			
			
	*38. CAN
		use data/revenue_raw, clear	
		keep if country=="CAN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019)
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965 & pct_tax!=. //no data for 2019 yet (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/CAN.dta, replace
		
			
	*39. MAR
		use data/revenue_raw, clear	
		keep if country=="MAR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_HA if inrange(year,1955,1999) 
			replace source = "HA" if inrange(year,1955,1999)
			replace pct_`x' = pct_`x'_OECD if year>1999
			replace source = "OECD" if year>1999				
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year<2000
		*1000 series
			replace pct_1100 = pct_1100 + pct_1300 if inrange(year,1997,1999) | year<1988
				replace pct_1300 = .  if inrange(year,1997,1999) | year<1988
			*interpolate the 1200 within 1000 ratio from 1987 to 1997
				gen _1200_1000 = pct_1200 / pct_1000
					order _1200_1000, after(pct_1200)
					replace _1200_1000 = . if year!=1987 & year!=1997
				ipolate _1200_1000 year, gen(temp)
						order temp, after (_1200_1000)
				replace pct_1200 = pct_1000 * temp if inrange(year,1988,1996)
				*after interpolating 1200, assign everything else (ie incl 1300) to 1100
					replace pct_1100 = pct_1000 - pct_1200 if inrange(year,1988,1996)
					replace pct_1300 = . if inrange(year,1988,1996)
							drop _* temp
		*now interpolate the missing years
			local disagg "1100	1200	1300	2000	4000	5100	5200	5300	6000" // 7000" //include the 7000 here, even if non-tax ? for now, no. we don't have 7000 from OECD, either
			foreach x of local disagg {								
				ipolate pct_`x' year if year<2000, gen(tempvar_`x')
					order tempvar_`x', after(pct_`x')
				replace pct_`x' = tempvar_`x' if pct_`x'==. & year<2000
					drop tempvar*
			}	 		
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2000)
			replace interpolated = 1 if inlist(year,1959,1966,1971,1972,1973,1995,1996)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/MAR.dta, replace
			
			
	*40. AFG
		use data/revenue_raw, clear	
		keep if country=="AFG"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}
		*1000 series is suspicious in ICTD 2006-10 (likely non-tax revenue rather than CIT), interpolate
			foreach x in 1200 1300 {
				replace pct_`x' = . if inrange(year,2006,2010)
				ipolate pct_`x' year, gen(temp)
					replace pct_`x' = temp if inrange(year,2006,2010)
						drop temp
			}
		*1000 series in 2018-19, extrapolate forward the split
			foreach x in 1100 1200 1300 {	
				replace pct_`x' = ( pct_`x'[_n-1] / pct_1000[_n-1] ) * pct_1000 if year==2018
				replace pct_`x' = ( pct_`x'[_n-1] / pct_1000[_n-1] ) * pct_1000 if year==2019
			}
		*2000 and 4000 series extrapolate forward
			forval year=2018/2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
				replace pct_4000 = pct_4000[_n-1] if year==`year'
			}
		*pct_1200 (ICTD 'resource component' does not add up--> exclude)
			replace pct_1200 = 0.00069786090821906 if year==2003
			replace pct_1200 = 0.00261218869664108 if year==2004
			replace pct_1200 = 0.000603085355135344 if year==2005
			replace pct_1200 = 0.00622683160107803 if year==2006
			replace pct_1200 = 0.00679302961800723 if year==2007
			replace pct_1200 = 0.00874283686581296 if year==2008
			replace pct_1200 = 0.0153709724774919 if year==2009
			replace pct_1200 = 0.015357803945563 if year==2010
			replace pct_1200 = 0.013673841690795 if year==2011
			replace pct_1200 = 0.0133819631987411 if year==2012
			replace pct_1200 = 0.0145576524869116 if year==2013
		*replace the aggregates after stitching (using disaggregates)
			cap drop pct_1000 pct_5000
		egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
		egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
		egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=2003 //earlier era data is unreliable
			format %9.2fc pct*
			order stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000, after(source)
			save data/harmonized/AFG.dta, replace
		
					
	*41. SAU
		use data/revenue_raw, clear	
		keep if country=="SAU"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*interpolate the 1000 and 5000 series
			local itp "1000 5000"
			foreach x of local itp {								
				ipolate pct_`x' year, gen(tempvar_`x')
					order tempvar_`x', after(pct_`x')
				replace pct_`x' = tempvar_`x' if pct_`x'==.
					drop tempvar*
			}	 		
			replace pct_1100 =.
			replace pct_1200 =.
			replace pct_1300 = pct_1000
		*replace the aggregates after stitching (using disaggregates)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inrange(year,2005,2008)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1994 //earlier era data is unavailable
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SAU.dta, replace
		
		
	*42. UZB
		use data/revenue_raw, clear	
		keep if country=="UZB"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*carry the 1200-within-1000 ratio, and interpolate the missing years
			*interpolate the 1200 within 1000 ratio from 1987 to 1997
				gen _1200_1000 = pct_1200 / pct_1000
						order _1200_1000, after(pct_1200)
					forval year = 2003 (1) 2019 {
						replace _1200_1000 = _1200_1000[_n-1] if year==`year'
					}
			*now interpolate the missing years
				local intp "1000 2000	4000	5100 5200 5300	6000"
				foreach x of local intp {								
					ipolate pct_`x' year, gen(tempvar_`x')
						order tempvar_`x', after(pct_`x')
					replace pct_`x' = tempvar_`x' if pct_`x'==.
						drop tempvar*
				}	 		
				replace pct_1200 = pct_1000 * _1200_1000 if year>2002
			*after interpolating 1200, assign everything else (ie incl 1300) to 1100
				replace pct_1100 = pct_1000 - pct_1200 if year>2002
				replace pct_1300 = . if year>2002
						drop _*
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inlist(year,2013,2014)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1993 //first post-Soviet year with data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/UZB.dta, replace				
							
				
	*43. PER
		use data/revenue_raw, clear	
		keep if country=="PER"
		*early years: extrapolate 1965-67 using RPC rate of change from 1965 to 1968
				ren pct_tax* pct_tax_*
			local all "tax 1000 1100 1200 1300 2000 4000 5000 5100 5200 5300 6000 7000"
			forval year = 1967 (-1) 1965 {
			foreach x of local all {
				replace pct_`x'_HA = ( pct_tax_RPC / pct_tax_RPC[_n+1] ) * pct_`x'_HA[_n+1] if year==`year'
			}
			}
		*adjustments
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year<1990  
			replace source = "HA" if year<1990 
			replace pct_`x' = pct_`x'_OECD if year>1989
			replace source = "OECD" if year>1989			
		}			
		*adjust 2000 using RPC in the HA years
			replace pct_2000 = pct_2000_RPC if source=="HA"			
		*interpolate the 1000 series split from 1982 to 1990
			gen _1200_1000 = pct_1200 / pct_1000
					order _1200_1000, after(pct_1200)
					replace _1200_1000 = . if !inlist(year,1982,1990)
				ipolate _1200_1000 year, gen(temp)
						order temp, after (_1200_1000)
			replace pct_1200 = pct_1000 * temp if inrange(year,1983,1989)
		*after interpolating 1200, assign everything else (ie incl 1300) to 1100
			replace pct_1100 = pct_1000 - pct_1200 if inrange(year,1983,1989)
				replace pct_1300 = . if inrange(year,1983,1989) //don't want this anymore
				drop _* temp
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/PER.dta, replace
		
		
	*44. VEN
		use data/revenue_raw, clear	
		keep if country=="VEN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year>=1990  
			replace source = "OECD" if year>=1990 
			replace pct_`x' = pct_`x'_HA if year<1980  
			replace source = "HA" if year<1980 									
			replace pct_`x' = pct_`x'_ICTD if inrange(year,1980,1989)  
			replace source = "ICTD" if inrange(year,1980,1989)						
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year<1990
			forval year = 2013/2017 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'	//impute pct_2000 constant from 2012-->2017 
			}
		*extrapolate the 1200-within-1000 from 1971 back to 1950, forward from 2015 to 2017
			gen _1200_1000 = pct_1200 / pct_1000 if inlist(year,1971,2015)
			forval year = 1970 (-1) 1950 {
					replace _1200_1000 = _1200_1000[_n+1] if year==`year'
				}	
			forval year = 2016 / 2017 {		//note nothing past 2017
					replace _1200_1000 = _1200_1000[_n-1] if year==`year'
				}
			replace pct_1200 = _1200_1000 * pct_1000 if inrange(year,1950,1970) | inrange(year,2016,2017)
			replace pct_1300 = pct_1000 - pct_1200 if inrange(year,1950,1970) | inrange(year,2016,2017)
				drop _1200_1000
		*interpolate the within ratios for everything (11 12 13 20 40 50 60) from 1975 to 1980
				replace pct_6000 = . if inrange(year,1976,1979) //don't need this, better off without it
			local disagg "1100	1200	1300	2000	4000	5100	5200	5300	6000" // 7000" //include the 7000 here, even if non-tax ? for now, no. we don't have 7000 from OECD, either
					gen pct_tax=0
				foreach x of local disagg {
					replace pct_tax = pct_tax + pct_`x' if pct_`x'!=.
				}
			foreach x of local disagg {								
				gen win_`x' = pct_`x' / pct_tax
				ipolate win_`x' year if inrange(year,1975,1980), gen(tempvar_`x')
				replace win_`x' = tempvar_`x' if win_`x'==. & inrange(year,1975,1980)
					drop tempvar*
				replace pct_`x' = win_`x' * pct_tax
					drop win*
			}	 	
		*based on scholarly sources, put the 1300 into PIT
			replace pct_1100 = pct_1100 + pct_1300 if pct_1100!=. & pct_1300!=.
			replace pct_1100 = pct_1300 if pct_1100==. & pct_1300!=.
			replace pct_1300 = .					
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1980,1990)
			replace interpolated = 1 if inrange(year,1976,1979)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/VEN.dta, replace
				
					
	*45. MYS
		use data/revenue_raw, clear	
		keep if country=="MYS"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)	
			replace pct_`x' = pct_`x'_OECD if year>1989  
			replace source = "OECD" if year>1989 
			replace pct_`x' = pct_`x'_HA if year<1990  
			replace source = "HA" if year<1990						
		}	
		*adjust 2000 series using RPC pre-1972 and interpolate between 1972 and 2000 (OECD)
			replace pct_2000 = pct_2000_RPC if year<1972
				ipolate pct_2000 year if inrange(year,1971,2000), gen(temp2000)
					order temp2000, after(pct_2000)
				replace pct_2000 = temp2000 if inrange(year,1972,1999)
					drop temp*
		*take the 1000 series split from IMF hist for years 1976-80
				replace pct_1300 = . if year<1980
			replace pct_1100 = pct_1000 * 0.242600679281902 if year<=1976
			replace pct_1100 = pct_1000 * 0.24336917562724 if year==1977
			replace pct_1100 = pct_1000 * 0.244794952681388 if year==1978
			replace pct_1100 = pct_1000 * 0.306355241716458 if year==1979
			replace pct_1100 = pct_1000 * 0.186917664955315 if year==1980
				replace pct_1200 = pct_1000 - pct_1100 if year<1981
		*interpolate for missing years (79 80 88)
				replace pct_1300 = 0 if year==1987
			local tax_disagg "1000 1100 1200 1300 5000" //there is no 4000, no 6000, already handled 2000, 1000 needs special treatment, don't care about 5000
			foreach x of local tax_disagg {								
				ipolate pct_`x' year, gen(tempvar_`x')
					order tempvar_`x', after(pct_`x')
				replace pct_`x' = tempvar_`x' if pct_`x'==. & inlist(year, 1979, 1980, 1988)
					drop tempvar*
			}
		*replace the aggregates after stitching (using disaggregates)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			replace interpolated = 1 if inlist(year,1979,1980,1988)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/MYS.dta, replace
			

	*46. AGO
		*skip for now; IMF data?

		
	*47. MOZ
		use data/revenue_raw, clear	
		keep if country=="MOZ"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
			replace pct_`x' = pct_`x'_ICTD if inrange(year,2015,2019)  
			replace source = "ICTD" if inrange(year,2015,2019) 				
		}				
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
			replace pct_2000 = 0.001 //all years in RPC //if inrange(year,2014,2016)
		*5100 adjustment for HA-->ICTD in 2015-16
			foreach x in 1000 5000 6000 {
				gen ratio_`x' = pct_`x'_HA / pct_`x'_ICTD
				replace ratio_`x' = ratio_`x'[_n-1] if year>2014
				replace pct_`x' = ratio_`x' * pct_`x'_ICTD if year>2014
					drop ratio*
			}
		*1200 within 1000 from Castro et al (IMF 2009) for 1994-2007, since we already have 1993
			gen _1200_1000=.
				order _1200_1000, after(pct_1200)
				*replace _1200_1000 = 0.51530612244898 if year==1993
				replace _1200_1000 = 0.495145631067961 if year==1994
				replace _1200_1000 = 0.461139896373057 if year==1995
				replace _1200_1000 = 0.439306358381503 if year==1996
				replace _1200_1000 = 0.44 if year==1997
				replace _1200_1000 = 0.484042553191489 if year==1998
				replace _1200_1000 = 0.48 if year==1999
				replace _1200_1000 = 0.37012987012987 if year==2000
				replace _1200_1000 = 0.359550561797753 if year==2001
				replace _1200_1000 = 0.336492890995261 if year==2002
				replace _1200_1000 = 0.294642857142857 if year==2003
				replace _1200_1000 = 0.307692307692308 if year==2004
				replace _1200_1000 = 0.324137931034483 if year==2005
				replace _1200_1000 = 0.452574525745257 if year==2006
				replace _1200_1000 = 0.434004474272931 if inrange(year,2007,2019) //extrapolate from 2007 to end
			replace pct_1200 = _1200_1000 * pct_1000 if inrange(year,1994,2019)
			replace pct_1100 = pct_1000 - pct_1200 if inrange(year,1994,2019)
			replace pct_1300 = . if inrange(year,1994,2019)
				drop _1200_1000
		*interpolate 1991 and 2001
			foreach x in 1100 1200 5100 5200 6000 {
					ipolate pct_`x' year, gen(temp_`x')
					order temp_`x', after(pct_`x')
				replace pct_`x' = temp_`x' if year==1991 | year==2001 | year==1985
					drop temp_`x' 
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
				order pct_5000, after(pct_4000)
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
				order pct_1000, before(pct_1100)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2015)
			replace interpolated = 1 if inlist(year,1991,2001)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1975 //first post-independence year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/MOZ.dta, replace
			
			
	*48. NPL
		use data/revenue_raw, clear	
		keep if country=="NPL"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year<2005  
			replace source = "HA" if year<2006 
			replace pct_`x' = pct_`x'_ICTD if year>2005   
			replace source = "ICTD" if year>2005 					
		}	
		*year 2005 is a mix of both
			foreach x in 1000 1100 1200 1300 4000 6000 {
				replace pct_`x' = pct_`x'_HA if year==2005
			}
			foreach x in 5000 5100 5200 5300 { 
				replace pct_`x' = pct_`x'_ICTD if year==2005
			}
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year<2006 | inlist(year,2010,2011)
		*1000 series
			*interpolate 1200 within 1000, for 2006-09
				gen _1200_1000 = .
					replace _1200_1000 = pct_1200 / pct_1000 if !inrange(year,2006,2009)
					ipolate _1200_1000 year, gen(temp)
					order _1200_1000 temp, after(pct_1200)		
			*extrapolate that ratio pre-1987
				forval year = 1986 (-1) 1976 {
					replace temp = temp[_n+1] if year==`year'
				}
			replace pct_1200 = temp * pct_1000
			replace pct_1100 = pct_1000 - pct_1200
			replace pct_1300 = .
				drop _1200* temp*
		*2018, 2019
			forval year = 2018/2019 {
				foreach x in 1100 1200 2000 4000 5000 {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_taxICTD[_n-1] ) * pct_taxICTD if year==`year'
				}
			}
			replace pct_6000 = pct_taxICTD - ( pct_1100 + pct_1200 + pct_2000 + pct_4000 + pct_5000) if inlist(year,2018,2019)
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000
			replace pct_5000 = pct_5100 + pct_5200 if year<2018
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
				order pct_1000, before(pct_1100)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2006)
			replace interpolated = 1 if inlist(year,2018,2019) //assume same breakdown from 2017, scale to 2018-19 totals from ICTD
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1976 //first post-independence year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/NPL.dta, replace
			
			
	*49. GHA
		use data/revenue_raw, clear	
		keep if country=="GHA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if inrange(year,1972,1989)
			replace source = "HA" if inrange(year,1972,1989)						
			replace pct_`x' = pct_`x'_OECD if year>1999  
			replace source = "OECD" if year>1999 
			replace pct_`x' = pct_`x'_HA if year<1972 | inrange(year,1990,1999)   
			replace source = "HA" if year<1972 | inrange(year,1990,1999) 				
		}						
		*adjust for WB (not UN via old WID) GDP	
			replace wb_wid_ratio = . if inrange(year,1990,2005)
				ipolate wb_wid_ratio year, gen(temp)
					replace wb_wid_ratio = temp if inrange(year,1990,2005)
						drop temp
		foreach var of varlist pct_1000 - pct_6000	{
			replace `var' = `var' / wb_wid_ratio if year > 1989
		}										
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year < 2000
		*carry backward the 1100 1200 split from 1972 back to 1967 
			foreach x in 1100 1200 {
					gen temp_`x' = pct_`x' / pct_1000 if year==1972
				forval year = 1971 (-1) 1967 {
					replace temp_`x' = temp_`x'[_n+1] if year==`year'
				}
				replace pct_`x' = temp_`x' * pct_1000 if inrange(year,1967,1971)
			}
				replace pct_1300 = 0 if inrange(year,1967,1971)
					drop temp*			
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
				order pct_1000, before(pct_1100)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1972,1990,2000)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1967 //first post-independence year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/GHA.dta, replace
		
				
	*50. YEM
		use data/revenue_raw, clear	
		keep if country=="YEM"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year<1998  
			replace source = "HA" if year<1998 
			replace pct_`x' = pct_`x'_ICTD if year>1997   
			replace source = "ICTD" if year>1997 							
		}									
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
		*adjust 1000 series for missing years, to have 1100 and 1200 split reflect the four observations throughout 2
			foreach x in 1100 1200  {
				gen _`x'_1000 = .
					replace _`x'_1000 = pct_`x' / pct_1000
					ipolate _`x'_1000 year, gen(temp_`x')
					forval year = 1997 (-1) 1990 {
						replace temp_`x' = temp_`x'[_n+1] if year==`year'
					}
					forval year = 2003 (1) 2012 {
						replace temp_`x' = temp_`x'[_n-1] if year==`year'
					}			
					replace pct_`x' = temp_`x' * pct_1000					
						drop _`x'_1000 temp_`x'
				}
			replace pct_1300 = .
		*adjust 5000 series in HA years (1990-97) to match scale of ICTD years (1998-2012)
			gen ratio_5000 = pct_5000_ICTD / pct_5000_HA if year==1998
			foreach x in 5000 5100 5200 5300 {
				forval year = 1997 (-1) 1990 {
					replace ratio_5000 = ratio_5000[_n+1] if year==`year'
					replace pct_`x' = pct_`x' * ratio_5000 if year==`year'
				}
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1998)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if inrange(year,1990,2012)  //modern Yemen, thru start of civil war
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/YEM.dta, replace
		

			
	*51. MDG
		use data/revenue_raw, clear	
		keep if country=="MDG"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year<1972  
			replace source = "HA" if year<1972 
			replace pct_`x' = pct_`x'_NS if inrange(year,1972,1989) 
			replace source = "HA" if inrange(year,1972,1989)
			replace pct_`x' = pct_`x'_ICTD if year>1989   
			replace source = "ICTD" if year>1989 				
		}				
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
				forval year = 2014 / 2019 {
					cap replace pct_2000 = pct_2000[_n-1] if year==`year' // if inrange(year,xxxx,xxxx) //extrapolate
				}
		*put 1300 into 1100 for 1965-68
			replace pct_1100 = pct_1300 if inrange(year,1965,1968)
			replace pct_1100 = pct_1100 + pct_1300 if pct_1300!=. & source=="ICTD" & year<2003 // we do nothing we ictd 1000 series split after 2002
			replace pct_1300 = . //if inrange(year,1965,1968) | year>2002 //ictd incomplete after 2002
			replace pct_1200 = . if year>2002 //ictd incomplete after 2002
		*interpolate 1000 4000 5000 6000 series for 1969-71 and missing years during IMF period
			replace pct_4000 = 0 if year==1968
			foreach x in 1000 1100 1200 4000 5000 6000 /*7000*/ {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' // if inrange(year,1969,1979) | inlist(year,1982,1985,1986)
					drop temp_`x'
			}
		*adjust 1000 series for missing years, to have 1100 and 1200 split reflect the four observations throughout 2
			foreach x in 1100 1200  {
				gen _`x'_1000 = .
					replace _`x'_1000 = pct_`x' / pct_1000
					ipolate _`x'_1000 year, gen(temp_`x')
					
					forval year = 2003 (1) 2019 {
						replace temp_`x' = temp_`x'[_n-1] if year==`year'
					}
						order _`x'_1000 temp_`x'*, after(pct_`x')
						format %9.2fc _* temp*
					replace pct_`x' = temp_`x' * pct_1000
					drop _`x'_1000 temp_`x'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
				order pct_1000, before(pct_1100)
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990, 1972)
			replace interpolated = 1 if inrange(year,1969,1971) | inrange(year,1974,1977) | inrange(year,1981,1987)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/MDG.dta, replace				
							
		
	*52. AUS
		use data/revenue_raw, clear	
		keep if country=="AUS"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019)
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965 & pct_tax!=. //no data for 2018 yet (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/AUS.dta, replace
		
		
	*53. CIV
		use data/revenue_raw, clear	
		keep if country=="CIV"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year>=1990  
			replace source = "OECD" if year>=1990 
			replace pct_`x' = pct_`x'_HA if year<1990   
			replace source = "HA" if year<1990 				
		}	
		*adjust 2000
			*use ICTD value 1980-2010, including its ratio with OECD 2011-16, and interpolate back from 1980 for missing years, trusting HA value
			replace pct_2000 = pct_2000_ICTD if year>1979
					gen ratio_2000 = pct_2000_OECD / pct_2000_ICTD if year>1989 //take 1990 ratio value, not the average
						forval year = 2011 / 2019 {
							replace ratio_2000 = ratio_2000[_n-1] if year==`year'
						}
				replace pct_2000 = pct_2000_OECD / ratio_2000 if year>2010
							drop ratio_2000
				replace pct_2000 = . if inrange(year,1968,1970)
			ipolate pct_2000 year if year<1981, gen(temp_2000) 
			replace pct_2000 = temp_2000 if year<1981
				drop temp_2000
		*1000 series (interpolate from 1963 HA to 1982 ICTD split, then use ICTD split going forward, by replacing OECD with its excess 2000 series revenue vis a vis ICTD)
			*first fix 1963
				replace pct_1100 = pct_1100 + pct_1300 if year==1963
				replace pct_1300 = 0 if year<1990 ==1963 //we don't want this to linger later
			*then interpolate to and use ICTD 1000 series split up through 1986-1989
				foreach x in 1100 1200 1300 {
						gen _`x'_1000 = .
							replace _`x'_1000 = pct_`x' / pct_1000 if year==1963
							replace _`x'_1000 = (pct_`x'_ICTD + (0.5 * pct_1300_ICTD))/ pct_1000_ICTD if inrange(year,1986,1989)
							ipolate _`x'_1000 year, gen(temp_`x')
							replace pct_`x' = temp_`x' * pct_1000 if year<1990
									drop _`x'_1000 temp_`x'
					}
		*then fix the OECD 1100 series by the 'wedge' amount between ICTD 2000 and OECD 2000
			replace pct_1100 = pct_1100 + (pct_2000_OECD - pct_2000) if year>1989 //_ICTD) if inrange(year,1990,2010)
		*fix 5000 series based on 6000 series, 1984-86 (see note re "unreported" indirect tax)
			replace pct_6000 = 0 if inrange(year,1990,1995)
			gen temp_6000 = pct_6000 if inrange(year,1963,1976) | year>1989
			ipolate temp_6000 year, gen(temp_6000_temp)
			replace pct_5300 = pct_6000 - temp_6000_temp if inrange(year,1984,1986)
			replace pct_6000 = temp_6000_temp
					drop temp_6000*
				replace pct_5300 = 0 if pct_5300==. & pct_5000!=.
		*interpolate disaggregates for missing years
				replace pct_4000 = 0 if inrange(year,1975,1976) //not listed
			foreach x in 1100 1200 1300 /*2000*/ 4000 5100 5200 5300 /*6000 7000*/ {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if pct_`x'==.
					drop temp_`x'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			replace interpolated = 1 if inrange(year,1977,1983) | inrange(year,1987,1989)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/CIV.dta, replace
		

	*54. TWN
		use data/revenue_raw, clear	
		keep if country=="TWN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
		}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000	
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2015)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax pct_1000, after(source)
			save data/harmonized/TWN.dta, replace
		

	*55. CMR
		use data/revenue_raw, clear	
		keep if country=="CMR"
			*from scholarly sources we have the following tax/GDP ratios pre-1995:
			replace pct_taxNS = 0.1039731875 if year==1966
			replace pct_taxNS = 0.1048902228 if year==1967
			replace pct_taxNS = 0.09798969 if year==1968
			replace pct_taxNS = 0.1010066574 if year==1969
			replace pct_taxNS = 0.1049944083 if year==1970
			replace pct_taxNS = 0.1129066727 if year==1971
			replace pct_taxNS = 0.1095851696 if year==1972
			replace pct_taxNS = 0.150307858 if year==1973
			replace pct_taxNS = 0.1374299706 if year==1974
			replace pct_taxNS = 0.126228983 if year==1975
			replace pct_taxNS = 0.1392106185 if year==1976
			replace pct_taxNS = 0.132417846 if year==1977
			replace pct_taxNS = 0.1502961966 if year==1978
			replace pct_taxNS = 0.140488992 if year==1979
			replace pct_taxNS = 0.1379272685 if year==1980
			replace pct_taxNS = 0.1460542776 if year==1981
			replace pct_taxNS = 0.1523827721 if year==1982
			replace pct_taxNS = 0.1511871924 if year==1983
			replace pct_taxNS = 0.1579228006 if year==1984
			replace pct_taxNS = 0.1413379176 if year==1985
			replace pct_taxNS = 0.1523599455 if year==1986
			replace pct_taxNS = 0.1481382859 if year==1987
			replace pct_taxNS = 0.0910414791 if year==1988
			replace pct_taxNS = 0.0858296508 if year==1989
			replace pct_taxNS = 0.0939405369 if year==1990
			replace pct_taxNS = 0.0860329479 if year==1991
			replace pct_taxNS = 0.0946329372 if year==1992
			replace pct_taxNS = 0.098635078 if year==1993
			replace pct_taxNS = 0.1136448864 if year==1994
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year<1993  
			replace source = "HA" if year<1993 
			replace pct_`x' = pct_`x'_OECD if year>1992   
			replace source = "OECD" if year>1992 				
		}	
		*we had in HA all taxes for 1964-68, only indirect for 1969-91
			*take the gap from AA1998 (cited above), use shares of the gap from 1965-68 to forward fill to 1991 (1980?)
				gen gap = pct_taxNS - pct_taxHA if inrange(year,1971,1991) 
			*now adjust the AA98 level to fit HA with OECD
				gen gap_add = pct_taxNS - (pct_taxOECD - pct_2000_OECD) if year==1993	//OECD includes ss, AA98 probably doesn't
				replace gap_add = pct_taxNS - pct_taxHA if year==1968 //want to fix AA98 to equal our HA in 68 and OECD in 93
				replace gap_add = 0 if year==1980 | year==1981 //trust AA98 in 80-81 (for lack of better option)
					ipolate gap_add year, gen(gap_add2)
						order gap*, after(year)
						format %9.2fc gap*
				replace	gap = gap + gap_add2
					drop gap_*
						replace pct_5300 = 0 if inrange(year,1993,1996) 
						replace pct_1300 = 0 if inrange(year,1993,1994) 
				foreach x in 1000 4000 5300 6000 {
					replace pct_`x' = 0 if inrange(year,1971,1991) & pct_`x'==. & year!=1989
					}
				replace pct_1000 = pct_1000 + 0.386812531169849 * gap if inrange(year,1971,1991)
				replace pct_4000 = pct_4000 + 0.365878948967835 * gap if inrange(year,1971,1991)
				replace pct_5300 = pct_5300 + 0.148319313787631 * gap if inrange(year,1971,1991)
				replace pct_6000 = pct_6000 + 0.098989206074685 * gap if inrange(year,1971,1991)
					replace pct_1000 = . if year==1971 | year==1972 
					replace pct_4000 = . if year==1971 | year==1972 
		*interpolate missing values
			foreach x in 1000 4000 5100 5200 5300 6000 {
				ipolate pct_`x' year, gen(temp_`x')
					order temp_`x', after(pct_`x')
					format %9.2fc temp_`x'
				replace pct_`x' = temp_`x' if pct_`x' == .
					drop temp_`x'
			}
		*interpolate 1000 series ratios
			foreach x in 1100 1200 {
				gen _`x'_1000 = pct_`x' / pct_1000
					ipolate	_`x'_1000 year, gen(_`x'_1000_temp)
						order _`x'_1000*, after(pct_`x')
						format %9.2fc _*
				replace pct_`x' = pct_1000 * _`x'_1000_temp if inrange(year,1969,1992)
					drop _*
				}
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year<1990 //don't trust after 89
				ipolate pct_2000 year, gen(temp_2000)
					order temp_2000, after(pct_2000)
				replace pct_2000 = temp_2000 if year<1993
					drop temp_2000						
		*fix the 4000 series to match better the march to OECD, and move to 5000 series the remainder	
			*interpolate that 4000 as a percentage of tax revenue will decline from 1968-1993
				gen pct_4000_temp = pct_4000 / (pct_1000 + pct_2000 + pct_4000 + pct_5100 + pct_5200 + pct_5300 + pct_6000) if !inrange(year,1969,1992)
				ipolate pct_4000_temp year, gen(pct_4000_temp_temp)
					order pct_4000_temp*, after(pct_4000)
					format %9.2fc pct_4000_temp*
				replace pct_4000_temp_temp	= pct_4000_temp_temp * (pct_1000 + pct_2000 + pct_4000 + pct_5100 + pct_5200 + pct_5300 + pct_6000) 
			replace pct_5300 = pct_5300 + pct_4000 - pct_4000_temp_temp if inrange(year,1969,1992)
			replace pct_4000 = pct_4000_temp_temp if inrange(year,1969,1992)
					drop pct_4000_temp*					
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1993)
			replace interpolated = 1 if inlist(year,1969,1970,1989,1992)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/CMR.dta, replace
	
					
	*56. LKA
		use data/revenue_raw, clear	
		keep if country=="LKA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
		}		
		*adjust 2000 using RPC (and extrapolate back, and interpolate forward with ICTD ratio)
			replace pct_2000 = pct_2000_RPC if year < 1990
					forval year = 1959 (-1) 1958 {
						replace pct_2000 = pct_2000[_n+1] if year==`year'
					}
			replace pct_2000 = pct_2000_ICTD if year > 1989
		*interpolate 1000 4000 5000 6000 for missing years 98-99
				replace pct_1300 = 0 if year==1997
				replace pct_4000 = 0 if year==2000
			foreach x in 1000 1100 1200 1300 4000 5100 5200 5300 6000 {
				ipolate pct_`x' year, gen(temp_`x')
					order temp_`x', after(pct_`x')
					format %9.2fc temp_`x'
				replace pct_`x' = temp_`x' if pct_`x'==. & inrange(year,1982,1999) //year==1998 | year==1999
					drop temp_`x'
			}		
		*and forward 2015-19, per HA-to-ICTD ratio in 2014
			foreach x in 1100 1200 1300 4000 5100 5200 5300 6000 { 
				gen ratio_`x' = pct_`x'_HA / pct_`x'_ICTD
						order ratio_`x', after(pct_`x')
					forval year = 2015 / 2019 {
						replace ratio_`x' = ratio_`x'[_n-1] if year==`year'									
					}
				replace pct_`x' = pct_`x'_ICTD * ratio_`x' if year>2014
							drop ratio_`x'
			}		
			replace pct_6000=0 if year>=2016 
		*extend 1000 series split from ICTD in 1980 back to 1950; use the ICTD 1000 series split for 1980-2001, too
			foreach x in 1100 1200 {
				gen _`x'_1000 = pct_`x'_ICTD / pct_1000_ICTD
					forval year = 1979 (-1) 1950 {
						replace _`x'_1000 = _`x'_1000[_n+1] if year==`year' 
					}
					order _`x'_1000, after(pct_`x')
					format %9.2fc _`x'_1000
			replace pct_`x' = pct_1000 * _`x'_1000 if year<2002
				drop _*
			}
			replace pct_1200 = pct_1000 - pct_1100 if year==1993
			replace pct_1300 = . if year<2002		
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inlist(year,1998,1999)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/LKA.dta, replace

			
	*57. NER
		use data/revenue_raw, clear	
		keep if country=="NER"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year<2000  
			replace source = "HA" if year<2000 
			replace pct_`x' = pct_`x'_OECD if year>1999   
			replace source = "OECD" if year>1999 					
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if inrange(year,1967,1999)
			*interpolate for 1990 and 1999
				ipolate pct_2000 year, gen(temp_2000)
					order temp_2000, after(pct_2000)
				replace pct_2000 = temp_2000 if year==1990 | year==1998
					drop temp_2000				
		*interpolate all disagg when missing 1967-74
			foreach x in 1000 1100 1200 1300 4000 5000 5100 5200 5300 6000 /*7000*/ {
				ipolate pct_`x' year, gen(temp_`x')
					order temp_`x', after(pct_`x')
					format %9.2fc temp_`x'
				replace pct_`x' = temp_`x' if inrange(year,1967,1974) 
					drop temp_`x'
			}
		*interpolate 1000 series split
			*first move the 1300 to 1100 in 1975-98
			replace pct_1100 = pct_1100 + pct_1300 if pct_1300!=. & inrange(year,1975,1998)
			replace pct_1300 = 0 if inrange(year,1975,1998)
		*replace 1000 series split for 1999 and pre-1975
			foreach x in 1100 1200 {
			gen _`x'_1000 = pct_`x' / pct_1000
				forval year = 1974 (-1) 1962 {
					replace _`x'_1000 = _`x'_1000[_n+1] if year==`year' 
				}
					ipolate _`x'_1000 year, gen(_`x'_1000_temp)
					replace pct_`x' = pct_1000 * _`x'_1000_temp if year==1999 | year<1975
						drop _`x'_1000*
				}	
			replace pct_1300 = . 
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if year==2000
			replace interpolated = 1 if inrange(year,1967,1974)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/NER.dta, replace
		

	*58. ROU
		use data/revenue_raw, clear	
		keep if country=="ROU"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1991 & pct_tax!=. //post-Soviet
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/ROU.dta, replace
			
			
			
			
			
				
				
	*59. BFA
		use data/revenue_raw, clear	
		keep if country=="BFA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_HA if year<2000  
			replace source = "HA" if year<2000 
			replace pct_`x' = pct_`x'_OECD if year>1999   
			replace source = "OECD" if year>1999 						
		}
		egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing 
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year<2000
		*interpolate missing years 1968, 1969, 1971, 1973, 1982, 1983, 1984
			foreach x in 1000 1100 1200 1300 4000 5000 5100 5200 5300 6000 {
				ipolate pct_`x' year, gen(temp_`x')
					order temp_`x', after(pct_`x')
					format %9.2fc temp_`x'
				replace pct_`x' = temp_`x' if inlist(year, 1968, 1969, 1971, 1973, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992) //4000 series disappeared in HA after 1981
					drop temp_`x'
			}
		*get (1000 5000 6000) tax level for 1993-99
			gen ratio_HA_ICTD = (pct_tax + pct_4000) / (pct_taxICTD - pct_2000_ICTD) //HA does not include 2000 or 4000
				order ratio*, after(pct_tax)
				forval year = 1993 / 1999 {
					replace ratio_HA_ICTD = ratio_HA_ICTD[_n-1] if year==`year'
				}
			replace pct_tax = pct_taxICTD * ratio_HA_ICTD if inrange(year,1993,1999)
				drop ratio*			
		*interpolate compositions
				replace pct_1300 = 0 if year==1992 //will be slightly above zero on the other side of the interpolation
			foreach x in 1100 1200 1300 2000 4000 5100 5200 5300 6000 {
				gen win_`x' = pct_`x' / (pct_tax + pct_2000) if inrange(year,1982, 1999) //HA didn't include 2000, we added later
				replace win_`x' = pct_`x' / pct_tax //OECD did include 2000
					ipolate win_`x' year, gen(win_`x'_temp)
						order win_`x'*, after(pct_`x')
						format %9.2fc win_`x'*
				replace pct_`x' = win_`x'_temp * (pct_tax + pct_2000) if inrange(year,1993,1999) //here tax does not include 2000 and 4000
						drop win_`x'*
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2000)
			replace interpolated = 1 if inlist(year,1968,1969,1971,1973,1982,1983,1984)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BFA.dta, replace
		

	*60. SYR
		use data/revenue_raw, clear	
		keep if country=="SYR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
		}
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if inrange(year,1962,1973) | inrange(year,1988,2007)
				ipolate pct_2000 year, gen(temp_2000)
					replace pct_2000 = temp_2000 if inrange(year,1974,1987)
					drop temp_2000			
		*interpolate missing years from 62 through 04
			replace interpolated = 1 if pct_1000==. & year<2005		
			foreach x in 1100 1200 1300 4000 5100 5200 5300 6000 {
				ipolate pct_`x' year, gen(temp_`x')
					order temp_`x', after(pct_`x')
					format %9.2fc temp_`x'
				replace pct_`x' = temp_`x' if year < 2005
					drop temp_`x'
			}
		*2005-08, estimate the HA based on mean HA:ICTD ratios in /*1998 - */ 2004 and the ICTD values 2005-07
			foreach x in 1100 1200 1300 4000 5100 5200 5300 6000 {
				gen ratio_`x' = pct_`x'_HA / pct_`x'_ICTD
					forval year = 2005 / 2008 {
					replace ratio_`x' /*_mean*/ = ratio_`x'[_n-1] if year==`year'
					}
				replace pct_`x' = pct_`x'_ICTD * ratio_`x' /*_mean*/ if inrange(year,2005,2007)
					drop ratio_`x'* /*_mean*/
			}		
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965 & year<2008 //civil war
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SYR.dta, replace
			
		
	*61. MWI
		use data/revenue_raw, clear	
		keep if country=="MWI"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)	
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
			replace pct_`x' = pct_`x'_OECD if year>2004   
			replace source = "OECD" if year>2004 						
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
				forval year = 2014 / 2019 {
					cap replace pct_2000 = pct_2000[_n-1] if year==`year'
				}
		*interpolate missing years 89-94 based on ICTD ratio
			foreach x in 1100 1200 4000 5100 5200 6000 {
				gen _`x'_HA_ICTD = pct_`x'_HA / pct_`x'_ICTD if year==1989 | year==1994 | year==2015
					ipolate _`x'_HA_ICTD year, gen(_`x'_HA_ICTD_temp)
				forval year = 2016 / 2019 {
					replace _`x'_HA_ICTD = _`x'_HA_ICTD[_n-1] if year==`year'
				}
				replace pct_`x' = _`x'_HA_ICTD_temp * pct_`x'_ICTD if inrange(year,1990,1993)					
					drop _`x'_HA_ICTD*
			}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2005)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/MWI.dta, replace
	
					
	*62. MLI
		use data/revenue_raw, clear	
		keep if country=="MLI"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year<1980  
			replace source = "HA" if year<1980 
			replace pct_`x' = pct_`x'_ICTD if inrange(year,1980,1999) 
			replace source = "ICTD" if inrange(year,1980,1999)
			replace pct_`x' = pct_`x'_OECD if year>1999  
			replace source = "OECD" if year>1999
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year<2000
		*interpolate missing 1964
			foreach x in 1100 1200 4000 5100 5200 6000 {
				ipolate pct_`x' year, gen(temp_`x')
					format %9.2fc temp_`x'
					order temp_`x', after(pct_`x')
				replace pct_`x' = temp_`x' if year==1964
					drop temp_`x'
			}	
				replace pct_1000 = pct_1100 + pct_1200 if year==1964 //there is no 1300 (until we re-calculate below)
		*extend ICTD 1000 series ratios back to 1960 and replace in 1982-383
			foreach x in 1100 1200 1300 {
				gen _`x'_1000 = pct_`x' / pct_1000 if year>=1980
						order _`x'*, after(pct_`x')
						format %9.2fc _*
					forval year = 1979 (-1) 1961 {
						replace _`x'_1000 = _`x'_1000[_n+1] if year==`year'
					}
					forval year = 1982 / 1983 {
						replace _`x'_1000 = _`x'_1000[_n-1] if year==`year'
					}
				replace pct_`x' = _`x'_1000 * pct_1000 if year<1980 | year==1982 | year==1983
						*drop _`x'_1000 
			}
		*interpolate the 1100 and 1200 and 1300 values for 2000-01
			foreach x in 1100 1200 1300 {
				replace _`x'_1000 = . if year==2000 | year==2001
						ipolate _`x'_1000 year, gen(_`x'_1000_temp)
						order _`x'*, after(pct_`x')
						format %9.2fc _*
				replace pct_`x' = _`x'_1000_temp * pct_1000 if year==2000 | year==2001
					drop _`x'*
			}		
		*4000 series
			ipolate pct_4000 year, gen(temp)
				replace pct_4000 = temp if pct_4000==. & inrange(year,1975,1983)
					drop temp
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1980,2000)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/MLI.dta, replace
			
					
	*63. CHL
		use data/revenue_raw, clear	
		keep if country=="CHL"
		foreach x in 1100 1200 1300 {
			gen _`x'_1000_ICTD = pct_`x'_ICTD / pct_1000_ICTD if year==1981 //ICTD 1000 series split interpolated back
				order _`x'_1000_ICTD, after(pct_`x'_ICTD) 
				format %9.2fc _`x'_1000_ICTD
			forval year = 1980 (-1) 1960 {
				replace _`x'_1000_ICTD = _`x'_1000_ICTD[_n+1] if year==`year'
				replace pct_`x'_NS = _`x'_1000_ICTD * pct_1000_NS
			}
					drop _`x'_1000_ICTD
			}	
			local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
			foreach x of local all_series {
				gen pct_`x' = .  
					order pct_`x', before(gdp_HA)
				replace pct_`x' = pct_`x'_NS if inrange(year,1960,1979)  
				replace source = "HA" if inrange(year,1960,1979) 
				replace pct_`x' = pct_`x'_ICTD if year>1979   
				replace source = "ICTD" if year>1979 				
			}	
			*2000 series
				forval year = 1969 (-1) 1960 {
					replace pct_2000 = pct_2000[_n+1] if year==`year'
				}
			*interpolate 1978-79 & 2012-15	
				replace pct_1000 = . if inrange(year,2012,2015)
				replace pct_1100 = . if inrange(year,2012,2015)
				replace pct_1200 = . if inrange(year,2012,2015)
				replace pct_1300 = . if year==2012 //inappropriate value for interpolation (missing PIT)
				replace pct_6000 = . if inrange(year,2013,2015)
				foreach x in 1100 1200 1300 2000 4000 5000 6000 {
					ipolate pct_`x' year, gen(temp_`x')
						format %9.2fc temp_`x'
						order temp_`x', after(pct_`x')
					replace pct_`x' = temp_`x' if inrange(year,1978,1980) | inrange(year,2012,2015)
						drop temp_`x'
				}
			*1000 series split in 87-89
				replace pct_1300 = . if inrange(year,1987,1989) //for interpolation
				replace pct_1300 = 0 if year==1990 //for interpolation
				foreach x in 1100 1200 1300 {
					gen _`x'_1000 = pct_`x' / pct_1000
						ipolate _`x'_1000 year, gen(_`x'_1000_temp)	
							order _`x'_1000*, after(pct_`x') 
							format %9.2fc _`x'_1000*
					replace pct_`x' = 	_`x'_1000_temp * pct_1000 if inrange(year,1987,1989) //| inrange(year,2012,2015)
							drop _`x'_1000*
				}
			*pct_1300 begins in 1995 is pct_1200
				replace pct_1200 = pct_1200 + pct_1300 if year>1994 & year!=2009 //1300 is missing that year
				replace pct_1300 = . if year>1994
			*4000
				replace pct_4000 = . if year >= 1980
				replace pct_4000 = pct_4000_UN if year>=1990 //IMF & CIAT-IDB
				ipolate pct_4000 year if inrange(year,1979,1990), gen(temp)
				replace pct_4000 = temp if inrange(year,1979,1990) & pct_4000==.
					drop temp
			*1000
					replace pct_1000 = pct_1100 + pct_1200 + pct_1300 if inrange(year,1978,1980)
				foreach x in 1100 1200 {
					replace pct_`x' = . if year >= 1980
					replace pct_`x' = pct_`x'_UN if year>=1990 //IMF & CIAT-IDB
					gen _`x'_1000 = pct_`x' / (pct_1100 + pct_1200) if inlist(year,1979,1990)
					ipolate _`x'_1000 year, gen(temp)
					replace _`x'_1000 = temp if inrange(year,1980,1989)
					replace pct_`x' = _`x'_1000 * pct_1000 if inrange(year,1980,1989)
					drop temp
				}
				replace source="CIAT-IDB" if year>=1990	
			*6000
				replace pct_6000 = 0 if pct_6000 < 0
			*replace the aggregates after stitching (using disaggregates)
					cap drop pct_1000 // pct_5000
				egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
				egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
			*save
				replace stitch = 1 if inlist(year,1981)
				replace interpolated = 1 if inlist(year,1978,1979)
				keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
					order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
				keep if year>=1965
					drop if year==2019 //incomplete
				format %9.2fc pct*
				order stitch interpolated pct_tax, after(source)
				save data/harmonized/CHL.dta, replace
	
					
	*64. KAZ
		use data/revenue_raw, clear	
		keep if country=="KAZ"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
			foreach x of local all_series {
				gen pct_`x' = .  
					order pct_`x', before(gdp_HA)
				replace pct_`x' = pct_`x'_OECD if year>1998  
				replace source = "OECD" if year>1998 
				replace pct_`x' = pct_`x'_ICTD if year<1999   
				replace source = "ICTD" if year<1999 							
			}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000[_n+1] if year==1994
			replace pct_2000 = pct_2000[_n+1] if year==1993		
		*1000
			foreach x in 1100 1200 1300 {
				gen _`x'_1000 = pct_`x' / pct_1000
					order _`x'_1000, after(pct_`x')
					format %9.2fc _`x'_1000
			
				forval year = 1998 (-1) 1993 {
					replace pct_`x' = . if year==`year'
					replace _`x'_1000 = _`x'_1000[_n+1] if year==`year'
					replace pct_`x' = pct_1000  * _`x'_1000 if year==`year'
				}
						drop _`x'_1000
			}
		*4000
			replace pct_4000 = pct_4000_HA if year<1999 //HA picks up better than ICTD (decentralized)
		*6000
			replace pct_6000 = 0 if pct_6000 < 0
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1999)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1993 //post-Soviet
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/KAZ.dta, replace
		
			
	*65. NLD
		use data/revenue_raw, clear	
		keep if country=="NLD"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019)
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/NLD.dta, replace
			
					
	*66. ZMB
		use data/revenue_raw, clear	
		keep if country=="ZMB"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
		}
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
				forval year = 2014 / 2019 {
					replace pct_2000 = pct_2000[_n-1] if year==`year'
				}
		*pre-68
			replace interpolated = 1 if pct_tax==. //we have the total tax level for missing years post-1980; interpolating all of the within-ratios
				*from 1968 extrapolate backward based on pct_tax_HA ratio vs pct_tax_RPC, back to 1965
				gen ratio = pct_tax / pct_tax_RPC if year<1970
					forval year = 1967 (-1) 1965 { 
						replace ratio = ratio[_n+1] if year==`year'
					}
				replace pct_tax = ratio * pct_tax_RPC if year<1968
					drop ratio
		*interpolate the total tax level from ICTD
			gen ratio = pct_tax / pct_tax_ICTD
			ipolate ratio year, gen(ratio2)
				replace ratio = ratio2 if year>1979
				forval year = 2010 / 2019 {
					replace ratio = ratio[_n-1] if year==`year'
				}
			replace pct_tax = ratio * pct_tax_ICTD if year>1979 & pct_tax==.
					drop ratio*	
		*interpolate and extrapolate the within- ratios for tax composition
			foreach x in 1100 1200 1300 4000 5100 5200 5300 6000 {
					gen ratio_`x' = pct_`x' / pct_tax
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
					replace ratio_`x' = ratio_`x'_temp if ratio_`x'==.
						drop ratio_`x'_temp
				forval year = 1967 (-1) 1965 {
					replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
				}
				forval year = 2010 (1) 2019 {
					replace ratio_`x' = ratio_`x'[_n-1] if year==`year'
				}
				replace pct_`x' = ratio_`x' * pct_tax if pct_`x'==.
					drop ratio_`x'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ZMB.dta, replace
		
					
	*67. GTM
		use data/revenue_raw, clear	
		keep if country=="GTM"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year<1990  
			replace source = "HA" if year<1990 
			replace pct_`x' = pct_`x'_OECD if year>1989   
			replace source = "OECD" if year>1989 				
		}
		ren pct_tax* pct_tax_*
		*adjust 2000 using OECD from 1990 extended back to 1978 //RPC corroborates, cf. US SSA
			forval year = 1989 (-1) 1978 {
				replace pct_2000 = pct_2000[_n+1] if year==`year'
			}
		*interpolate the level of tax from 1984 to 89 using HA-to-ICTD ratio unto OECD(minus2000)-to-ICTD ratio
			gen ratio = pct_tax_HA / pct_tax_ICTD if year==1983
				replace ratio = (pct_tax_OECD - pct_2000) / pct_tax_ICTD if year==1990
				ipolate ratio year, gen(ratio2)
			gen pct_tax = ratio2 * pct_tax_ICTD if inrange(year,1984,1989) 
				drop ratio*			
		*interpolate the within ratios for 1100 1200 4000 5000 6000
			replace pct_4000 = 0 if year==1990
			egen sum = rowtotal(pct_1100 pct_1200 pct_4000 pct_5100 pct_5200 pct_6000), missing
			foreach x in 1100 1200 4000 5100 5200 6000 { 
				gen ratio_`x' = pct_`x' / sum if year==1983 | year==1990
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = ratio_`x'_temp * pct_tax if inrange(year,1984,1989)
					drop ratio_`x'*
			}
		*re-assign 1300 in OECD since 1995 (solidarity tax) as 1200
			replace pct_1200 = pct_1200 + pct_1300 if year>1994 & pct_1300!=.
			replace pct_1300 = . if year>1994 & pct_1300!=.
		*put the pre-1978 6000 series into 5000 series (to better match the later classification)
			replace pct_5300 = pct_6000 if year<1978 //this number had been missing
			replace pct_6000 = 0 if year<1978
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			replace interpolated = 1 if inrange(year,1984,1989)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/GTM.dta, replace		
		

	*68. ECU
		use data/revenue_raw, clear	
		keep if country=="ECU"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS
			replace source = "HA" if year < 1990 
			replace source = "OECD" if year > 1989 				
			replace source = "IDB-CIAT" if year > 1992 				
		}	
		*2000 series: HA pre-1990, OECD post-89
				replace pct_2000 = pct_2000_HA if year<1993
			*also OECD 4000 5000 6000 post-1989
				foreach x in 2000 4000 5000 6000 {
					replace pct_`x' = pct_`x'_OECD if inrange(year,1990,1992)
				}
		*1000 series interpolate from 1989-99
			foreach x in 1100 1200 {
				ipolate pct_`x' year, gen(temp_`x')
					order temp_`x', after(pct_`x')
					format %9.2fc temp_`x'
				replace pct_`x' = temp_`x' if inrange(year,1990,1997)
					drop temp_`x'
			}
		*6000
			replace pct_6000 = 0 if pct_6000 < 0
		*source
			replace source = "CIAT-IDB" if source=="IDB-CIAT"
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990,1993)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1973
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ECU.dta, replace	

			
	*69. ZWE
		use data/revenue_raw, clear	
		keep if country=="ZWE"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year > 1988
			forval year = 2014 / 2019 {
				cap replace pct_2000 = pct_2000[_n-1] if year==`year'
			}		
		*interpolate 1998
				replace pct_6000 = 0 if year==1997
				replace pct_4000 = 0 if year==1999
				replace pct_5300 = 0 if year==1999
			foreach x in 1100 1200 1300 4000 5100 5200 5300 6000 { //7000
				ipolate pct_`x' year, gen(temp_`x')
					replace pct_`x' = temp_`x' if year==1998
						drop temp_`x'
			}			
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inlist(year,1998)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1980 //independence
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ZWE.dta, replace	
				
					
	*70. KHM
		use data/revenue_raw, clear	
		keep if country=="KHM"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD"			
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
			forval year = 2014 / 2019 {
				cap replace pct_2000 = pct_2000[_n-1] if year==`year'
			}		
		*interpolate the missing 1000 series split 1994, 2004-05, 2015
			replace pct_1300 = . if inlist(year,1994,2004,2005,2015)
			replace pct_1300 = 0 if pct_1300 == . & !inlist(year,1994,2004,2005,2015)
			foreach x in 1100 1200 1300 {
				gen _`x'_1000 = pct_`x' / pct_1000
				ipolate _`x'_1000 year, gen(_`x'_1000_temp) 
					replace _`x'_1000_temp = _`x'_1000_temp[_n+1] if year==1994 //extrapolate back for this first year
						format %9.2fc _`x'_1000*
						order _`x'_1000*, after(pct_`x')
				replace pct_`x' = _`x'_1000_temp * pct_1000 if inlist(year,1994,2004,2005,2015)
					drop _`x'_1000*
			}			
			*replace the aggregates after stitching (using disaggregates)
					cap drop pct_1000 pct_5000
				egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
				egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
				egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
			*save
				keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
					order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
				keep if year>=1994 //post-Communist and post-war
				format %9.2fc pct*
				gen excomm = 1
				order stitch interpolated excomm pct_tax, after(source)
				save data/harmonized/KHM.dta, replace	
		
					
	*71. SEN
		use data/revenue_raw, clear	
		keep if country=="SEN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)			
			replace pct_`x' = pct_`x'_HA if year<1972  
			replace source = "HA" if year<1972 
			replace pct_`x' = pct_`x'_NS if inrange(year,1972,1984)
			replace source = "HA" if inrange(year,1972,1984)
			replace pct_`x' = pct_`x'_ICTD if inrange(year,1985,1998)
			replace source = "ICTD" if inrange(year,1985,1998)		
			replace pct_`x' = pct_`x'_OECD if year>1998
			replace source = "OECD" if year>1998
		}	
			replace pct_5300 = pct_5000 if source=="IMF"
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if inrange(year,1975,1998)
		*interpolate all within series for 1985-90: 1000 4000 5000 6000
			foreach x in 1000 4000 5000 6000 {
					gen win_`x' = pct_`x' / pct_tax if year==1991
					replace win_`x' = pct_`x' / (pct_tax - pct_2000_NS) if year==1984
				ipolate win_`x' year, gen(win_`x'_temp)
					replace pct_`x' = pct_tax * win_`x'_temp if inrange(year,1985,1990)
						format %9.2fc win_`x'*
						order win_`x'*, after(pct_`x')
							drop win_`x'*
			}
		*extrapolate the IMF 1972 1000 series split back to 1960
				replace pct_1300 = . if year==1991 | year==1992
			foreach x in 1100 1200 1300 {
				gen _`x'_1000 = pct_`x' / pct_1000
				forval year = 1971 (-1) 1960 {
					replace _`x'_1000 = _`x'_1000[_n+1] if year==`year'
				}
				*and interpolate the 1000 series split for 1985-92
				ipolate _`x'_1000 year, gen(_`x'_1000_temp)
						order _`x'_1000*, after(pct_`x')
						format %9.2fc _`x'_1000*
					replace _`x'_1000  = _`x'_1000_temp if inrange(year,1985,1992)
				replace pct_`x' = _`x'_1000 * pct_1000 if year<1972 | inrange(year,1985,1992)
					drop _`x'_1000*
			}
		*4000 series
			ipolate pct_4000 year, gen(temp)
				replace pct_4000 = temp if inrange(year,1985,1992)
					drop temp
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing						
		*save
			replace stitch = 1 if inlist(year,1972,1985,1999)
			replace interpolated = 1 if inrange(year,1985,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SEN.dta, replace
				
					
	*72. TCD
		use data/revenue_raw, clear	
		keep if country=="TCD"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year < 1978  
			replace source = "HA" if year < 1983 
			replace pct_`x' = pct_`x'_ICTD if year >  1982   
			replace source = "ICTD" if year > 1982
			replace pct_`x' = pct_`x'_OECD if year >  2009   
			replace source = "OECD" if year > 2009
		}	
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year>1976 & year<2010	
		*interpolate total (and then within 1000 4000 5000 6000) for years 1978-1982
			ipolate pct_tax year, gen(pct_tax_temp)
				replace pct_tax = pct_tax_temp if inrange(year,1978,1982) 
						drop pct_tax_temp
					replace pct_5000 = . if inrange(year,1983,1985)
					replace pct_5200 = . if inrange(year,1983,1985)
					replace pct_6000 = . if inrange(year,1983,1985)						
			foreach x in 1000 4000 5000 6000 {
					gen win_`x' = pct_`x' / pct_tax if inlist(year,1977,1986) 
				ipolate win_`x' year, gen(win_`x'_temp)
					replace pct_`x' = pct_tax * win_`x'_temp if inrange(year,1978,1985)
				replace win_`x' = pct_`x' / (pct_tax - pct_2000_ICTD) if year==2005
					forval year = 2006 / 2019 {
						replace win_`x' = win_`x'[_n-1] if year==`year'
					}
					replace pct_`x' = pct_tax * win_`x' if year>2005
						format %9.2fc win_`x'*
						order win_`x'*, after(pct_`x')
							drop win_`x'*
			}
		*interpolate the 1000 series split between 1977 and 1994, and extend from 2005 through 2009
			*first extend for 2006-2009
				replace pct_1300 = . if inrange(year,1986,1993)
			foreach x in 1100 1200 1300 {
				gen _`x'_1000 = pct_`x' / pct_1000 if !inrange(year,2006,2009)
					ipolate _`x'_1000 year, gen(temp)
					replace _`x'_1000 = temp if inrange(year,2006,2009)
						drop temp
				*then interpolate for 1978-93
				ipolate _`x'_1000 year, gen(_`x'_1000_temp)
					replace _`x'_1000  = _`x'_1000_temp if inrange(year,1978,1993)
			*now calculate the pct's
				replace pct_`x' = _`x'_1000_temp * pct_1000 if inrange(year,1978,1993) | inrange(year,2006,2009)
					drop _`x'_1000*
			}
		*interpolate 2006-09
			foreach x in 1000 1100 1200 1300 2000 4000 5000 5100 5200 5300 6000 {
					replace pct_`x' = . if inrange(year,2006,2009)
				ipolate pct_`x' year, gen(temp)
					replace pct_`x' = temp if inrange(year,2006,2009)
						drop temp
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1983,2010)
			replace interpolated = 1 if inrange(year,1978,1982) | inlist(year,1992,1993) | inrange(year,2006,2009)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/TCD.dta, replace
		
		
	*73. SOM
		*skip for now
	
				
	*74. GIN
		use data/revenue_raw, clear	
		keep if country=="GIN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)	
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 1980 to match 1981
			foreach x in 1000 2000 5000 6000 {
				replace pct_`x' = ( pct_taxICTD / pct_taxICTD[_n+1] ) * pct_`x'[_n+1] if year==1980
			}	
		*adjust 2000 using RPC
			replace pct_2000 = .001 if year > 1999 // = RPC			
		*extend 1000 series split backward from 1985, forward from 1999
				replace pct_1300 = . if !inrange(year,1985,1999)
				replace pct_1200 = . if !inrange(year,1985,1999)
			foreach x in 1100 1200 1300 {
				gen _`x'_1000 = pct_`x' / pct_1000
					forval year = 2000 / 2019 {
						replace _`x'_1000 = _`x'_1000[_n-1] if year==`year'
					}
					forval year = 1984 (-1) 1980 {
						replace _`x'_1000 = _`x'_1000[_n+1] if year==`year'
					}
				replace pct_`x' = _`x'_1000 * pct_1000 if !inrange(year,1985,1999)
						drop _`x'_1000
			}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inlist(year,1980)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1980 //first post-independence year with data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/GIN.dta, replace
	
			
	*75. RWA
		use data/revenue_raw, clear	
		keep if country=="RWA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year < 1996
			replace source = "HA" if year < 1996
			replace pct_`x' = pct_`x'_OECD if year > 1995 
			replace source = "OECD" if year > 1995				
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year<1996
		*for the years 1990-94, take HA to ICTD ratios 1990 and 94, interpolate, then multiply ICTD to estimate HA
				replace pct_6000 = 0 if year==1995 | year==1980
			foreach x in 1000 4000 5000 6000 {
				gen ratio_`x' = pct_`x'_HA / pct_`x'_ICTD if year==1989 | year==1995
					ipolate ratio_`x' year, gen(ratio_`x'_temp)
						format %9.2fc ratio_`x'*
						order ratio_`x'*, after(pct_`x')
					replace pct_`x' = pct_`x'_ICTD * ratio_`x'_temp if inrange(year,1990,1994)
						drop ratio_`x'**
			}
		*6000 series
			gen win_6000 = pct_6000 / (pct_1000 + pct_4000 + pct_5000) if year == 1989 | year==1995
			ipolate win_6000 year, gen(win_6000_temp)
			replace pct_6000 = win_6000_temp * (pct_1000 + pct_4000 + pct_5000) if inrange(year,1990,1994)								
		*interpolate 1979
			foreach x in 1100 1200 1300 4000 5000 5100 5200 6000 {
				replace pct_`x' = ( pct_`x'[_n+1] + pct_`x'[_n-1] ) / 2 if year==1979
			}
		*interpolate the 1000 series split for the civil war years 1990-94
			foreach x in 1100 1200 1300 {
				gen _`x'_1000 = pct_`x' / pct_1000
				ipolate _`x'_1000 year, gen(_`x'_1000_temp)
				replace pct_`x' = _`x'_1000_temp * pct_1000 if inrange(year,1990,1994)
					drop _`x'_1000*
			}
		*1300 --> 1200
			replace pct_1200 = pct_1200 + pct_1300 if pct_1300!=.
				replace pct_1300 = .
		*interpolate 1995 for transition year
				replace pct_6000 = 0 if year==1996
			foreach x in 1100 1200 2000 4000 5000 6000 {
				replace pct_`x' = ( pct_`x'[_n-1] + pct_`x'[_n+1] ) / 2 if year==1995
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1996)
			replace interpolated = 1 if inlist(year,1979,1995)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1967 //first post-independence year with data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/RWA.dta, replace	
					
			
	*76. CUB
		use data/revenue_raw, clear	
		keep if country=="CUB"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)	
			replace pct_`x' = pct_`x'_OECD
			replace source = "OECD" 
		}
		*CIT early '90s
			replace pct_1200 = 0 if pct_1200==. //1990-92
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1990 //first year with consistent data, perhaps reflects post-Communist transitions
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/CUB.dta, replace	
		
			
	*77. TUN
		use data/revenue_raw, clear	
		keep if country=="TUN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)	
			replace pct_`x' = pct_`x'_OECD if year > 1999
			replace source = "OECD" if year > 1999
			replace pct_`x' = pct_`x'_HA if   year < 2000
			replace source = "HA" if  year < 2000			
		}	
		*adjust 2000 using RPC and ICTD
			replace pct_2000 = pct_2000_RPC if year < 1984
			replace pct_2000 = pct_2000_ICTD if inrange(year,1984,1999)	
		*adjust 1000 4000 5000 6000 interpolating HA via ICTD
			foreach x in 1000 4000 5000 6000 {
				gen ratio_`x' = pct_`x'_HA / pct_`x'_ICTD
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
					order ratio_`x'*, after(pct_`x')
					format %9.2fc ratio_`x'*
				replace pct_`x' = pct_`x'_ICTD * ratio_`x'_temp if inrange(year,1987,1997)
					drop ratio_`x'*
			}		
		*interpolate the 1000 series split from 1986 to 1998
				replace pct_1300 = 0 if year==1998
			foreach x in 1100 1200 1300 {
				gen _`x'_1000 = pct_`x' / pct_1000
				ipolate _`x'_1000 year, gen(_`x'_1000_temp)
					format %9.2fc _`x'_1000*
					order _`x'_1000*, after(pct_`x')
				replace pct_`x' = _`x'_1000_temp * pct_1000 if inrange(year,1987,1997)
					drop _`x'_1000*
			}			
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2000)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/TUN.dta, replace	
			
			
	*78. BEL
		use data/revenue_raw, clear	
		keep if country=="BEL"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .
			order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019)
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BEL.dta, replace
		
			
	*79. BOL
		use data/revenue_raw, clear	
		keep if country=="BOL"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_OECD if year > 1989
			replace source = "OECD" if year > 1989
			replace pct_`x' = pct_`x'_HA if year<1981  
			replace source = "HA" if year<1990				
		}	
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
		*scholarly sources for tax/GDP total back to 1970
			replace pct_tax = 0.105 if year==1970 // & pct_tax==.
			replace pct_tax = 0.092 if year==1971 // & pct_tax==.
			replace pct_tax = 0.093 if year==1972 // & pct_tax==.
			replace pct_tax = 0.115 if year==1973 // & pct_tax==.
			replace pct_tax = 0.128 if year==1974 & pct_tax==.
			replace pct_tax = 0.118 if year==1975 & pct_tax==.
			replace pct_tax = 0.121 if year==1976 & pct_tax==.
			replace pct_tax = 0.117 if year==1977 & pct_tax==.
			replace pct_tax = 0.112 if year==1978 & pct_tax==.
			replace pct_tax = 0.092 if year==1979 & pct_tax==.
			replace pct_tax = 0.096 if year==1980 & pct_tax==.
			replace pct_tax = 0.094 if year==1981 & pct_tax==.
			replace pct_tax = 0.05 if year==1982 & pct_tax==.
			replace pct_tax = 0.029 if year==1983 & pct_tax==.
			replace pct_tax = 0.026 if year==1984 & pct_tax==.
			replace pct_tax = 0.013 if year==1985 & pct_tax==.
			replace pct_tax = 0.103 if year==1986 & pct_tax==.
			replace pct_tax = 0.128 if year==1987 & pct_tax==.						
		*interpolate total for 1988-89
			ipolate pct_tax year, gen(temp)
				replace pct_tax = temp if inrange(year,1988,1989)
					drop temp
			*temper by ratio to RPC in 1970 and RPC tax level pre-1970
				gen ratio = pct_tax / pct_tax_RPC if year==1970
			forval year = 1969 (-1) 1962 {
				replace ratio = ratio[_n+1] if year==`year'
			}
				replace pct_tax = ratio * pct_tax_RPC if inrange(year,1962,1969)
			replace interpolated=1 if pct_1000==.
		*replace disaggregate totals using within ratio for each series 
			*and interpolate those ratios for missing years through 1990 (start OECD)
				replace pct_5100 = . if year<1990
				replace pct_5200 = . if year<1990
				replace pct_5300 = . if year<1990
					replace pct_1200 = 0 if year==1990
					replace pct_1300 = 0 if year==1990
				foreach x in 1100 1200 1300 4000 5000 6000 {
					gen win_`x' = pct_`x' / pct_tax_HA
					ipolate win_`x' year, gen(win_`x'_temp)
						format %9.2fc win_`x'*
						order win_`x'*, after(pct_`x')
					replace pct_`x' = pct_tax * win_`x'_temp if year<1990 //for all missing years pre-OECD, including where there was a pre-existing estimate in HA
						drop win_`x'*
				}
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year<1990
				ipolate pct_2000 year, gen(temp)
					replace pct_2000 = temp if inrange(year,1990,1999)
						drop temp			
		*CIT
			replace pct_1200 = 0 if pct_1200 == . //1991-93
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
				drop if year==2019 //no data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BOL.dta, replace
	
			
	*80. BEN
		use data/revenue_raw, clear	
		keep if country=="BEN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year>1969 // first year of program
				forval year = 2014/2019 {
					replace pct_2000 = pct_2000[_n-1] if year==`year'
				}
		*interpolate the gap 1986-89 from HA via ICTD
				replace pct_6000 = 0 if year==1988 | year==1989 //to avoid ratio problem below
			foreach x in 1000 4000 5000 6000 {
				gen ratio_`x' = pct_`x'_HA / pct_`x'_ICTD if inlist(year,1985,1990)
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = ratio_`x'_temp * pct_`x'_ICTD if pct_`x'==. //because of the pct_6000 above in 88-89
						drop ratio_`x'*
			}
		*and through 2013 HA to ICTD
			foreach x in 1000 4000 5000 6000 {
				gen ratio_`x' = pct_`x'_HA / pct_`x'_ICTD if year==2007
				forval year = 2008 / 2019 {
					replace ratio_`x' = ratio_`x'[_n-1] if year==`year'
				}
					replace pct_`x' = ratio_`x' * pct_`x'_ICTD if year>2007
						drop ratio_`x'*
			}
		*then extrapolate forward through 2016 for pct_tax and same within for 1000 4000 5000 6000
			foreach x in 1000 4000 5000 6000 {
				gen win_`x' = pct_`x' / (pct_taxICTD - pct_2000_ICTD)
				forval year = 2014 / 2019 {
					replace win_`x' = win_`x'[_n-1] if year==`year'
				}
				replace pct_`x' = win_`x' * pct_taxICTD  if year>2013
					drop win_`x'*
			}
		*4000 series
			ipolate pct_4000 year, gen(temp)
				replace pct_4000 = temp if inrange(year,1970,1989) & pct_4000==.
					drop temp
		*carry 1000 series split backward from to 1970 to 1959
			foreach x in 1100 1200 {
				gen _`x'_1000 = pct_`x' / pct_1000
				forval year = 1969 (-1) 1959 {
					replace _`x'_1000 = _`x'_1000[_n+1] if year==`year'
					replace pct_`x' = _`x'_1000 * pct_1000 if year==`year'
						replace pct_1300 = . if year==`year'
				}
			*also interpolate through the gaps 85-90
				ipolate _`x'_1000 year, gen(_`x'_1000_temp)
				replace pct_`x' = _`x'_1000_temp * pct_1000 if inrange(year,1986,1989)		
			*and carry forward same 1000 series split from 2007
				forval year = 2008 / 2019 {
					replace _`x'_1000 = _`x'_1000[_n-1] if year==`year'
					replace pct_`x' = _`x'_1000 * pct_1000 if year==`year'
				}
						drop _`x'_1000*
			}		
			*replace the aggregates after stitching (using disaggregates)
					cap drop pct_1000 //pct_5000
				egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
				egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inrange(year,2014,2019)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BEN.dta, replace
			
			
	*81. HTI
		use data/revenue_raw, clear	
		keep if country=="HTI"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD if year > 1989
			replace source = "ICTD" if year > 1989
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if year<1990
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
			forval year = 2014/2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*interpolate 1000 4000 5000 6000 for the years 88-89
				replace pct_1000 = pct_1100 + pct_1200 + pct_1300 if year==1987
				replace pct_4000 = 0 if year==1990
			foreach x in 1000 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inrange(year,1988,1989)
					drop temp_`x'
			}
		*5100 series 2017-19
			forval year = 2017/2019 {
				replace pct_5100 = pct_5100[_n-1] if year==`year'
			}
			replace pct_5000 = pct_5100 + pct_5200 if year>1989
		*pct_1000 pct_6000 ratios from 2016
			gen subtotal = pct_6000 if year>2016
				replace subtotal = pct_1000 + pct_5100 + pct_6000 if year==2016
			forval year = 2017/2019 {
				foreach x in 1000 6000 {
					replace pct_`x' = ( pct_`x'[_n-1] / subtotal[_n-1] ) * subtotal if year==`year'
				}
			}
				drop subtotal
		*interpolate and extrapolate forward the 1000 series split
			replace pct_1300 = . if inrange(year,1990,1994) | year>2006
			foreach x in 1100 1200 1300 {
					gen _`x'_1000 = pct_`x' / pct_1000
				*interpolate 88-94 1000 series split
					ipolate _`x'_1000 year, gen(_`x'_1000_temp)
						format %9.2fc _`x'_1000*
						order _`x'_1000*, after(pct_`x')
					replace pct_`x' = _`x'_1000_temp * pct_1000 if inrange(year,1988,1994)
				*extrapolate 2006 split values through 2019
					forval year = 2007 / 2019 {
						replace _`x'_1000 = _`x'_1000[_n-1] if year==`year'
						replace pct_`x' = pct_1000 * _`x'_1000 if year==`year'
					}
							drop _`x'_1000*
			}
		*replace the aggregates after stitching (using disaggregates), incl 5000
				cap drop pct_tax 
				cap drop pct_1000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			replace interpolated = 1 if inlist(year,1988,1989)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1975 //first year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/HTI.dta, replace	
	
			
	*82. GRC
		use data/revenue_raw, clear	
		keep if country=="GRC"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_OECD  
			replace source = "OECD" 
		}	
		*impute penultimate 1000 series split to latest year
			foreach x in 1100 1200 1300 {
				gen _`x'_1000 = pct_`x' / pct_1000
					replace _`x'_1000 = _`x'_1000[_n-1] if year==2018 //latest year
				replace pct_`x' = pct_1000 * _`x'_1000 if year==2018 //latest year
						drop _`x'_1000
			}
		*1300 to 1100
			replace pct_1100 = pct_1100 + pct_1300 if pct_1300!=.
			replace pct_1300 = . 
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing		
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/GRC.dta, replace
			
			
	*83. DOM	
		use data/revenue_raw, clear	
		keep if country=="DOM"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year < 1990
			replace source = "HA" if year < 1990
			replace pct_`x' = pct_`x'_OECD if year > 1989  
			replace source = "OECD" if year > 1989				
		}	
		*adjust 2000 using RPC
			*use ICTD pre-OECD, and then ICTD to RPC ratio before then...
			replace pct_2000 = pct_2000_ICTD if inrange(year,1980,1989)
			gen ratio = pct_2000_ICTD / pct_2000_RPC if year==1980
				forval year = 1979 (-1) 1968 {
					replace ratio = ratio[_n+1] if year==`year'
					replace pct_2000 = pct_2000_RPC * ratio if year==`year'
				}
						drop ratio						
		*interpolate 1000 4000 5000 6000 for 1988-89: use ratio to ICTD (HA 1987, OECD 1990)
			foreach x in 1000 4000 5000 6000 {
				gen ratio_`x' = pct_`x' / pct_`x'_ICTD if year==1987 | year==1990
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = ratio_`x'_temp * pct_`x'_ICTD if year==1988 | year==1989
					drop ratio_`x'*
			}
		*take the ICTD for 1300 split pre-2000, interpolate in 1999, pre-1980
				replace pct_1300_ICTD = 0 if pct_1300_ICTD==. & inrange(year,1980,2019)
			foreach x in 1100 1200 1300 {
				gen ratio_`x' = pct_`x'_ICTD / pct_1000_ICTD if year<1999 
				replace ratio_`x' = pct_`x'_OECD / pct_1000_OECD if year==2000 
					replace pct_1300 = . if  year<2000
					replace ratio_`x' = (ratio_`x'[_n-1] + ratio_`x'[_n+1] ) / 2 if year==1999							
				forval year = 1979 (-1) 1968 {
					replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
				}
				replace pct_`x' = ratio_`x' * pct_1000 if year<2000 
						drop ratio_`x'*
			}
		*6000 series interpolation in 1989
			replace pct_6000 = ( pct_6000[_n-1] + pct_6000[_n+1] ) / 2 if year==1989 
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			replace interpolated = 1 if inlist(year,1988,1989)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1968 //first year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/DOM.dta, replace
	
			
	*84. CZE
		use data/revenue_raw, clear	
		keep if country=="CZE"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD 
			replace source = "OECD"
		}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing		
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1993 //first year post-Soviet with consistent data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/CZE.dta, replace
				
			
	*85. BDI
		use data/revenue_raw, clear	
		keep if country=="BDI"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA"		
			replace pct_`x' = pct_`x'_NS if inrange(year,1973,1981)   
			replace source = "HA" if inrange(year,1973,1981) 				
		}	
		*2013-14 based on ICTD for some series
			foreach x in 1000 4000 5000 /*6000*/ { 
				replace pct_`x' = pct_`x'_ICTD if year>2012
			}
		*interpolate from HA to IMF in 1971-72
				replace pct_6000 = 0 if year==1970
			foreach x in 1000 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x') 
				replace pct_`x' = temp_`x' if year==1971 | year==1972
					drop temp_`x'
			}
		*1000 series split, backward from 1973, forward from 2012
			foreach x in 1100 1200 1300 {
				replace pct_`x' = . if year <1973 
				gen ratio_`x' = pct_`x' / pct_1000
					forval year = 1972 (-1) 1962 {
						replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
					}
					forval year = 2013 / 2014 {
						replace ratio_`x' = ratio_`x'[_n-1] if year==`year'
					}
				replace pct_`x' = pct_1000 * ratio_`x' if !inrange(year,1973,2012)
					drop ratio_`x'
			}
			*additional data
				local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
				foreach x of local all_series {
					replace pct_`x' = pct_`x'_UN if year>2001
					replace source = "HA" if year>2001			
				}	
					replace pct_5100=. if year>2001
					replace pct_5200=. if year>2001
			*adjust 2000 using RPC
				replace pct_2000 = pct_2000_RPC if !inrange(year,1973,1983)
					ipolate pct_2000 year, gen(temp)
					replace pct_2000 = temp if year==1982 | year==1983
						drop temp
				forval year = 2014/2019 {
						replace pct_2000 = pct_2000[_n-1] if year==`year' //extrapolating RPC
				}
		*source
			replace source = "HA" if source=="NS" //for clarity
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1973,1982,2002)
			replace interpolated = 1 if inlist(year,1971,1972)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BDI.dta, replace
			
			
	*86. PRT
		use data/revenue_raw, clear	
		keep if country=="PRT"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)			
			replace pct_`x' = pct_`x'_OECD  
			replace source = "OECD" 
		}	
		*here we calculate the part of 1300 that is actually 1100, 1200, and still 1300
			merge 1:1 year using data/misc/auxiliary/PRT_ratios, nogen
					replace pct_1100 = 0 if year < 1989
					replace pct_1200 = 0 if year < 1989
					gen pct_1300_2 = pct_1300 if year <1992
					replace pct_1300 = 0 if year < 1992
				foreach x in 1100 1200 1300 {
					replace pct_`x' = pct_`x' + ratio_`x' * pct_1300_2 if year<1992
				}
						drop ratio* pct_1300_2

		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000
			keep if year>=1965 & pct_tax!=. //no 2019 data (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/PRT.dta, replace
			
			
	*87. SWE
		use data/revenue_raw, clear	
		keep if country=="SWE"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965 & pct_tax!=. //no 2019 data (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SWE.dta, replace
			
			
	*88. HUN
		use data/revenue_raw, clear	
		keep if country=="HUN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1990
			replace source = "OECD" if year > 1990
			replace pct_`x' = pct_`x'_ICTD if  inrange(year,1981,1990) 
			replace source = "ICTD" if inrange(year,1981,1990)				
		}	
		*use IMF historical source for 1981-87 (not 88-89?)
			replace pct_1200 = pct_1000 * 0.993523316062176 if year==1981
			replace pct_1200 = pct_1000 * 0.99002849002849 if year==1982
			replace pct_1200 = pct_1000 * 0.961493582263711 if year==1983
			replace pct_1200 = pct_1000 * 0.95855472901169 if year==1984
			replace pct_1200 = pct_1000 * 0.931330472103004 if year==1985
			replace pct_1200 = pct_1000 * 0.965412004069176 if year==1986
			replace pct_1200 = pct_1000 * 0.965841161400512 if year==1987
			replace pct_1200 = pct_1000 * 0.959546925566343 if year==1988
			replace pct_1200 = pct_1000 * 0.835020845741513 if year==1989
			replace pct_1100 = pct_1000 - pct_1200 if inrange(year,1981,1989)
			replace pct_1300 = 0 if inrange(year,1981,1989)	

*extrapolate 1980 //cf. Egger et al
	foreach var of varlist source - pct_6000 {
		replace `var' = `var'[_n+1] if year==1980
		}
	replace interpolated = 1 if inlist(year,1980)
	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
keep if year>=1980 //first year of data, perhaps reflecting political economy transition
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/HUN.dta, replace
		
			
	*89. AZE
		use data/revenue_raw, clear	
		keep if country=="AZE"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)	
			replace pct_`x' = pct_`x'_HA if year>1994   
			replace source = "HA" if  year>=1994							
		}	
		*1300 is actually 1100 in ICTD and 1200 in HA, except 1200 in 2016
			replace pct_1200 = pct_1300 if year>1994
			replace pct_1300 = .
		*2000 see RPC compare to ICTD
			replace pct_2000 = pct_2000_RPC if inrange(year,1994,1998)
			replace pct_2000 = pct_2000_UN if inrange(year,1998,2017)
			replace pct_2000 = (pct_2000_UN[_n-1]/pct_2000_ICTD[_n-1])*pct_2000_ICTD if year==2018
		*HA extend by way of ICTD, with attention to ICTD 5300 and 6000
			replace pct_5300_ICTD = . if year>2016
			replace pct_5000_ICTD = pct_5100_ICTD + pct_5200_ICTD if year>2016
			replace pct_6000_ICTD = pct_6000_ICTD[_n-1] if year==2016
			forval year = 2017/2018{	
				foreach x in 1100 1200 4000 5000 6000 {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_`x'_ICTD[_n-1] ) * pct_`x'_ICTD	if year==`year'
				}
			}
		*4000 series
			forval year = 2017 / 2018 {
				replace pct_4000 = pct_4000[_n-1] if year==`year'
			}
		*1994
			foreach var of varlist pct_1000 - pct_6000 {
				replace `var' = `var'[_n+1] if year==1994
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1994 //first year of consistent data, perhaps reflecting political economy transition
			format %9.2fc pct*
			replace interpolated=1 if year==1994
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/AZE.dta, replace

			
	*90. BLR
		use data/revenue_raw, clear	
		keep if country=="BLR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 1992-2002 by the 2002 ratio of ICTD to Article IV (ICTD used Art IV but lacks 5200 series)
			gen ratio = pct_5000 / .126 if year==2002
			replace ratio = pct_5000 / .128 if year==2003
			forval year = 2001 (-1) 1992 {
				replace ratio = ratio[_n+1] if year==`year'
			}
			forval year = 2004 / 2019 {
				replace ratio = ratio[_n-1] if year==`year'
			}							
			replace pct_5000 = pct_5000 / ratio
				drop ratio
		*4000 series
			replace pct_4000 = pct_4000[_n+1] if year==1992 //predicted value of missing data
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1993 //first year of consistent data, perhaps reflecting political economy transition
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/BLR.dta, replace
		
		
	*91. JOR
		use data/revenue_raw, clear	
		keep if country=="JOR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_ICTD if year > 1989
			replace source = "ICTD" if year > 1989
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if  year < 1990				
		}	
		*interpolate 1000 series split 1980-88
			foreach x in 1100 1200 {
				gen _`x'_sum = pct_`x' / (pct_1100 + pct_1200) ==1979 | year==1988
				ipolate _`x'_sum year, gen(_`x'_temp)
					format %9.2fc _*
					order _*, after(pct_`x')
				replace pct_`x' = _`x'_temp * (pct_1000 - pct_1300) if inrange(year,1980,1987)
						drop _*
			}
		*4000 series
			ipolate pct_4000 year, gen(temp)
				replace pct_4000 = temp if pct_4000==. 
					drop temp
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1973 //first year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/JOR.dta, replace
			
			
	*92. ARE
		*skip for now

	
	*93. HND
		use data/revenue_raw, clear	
		keep if country=="HND"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year < 1990 
			replace source = "HA" if year < 1990
			replace pct_`x' = pct_`x'_OECD if  year > 1989
			replace source = "OECD" if year > 1989					
		}	
		*adjust 2000 using RPC
			gen ratio = pct_2000_OECD / pct_2000_RPC if year==1990
			forval year = 1989 (-1) 1965 {
				replace ratio = ratio[_n+1] if year==`year'								
			}
			replace pct_2000 = pct_2000_RPC * ratio if year < 1990
					drop ratio
		*1974					
			replace pct_4000 = 0.000891305742 if year==1974 //IMF level, over WID GDP
			replace pct_1000 = pct_6000 - pct_4000 if year==1974 //we say that the HA had "other taxes" to include direct taxes 1000 and 4000
			replace pct_6000 = . if year==1974
			replace pct_6000 = 0 if pct_6000==. & inrange(year,1974,1977)
		*interpolate tax subtotal
			gen pct_tax = pct_1000 + pct_2000 + pct_4000 + pct_5000 + pct_6000
				ipolate pct_tax year, gen(temp)
				replace pct_tax = temp
					drop temp
		*interpolate main disaggregates
			foreach x in 1000 4000 5000 6000 {
				gen ratio_`x' = pct_`x' / (pct_tax - pct_2000)
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
					order ratio_`x'*, after(pct_`x')
					format %9.2fc ratio_`x'*
				replace pct_`x' = ratio_`x'_temp * (pct_tax - pct_2000) if pct_`x'==.
						drop ratio_`x'*
			}			
		*for 1000 series split use IMF historical to take the ratios 1972-81 for PIT / 1000
			gen ratio_1100 = pct_1100 / pct_1000
			replace ratio_1100 = 0.275285403154393 if year==1965
			replace ratio_1100 = 0.147446112244026 if year==1966
			replace ratio_1100 = 0.131789531861852 if year==1967
			replace ratio_1100 = 0.137660432336333 if year==1968
			replace ratio_1100 = 0.149893386721357 if year==1969
			replace ratio_1100 = 0.166946328551509 if year==1970
			replace ratio_1100 = 0.190977964081068 if year==1971
			replace ratio_1100 = 0.235443037974684 if year==1972
			replace ratio_1100 = 0.243128964059197 if year==1973
			replace ratio_1100 = 0.296636085626911 if year==1974
			replace ratio_1100 = 0.276510067114094 if year==1975
			replace ratio_1100 = 0.401907356948229 if year==1976
			replace ratio_1100 = 0.434065934065934 if year==1977
			replace ratio_1100 = 0.446515397082658 if year==1978
			replace ratio_1100 = 0.453809844908968 if year==1979
			replace ratio_1100 = 0.313776618861365 if year==1980
			replace ratio_1100 = 0.287228109313999 if year==1981
			replace pct_1100 = pct_1000 * ratio_1100 if year<1982
			replace pct_1200 = pct_1000 - pct_1100 if year<1982
			replace pct_1300 = . <1982
				drop ratio*
		*interpolate the within-ratio for 1000 series split in 1989
			foreach x in 1100 1200 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
					order ratio_`x'*, after(pct_`x')
					format %9.2fc ratio_`x'*
				replace pct_`x' = ratio_`x'_temp * pct_1000 if pct_`x'==. 
						drop ratio_`x'*
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			replace interpolated = 1 if inlist(year,1978,1980,1982,1983)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1973 //first year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/HND.dta, replace
		
		
	*94. AUT
		use data/revenue_raw, clear	
		keep if country=="AUT"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/AUT.dta, replace

			
	*95. ISR
		use data/revenue_raw, clear	
		keep if country=="ISR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1994
			replace source = "OECD" if year > 1992
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if year<1993			
		}
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
		*adjust 2000 using UN
			replace pct_2000 = pct_2000_UN if inrange(year,1972,1974)
		*extend to 1990 the IMF by way of ICTD
			foreach x in 1000 1100 1200 1300 2000 4000 5000 6000 {
				replace pct_`x' = pct_`x'_NS[_n-1] / pct_`x'_ICTD[_n-1] * pct_`x'_ICTD if year==1990
			}
				replace source = "IMF" if year==1990
		*adjust 4000 series by way of ICTD
			replace pct_4000 = pct_4000_ICTD if inrange(year,1980,1991)
			gen diff = pct_4000_ICTD - pct_4000_NS if year==1980
			forval year = 1979 (-1) 1972 {
				replace diff = diff[_n+1] if year==`year'
				replace pct_4000 = pct_4000 + diff if year==`year'
			}
				drop diff									
		*interpolate pct_tax_ICTD for 1991 and also use value for 92-94
				replace pct_tax = pct_1000 + pct_2000 + pct_4000 + pct_5000 + pct_6000 if year<1991 //better now (including 1990 and updated 4000 series)
			ipolate pct_tax_ICTD year, gen(temp)
				replace pct_tax = temp if year==1991
			replace pct_tax = pct_tax_ICTD if inrange(year,1992,1994)
				drop temp
		*then take within ratios and multiply by the overall tax/GDP
			replace pct_6000 = 0 if year==1995
		foreach x in 1100 1200 1300 2000 4000 5000 6000 {
			gen ratio_`x' = pct_`x' / pct_tax
			ipolate ratio_`x' year, gen(ratio_`x'_temp)
			replace pct_`x' = ratio_`x'_temp * pct_tax if inrange(year,1991,1994)
					drop ratio_`x'*
		}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1993)
			replace interpolated = 1 if inrange(year,1991,1994)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //first year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ISR.dta, replace
			
			
	*96. CHE
		use data/revenue_raw, clear	
		keep if country=="CHE"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*1300 is actually allocable to PIT vs K tax (tax on property gains) //calculated from raw OECD numbers
			*1100
				replace pct_1100 = pct_1100 + 0.665277493118558 * pct_1300 if year==1990
				replace pct_1100 = pct_1100 + 0.7253992963892 * pct_1300 if year==1991
				replace pct_1100 = pct_1100 + 0.744308019932068 * pct_1300 if year==1992
				replace pct_1100 = pct_1100 + 0.625753724390252 * pct_1300 if year==1993
				replace pct_1100 = pct_1100 + 0.742772052302618 * pct_1300 if year==1994
				replace pct_1100 = pct_1100 + 0.620216900869203 * pct_1300 if year==1995
				replace pct_1100 = pct_1100 + 0.755105594291949 * pct_1300 if year==1996
				replace pct_1100 = pct_1100 + 0.725805886376451 * pct_1300 if year==1997
				replace pct_1100 = pct_1100 + 0.812919025233744 * pct_1300 if year==1998
				replace pct_1100 = pct_1100 + 0.641516690422415 * pct_1300 if year==1999
				replace pct_1100 = pct_1100 + 0.868672371574104 * pct_1300 if year==2000
				replace pct_1100 = pct_1100 + 0.491398229894326 * pct_1300 if year==2001
				replace pct_1100 = pct_1100 + 0.712280925250313 * pct_1300 if year==2002
				replace pct_1100 = pct_1100 + 0.638315256173787 * pct_1300 if year==2003
				replace pct_1100 = pct_1100 + 0.717339404273529 * pct_1300 if year==2004
				replace pct_1100 = pct_1100 + 0.787699883151824 * pct_1300 if year==2005
				replace pct_1100 = pct_1100 + 0.765662298114859 * pct_1300 if year==2006
				replace pct_1100 = pct_1100 + 0.747253225022777 * pct_1300 if year==2007
				replace pct_1100 = pct_1100 + 0.821710425322881 * pct_1300 if year==2008
				replace pct_1100 = pct_1100 + 0.74886875072164 * pct_1300 if year==2009
				replace pct_1100 = pct_1100 + 0.758708153846006 * pct_1300 if year==2010
				replace pct_1100 = pct_1100 + 0.737806744939125 * pct_1300 if year==2011
				replace pct_1100 = pct_1100 + 0.690319941880289 * pct_1300 if year==2012
				replace pct_1100 = pct_1100 + 0.734275233366777 * pct_1300 if year==2013
				replace pct_1100 = pct_1100 + 0.731466742345431 * pct_1300 if year==2014
				replace pct_1100 = pct_1100 + 0.764658122265302 * pct_1300 if year==2015
				replace pct_1100 = pct_1100 + 0.721682709905282 * pct_1300 if year==2016
				replace pct_1100 = pct_1100 + 0.806362357613336 * pct_1300 if year==2017
				replace pct_1100 = pct_1100 + 0.802342588839206 * pct_1300 if year==2018
			*1200
				replace pct_1200 = pct_1200 + 0.334722506881442 * pct_1300 if year==1990
				replace pct_1200 = pct_1200 + 0.2746007036108 * pct_1300 if year==1991
				replace pct_1200 = pct_1200 + 0.255691980067932 * pct_1300 if year==1992
				replace pct_1200 = pct_1200 + 0.374246275609748 * pct_1300 if year==1993
				replace pct_1200 = pct_1200 + 0.257227947697382 * pct_1300 if year==1994
				replace pct_1200 = pct_1200 + 0.379783402031128 * pct_1300 if year==1995
				replace pct_1200 = pct_1200 + 0.244894405708051 * pct_1300 if year==1996
				replace pct_1200 = pct_1200 + 0.274194113623549 * pct_1300 if year==1997
				replace pct_1200 = pct_1200 + 0.187080974766256 * pct_1300 if year==1998
				replace pct_1200 = pct_1200 + 0.358483309577585 * pct_1300 if year==1999
				replace pct_1200 = pct_1200 + 0.131327628425896 * pct_1300 if year==2000
				replace pct_1200 = pct_1200 + 0.508601770105674 * pct_1300 if year==2001
				replace pct_1200 = pct_1200 + 0.287719074749687 * pct_1300 if year==2002
				replace pct_1200 = pct_1200 + 0.361685132707778 * pct_1300 if year==2003
				replace pct_1200 = pct_1200 + 0.282660595726471 * pct_1300 if year==2004
				replace pct_1200 = pct_1200 + 0.212300116848176 * pct_1300 if year==2005
				replace pct_1200 = pct_1200 + 0.234337895893541 * pct_1300 if year==2006
				replace pct_1200 = pct_1200 + 0.252746774977223 * pct_1300 if year==2007
				replace pct_1200 = pct_1200 + 0.178289446752768 * pct_1300 if year==2008
				replace pct_1200 = pct_1200 + 0.251131249278359 * pct_1300 if year==2009
				replace pct_1200 = pct_1200 + 0.241291846153994 * pct_1300 if year==2010
				replace pct_1200 = pct_1200 + 0.262193406855628 * pct_1300 if year==2011
				replace pct_1200 = pct_1200 + 0.309680058119711 * pct_1300 if year==2012
				replace pct_1200 = pct_1200 + 0.265724766633222 * pct_1300 if year==2013
				replace pct_1200 = pct_1200 + 0.268533257654569 * pct_1300 if year==2014
				replace pct_1200 = pct_1200 + 0.235341877734698 * pct_1300 if year==2015
				replace pct_1200 = pct_1200 + 0.278317290094718 * pct_1300 if year==2016
				replace pct_1200 = pct_1200 + 0.193637642386664 * pct_1300 if year==2017
				replace pct_1200 = pct_1200 + 0.197657411160794 * pct_1300 if year==2018
			*1300	
				replace pct_1300 = .
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/CHE.dta, replace
			
			
	*97. PNG
		use data/revenue_raw, clear	
		keep if country=="PNG"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1999
			replace source = "OECD" if year > 1999
			replace pct_`x' = pct_`x'_HA if year < 1975 | inrange(year, 1990,1999)
			replace source = "HA" if year < 1975 | inrange(year, 1990,1999)			
			replace pct_`x' = pct_`x'_NS if inrange(year,1975,1989)   
			replace source = "HA" if inrange(year,1975,1989) 				
		}		
		*adjust the first two OECD years 5000 series (missing 5200 series, cf. HA and IMF)
			forval year = 2001 (-1) 2000 {
				replace pct_5000 =  pct_5000_HA * ratio_WB if year==`year'
				replace pct_5100 = . if year==`year'
			}
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if inrange(year,1980,1999)
			replace pct_2000 = ( pct_2000[_n-1] + pct_2000[_n+1] ) / 2 if year==2015
		*interpolate the rest
				replace pct_6000 = 0 if year == 2000
				replace pct_1300 = 0 if year == 2000
			foreach x in 1100 1200 1300 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if pct_`x'==. & temp_`x'!=.
					drop temp_`x'
			}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1975,1992,2000)
			replace interpolated = 1 if inlist(year,1990,1991,1995,1998,1999)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965 //first year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/PNG.dta, replace
		
			
	*98. TGO
		use data/revenue_raw, clear	
		keep if country=="TGO"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1999
			replace source = "OECD" if year > 1999	
			replace pct_`x' = pct_`x'_HA if  year < 2000
			replace source = "HA" if year < 2000				
		}	
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if inrange(year,1968,1999)		
		*interpolate everything for 81-82
			*start with overall level from ICTD (based on ratio of HA to ICTD on either side)
				gen ratio = pct_tax / pct_tax_ICTD
					ipolate ratio year, gen(ratio_temp)
					replace pct_tax = ratio_temp * pct_tax_ICTD if inrange(year,1981,1982)
							drop ratio*
			*then move to the within ratios of HA
				foreach x in 1000 4000 5000 6000 {
					gen temp_`x' = pct_`x' / (pct_1000 + pct_4000 + pct_5000 + pct_6000) ==1980 | year==1983
					ipolate temp_`x' year, gen(temp_`x'_temp)
					replace pct_`x' = temp_`x'_temp * pct_tax if inrange(year,1981,1982)
						drop temp_`x'*
				}
		*interpolate 88-99 based on ratio to ICTD, for 1000 4000 5000 6000
			*for each item, interpolate ratios of HA to ICTD vs OECD to ICTD, then make them meet
				foreach x in 1000 4000 5000 6000 {
					gen ratio_`x' = pct_`x' / pct_`x'_ICTD
					ipolate ratio_`x' year, gen(ratio_`x'_temp)
					replace pct_`x' = ratio_`x'_temp * pct_`x'_ICTD if inrange(year,1988,1999)
							drop ratio_`x'* 
				}
			*same again but slightly adjusted for 4000 series because missing in ICTD (although not missing in HA or OECD) 1987-2000
				gen ratio = pct_4000 / pct_tax_ICTD
				ipolate ratio year, gen(ratio_temp)
				replace pct_4000 = ratio_temp * pct_tax_ICTD if inrange(year,1988,1999)
					drop ratio*
		*interpolate within the 1000 series split from 1974 to 1977, and for missing years 81-82, and the period 1987-2000
				replace pct_1300 = 0 if year==2000
			foreach x in 1100 1200 1300 {
				replace pct_`x'=. if inrange(year,1975,1976) // | inrange(year,1981,1982) | inrange(year,1988,1999)
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = pct_1000 * ratio_`x'_temp if inrange(year,1975,1976) | inrange(year,1981,1982) | inrange(year,1988,1999) //more later
					drop ratio_`x'*
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2000)
			replace interpolated = 1 if inlist(year,1981,1982)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1966 //first year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/TGO.dta, replace
			
			
	*99. SLE
		use data/revenue_raw, clear	
		keep if country=="SLE"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "IMF" if year < 1990
			replace pct_`x' = pct_`x'_ICTD if year > 1989
			replace source = "ICTD" if year > 1989 				
			replace pct_`x' = pct_`x'_HA if year < 1974
			replace source = "HA" if year < 1974
		}
		*interpolate for 1965 67 68
			foreach x in 1100 1200 1300 2000 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inlist(year,1965,1967,1968)
					drop temp_`x'
			}		
		*adjust 2000 using RPC
			gen ratio = pct_2000 / pct_2000_RPC
			forval year = 1990 / 2013 {
				replace ratio = ratio[_n-1] if year==`year'
				replace pct_2000 = ratio * pct_2000_RPC if year==`year'
			}
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*interpolate 1300 split 1990-97
				replace pct_1300 = . if inrange(year,1990,1997)
			foreach x in 1100 1200 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
					order ratio_`x'*, after(pct_`x')
					format %9.2fc ratio_`x'*
				replace pct_`x' = ratio_`x'_temp * pct_1000 if inrange(year,1990,1997)
						drop ratio_`x'*
			}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1974,1990)
			replace interpolated = 1 if inlist(year,1965,1967,1968)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SLE.dta, replace
		
		
	*100. BGR
		use data/revenue_raw, clear				
		keep if country=="BGR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
		}	
		*2000 series from ICTD
		replace pct_2000 = pct_2000_ICTD
			replace pct_1300 = 0 if year==2009
			replace pct_4000 = 0 if year==2009
		*interpolate
		foreach x in 1100 1200 1300 2000 4000 5000 6000 {
			ipolate pct_`x' year, gen(temp_`x')
			replace pct_`x' = temp_`x' if pct_`x'==. & gdp_HA==. //only interpolates these compo for the years where everything is missing
				drop temp_`x'
		}
		*extend HA by way of ICTD
		forval year = 2018/2019{	
			foreach x in 1100 1200 4000 5000 6000 {
				replace pct_`x' = ( pct_`x'[_n-1] / pct_`x'_ICTD[_n-1] ) * pct_`x'_ICTD	if year==`year'
			}
		}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inlist(year,2001,2005,2010,2011,2012)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1993 //first year of consistent data, likely reflecting political economy transition
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/BGR.dta, replace
	
			
	*101. SRB
		use data/revenue_raw, clear	
		keep if country=="SRB"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*interpolate 2016-17
			foreach x in 1000 1100 1200 1300 2000 4000 5000 6000 {
			ipolate pct_`x' year, gen(temp_`x')
			replace pct_`x' = temp_`x' if inrange(year,2016,2017)
				drop temp_`x'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inlist(year,2016,2017)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=2000 //first year of consistent data, likely reflecting political economy transition
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/SRB.dta, replace
		
			
	*102. LAO
		use data/revenue_raw, clear	
		keep if country=="LAO"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  if year<2010
			replace source = "ICTD" if year<2010
			replace pct_`x' = pct_`x'_OECD  if year>2009
			replace source = "OECD" if year>2009
		}	
		*extrapolate the early ratios pre-1994
			foreach x in 5000 5100 5200 6000 {
				replace pct_`x' = . if inrange(year,1982,1993)
			}
			foreach x in 1100 1200 4000 5000 6000 {
				gen ratio_`x' = pct_`x' / pct_taxICTD if year==1994 
						order ratio_`x', after(pct_`x')
						format %9.2fc ratio_`x'
					forval year = 1993 (-1) 1982 {
						replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
					}
				replace pct_`x' = ratio_`x' * pct_taxICTD if inrange(year,1982,1993)
					drop ratio_`x'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if year==2010
			replace interpolated = 1 if inrange(year,1982,1993)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1982 //first year of consistent data, likely reflecting political economy transition
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/LAO.dta, replace
		
			
	*103. PRY
		use data/revenue_raw, clear	
		keep if country=="PRY"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1989
			replace source = "OECD" if year > 1989
			replace pct_`x' = pct_`x'_HA if  year < 1990 
			replace source = "HA" if year < 1990				
		}		
		*bridge the HA by way of IMF
			foreach x in 1000 4000 5000 6000 { 
				gen ratio_`x' = pct_`x' / pct_`x'_NS 
					ipolate ratio_`x' year, gen(ratio_`x'_temp)
					replace pct_`x' = ratio_`x'_temp * pct_`x'_NS if inrange(year,1974,1977)
						drop ratio_`x'*
			}
		*extend the IMF one year further by way of ICTD
			foreach x in 1000 4000 5000 6000 { 
				replace pct_`x'_NS = ( pct_`x'_NS[_n-1] / pct_`x'_ICTD[_n-1] ) * pct_`x'_ICTD if year==1990
			}								
		*then bridge the HA to OECD by way of IMF
			foreach x in 1000 4000 5000 6000 { 
				gen ratio_`x' = pct_`x' / pct_`x'_NS 
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = ratio_`x'_temp * pct_`x'_NS if inrange(year,1983,1989) 
						drop ratio_`x'*
			}		
		*use 1000 series split for 1972-89, and bridge to OECD's in 1999
				replace pct_1300 = . 
			foreach x in 1100 1200 {
				gen ratio_`x' = pct_`x'_NS / pct_1000_NS if year < 1990
				replace ratio_`x' = pct_`x'_OECD / pct_1000_OECD if year > 1989
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 1971 (-1) 1950 { 
					replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
					replace ratio_`x'_temp = ratio_`x' if year==`year'
				}
				replace pct_`x' = ratio_`x'_temp * pct_1000
						drop ratio_`x'*
			}
		*2000 series
			replace pct_2000 = pct_2000_RPC if year<1999		
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/PRY.dta, replace
			
			
	*104. SLV	
		use data/revenue_raw, clear	
		keep if country=="SLV"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1989
			replace source = "OECD" if year > 1989	
			replace pct_`x' = pct_`x'_HA if  year < 1990 
			replace source = "HA" if year < 1990				
		}	
		*adjust 2000 using RPC (and interpolate ...)
			replace pct_2000 = pct_2000_RPC if year==1960 // /*2.5*/ if inrange(year,1960,1985)
				ipolate pct_2000 year, gen(temp)
				replace pct_2000 = temp if inrange(year,1961,1989)
					drop temp			
		*use 1000 4000 5000 from IMF			
			foreach x in 1000 4000 5000 {
			gen ratio_`x' = pct_`x' / pct_`x'_NS // if inlist(year,1984,1990)
			forval year = 1979 / 1989 {
				replace ratio_`x' = ratio_`x'[_n-1] if year==`year'
			}
			replace pct_`x' = ratio_`x' * pct_`x'_NS if inrange(year,1979,1989) // | inrange(year,1983,1984)
					drop ratio_`x'*
			}
		*6000 series
			ipolate pct_6000 year, gen(temp)
			replace pct_6000 = temp if inrange(year,1979,1989)
				drop temp
		*use 1000 series split for 1972-89 where needed, and bridge to OECD's in 2001
				replace pct_1300 = 0 if inrange(year,1990,2001) 
				replace pct_1300 = . if inrange(year,1970,1973) | year < 1964
				replace pct_1100 = . if year < 1964
			foreach x in 1100 1200 1300 {
				gen ratio_`x' = pct_`x'_NS / pct_1000_NS if inrange(year,1972,1973) | inrange(year,1979,1989)
				replace ratio_`x' = pct_`x' / pct_1000 if pct_1100!=.
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 1963 (-1) 1960 { 
					replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
					replace ratio_`x'_temp = ratio_`x' if year==`year'
				}
				replace pct_`x' = ratio_`x'_temp * pct_1000
						drop ratio_`x'*
			}
			replace pct_1300 = 0 if pct_1300 < 0
		*1989 interpolation
			foreach x in 1100 1200 1300 4000 5000 6000 {
				replace pct_`x' = ( pct_`x'[_n-1] + pct_`x'[_n+1] ) / 2 if year==1989
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inlist(year,1989)
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SLV.dta, replace
			
			
	*105. NIC
		use data/revenue_raw, clear	
		keep if country=="NIC"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if year < 1990
			replace pct_`x' = pct_`x'_OECD if  year > 1989  
			replace source = "OECD" if  year > 1989  				
			replace pct_`x' = pct_`x'_HA if year < 1972
			replace source = "HA" if year < 1972
		}				
		*2000 series, extrapolate ratio pre-1972
			gen ratio = pct_2000 / pct_2000_RPC if year==1972
			forval year = 1971 (-1) 1965 {
				replace ratio = ratio[_n+1] if year==`year'
				replace pct_2000 = ratio * pct_2000_RPC if year==`year'
			}
					drop ratio
		*1300 adjustment
			replace pct_1300 = . //if...			
		*interpolation 1990
			foreach x in 1000 2000 4000 5000 6000 {
				replace pct_`x' = ( pct_`x'[_n-1] + pct_`x'[_n+1] ) /2  if year==1990
			}		
		*get 1300 split from CIAT
			gen ratio_1100=.		
			replace ratio_1100=0.261660221444448 if year==2000
			replace ratio_1100=0.297035184893993 if year==2001
			replace ratio_1100=0.275961418619594 if year==2002
			replace ratio_1100=0.244987493770513 if year==2003
			replace ratio_1100=0.240551672144047 if year==2004
			replace ratio_1100=0.237121641579946 if year==2005
			replace ratio_1100=0.256502143853864 if year==2006
			replace ratio_1100=0.259045174786576 if year==2007
			replace ratio_1100=0.274887164209756 if year==2008
			replace ratio_1100=0.247981329992527 if year==2009
			replace ratio_1100=0.222400712542605 if year==2010
			replace ratio_1100=0.208250797840918 if year==2011
			replace ratio_1100=0.226158400937403 if year==2012
			replace ratio_1100=0.212539369856217 if year==2013
			replace ratio_1100=0.208954159336494 if year==2014
			replace ratio_1100=0.20793846567387 if year==2015
			replace ratio_1100=0.216604549493497 if year==2016
			replace ratio_1100=0.226486842713258 if year==2017
			replace ratio_1100=0.235414316803448 if year==2018			
			forval year = 1999 (-1) 1965 { 
				replace ratio_1100 = ratio_1100[_n+1] if year==`year'
			}			
			gen ratio_1200 = 1 - ratio_1100			
			foreach x in 1100 1200 {
				replace pct_`x' = ratio_`x' * pct_1000
			}			
			drop ratio_*
		*6000
			replace pct_6000 = 0 if pct_6000 < 0
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000						
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace interpolated = 1 if inlist(year,1990)
			replace stitch = 1 if inlist(year,1972,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/NIC.dta, replace
		
			
	*106. KGZ
		use data/revenue_raw, clear	
		keep if country=="KGZ"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)			
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 2000 using RPC
			gen gap = pct_2000 - pct_2000_RPC
			gen gap2 = pct_2000 / pct_2000_RPC
			forval year = 2000 (-1) 1993 {
				replace gap = gap[_n+1] if year==`year'
				replace gap2 = gap2[_n+1] if year==`year'	
			}
			replace pct_2000 = pct_2000_RPC + gap  /* pct_2000_RPC * gap2 */ if year<2001
					drop gap*				
		*1300 series interpolate 2005-2014
				replace pct_1300 = . if inrange(year,2006,2013)
			foreach x in 1100 1200 1300 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = pct_1000 * ratio_`x'_temp if inrange(year,2006,2013)	
						drop ratio_`x'*
			}
		*4000
			replace pct_4000 = pct_4000[_n+1] if year==1994 //predicted value of missing value
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1994 //post-Soviet
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/KGZ.dta, replace
			
			
	*107. LBN
		use data/revenue_raw, clear	
		keep if country=="LBN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)			
			replace pct_`x' = pct_`x'_HA // 
			replace source = "HA" 
			replace pct_`x' = pct_`x'_ICTD if inrange(year,1988,2001)  
			replace source = "ICTD" if inrange(year,1988,2001)				
		}	
			replace interpolated = 1 if pct_direct==. & pct_1000==. //may 2020 see below
		*deal with the historical data for civil war era
			foreach x in direct indirect {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if pct_`x'==. & inrange(year,1973,1987)
					drop temp_`x'
			}
		*figure out the within ratios for direct and indirect
					replace pct_4000 = 0 if year==1988
				foreach x in 1000 4000 {	
					gen ratio_`x' = pct_`x' / (pct_1000 + pct_4000)
					ipolate ratio_`x' year, gen(ratio_`x'_temp)
					replace pct_`x' = ratio_`x'_temp * pct_direct if inrange(year,1972,1987)
							drop ratio_`x'*
				}
			foreach x in 5000 6000 {
				gen ratio_`x' = pct_`x' / (pct_5000 + pct_6000)
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
					order ratio_`x'*, after(pct_`x')
					format %9.2fc ratio*
				replace pct_`x' = ratio_`x'_temp * pct_indirect if inrange(year,1972,1987)
						drop ratio_`x'*
			}
			replace source = "IMF" if inrange(year,1972,1987)
					drop pct_indirect pct_direct
		*1300 split
				replace pct_1300 = . //if....
				replace pct_1200 = .9 * pct_1000 if year < 1993
				replace pct_1100 = .1 * pct_1000 if year < 1993
			foreach x in 1100 1200 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
					replace pct_`x' = ratio_`x'_temp * pct_1000 if pct_`x'==.
						drop ratio_`x'*
			}
		*adjust 2000 using RPC and ICTD
				replace pct_2000 = pct_2000_RPC
				replace pct_2000_ICTD = 0.00275024 if year==2017 & pct_2000_ICTD == .
			replace pct_2000 = pct_2000_ICTD if year>2000
		*2018-19 via ICTD
			forval year = 2018/2019 {
				foreach x in 1000 4000 5000 6000	{
					replace pct_`x' = ( pct_`x'[_n-1] / pct_`x'_ICTD[_n-1] ) * pct_`x'_ICTD if year==`year'
				}
			}	
		*and PIT CIT split from 2017
			forval year = 2018 / 2019 {
				foreach x in 1100 1200 {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_1000[_n-1] ) * pct_1000 if year==`year'
				}
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1972,1988,2002)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/LBN.dta, replace
		
			
	*108. DNK
		use data/revenue_raw, clear	
		keep if country=="DNK"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*1300 --> 1100 (tax on pension assets): http://www.siepweb.it/siep/images/joomd/1399110371192.pdf
			replace pct_1100 = pct_1100 + pct_1300 if pct_1300!=.
			replace pct_1300 = .
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/DNK.dta, replace			
			
			
	*109. SGP
		use data/revenue_raw, clear	
		keep if country=="SGP"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)	
			replace pct_`x' = pct_`x'_OECD if year > 1999
			replace source = "OECD" if year > 1999
			replace pct_`x' = pct_`x'_HA if   year < 2000
			replace source = "HA" if year < 2000					
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
			forval year = 2014/2019 {
				cap replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*revise 6000 series
			replace pct_6000 = pct_6000_ICTD if inrange(year,1980,1999)	
		*revise 4000 series
			*some 4000 is included in the 5000 pre-1971
				replace pct_4000 = 0 if year<1971
			gen ratio = pct_4000 / (pct_4000 + pct_5000)
			forval year = 1970 (-1) 1964 {
				replace ratio = ratio[_n+1] if year==`year'
			}
				replace pct_4000 = ratio * pct_5000 if year<1971
				replace pct_5000 = pct_5000 - pct_4000 if year<1971
					replace pct_5100 = . if year<1971
						drop ratio																	
		*interpret 1300 split back in time
			gen ratio_1100 = .435 if year==1966	//see source online, Asher 1980
			replace ratio_1100 = .317 if year==1976 //see source online, Asher 1980
			replace ratio_1100 = .35198135198 if inrange(year,1985,1987) //see source online, NBER Asher 1990
			gen ratio_1300 = 0 if year==1966 | year==1976 | inrange(year,1985,1987)
			gen ratio_1200 = 1 - ratio_1100 if year==1966 | year==1976 | inrange(year,1985,1987)
			foreach x in 1100 1200 1300 {
				replace pct_`x' = . if year<2000
				replace ratio_`x' = pct_`x' / pct_1000 if pct_`x'!=.
					forval year = 1965 (-1) 1964 {
						replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
					}
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
					replace ratio_`x' = ratio_`x'_temp if ratio_`x'==.
				replace pct_`x' = ratio_`x' * pct_1000 if year<2000
						drop ratio_`x'*
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2000)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
				drop if year==2019 //no data yet
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SGP.dta, replace
			
			
	*110. FIN
		use data/revenue_raw, clear	
		keep if country=="FIN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965 & pct_tax!=. //no 2019 yet (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/FIN.dta, replace
			
			
	*111. SVK
		use data/revenue_raw, clear	
		keep if country=="SVK"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_OECD  
			replace source = "OECD"
			replace pct_`x' = pct_`x'_ICTD if year==1994  
			replace source = "ICTD" if year==1994   				
		}	
		*4000 series
			replace pct_4000 = pct_6000 if year==1994
				replace pct_6000 = .
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1995)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1994 & pct_tax!=. //post-Soviet ; 2019 data not available yet (as of Dec 2020)
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/SVK.dta, replace
			
			
	*112. NOR
		use data/revenue_raw, clear	
		keep if country=="NOR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/NOR.dta, replace
			
			
	*113. COG	
		use data/revenue_raw, clear	
		keep if country=="COG"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year < 1982
			replace source = "HA" if year < 1982
			replace pct_`x' = pct_`x'_ICTD if year > 1981  
			replace source = "ICTD" if year > 1981		
			replace pct_`x' = pct_`x'_OECD if year > 1998   
			replace source = "OECD" if year > 1998
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if inrange(year,1981,1991)
				ipolate pct_2000 year, gen(temp)
				replace pct_2000 = temp if inrange(year,1992,1998)
					drop temp														
		*interpolate totally 1977-79...
				replace pct_4000 = 0 if year==1982
			foreach x in 1100 1200 1300 2000 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inrange(year,1977,1979)
					drop temp_`x'
			*and within ratios for 1981
				gen ratio_`x' = pct_`x' / (pct_1000 + pct_4000 + pct_5000 + pct_6000)
					order ratio_`x', after(pct_`x')
					format %9.2fc ratio_`x'
				replace ratio_`x' = ( ratio_`x'[_n-1] + ratio_`x'[_n+1] ) / 2 if year==1981
				replace pct_`x' = ratio_`x' * (pct_taxRPC - pct_2000) if year==1981
						drop ratio_`x'
			}
		*adjust 1300 series
				replace pct_1300 = . if inrange(year,1995,1998)
				replace pct_1300 = 0 if year==1999
			foreach x in 1100 1200 1300 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = ratio_`x'_temp * pct_1000 if inrange(year,1995,1998)
						drop ratio_`x'*
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1982,1999)
			replace interpolated = 1 if inlist(year,1977,1978,1979,1981)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //first post-independence year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/COG.dta, replace
		
		
	*114. CRI
		use data/revenue_raw, clear	
		keep if country=="CRI"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1989
			replace source = "OECD" if year > 1989
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if year < 1990	
			replace pct_`x' = pct_`x'_HA if year < 1974
			replace source = "HA" if year < 1974				
		}			
		*adjust 2000 using HA and IMF prior to OECD
			replace pct_2000 = pct_2000_NS if year==1972 | year==1973
		*ipolate 1000 for the missing years (also interpolate all other series)
			foreach x in 1000 2000 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inlist(year,1957,1963,1970,1971) //71 is just for SS
					drop temp_`x'
			}		
		*adjust 1300 split based on CIAT data
			gen ratio_1100 = .
			gen ratio_1200 = .
			replace ratio_1100=0.399612282057977 if year==2003
			replace ratio_1100=0.36074076240474 if year==2004
			replace ratio_1100=0.326591953062595 if year==2005
			replace ratio_1100=0.178158035722855 if year==2006
			replace ratio_1100=0.231570376091855 if year==2007
			replace ratio_1100=0.151571272867401 if year==2008
			replace ratio_1100=0.228161191454613 if year==2009
			replace ratio_1100=0.270992950320871 if year==2010
			replace ratio_1100=0.281654960833634 if year==2011
			replace ratio_1100=0.344763710262158 if year==2012
			replace ratio_1100=0.31206974332726 if year==2013
			replace ratio_1100=0.319604211767498 if year==2014
			replace ratio_1100=0.309299027047838 if year==2015
			replace ratio_1100=0.292170046401194 if year==2016
			replace ratio_1100=0.285689442514848 if year==2017
			replace ratio_1100=0.28444359442373 if year==2018			
			replace ratio_1200 = 1 - ratio_1100 if inrange(year,2003,2018)
			replace pct_1100 = ratio_1100 * pct_1000 if year>2002
			replace pct_1200 = ratio_1200 * pct_1000 if year>2002
		*consider IMF historical data
			replace pct_1100 = pct_1300 if year < 1970
		*we don't have any 1300 in CIAT years, nor at the beginning of the IMF hist period
			replace pct_1300 = . if !inrange(year,1983,1988)
			replace pct_1100 = . if year==1960 | year==1961
		*then ipolate 1300 split for where it doesn't exist yet (including some years where we did have the 1000 already)
			foreach x in 1100 1200 {
				replace ratio_`x' = pct_`x' / pct_1000 if year<2003 //for 2003-present we defined this above
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace ratio_`x' = ratio_`x'_temp if ratio_`x'==.
				replace pct_`x' = ratio_`x' * pct_1000 if pct_`x'==.
						drop ratio_`x'*
			}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1974,1990)
			replace interpolated = 1 if inlist(year,1957,1963,1970)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/CRI.dta, replace
		
			
	*115. IRL
		use data/revenue_raw, clear	
		keep if country=="IRL"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/IRL.dta, replace
		
		
	*116. NZL
		use data/revenue_raw, clear	
		keep if country=="NZL"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/NZL.dta, replace
		
			
	*117. LBR
		use data/revenue_raw, clear	
		keep if country=="LBR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD if year > 1999
			replace source = "ICTD" if year > 1999
			replace pct_`x' = pct_`x'_NS if inrange(year,1974,1988)
			replace source = "HA" if inrange(year,1974,1988) 				
			replace pct_`x' = pct_`x'_HA if year<1974  
			replace source = "HA" if year<1974 				
		}	
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100	pct_1200	pct_1300	pct_2000	pct_4000	pct_5000	pct_6000), missing
		*adjust 2000 using RPC for the post-war period
			replace pct_2000 = pct_2000_RPC if year > 1999
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}		
		*replace 6000 ==> 5000 pre-1970
			replace pct_5000 = pct_5000 + pct_6000 if year<1968
			replace pct_6000 = 0 if year<1968
			replace pct_5100 = . if year<1968 
			replace pct_5200 = . if year<1968 
		*interpolate 1968-69
				replace pct_6000 = 0 if year==1970
			foreach x in 1100 1200 /*1300 2000*/ 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inrange(year,1968,1969)
			}	
		*disaggregate 2013-16 ICTD based on HA `within' ratios
			foreach x in 1100 1200 1300 /*2000*/ 4000 5000 6000 {
				gen ratio_`x' = pct_`x'_HA / pct_tax_HA
				gen ratio_`x'_ICTD = pct_`x'_ICTD / pct_tax_ICTD 	
				replace pct_`x' = ratio_`x' * pct_tax if inrange(year,2013,2015)
						drop ratio_`x'*
			}
		*interpolate 1000 series split from 2004 - 2013 and then from 2016-2018
				replace pct_1300 = . if inrange(year,2005,2012) | inrange(year,2016,2018)
			foreach x in 1100 1200 1300 {
				gen ratio_`x' = pct_`x' / (pct_1100 + pct_1200 + pct_1300) if year>1999
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 2016/2019 {
					replace ratio_`x'_temp = ratio_`x'_temp[_n-1] if year==`year'
				}
				replace pct_`x' = ratio_`x'_temp * pct_1000 if inrange(year,2005,2012) | inrange(year,2016,2019)
						drop ratio_`x'*
			}		
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1974,2000)
			replace interpolated = 1 if inlist(year,1968,1969)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1970 & !inrange(year,1989,1999) //earliest year post-independence with consistent data ; later civil war
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/LBR.dta, replace
		
			
	*118. CAF
		use data/revenue_raw, clear	
		keep if country=="CAF"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year < 2008
			replace source = "HA" if year < 2008
			replace pct_`x' = pct_`x'_ICTD if  year > 2007 //| inrange(year,1980,1985)
			replace source = "ICTD" if year > 2007 //| inrange(year,1980,1985)	
			replace pct_`x' = pct_`x'_NS if  year == 1981 
			replace source = "HA" if inrange(year,1980,1985)										
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year>1962
				forval year = 2014 / 2019 {
					replace pct_2000 = pct_2000[_n-1] if year==`year'
				}			
		*interpolate IMF-ICTD ratio using ICTD data for 1980-86
			foreach x in 1000 5000 6000 {
				gen ratio_`x' = pct_`x'_NS / pct_`x'_ICTD if year==1981
					order ratio_`x'*, after(pct_`x')
					format %9.2fc ratio_`x'*
				forval year = 1982 / 1985 {
					replace ratio_`x' = ratio_`x'[_n-1] if year==`year'
				}
					replace ratio_`x' = ratio_`x'[_n+1] if year==1980
				replace pct_`x' = ratio_`x' * pct_`x'_ICTD if inrange(year,1980,1985) //1981 is the ratio basis, so stays same
						drop ratio_`x'*
			}
		*direct taxes
			*replace 4000 series for places where we won't interpolate
				replace pct_4000 = pct_4000_ICTD if year==1986 | year==1985
				replace pct_4000 = pct_4000[_n+1] if year==1963
			*propoerty taxes as a share of direct taxes, re ICTD in 2012-16
				gen ratio = pct_4000 / (pct_4000 + pct_1000) if year==2012
				forval year = 2013 / 2019 {
					replace ratio=ratio[_n-1] if year==`year'
					replace pct_4000 = ratio * pct_1000 if year==`year'
					replace pct_1000 = pct_1000 - pct_4000 if year==`year'
				}
						drop ratio				
				*interpolate all missing years / missing values 1974-79, 1997-2000
						replace pct_6000 = 0 if pct_6000 == . & year > 1985
					foreach x in 1000 4000 5000 6000 {
						ipolate pct_`x' year, gen(temp_`x')
						replace pct_`x' = temp_`x' if pct_`x'==.
					}
			*1300 series is actually (1100 + 4000) in 1986-2007 (vis a vis direct taxes, which should include property taxes)
				replace pct_1100 = pct_1300 - pct_4000 if inrange(year,1986,1996)
				replace pct_1300 = . if inrange(year,1986,2007) | year > 2012
				replace pct_1000 = pct_1000 - pct_4000 if inrange(year,1986, 2007)
			*1300 is actually 1200 in 1963-73
				replace pct_1200 = pct_1200 + pct_1300 if inrange(year,1963,1973)
				replace pct_1300 = 0 if inrange(year,1963,1973)
			*6000 series is actually 1000 series in recent years?
				gen temp = pct_1000 + pct_6000 if year==2012
				forval year = 2013/2019{
					replace temp = pct_6000 if year==`year'
					replace pct_1000 = (pct_1000[_n-1] / temp[_n-1]) * temp  if year==`year'
					replace pct_6000 = (pct_6000[_n-1] / temp[_n-1]) * temp if year==`year'
				}
						drop temp
			*interpolate the 1000 series split over time
					replace pct_1300 = 0 if pct_1300==. & pct_1100!=.
				foreach x in 1100 1200 1300 {
					gen ratio_`x' = pct_`x' / pct_1000
					ipolate ratio_`x' year, gen(ratio_`x'_temp)
					forval year = 2012 / 2019 { //don't trust the 2012 value, no values 2013-16
						replace ratio_`x'_temp = ratio_`x'_temp[_n-1] if year==`year'
					}
					replace pct_`x' = ratio_`x'_temp * pct_1000 if pct_`x'==.
							drop ratio_`x'*
				}
			*4000 series
				forval year = 2013 / 2019 {
					replace pct_4000 = pct_4000[_n-1] if year==`year' 	//predicted value of missing value
				}
		*replace the aggregates after stitching (using disaggregates)
				cap drop  pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1980,1986,2008)
			replace interpolated = 1 if inrange(year,1974,1979)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965 
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/CAF.dta, replace
		
				
	*119. OMN
		use data/revenue_raw, clear	
		keep if country=="OMN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if year < 1990
			replace pct_`x' = pct_`x'_ICTD if  year > 1989 
			replace source = "ICTD" if year > 1989		
		}	
		*interpolate from ICTD via HA for 2014+
			foreach x in 1000 1200 /*2000*/ 4000 5000 6000 {
				gen ratio_`x' = pct_`x'_ICTD / pct_`x'_HA
				forval year = 2014 / 2019 {				
							replace pct_`x' = ratio_`x'[_n-1] * pct_`x'_HA if year==`year'
				}
			}
		*2000 series has nothing in HA
			forval year = 2014 / 2019 {
						replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*4000 has nothing in ICTD in recent era
			replace pct_4000 = pct_4000_HA if year > 2004
				ipolate pct_4000 year, gen(temp)
				replace pct_4000 = temp if inrange(year,2000,2004)
					drop temp
		*1100 vs 1300
			replace pct_1100 = pct_1000 - pct_1200 if year>1989
			replace pct_1300 = 0
			replace pct_1200 = pct_1000 //see KPMG source
			replace pct_1100 = 0
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //no data post-2014 (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/OMN.dta, replace
		

	*120. MRT
		use data/revenue_raw, clear	
		keep if country=="MRT"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)			
			replace pct_`x' = pct_`x'_OECD if year > 2006
			replace source = "OECD" if year > 2006
			replace pct_`x' = pct_`x'_HA if  year < 2007
				replace pct_`x' = pct_`x' / 10 if year<2007 //cf. currency conversion factors 
			replace source = "HA" if year < 2007				
		}	
		*1000 series
				replace pct_1000 = pct_1000 + pct_6000 if year < 2007 //aligning HA with OECD
				replace pct_6000 = . if year <2007
				replace pct_1000 = ( pct_1000[_n-1] + pct_1000[_n+1] ) / 2 if year==2000
			*1000 series split from ICTD
					replace pct_1100 = . if year < 2007
					replace pct_1300 = 0 if year==2007
					foreach x in 1100 1200 1300 { 
						gen ratio_`x' = pct_`x'_ICTD / pct_1000_ICTD if inrange(year,1993,2005)
						replace ratio_`x'= pct_`x' / pct_1000 if year>2006 //OECD years
						ipolate ratio_`x' year, gen(ratio_`x'_temp)
						forval year = 1992 (-1) 1986 {
							replace ratio_`x'_temp = ratio_`x'_temp[_n+1] if year==`year'
						}
						replace pct_`x' = ratio_`x'_temp * pct_1000 if pct_`x'==. //& year<2007
								drop ratio_`x'*
					}		
		*4000 series
			ipolate pct_4000 year, gen(temp)
			replace pct_4000 = temp if pct_4000 == .
				drop temp
		*adjust 2000 using RPC ratio with OECD (and interpolate)
		gen gap = pct_2000_RPC - pct_2000_OECD
			order gap, after(pct_2000_OECD)
		forval year = 2006 (-1) 1986 {
			replace gap = gap[_n+1] if year==`year'
		}
			replace pct_2000_RPC = ( pct_2000_RPC[_n-1] + pct_2000_RPC[_n+1] ) / 2 if year == 2000
		replace pct_2000 = pct_2000_RPC - gap if year < 2007
				drop gap						
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing			
		*save
			replace stitch = 1 if inlist(year,2007)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1986 //first year post-independence with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/MRT.dta, replace

			
	*121. HRV
		use data/revenue_raw, clear	
		keep if country=="HRV"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*interpolate 1000 series split
			forval year = 2015 / 2019 {
				replace pct_1300 = . if year==`year'
				replace pct_1100 = pct_1100[_n-1] / pct_1000[_n-1] * pct_1000 if year==`year'
				replace pct_1200 = pct_1200[_n-1] / pct_1000[_n-1] * pct_1000 if year==`year'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=2002 //first year post-conflict with consistent data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/HRV.dta, replace

			
	*122. KWT
		use data/revenue_raw, clear	
		keep if country=="KWT"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year <1990
			replace source = "HA" if year <1990
			replace pct_`x' = pct_`x'_ICTD if year>1989
			replace source = "ICTD" if year>1989				
		}	
		*interpolate for 1975-76
			foreach x in 1000 1200 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if year==1975 | year==1976
					drop temp_`x'
			}
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year>1976
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*1000 series for 1999-2009
			replace pct_1200 = pct_1300 if inrange(year,1999,2009)
			replace pct_1300 = . if inrange(year,1999,2009)		
		*all series 2010 - 16
			replace pct_6000 = . if year>2009
			foreach x in 1000 1200 4000 5000 {
				gen ratio_`x' = pct_`x' / pct_taxICTD
				forval year = 2010 / 2019 {
					replace ratio_`x' = ratio_`x'[_n-1] if year==`year'
				}
				replace pct_`x' = ratio_`x' * pct_taxICTD if inrange(year,2010,2019)
						drop ratio_`x'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 // pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			replace interpolated = 1 if inrange(year,1975,1976) | inrange(year,2010,2019)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //first year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/KWT.dta, replace
	
	
	*123. PAN
		use data/revenue_raw, clear	
		keep if country=="PAN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1989
			replace source = "OECD" if year > 1989
			replace pct_`x' = pct_`x'_NS if  year < 1990 
			replace source = "HA" if  year < 1990 				
		}		
		*adjust 1000 series
			foreach x in 1100 1200 1300 { 
				replace pct_`x' = . if year<1990
				gen ratio_`x' = pct_`x' / pct_1000
					forval year = 1989 (-1) 1973 {
						replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
					}
				replace pct_`x' = ratio_`x' * pct_1000 if year < 1990
					drop ratio_`x'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1973 //first year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/PAN.dta, replace
		
			
	*124. GEO
		use data/revenue_raw, clear	
		keep if country=="GEO"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if inrange(year,1997,2003) | inrange(year,2008,2011)
			forval year = 1996 (-1) 1995 {
				replace pct_2000 = pct_2000[_n+1] if year==`year'
			}
			replace pct_2000 = pct_2000_RPC / 10 if inrange(year,2012,2013) //common typo for this dataset...
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'								
			}
		*4000 series (ICTD puts in pct_6000) //NB similar seems likely for pct_5000 but not likely for our project
			forval year = 2003 (-1) 1995 {
				replace pct_4000 = pct_4000[_n+1] if year==`year'
					replace pct_6000 = pct_6000 - pct_4000 if year==`year'
			}
		*1994
			foreach var of varlist pct_1000 - pct_6000 {
				replace `var' = `var'[_n+1] if year==1994
			}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1994 //first post-Soviet year with consistent data
			format %9.2fc pct*
			replace interpolated=1 if year==1994
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/GEO.dta, replace
		
			
	*125. MDA
		use data/revenue_raw, clear	
		keep if country=="MDA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year==1992
		*4000 series
			replace pct_4000 = pct_4000_HA if year < 2003
			forval year = 1994 (-1) 1992 {
				replace pct_4000 = pct_4000[_n+1] if year==`year'
			}		
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1992 //first post-Soviet year with consistent data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/MDA.dta, replace
			
			
	*126. BIH
		use data/revenue_raw, clear	
		keep if country=="BIH"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 1000 series 1999-06
			foreach x in 1100 1200 1300 {
				replace pct_`x' = . if year<2007
				gen ratio_`x' = pct_`x' / pct_1000
					forval year = 2006 (-1) 1999 {
						replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
					}
				replace pct_`x' = ratio_`x' * pct_1000 if year<2007
							drop ratio_`x'
			}
		*adjust Article IV era
			replace pct_2000 = pct_2000 + 0.01841574 if year<2005
			replace pct_4000 = 0.00574775524712176 if year<2005
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1999 //first post-conflict year with consistent data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/BIH.dta, replace
			
			
	*127. URY
		use data/revenue_raw, clear	
		keep if country=="URY"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1989
			replace source = "OECD" if year > 1989
			replace pct_`x' = pct_`x'_NS if year < 1990  
			replace source = "HA" if year < 1990				
		}	
		*1100 
			replace pct_1100 = pct_1100_HA if inrange(year,1990,1992)
			replace pct_1200 = pct_1200 - pct_1100 if inrange(year,1990,1992)
			ipolate pct_1100 year, gen(temp)
				replace pct_1100 = temp if inrange(year,1993,1998)
					drop temp
		*6000
			replace pct_6000 = 0 if pct_6000 < 0
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //earliest year with data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/URY.dta, replace
		
			
	*128. MNG
		use data/revenue_raw, clear	
		keep if country=="MNG"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 4000 series
			replace pct_4000 = pct_4000_HA
				replace pct_4000 = ( pct_4000[_n-1] + pct_4000[_n+1] ) / 2 if year==1996
			replace pct_4000 = pct_4000[_n-1] if year==2018
		*PIT vs CIT
				replace pct_1300 = . if inrange(year,2008,2013)
			foreach x in 1100 1200 {
				gen ratio_`x' = pct_`x' / pct_1000 if inlist(year,2007,2014)
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = ratio_`x'_temp * pct_1000 if inrange(year,2008,2013)
					drop ratio_`x'* 
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1994 & pct_tax!=. //first post-Soviet year with consistent data ; no 2019 data yet (as of Dec 2020)
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/MNG.dta, replace
			
			
	*129. ARM
		use data/revenue_raw, clear	
		keep if country=="ARM"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)			
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA"
		}	
		*adjust 1000 series with ICTD data (-2013) and CIT inference (2014-)
			foreach x in 1000 1100 1200 1300 {
				replace pct_`x' = pct_`x'_ICTD if year<2013
			}
			replace pct_1200 = pct_1200 + pct_1300 if year>2012
			replace pct_1300 = 0 if year>2012
		*extend HA by way of ICTD
			forval year = 2018/2019{	
				foreach x in 1100 1200 4000 5000 6000 {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_`x'_ICTD[_n-1] ) * pct_`x'_ICTD	if year==`year'
				}
			}
		*extend 2000 series
			replace pct_2000 = pct_2000[_n-1] if year==2018
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1994 //first post-Soviet year with consistent data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/ARM.dta, replace
		
			
	*130. JAM
		use data/revenue_raw, clear			
		keep if country=="JAM"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_OECD if year >1992
			replace source = "OECD" if year >1989
			replace pct_`x' = pct_`x'_NS if year<1993  
			replace source = "HA" if year<1990				
		}	
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000) if year>1967, missing
			replace pct_tax = pct_1000 + pct_2000 + pct_4000 + pct_5000 + pct_6000 if year==1967
			replace pct_tax = pct_tax__NS if year==1965
		*use HA here
			foreach x in  1000	1100	1200	1300	4000	5000	5100	5200	5300	6000 {
				replace pct_`x' = . if inrange(year,1975,1985) | year==1967
			}				
			foreach x in tax 2000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if pct_`x'==.
					drop temp_`x'
			}		
		*refer to CIAT-IDB (raw data, calculations) for 1300 and 2000 and 1000 series split where missing
			replace pct_1100 = 0.0442191159183477 if year==1990	
			replace pct_1100 = 0.0411437321799318 if year==1991	
			replace pct_1100 = 0.0342006898109809 if year==1992
			replace pct_1200 = 0.0335569911652413 if year==1990	
			replace pct_1200 = 0.0241079468938568 if year==1991	
			replace pct_1200 = 0.024855208718924 if year==1992
			replace pct_1300=0 if inrange(year,1990,1992)
			replace pct_1300 = pct_1300 - 0.00790390391893624 if year==1990
			replace pct_1300 = pct_1300 - 0.00790390391893624 if year==1991
			replace pct_1300 = pct_1300 - 0.00790390391893624 if year==1992
			replace pct_1300 = pct_1300 - 0.00790390391893624 if year==1993
			replace pct_1300 = pct_1300 - 0.00790390391893624 if year==1994
			replace pct_1300 = pct_1300 - 0.00846091615039663 if year==1995
			replace pct_1300 = pct_1300 - 0.00954573305037498 if year==1996
			replace pct_1300 = pct_1300 - 0.0102438586729534 if year==1997
			replace pct_1300 = pct_1300 - 0.0103219921361996 if year==1998
			replace pct_1300 = pct_1300 - 0.00986421687881235 if year==1999
			replace pct_1300 = pct_1300 - 0.00967255806829718 if year==2000
			replace pct_1300 = pct_1300 - 0.00977254047991064 if year==2001
			replace pct_1300 = pct_1300 - 0.0100296072712227 if year==2002
			replace pct_1300 = pct_1300 - 0.0100352975280662 if year==2003
			replace pct_1300 = pct_1300 - 0.0100836272166878 if year==2004
			replace pct_1300 = pct_1300 - 0.0102753020228413 if year==2005
			replace pct_1300 = pct_1300 - 0.0111295844542781 if year==2006
			replace pct_1300 = pct_1300 - 0.0111801790005651 if year==2007
			replace pct_1300 = pct_1300 - 0.0115100068742241 if year==2008
			replace pct_1300 = pct_1300 - 0.0114362723858837 if year==2009
			replace pct_1300 = pct_1300 - 0.0110846691308818 if year==2010
			replace pct_1300 = pct_1300 - 0.0118436310522312 if year==2011
			replace pct_1300 = pct_1300 - 0.0113262045878992 if year==2012
			replace pct_1300 = pct_1300 - 0.0120589466745789 if year==2013
			replace pct_1300 = pct_1300 - 0.0124383892007557 if year==2014
			replace pct_1300 = pct_1300 - 0.0127377635294941 if year==2015
			replace pct_1300 = pct_1300 - 0.0129728311606893 if year==2016
			replace pct_1300 = pct_1300 - 0.0136322980567679 if year==2017
			replace pct_1300 = pct_1300 - 0.0136322980567679 if year==2018 //extended
			replace pct_1200 = pct_1200 + pct_1300 if inrange(year,1990,2017)
			replace pct_1300 = . if inrange(year,1990,2017)
			replace pct_2000 = pct_2000 + 0.00790390391893624 if year==1990
			replace pct_2000 = pct_2000 + 0.00790390391893624 if year==1991
			replace pct_2000 = pct_2000 + 0.00790390391893624 if year==1992
			replace pct_2000 = pct_2000 + 0.00790390391893624 if year==1993
			replace pct_2000 = pct_2000 + 0.00790390391893624 if year==1994
			replace pct_2000 = pct_2000 + 0.00846091615039663 if year==1995
			replace pct_2000 = pct_2000 + 0.00954573305037498 if year==1996
			replace pct_2000 = pct_2000 + 0.0102438586729534 if year==1997
			replace pct_2000 = pct_2000 + 0.0103219921361996 if year==1998
			replace pct_2000 = pct_2000 + 0.00986421687881235 if year==1999
			replace pct_2000 = pct_2000 + 0.00967255806829718 if year==2000
			replace pct_2000 = pct_2000 + 0.00977254047991064 if year==2001
			replace pct_2000 = pct_2000 + 0.0100296072712227 if year==2002
			replace pct_2000 = pct_2000 + 0.0100352975280662 if year==2003
			replace pct_2000 = pct_2000 + 0.0100836272166878 if year==2004
			replace pct_2000 = pct_2000 + 0.0102753020228413 if year==2005
			replace pct_2000 = pct_2000 + 0.0111295844542781 if year==2006
			replace pct_2000 = pct_2000 + 0.0111801790005651 if year==2007
			replace pct_2000 = pct_2000 + 0.0115100068742241 if year==2008
			replace pct_2000 = pct_2000 + 0.0114362723858837 if year==2009
			replace pct_2000 = pct_2000 + 0.0110846691308818 if year==2010
			replace pct_2000 = pct_2000 + 0.0118436310522312 if year==2011
			replace pct_2000 = pct_2000 + 0.0113262045878992 if year==2012
			replace pct_2000 = pct_2000 + 0.0120589466745789 if year==2013
			replace pct_2000 = pct_2000 + 0.0124383892007557 if year==2014
			replace pct_2000 = pct_2000 + 0.0127377635294941 if year==2015
			replace pct_2000 = pct_2000 + 0.0129728311606893 if year==2016
			replace pct_2000 = pct_2000 + 0.0136322980567679 if year==2017
			replace pct_2000 = pct_2000 + 0.0136322980567679 if year==2018 //extended
		cap drop pct_1000 //pct_5000				
		egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
		*examine within ratios, use for OECD 90-92, cf. HA pre-75
			foreach x in 1000 /*2000*/ 4000 5000 6000 {
					*gen ratio_`x' = pct_`x' / pct_tax
				gen ratio_`x' /*_HA*/ = pct_`x'_HA / pct_tax_HA
				replace ratio_`x' /*_HA*/ = pct_`x'_OECD / pct_tax_OECD if year>1992 //inrange(year,1990,1992)
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
					format %9.2fc ratio*
					order ratio_`x'*, after(pct_`x')
				replace pct_`x' = ratio_`x'_temp * (pct_tax - pct_2000) if year < 1993
						drop ratio_`x'*
			}						
		*1000 series split
			foreach x in 1100 1200 1300 {
				gen ratio_`x' = pct_`x'_NS / pct_1000_NS if inrange(year,1975,1985)
				replace ratio_`x' = pct_`x' / pct_1000 if year>1989
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 1974 (-1) 1961 {
					replace ratio_`x'_temp = ratio_`x'_temp[_n+1] if year==`year'
				}
				replace pct_`x' = ratio_`x'_temp * pct_1000 if pct_`x'==.
						drop ratio_`x'*
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			replace interpolated = 1 if inlist(year,1966,1982)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/JAM.dta, replace
			
			
	*131. ALB
		use data/revenue_raw, clear	
		keep if country=="ALB"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*adjust 1100 series in 1993
			replace pct_1100 = pct_1100_HA if year==1993
			replace pct_1200 = pct_1200 - pct_1100 if year==1993
		*4000 series
			replace pct_4000 = pct_4000[_n+1] if year==1993
			ipolate pct_4000 year, gen(temp)
				replace pct_4000 = temp if inlist(year,1997,2005,2006)
					drop temp
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1994 //first post-Soviet year with consistent data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/ALB.dta, replace
			
			
	*132. LTU
		use data/revenue_raw, clear	
		keep if country=="LTU"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year >1994
			replace source = "OECD" if year > 1994
			replace pct_`x' = pct_`x'_HA if year <1995
			replace source = "HA" if year<1995 				
		}	
		*adjust 2000 using ICTD and RPC
			replace pct_2000 = pct_2000_ICTD if year<1995
			replace pct_2000 = pct_2000_RPC if year==1991				
		*adjust 1000 series in 1991-92
			replace pct_1200 = pct_1300 if year<1993
				replace pct_1300 = . if year<1993			
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1995)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1991 & pct_tax!=. //first post-Soviet year with consistent data ; no 2018 data yet (as of Dec 2020)
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/LTU.dta, replace
		
			
	*133. QAT
		use data/revenue_raw, clear	
		keep if country=="QAT"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)			
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}			
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}			
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=2000 //earliest year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/QAT.dta, replace
			
			
	*134. NAM
		use data/revenue_raw, clear	
		keep if country=="NAM"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
		}			
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}										
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing					
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1991 //first post-independence year with consistent data 
				drop if year==2019 //no data yet
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/NAM.dta, replace
							
			
	*135. BWA
		use data/revenue_raw, clear	
		keep if country=="BWA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year < 1972
			replace source = "HA" if year < 1972
			replace pct_`x' = pct_`x'_NS if inrange(year,1972,1989)  
			replace source = "HA" if inrange(year,1972,1989)				
			replace pct_`x' = pct_`x'_ICTD if  inrange(year,1990,2003)
			replace source = "ICTD" if 		inrange(year,1990,2003)
			replace pct_`x' = pct_`x'_OECD if year>2003
			replace source = "OECD" if year>2003											
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*1200 for the year 1990
			replace pct_1200 = ( pct_1200[_n-1] + pct_1200[_n+1] ) / 2 if year==1990
				*and 1300
				replace pct_1300 = ( pct_1300[_n-1] + pct_1300[_n+1] ) / 2 if year==1990
		*5000 series for OECD era
			foreach x in 5000 5100 5200 5300 {
				replace pct_`x' = pct_`x'_ICTD if year>2003									
			}
		*replace 1200 with the 2002 ratio of resource_cit (as pct of CIT), ie with the PIT proportion of non-resource revenue
			replace pct_1100 = ((0.57701 * pct_1300_ICTD) / pct_1000_ICTD) * pct_1000  if year>2003 
			replace pct_1200 = pct_1000 - pct_1100 if year>2003
			replace pct_1300 = . if year>2003
		*1000 4000 6000 split for pre-66 and 70-71
			egen pct_direct = rowtotal(pct_1000 pct_4000 pct_6000), missing
			replace pct_6000 = . if inlist(year,1970,1971) | year<1966
			foreach x in 1000 4000 6000 {
				gen ratio_`x' = pct_`x' / pct_direct
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 1965 (-1) 1960 {
					replace ratio_`x'_temp = ratio_`x'_temp[_n+1] if year==`year'
				}
				replace pct_`x' = ratio_`x'_temp * pct_direct if inlist(year,1970,1971) | year<1966
						drop ratio_`x'* 
			}
				drop pct_direct	
		*1000 series from HA for 1997-02
			foreach x in 1000 1100 1200  {
				replace pct_`x' = pct_`x'_HA if inrange(year,1997,2002)
				replace pct_`x' = . if inrange(year,1995,1996)
			}
			replace pct_1300 =. if inrange(year,1995,2002)
		*interpolate for 95-96
			ipolate pct_1000 year, gen(temp)
			replace pct_1000 = temp if inrange(year,1995,1996)
				drop temp
			foreach x in 1100 1200 1300 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = ratio_`x'_temp * pct_1000 if inrange(year,1995,2002)
						drop ratio_`x'* 
			}
		*1000 series split pre-72
			replace pct_1100 = pct_1100 + pct_1300 if year==1969
			replace pct_1300 = . if year<1972
				replace pct_1100 = . if year==1968
				replace pct_1200 = . if year==1968
			foreach x in 1100 1200 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 1968 (-1) 1960 {
					replace ratio_`x'_temp = ratio_`x'_temp[_n+1] if year==`year'
				}
				replace pct_`x' = ratio_`x'_temp * pct_1000 if year < 1972
						drop ratio_`x'* 
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2004,1990,1972)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1967 //post-independence 
				drop if year==2019 //no data yet
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BWA.dta, replace
		
		
	*136. LSO
		use data/revenue_raw, clear	
		keep if country=="LSO"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year <1980
			replace source = "HA" if year <1982
			replace pct_`x' = pct_`x'_ICTD if  year>1981
			replace source = "ICTD" if year>1981				
		}			
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year>1983
			replace pct_2000 = . if year<1983
			forval year = 2014 / 2019 {
				cap replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*use IMF hist for 1972, interpolate for 1968
			foreach x in 1000 4000 5000 6000 {
				replace pct_`x' = ( pct_`x'_HA[_n+1] / pct_`x'_NS[_n+1] ) * pct_`x'_NS if year==1972
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if year==1968
					drop temp_`x'
			}		
		*1300 breakdown from IMF historical data: extrapolate backward 1971 to 1964
				*use HA data where exists 1998-2007
			foreach x in 1100 1200 1300 {
				replace pct_`x' = . if year <1980 | inrange(year,1998,2000)
				gen ratio_`x' = pct_`x' / pct_1000
				replace ratio_`x' = pct_`x'_NS / pct_1000_NS if year<1980
					replace ratio_`x' = pct_`x'_HA / pct_1000_HA if inrange(year,1998,2007)
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 1971 (-1) 1964 {
					replace ratio_`x'_temp = ratio_`x'_temp[_n+1] if year==`year'
				}
				replace pct_`x' = ratio_`x'_temp * pct_1000 if pct_`x' == . 
						drop ratio_`x'*
			}	
		*interpolate 1978-81
			foreach x in 1100 1200 1300 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp)
					replace pct_`x' = temp if pct_`x'==. //also pct_4000 in 1969-71 and 1976-77
						drop temp
			}
		*4000 series since 2014
			forval year = 2015 / 2019 {
				replace pct_4000 = pct_4000[_n-1] if year==`year' //predicted value for missing value
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1982)
			replace interpolated = 1 if inlist(year,1968) | inrange(year,1978,1981)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1966 //post-independence 
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/LSO.dta, replace
		
		
	*137. MKD
		use data/revenue_raw, clear	
		keep if country=="MKD"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)			
			replace pct_`x' = pct_`x'_ICTD  
			replace source = "ICTD" 
		}	
		*1000 series split
			replace pct_1300 = . if inrange(year,2003,2005)
			foreach x in 1100 1200 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' * pct_1000 if inrange(year,2003,2005)
					drop temp_`x'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1993 //first year post-independence with consistent data
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/MKD.dta, replace
			
			
	*138. SVN
		use data/revenue_raw, clear	
		keep if country=="SVN"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*1994
			foreach var of varlist pct_1000 - pct_6000 {
				replace `var' = `var'[_n+1] if year==1994
			}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1994 //earliest post-Communist data (OECD)
			format %9.2fc pct*
			replace interpolated=1 if year==1994
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/SVN.dta, replace

			
	*139. GMB
		use data/revenue_raw, clear	
		keep if country=="GMB"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year < 1988
			replace source = "HA" if year < 1988
			replace pct_`x' = pct_`x'_ICTD if  year > 1987 
			replace source = "ICTD" if  year > 1987			
		}	
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
			replace pct_tax = pct_1000 + pct_2000 + pct_5000 + pct_6000 if year<1988
		*adjust pre-88 to match ICTD
			gen ratio = pct_tax / pct_tax_ICTD if year < 1988
			order ratio, after(year)
			forval year = 1979 (-1) 1972 {
				replace ratio = ratio[_n+1] if year==`year'
			}
			foreach var of varlist pct_1000 - pct_6000 {
				replace `var' = `var' / ratio if year<1988 //source=="IMF"
			}
				drop ratio			
		*1000 series splits
				replace pct_1300 = . if pct_1100 ==.
			foreach x in 1100 1200 1300 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 2007 / 2019 {
					replace ratio_`x'_temp = ratio_`x'_temp[_n-1] if year==`year'
				}
				replace pct_`x' = ratio_`x'_temp * pct_1000 if pct_`x' == .
						drop ratio_`x'*
			}
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year>1987 //inlist(year,1988,1989) | year>
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1988)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //first post-independence year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/GMB.dta, replace
			
			
	*140. GAB
		use data/revenue_raw, clear	
		keep if country=="GAB"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year < 1973
			replace source = "HA" if year < 1973	
			replace pct_`x' = pct_`x'_NS if  inrange(year,1973,1985) 
			replace source = "HA" if inrange(year,1973,1985)				
			replace pct_`x' = pct_`x'_ICTD if  year>1985 //inrange(year,1986,1995) 
			replace source = "ICTD" if year>1985 //inrange(year,1986,1995)	
		}					
			ren pct_tax* pct_tax_*
				replace pct_5300 = pct_5000 if inrange(year,1973,1985)
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
		*adjust 2000 using RPC
			ipolate pct_2000 year, gen(temp)
			replace pct_2000 = temp if inrange(year,1964,1972)
				drop temp
			replace pct_2000 = pct_2000_RPC if pct_2000==.
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}	
		*adjust 4000
			ipolate pct_4000 year, gen(temp)
			replace pct_4000 = temp if inrange(year,1970,1972)
				drop temp
			gen ratio = pct_4000 / pct_tax
				replace ratio = pct_4000_NS / pct_tax__NS if year==1989
					order ratio
				ipolate ratio year, gen(temp)
				replace ratio = temp if inrange(year,1986,1989)
			forval year = 1990 / 2019 {
				replace ratio = ratio[_n-1] if year==`year'
			}
			replace pct_4000 = ratio * pct_tax_ICTD if year>1985
						drop ratio
			replace pct_6000 = pct_6000 - pct_4000 if year>1985
		*adjust 1000 series when 6000 in ICTD
				replace pct_1300 = 0 if pct_1300 == . & pct_1100!=.
			replace pct_1200 = pct_1200 + pct_6000 if inrange(year,1986,1996) 
			replace pct_1000 = pct_6000 if inrange(year,1990,1991)
			replace pct_6000 = 0 if inrange(year,1986,1996) 
			replace pct_1000 = pct_1100 + pct_1200 + pct_1300 if inrange(year,1986,1996) & !inrange(year,1990,1991)
		*interpolate 1 4 5 6  //76-80
			foreach x in 1000 1100 1200 1300 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if inrange(year,1977,1979)
					drop temp_`x'
			}
		*1100 series: see WB2019 public expenditure review: http://documents1.worldbank.org/curated/en/756881557892158812/pdf/Examen-des-D%C3%A9penses-Publiques-au-Gabon-Am%C3%A9liorer-la-Qualit%C3%A9-des-D%C3%A9penses-Publiques-pour-Promouvoir-une-Croissance-Inclusive.pdf
				replace pct_1100 = .014 if year==2010
					replace pct_1100 = .015 if year==2011
					replace pct_1100 = .015 if year==2012
					replace pct_1100 = .015 if year==2013
					replace pct_1100 = .014 if year==2014
					replace pct_1100 = .017 if year==2015
					replace pct_1100 = .015 if year==2016
					replace pct_1100 = .012 if year==2017
					replace pct_1100 = (.012/(.012+.025))*pct_1000 if year==2018 //extend same split
					replace pct_1100 = (.012/(.012+.025))*pct_1000 if year==2019 //extend same 2017 split
				replace pct_1200 = .042 if year==2010
					replace pct_1200 = .056 if year==2011
					replace pct_1200 = .043 if year==2012
					replace pct_1200 = .057 if year==2013
					replace pct_1200 = .046 if year==2014
					replace pct_1200 = .035 if year==2015
					replace pct_1200 = .021 if year==2016
					replace pct_1200 = .025 if year==2017
					replace pct_1200 = (.025/(.012+.025))*pct_1000  if year==2018 //extend same split
					replace pct_1200 = (.025/(.012+.025))*pct_1000  if year==2019 //extend same 2017 split
				replace pct_1300 = . if inrange(year,2005,2019)
			*interpolate and extrapolate the 1000 series splits
					replace pct_1300 = . if pct_1100==.
				foreach x in 1100 1200 1300 {
						gen ratio_`x' = pct_`x' / pct_1000
						ipolate ratio_`x' year, gen(ratio_`x'_temp)
						forval year = 2005 / 2009 {
							replace ratio_`x'_temp = ratio_`x'_temp[_n-1] if year==`year'
						}
					replace pct_`x' = ratio_`x'_temp * pct_1000 if pct_`x'==.
								drop ratio_`x'*
				}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1973,1986)
			replace interpolated = 1 if inrange(year,1977,1979)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965 //first post-independence year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/GAB.dta, replace
			
			
	*141. LVA
		use data/revenue_raw, clear	
		keep if country=="LVA"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*1994
			foreach var of varlist pct_1000 - pct_6000 {
				replace `var' = `var'[_n+1] if year==1994
			}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1994 //earliest post-Communist data (OECD)
			format %9.2fc pct*
			replace interpolated=1 if year==1994
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/LVA.dta, replace
		
		
	*142. KOS
		use data/revenue_raw, clear	
		keep if country=="KOS"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_HA if year < 2016
			replace source = "HA" if year < 2016
			replace pct_`x' = pct_`x'_ICTD if year >= 2016
			replace source = "ICTD" if year >= 2016
		}	
			replace pct_1200 = .015 					if year<2016 //see WB publication (see commentary)
			replace pct_1100 = pct_1000 - pct_1200 		if year<2016
			replace pct_1300 = .		
		*adjust 2000 
				replace pct_2000 = pct_2000[_n+1] if year==2008
				replace pct_2000 = pct_2000[_n-1] if year==2015
			forval year = 2016/2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}			
		*adjust 4000
			forval year = 2016/2019 {
				replace pct_4000 = pct_4000[_n-1] if year==`year'
			}			
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2016)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=2008 //first post-independence year with consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/KOS.dta, replace
	
			
	*143. BHR
		use data/revenue_raw, clear				
		keep if country=="BHR"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)	
			replace pct_`x' = pct_`x'_NS if year <1988
			replace source = "HA" if year<1988
			replace pct_`x' = pct_`x'_ICTD if   year>1987
			replace source = "ICTD" if year>1987				
		}			
		foreach x in 1000 1200 5000 {
			ipolate pct_`x' year, gen(temp_`x')
			replace pct_`x' = temp_`x' if pct_`x'==.
				drop temp_`x'
		}
		*adjust 2000 using RPC, and extrapolate forward
			replace pct_2000 = pct_2000_RPC if year>1989
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1988)
			replace interpolated = 1 if inlist(year,2012)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1974 & pct_tax!=. //earliest consistent data ; none lately (as of Dec 2020)
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BHR.dta, replace
		
		
	*144. TTO
		use data/revenue_raw, clear	
		keep if country=="TTO"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_OECD if year >1989
			replace source = "OECD" if year >1989
			replace pct_`x' = pct_`x'_HA if  year<1990 
			replace source = "HA" if 		year<1990		
		}				
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year<1990
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/TTO.dta, replace
			
			
	*145. SWZ
		use data/revenue_raw, clear	
		keep if country=="SWZ"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA if year < 1972 | inrange(year,1990,1997)
			replace source = "HA" if year < 1972 | inrange(year,1990,1998)
			replace pct_`x' = pct_`x'_NS if  inrange(year,1972,1989) 
			replace source = "HA" if inrange(year,1972,1989)				
			replace pct_`x' = pct_`x'_OECD if  year>1998
			replace source = "OECD" if year>1998										
		}	
		*adjust 5200
			replace pct_5200 = pct_5200_ICTD if year>1998
			replace pct_5000 = pct_5100 + pct_5200 + pct_5300 if year>1998			
		*adjust 2000 using RPC
			replace pct_2000 =  .6039858 * pct_2000_RPC if inrange(year,1974,1998) //ratio of 2000 series per OECD vs. per RPC in year 1999 (first year of overlap)
		*1000 series split
			foreach x in 1100 1200 1300 {
					replace pct_`x'= . if year<1972
				gen ratio_`x' = pct_`x' / pct_1000
						order ratio_`x', after(pct_`x')
				forval year = 1971 (-1) 1965 {
					replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
				}
				replace pct_`x' = ratio_`x' * pct_1000 if year<1972
						drop ratio_`x'
			}
		*interpolate 1998
			foreach x in 1100 1200 1300 4000 5000 6000 {
				replace pct_`x' = ( pct_`x'[_n-1] + pct_`x'[_n+1] ) / 2 if year==1998
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1972,1990,1999)
			replace interpolated = 1 if inlist(year,1998)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SWZ.dta, replace
		
			
	*146. EST
		use data/revenue_raw, clear	
		keep if country=="EST"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD  
			replace source = "OECD" 
			replace pct_`x' = pct_`x'_ICTD if   year<1995
			replace source = "ICTD" if 		year<1995		
		}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1995)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1993 //post-Soviet
			format %9.2fc pct*
			gen excomm = 1
			order stitch interpolated excomm pct_tax, after(source)
			save data/harmonized/EST.dta, replace
			
			
	*147. TLS
		use data/revenue_raw, clear	
		keep if country=="TLS"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_HA  
			replace source = "HA" 
		}	
		*1300 --> 1100
			replace pct_1100 = pct_1100 + pct_1300 if pct_1300!=.
			replace pct_1300=.
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=2006 //first post-independence year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/TLS.dta, replace
			
				
	*148. MUS
		use data/revenue_raw, clear	
		keep if country=="MUS"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if year < 1990
			replace pct_`x' = pct_`x'_OECD if year>1989  
			replace source = "OECD" if year>1989 				
		}		
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1973 //first post-independence year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/MUS.dta, replace
			
			
	*149. GNQ
		use data/revenue_raw, clear			
		keep if country=="GNQ"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)		
			replace pct_`x' = pct_`x'_OECD if year > 2004
			replace source = "OECD" if year > 2004
			replace pct_`x' = pct_`x'_ICTD if  year<2005 
			replace source = "ICTD" if  year<2005 				
		}	
		*4000 in 1992
			replace pct_4000 = pct_4000[_n+1] if year==1992
			replace pct_6000 = pct_6000 - pct_4000 if year==1992
		*1998-00
			replace pct_1000 = pct_1000 + pct_6000 - 0.00274245041084419 if year==1998
				replace pct_6000 = 0.00274245041084419 if year==1998
			replace pct_1000 = pct_1000 + pct_6000 - 0.00259183144117001 if year==1999
				replace pct_6000 = 0.00259183144117001 if year==1999
			replace pct_1000 = pct_1000 + pct_6000 - 0.00332884228213706 if year==2000
				replace pct_6000 = 0.00332884228213706 if year==2000
		*ipolate 1000 4000 5100 6000
			foreach x in 1000 4000 5100 6000 {
				gen ratio_`x' = pct_`x' / (pct_1000 + pct_4000 + pct_5100 + pct_6000)
				forval year = 1991 (-1) 1980 {
					replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
				}
					order ratio_`x', after(pct_`x')
					format %9.2fc ratio*
				replace pct_`x' = ratio_`x' * pct_6000 if year<1992
						drop ratio_`x'
			}
		*1000 series from 80-00 save 97
			replace pct_1300=. if year<1997
			foreach x in 1100 1200 {
				replace pct_`x' = . if inrange(year,1998,2000)
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 1996 (-1) 1980  {
					replace ratio_`x'_temp = ratio_`x'_temp[_n+1] if year==`year'
				}
					format %9.2fc ratio*
					order ratio_`x'*, after(pct_`x')
				replace pct_`x' = ratio_`x'_temp * pct_1000 if pct_`x'==.
						drop ratio_`x'*
			}				
		*adjust 2000 using RPC
			replace pct_2000 = 0.001 //pct_2000_RPC
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 pct_5000
			egen pct_5000 = rowtotal(pct_5100 pct_5200 pct_5300), missing
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2005)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1981 //first post-independence year of consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/GNQ.dta, replace
			
			
	*150. CYP
		use data/revenue_raw, clear	
		keep if country=="CYP"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)			
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if year <1990
			replace pct_`x' = pct_`x'_HA if  year > 1989
			replace source = "HA" if  year > 1989
			replace pct_`x' = pct_`x'_ICTD if year==1994
		}	
		*4000 in 1994
			replace pct_4000 = ( pct_4000[_n+1] + pct_4000[_n-1] ) / 2 if year==1994
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if year>1989
			gen temp = pct_2000_RPC / pct_2000_UN 
				order temp, after(pct_2000)
			forval year = 2014 / 2019 {
				replace temp = temp[_n-1] if year==`year'
				replace pct_2000 = pct_2000_UN * temp if year==`year'
			}
					drop temp
		*extend by way of ICTD										
			forval year = 2017/2018{	
				foreach x in 1100 1200 1300 4000 5000 6000 {
					replace pct_`x' = ( pct_`x'[_n-1] / pct_`x'_ICTD[_n-1] ) * pct_`x'_ICTD	if year==`year'
				}
			}											
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //earliest available consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/CYP.dta, replace
			
			
	*151. FJI
		use data/revenue_raw, clear	
		keep if country=="FJI"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if year < 1990	
			replace pct_`x' = pct_`x'_ICTD if  year > 1989 
			replace source = "ICTD" if  year > 1989
			replace pct_`x' = pct_`x'_OECD if   year > 2007
			replace source = "OECD" if 	year > 2007	
		}	
		*1000 series split in 1995 and 2007
			replace pct_1300 = . if inlist(year,1995,2007)
			replace pct_1300 = 0 if year==2008
			foreach x in 1100 1200 1300 {
				gen ratio_`x' = pct_`x' / pct_1000
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace pct_`x' = ratio_`x'_temp * pct_1000 if inlist(year,1995,2007)
					drop ratio_`x'*
			}			
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC
			forval year = 2014 / 2019 {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}				
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2008,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //earliest available consistent data
				drop if year==2019 //no data yet
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/FJI.dta, replace
	
			
	*152. GUY
		use data/revenue_raw, clear	
		keep if country=="GUY"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			cap gen pct_`x'_NS=.
			replace pct_`x' = pct_`x'_NS if year < 1987
			replace source = "HA" if year < 1987			
			replace pct_`x' = pct_`x'_ICTD if  year>1986 
			replace source = "ICTD" if 	year>1986
			replace pct_`x' = pct_`x'_OECD if  year>1989
			replace source = "OECD" if 	year>1989				
		}
		foreach x in 1100 1200 1300 2000 4000 5000 6000 {
			ipolate pct_`x' year, gen(temp_`x')
			replace pct_`x' = temp_`x' if inrange(year,1986,1990)
				drop temp_`x'
		}	
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1987,1990)
			replace interpolated = 1 if inlist(year,1986)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //earliest available consistent data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/GUY.dta, replace
		
						
		*153. SLB
			use data/revenue_raw, clear	
			keep if country=="SLB"
			local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
			foreach x of local all_series {
				gen pct_`x' = .  
					order pct_`x', before(gdp_HA)
				replace pct_`x' = pct_`x'_OECD if year > 2007
				replace source = "OECD" if year > 2007
				replace pct_`x' = pct_`x'_ICTD if  year < 2008
				replace source = "ICTD" if  year < 2008	
			}	
			foreach x in 1100 1200 5000 {
				replace pct_`x' = ( pct_`x'[_n+1] + pct_`x'[_n-1] ) / 2 if year==1996
			}			
				replace pct_1300=. if year==2007
			foreach x in 1100 1200 {
				gen ratio_`x' = pct_`x' / pct_1000
				replace ratio_`x' = ( ratio_`x'[_n+1] + ratio_`x'[_n-1] ) / 2 if year==2007
				replace pct_`x' = ratio_`x' * pct_1000 if year==2007
			}	
			*4000 series
				forval year = 2007 (-1) 1993 {
					replace pct_4000 = pct_4000[_n+1] if year==`year' //predicted values for missing values
				}
			*replace the aggregates after stitching (using disaggregates)
					cap drop pct_1000 //pct_5000
				egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
				egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
			*save
				replace stitch = 1 if inlist(year,2008)
				replace interpolated = 1 if inlist(year,1996)
				keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
					order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
				keep if year>=1993 //earliest available consistent and detailed data
				format %9.2fc pct*
				order stitch interpolated pct_tax, after(source)
				save data/harmonized/SLB.dta, replace
			
			
	*154. LUX
		use data/revenue_raw, clear	
		keep if country=="LUX"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/LUX.dta, replace
		
		
	*155. BHS
		use data/revenue_raw, clear	
		keep if country=="BHS"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			cap gen pct_`x'_NS=.
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year >1989
			replace source = "OECD" if year >1989
			replace pct_`x' = pct_`x'_NS if  year < 1990 
			replace source = "IMF" if year<1990				
		}	
		*adjust 2000 using RPC 
			replace pct_2000 = pct_2000_RPC if year<1990
		*6000 series
			replace pct_6000 = 0 if pct_6000 < 0
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1973 //earliest available consistent and detailed data ; NB no income tax
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BHS.dta, replace
		

	*156. BLZ
		use data/revenue_raw, clear	
		keep if country=="BLZ"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			cap gen pct_`x'_NS=.
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_NS if year < 1990
			replace source = "HA" if year < 1990
			replace pct_`x' = pct_`x'_OECD if   year>1989
			replace source = "OECD" if 	year>1989
		}	
		*adjust 2000 using RPC
			replace pct_2000 = . if year < 1990
			replace pct_2000 = pct_2000_RPC if year==1979
		*interpolate missing data
			foreach x in 1100 1200 1300 2000 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp_`x')
				replace pct_`x' = temp_`x' if pct_`x'==. & inrange(year,1980,1989)
					drop temp_`x'
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing			
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			replace interpolated = 1 if inlist(year,1986,1987)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1977 //earliest available consistent and detailed data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BLZ.dta, replace	
						
						
	*157. ISL
		use data/revenue_raw, clear	
		keep if country=="ISL"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
				gen pct_`x' = .
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if inrange(year,1965,2019)
			replace source = "OECD" if inrange(year,1965,2019) 
		}
		*interpolate
			replace interpolated = 1 if pct_1000==.
			foreach x in 1000 1100 1200 2000 4000 5000 6000 {
				ipolate pct_`x' year, gen(temp)
				replace pct_`x' = temp if year<1980 & pct_`x'==.
					drop temp
			}
		*save	
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing				
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
			keep if year>=1965
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/ISL.dta, replace
		
						
	*158. BRB
		use data/revenue_raw, clear	
		keep if country=="BRB"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			cap gen pct_`x'_NS=.
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year >1989
			replace source = "OECD" if year>1989
			replace pct_`x' = pct_`x'_NS if  year<1990 
			replace source = "HA" if year<1990				
		}	
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_ICTD if inrange(year,1986,1990)
		*4000 series
			replace pct_4000 = pct_4000 + pct_6000 if year<1990
				replace pct_6000 = .
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1972 //earliest available consistent and detailed data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/BRB.dta, replace
		
					
	*159. VUT
		/*skip for now // 4000 series ambiguous, absence of 1000 series?
		use data/revenue_raw, clear	
		keep if country=="VUT"
		merge 1:1 year using data/VUT, update replace nogen	
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			cap gen pct_`x'_NS=.
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 1999
			replace source = "OECD" if year> 1999			
			replace pct_`x' = pct_`x'_ICTD if  year < 2000
			replace source = "ICTD" if year < 2000
			replace pct_`x' = pct_`x'_NS if   year < 1990
			replace source = "IMF" if year < 1990			
		}	
		*ipolate 5000, the rest is 6000
			replace pct_6000 = . if inrange(year,1991,1992)
			ipolate pct_6000 year, gen(temp)
			replace pct_6000 = temp if inrange(year,1991,1992)
				drop temp
			replace pct_5000 = pct_taxICTD - pct_6000 if inrange(year,1991,1992)		
		*4000 series?
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1990,2000)
			replace interpolated = 1 if inlist(year,1991,1992)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1981 //earliest available consistent and detailed data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/VUT.dta, replace
		*/
		
								
	*160. WSM
		use data/revenue_raw, clear	
		keep if country=="WSM"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year > 2004
			replace source = "OECD" if year > 2004
			replace pct_`x' = pct_`x'_ICTD if   year<2005
			replace source = "ICTD" if 	year<2005			
		}	
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
				replace pct_6000 = . if year<1992
				replace pct_1000 = 0.0663426142518307 if year==1984
				replace pct_2000 = 0 if year==1984
				replace pct_4000 = 0.000856370620802852 if year==1984
				replace pct_5000 = 0.180323455171859 if year==1984
				replace pct_6000 = 0.00073626986300733 if year==1984			
				replace pct_1300 = .
				replace pct_tax = ( pct_tax[_n-1] + pct_tax[_n+1] ) / 2 if year==1991	
			foreach x in 1000 	4000 5000 6000 {
				gen ratio_`x' = pct_`x' / pct_tax
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				replace	ratio_`x'_temp = ratio_`x'_temp[_n+1] if year==1983
				replace pct_`x' = ratio_`x'_temp * pct_tax if pct_`x'==.
					drop ratio_`x'*
			}
				replace pct_1100 = . if year==2005
				replace pct_1200 = . if year==2005
		*extend backward the 1100/1200 split from OECD
			foreach x in 1100 1200 {
				gen ratio_`x' = pct_`x' / pct_1000 if year==2006
				forval year = 2005 (-1) 1983 {
					replace ratio_`x' = ratio_`x'[_n+1] if year==`year'
					replace pct_`x' = ratio_`x' * pct_1000 if year==`year'
				}
			}
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax //pct_1000 //pct_5000
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,2005)
			replace interpolated = 1 if inlist(year,1983) | inrange(year,1985,1991)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1983 //earliest available consistent and detailed data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/WSM.dta, replace
				
				
						
						
					
	*161. SYC
		use data/revenue_raw, clear	
		keep if country=="SYC"
		local all_series "1000	1100	1200	1300	2000	4000	5000	5100	5200	5300	6000"
		foreach x of local all_series {
			cap gen pct_`x'_NS = .
			gen pct_`x' = .  
				order pct_`x', before(gdp_HA)
			replace pct_`x' = pct_`x'_OECD if year >2007
			replace source = "OECD" if year>2007
			replace pct_`x' = pct_`x'_ICTD if  year<2008
			replace source = "ICTD" if year<2008
			replace pct_`x' = pct_`x'_NS if  inrange(year,1985,1989)
			replace source = "HA" if 	inrange(year,1985,1989)			
		}	
			ren pct_tax* pct_tax_*
			egen pct_tax = rowtotal(pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5100 pct_5200 pct_5300 pct_6000), missing
		*adjust 2000 using RPC
			replace pct_2000 = pct_2000_RPC if pct_2000==. | inrange(year,2005,2007)
			forval year = 2014 / 2017  {
				replace pct_2000 = pct_2000[_n-1] if year==`year'
			}
		*4000 series
			replace pct_4000 = 0 if year==1993
		*extend within tax structures to missing values
				replace pct_6000 = . if year<1985 | inrange(year,1990,1992)
			foreach x in 1100 1200 4000 5000 6000 {
				gen ratio_`x' = pct_`x' / (pct_1000 + pct_4000 + pct_5000 + pct_6000)
				ipolate ratio_`x' year, gen(ratio_`x'_temp)
				forval year = 1984 (-1) 1980 {
					replace ratio_`x'_temp = ratio_`x'_temp[_n+1] if year==`year'
				}
				replace pct_`x' = ratio_`x'_temp * (pct_tax - pct_2000) if year<1985 | inrange(year,1990,1992)
					drop ratio_`x'*
			}
		*interpolate 1100 and 4000 series
			foreach x in 1100 4000 {
				ipolate pct_`x' year, gen(temp)
					*replace pct_1200 = temp if pct_1100==.
					replace pct_`x' = temp if pct_`x'==. //inlist(year,1999.2000,2003,2004,2008,2009)
						drop temp
			}
			replace pct_1200 = pct_1200 - pct_1100 if inlist(year,1999.2000,2003,2004,2008,2009)
		*replace the aggregates after stitching (using disaggregates)
				cap drop pct_tax pct_1000 //pct_5000
			egen pct_1000 = rowtotal(pct_1100 pct_1200 pct_1300), missing
			egen pct_tax = rowtotal(pct_1000 pct_2000 pct_4000 pct_5000 pct_6000), missing
		*save
			replace stitch = 1 if inlist(year,1985,1990,2008)
			replace interpolated = 1 if inrange(year,1980,1984) | inrange(year,1990,1992)
			keep country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 //pct_5100 pct_5200 pct_5300 pct_7000 
				order country year source stitch interpolated pct_tax pct_1000 pct_1100 pct_1200 pct_1300 pct_2000 pct_4000 pct_5000 pct_6000 
			keep if year>=1980 //earliest available consistent and detailed data
			format %9.2fc pct*
			order stitch interpolated pct_tax, after(source)
			save data/harmonized/SYC.dta, replace
	
	

