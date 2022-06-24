
	*graph coverage of gdp, population, and #countries
	*by high vs low
	
	u output/figs1-3, clear
		keep country year rich ETR_K_prime ETR_L_prime pop gdp
		drop if ETR_L_prime==. //in order to not hold GDP for countries where no data
	 

	 *import GDP from World Bank WDI: we use World Bank totals for its world total and for high-income vs. developing-country totals	
		merge 1:1 country year using "data/misc/auxiliary/all regions gdp and pop_wdi.dta", keepusing(gdp_2010usd gdp_currentusd pop)
			drop if _merge==2 & country!="WLD" & country!="HIC"
			drop _merge //TWN
		
		*import GDP to WB dataset, from WID, for (Taiwan and other) countries missing GDP (missing from World Bank but not from our dataset via WID)
				merge 1:1 country year using output/Lsh_compo_wid_raw.dta, keepusing(nni nni_usd gdp pop nni_index) update
					*put the WID (-->our dataset) GDP totals into 2010 index in order to match the World Bank WDI measurements
						egen nni_index_usd = mean(nni_index) if country=="USA", by(year)
							egen temp = mean(nni_index_usd), by(year)
							replace	nni_index_usd = temp if nni_index_usd==.
							drop temp
							drop nni_index
						egen nni_index_2010usd = mean(nni_index_usd) if year==2010
							egen temp = mean(nni_index_2010usd)
							replace nni_index_2010usd = temp if nni_index_2010usd==.
							drop temp
						gen	nni_currentusd = nni_usd * nni_index_usd
						gen nni_2010usd = nni_usd * nni_index_2010usd
						format %25.0fc nni_currentusd nni_2010usd
							/*missing in WB, replaced from WID	
							br if ETR_K!=. & gdp_2010usd==.
							gen flag=1 if ETR_K!=. & gdp_2010usd==.
							egen flag_country = max(flag), by(country)
							br if flag_country==1
							drop flag*
							*/
						*fill series & housekeeping
							replace gdp_currentusd = nni_currentusd * gdp if ETR_K!=. & gdp_currentusd==. // country=="TWN"
							replace gdp_2010usd = nni_2010usd * gdp if ETR_K!=. & gdp_2010usd==. // country=="TWN"
						
							drop if ETR_K==. & country!="WLD" & country!="HIC"
							drop if !inrange(year,1965,2018)
							drop nni - nni_2010usd
			
			*replace HIC pop and gdp to exclude the non-OECD countries that are part of WB 'high-income' definition but are not part of our 'high-income OECD' definition
					gen tag=.
					replace tag=1 if country=="BHR"
					replace tag=1 if country=="BHS"
					replace tag=1 if country=="BRB"
					replace tag=1 if country=="CYP"
					replace tag=1 if country=="HRV"
					replace tag=1 if country=="MUS"
					replace tag=1 if country=="OMN"
					replace tag=1 if country=="PAN"
					replace tag=1 if country=="QAT"
					replace tag=1 if country=="ROU"
					replace tag=1 if country=="SAU"
					replace tag=1 if country=="SYC"
					replace tag=1 if country=="TTO"
					replace tag=1 if country=="URY"

	*totals of GDP, by high-income vs. developing
			foreach concept in pop gdp_2010usd gdp_currentusd {
				egen total_`concept' = total(`concept') if country!="WLD" & country!="HIC", by(year)
				egen total_rich_`concept' = total(`concept') if rich==1 /*country!="WLD" & country!="HIC"*/, by(year)
					egen temp = mean(total_`concept'), by(year)
					egen temp_rich = mean(total_rich_`concept'), by(year)
						replace total_`concept' = temp if total_`concept'==.
						replace total_rich_`concept' = temp_rich if total_rich_`concept'==.
							drop temp*
				egen total_nonoecd_`concept' = total(`concept') if tag==1, by(year) //this is the amt to subtract from WB high-income denominator in order to retrieve an apples-to-apples high-inc non-OECD denominator
					egen temp = mean(total_nonoecd_`concept'), by(year)
					replace total_nonoecd_`concept' = temp if total_nonoecd_`concept'==.
					drop temp
			}
			
				gen countries=.
				gen countries_rich=.
			forval year = 1965 / 2018 {	
				count if ETR_K!=. & year==`year'
				replace countries=`r(N)' if year==`year'
				
				count if ETR_K!=. & year==`year' & rich==1
				replace countries_rich=`r(N)' if year==`year'
			}
				
			*fix HIC to exclude non-OECD
				foreach concept in pop gdp_2010usd gdp_currentusd {
					replace `concept' = `concept' - total_nonoecd_`concept' if country=="HIC"
				}
					drop total_nonoecd* *gdp_currentusd //strictly use constant
						
			*percentages
				foreach concept in pop gdp_2010usd {
					gen world_`concept' = `concept' if country=="WLD"
					gen hic_`concept' = `concept' if country=="HIC"
						egen temp1 = mean(world_`concept'), by(year)
						egen temp2 = mean(hic_`concept'), by(year)
							replace world_`concept' = temp1 if world_`concept'==.
							replace hic_`concept' = temp2 if hic_`concept'==.
								drop temp*
				}
				
					
						
						
				collapse world_pop hic_pop 	total_pop total_rich_pop 	world_gdp_2010usd hic_gdp_2010usd	total_gdp_2010usd total_rich_gdp_2010usd 	countries countries_rich, by(year)
					ren *gdp_2010usd *gdp		 
					ren world* wdi*
					ren hic* wdi_rich*
					ren total* bfjz*
					ren countries* bfjz_countries*

				foreach concept in pop gdp {
				foreach source in wdi bfjz {
					gen `source'_nonrich_`concept' = `source'_`concept' - `source'_rich_`concept'
					order `source'_nonrich_`concept', after(`source'_rich_`concept')
				}
				}

				order year wdi_pop wdi_rich_pop wdi_nonrich_pop wdi_gdp wdi_rich_gdp wdi_nonrich_gdp bfjz_pop bfjz_rich_pop bfjz_nonrich_pop bfjz_gdp bfjz_rich_gdp bfjz_nonrich_gdp bfjz_countries bfjz_countries_rich


				foreach concept in pop rich_pop nonrich_pop gdp rich_gdp nonrich_gdp {
					gen pct_`concept' = bfjz_`concept' / wdi_`concept' 
					replace pct_`concept' = 1 if pct_`concept' > 1 //measurement error in WB 'high-income' concept vs. ours? (are we subtracting some values [tag==1] that were never even counted...?
				}
					gen bfjz_countries_nonrich = bfjz_countries - bfjz_countries_rich

								/*keep if country=="WLD" | country=="HIC"
								foreach concept in pop gdp_2010usd gdp_currentusd {
									gen pct_`concept' = total_`concept' / `concept' if country=="WLD"
									replace `concept' = `concept' - total_nonoecd_`concept' if country=="HIC"
									gen pct_`concept' = total_rich_`concept' / `concept' if country=="HIC"
								}
								*/
				format %9.2fc pct_*
				order year pct_* bfjz_countries*
				br
				
				keep year - bfjz_countries_nonrich 
				
				
				
				*for graph, multiply by 100
				foreach var of varlist pct* {
					replace `var' = `var' * 100
				}
		
		
		********** COVERAGE FIGURE IN PAPER *******************
			
		**** Figure options
		
			local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
			local yaxis1 "ylabel(0(25)100, angle(0) nogrid labsize(small) format(%3.0fc)) yscale(range(0 100)) yline(0(25)100, lstyle(minor_grid) lcolor(gs1))" 			
			local ytitle1	"ytitle("coverage (%)", size(small) margin(small))" 
			local yaxis2 "ylabel(0(50)150, angle(0) nogrid labsize(small) format(%3.0fc) axis(2))"
 			local yaxis2_rich "ylabel(0(10)40, angle(0) nogrid labsize(small) format(%3.0fc) axis(2))" 
			local yaxis2_poor "ylabel(0(25)125, angle(0) nogrid labsize(small) format(%3.0fc) axis(2))" 
			local ytitle2	"ytitle("# countries", size(small) margin(small) axis(2))" 
			local xaxis "xlabel(1965(10)2018, labsize(small))"				
			local xtitle xtitle("")
			local color1 color(olive_teal maroon)
			// local color1 color(midblue orange_red)
			local color2 color(black)
			local lpattern1 lpattern(solid solid)
			local lpattern2 lpattern(dash)
			local lwidth1 lwidth(thick thick)
			local lwidth2 lwidth(thin)
			
		*global		
												/*
												#delim ; 
													twoway  line pct_pop pct_gdp year	, yaxis(1) `yaxis1' `ytitle1'
														||	line bfjz_countries year, yaxis(2)	`yaxis2' `ytitle2'
														||	`xaxis' `xtitle'
															`color' `lpattern' `lwidth'
															`graph_region'	
															legend(off)
															t1(Global, size(small))
															name(coverage_all, replace)
														;
												#delim cr
												*/
			
			
			#delim ; 
				twoway  line pct_pop pct_gdp year	, yaxis(1) `yaxis1' `ytitle1' `color1' `lpattern1' `lwidth1'
					||	line bfjz_countries year, yaxis(2) `yaxis2' `ytitle2' `color2' `lpattern2' `lwidth2'
						`xaxis' `xtitle'
						`graph_region'	
						legend(off)
						t1(Global, size(small))
						name(coverage_all, replace)
					;
			#delim cr
		
		*Rich
			#delim ; 
				twoway  line pct_rich_pop pct_rich_gdp year	, yaxis(1) `yaxis1' `ytitle1' `color1' `lpattern1' `lwidth1'
					||	line bfjz_countries_rich year, yaxis(2) `yaxis2_rich' `ytitle2' `color2' `lpattern2' `lwidth2'
						`xaxis' `xtitle'
						`graph_region'	
						legend(off)
						t1(High-Income Countries, size(small))
						name(coverage_rich, replace)
					;
			#delim cr
			
		*Poor
			#delim ; 
				twoway  line pct_nonrich_pop pct_nonrich_gdp year	, yaxis(1) `yaxis1' `ytitle1' `color1' `lpattern1' `lwidth1'
					||	line bfjz_countries_nonrich year, yaxis(2) `yaxis2_poor' `ytitle2' `color2' `lpattern2' `lwidth2'
						`xaxis' `xtitle'
						`graph_region'	
						t1(Low & Middle-Income Countries, size(small))
						legend(symxsize(7) cols(1) order(1 "Population (% of total)" 2 "GDP (% of total)" 3 "# countries" ) size(vsmall) region(style(none)))
						name(coverage_poor, replace)
					;
			#delim cr
		
		* Combine all three panels
					#delim ; 
						grc1leg2 coverage_all coverage_rich coverage_poor, 
						legendfrom(coverage_poor) ring(0) pos(2) holes(2)  
						graphregion(color(white)) plotregion(color(white)); 
					#delim cr		
						gr_edit legend.xoffset = -15
						gr_edit legend.yoffset = -10
		
	
		graph export output/coverage.png, replace
		
