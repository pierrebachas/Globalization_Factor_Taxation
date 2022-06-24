
		*********************************************************
		*  Globalization and Factor Income Taxation				*
		*	ETR figures   										*
		*   Produces Figure 3 and 4 in Paper					*
		* 	do.descriptive_Figure2								*
		*********************************************************
		
		/* This do-file generates the time-series of ETR
			
		(1) Produces FIGURE 3: 	ETR on K, L and CIT
		(2) Produces Figure 4: Robustness of ETR patterns 
		
														*/
		*** CONTROL CENTER
		clear all 
		set more off	
		
		local figure3 = 1 
		local figure4 = 0
		
		*********************************************************
		* (1) Produces FIGURE 3: 	ETR on K, L and CIT
		*********************************************************
				
		
pause on				
	if `figure3' {
	
		local conditions ""rich!=." "rich==1" "rich==0""  // ""rich!=." "rich==1" "rich==0""
		local titles ""Global" "High-Income Countries" "Low & Middle-Income Countries"" 
		local i = 0
	
	foreach condition in `conditions' { 
		local i = `i'+1
		
		global title `: word `i' of `titles''

		use output/figs1-3.dta, replace   // figs1-3  ; data_with_selectioncorrection.dta
			
		// Need to adjust for China which appears to be missing
		replace Ksh_psz = Ksh_ndp	if country_name == "China"	
		replace Lsh_psz = Lsh_ndp	if country_name == "China"		
			
			display "$title: `condition'"
			keep if `condition'
			** Construct the totals for K, L and cit
			
			rename ETR_cit ETR_cit_prime //  Just to make the loop run
			
				foreach f in L K cit	{ 				 			
					gen T_`f' = ( ETR_`f'_prime / 100 ) * (`f'sh_ndp / 100) * ndp_usd
					gen Y_`f' = (`f'sh_ndp / 100) * ndp_usd	
					egen total_T_`f' = total(T_`f') , by(year)
					egen total_Y_`f' = total(Y_`f') , by(year)
					gen total_ETR_`f' = (total_T_`f' / total_Y_`f')*100
					}
					
					*ILO - psz correction for US
					foreach f in L K	{ 				 			
						gen T_`f'_ilo = ( ETR_`f'_prime / 100 ) * (`f'sh_ndp / 100) * ndp_usd
						gen Y_`f'_ilo = (`f'sh_psz / 100) * ndp_usd									// Note psz used to correct for US 
						egen total_T_`f'_ilo = total(T_`f'_ilo) , by(year)
						egen total_Y_`f'_ilo = total(Y_`f'_ilo) , by(year)
						gen total_ETR_`f'_ilo = (total_T_`f'_ilo / total_Y_`f'_ilo)*100
						}
						
			duplicates drop year, force	
			keep total_ETR_L total_ETR_L_ilo total_ETR_K total_ETR_K_ilo total_ETR_cit year
			sort year 	
*pause
			local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
			local yaxis "ylabel(0(10)40, angle(0) nogrid labsize(vsmall) format(%3.0fc)) yscale(range(0 40)) yline(0(10)40, lstyle(minor_grid) lcolor(gs1))" 			
			local ytitle	"ytitle("Effective Tax Rate (%)", size(vsmall) margin(small))" 
			local xaxis "xlabel(1965(10)2018, labsize(vsmall))"				
			local xtitle xtitle("")
			local color color(red maroon midblue navy midblue)
			local lpattern lpattern(solid shortdash solid shortdash)
			local lwidth lwidth(medthick medthick medthick medthick)
			local legend "legend(symxsize(7) cols(1) order(1 "on Labor" 2 "on Labor (ILO mixed income)" 3 "on Capital" 4 "on Capital (ILO mixed income)") size(vsmall) region(style(none)))"
			local size 	"xsize(7) ysize(7)"	
				
			#delim ; 
			
			twoway line total_ETR_L total_ETR_L_ilo total_ETR_K total_ETR_K_ilo  year , 
						t1($title, size(small))
						`xaxis' `xtitle'
						`yaxis' `ytitle'
						`color' `lpattern' `lwidth'
						`graph_region'	 
						`legend'
						name(G`i', replace) 		; 
						
				#delim cr	
						
		} 	// End of conditions loop 
				
				* Graph combine the three panels: FIGURE 3 in Paper
					#delim ; 
						grc1leg2 G1 G2 G3, 
						legendfrom(G3) ring(0) pos(2) holes(2)  
						graphregion(color(white)) plotregion(color(white)); 
					#delim cr		
						gr_edit legend.xoffset = -10
						gr_edit legend.yoffset = -15
		
				graph export output/Figure3_ilo.png, replace
		
	}		// End of Figure 3 
		
		***************************************************************************************
		* (2) Produces Figure 4: Robustness of ETR patterns in developing countries 
		***************************************************************************************
	
		** oil_impt takes values . or 1 --> fix way erlier to take values 0,1 and then remember to change conditions here
	
	if `figure4'{
	
		local conditions ""rich==0" "rich==0 & excomm!=1" "rich==0 & oil_impt!=1" "rich==0 & oil_impt!=1 & excomm!=1" "rich==0 & oil_impt!=1 & large==1" "rich==0 & oil_impt!=1 & large==0""
		local titles ""Benchmark" "Excluding Ex-Communist" "Excluding Oil-Rich" "Excluding Ex-Communist & Oil-Rich" "Large Countries (pop>40M, Non-Oil Rich)" "Small Countries (pop<40M, Non-Oil Rich)"" 
		local i = 0
	
	foreach condition in `conditions' { 
		local i = `i'+1
		
		global title `: word `i' of `titles''

		use output/figs1-3.dta, clear 
			
			display "$title: `condition'"
			keep if `condition'
			
			rename ETR_cit ETR_cit_prime //  Just to make the loop run
			
					foreach f in L K cit	{ 	 	
				
						gen T_`f' = ( ETR_`f'_prime / 100 ) * (`f'sh_ndp / 100) * ndp_usd
						gen Y_`f' = (`f'sh_ndp / 100) * ndp_usd
						
						egen total_T_`f' = total(T_`f') , by(year)
						egen total_Y_`f' = total(Y_`f') , by(year)
						
						gen total_ETR_`f' = (total_T_`f' / total_Y_`f')*100
						
					}	
				
			unique country 	
		
			duplicates drop year, force	
			keep total_ETR_L total_ETR_K total_ETR_cit year
			sort year

			local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
			local yaxis "ylabel(0(10)30, angle(0) nogrid labsize(vsmall) format(%3.0fc)) yscale(range(0 30)) yline(0(10)30, lstyle(minor_grid) lcolor(gs1))" 			
			local ytitle	"ytitle("Effective Tax Rate (%)", size(vsmall) margin(small))" 
			local xaxis "xlabel(1965(10)2018, labsize(vsmall))"				
			local xtitle xtitle("")
			local color color(red midblue midblue )
			local lpattern lpattern(solid solid dash)
			local lwidth lwidth(thick thick thin)	
			//local size "xsize(7) ysize(7)"	
				
			#delim ; 
			
			twoway line total_ETR_L total_ETR_K  total_ETR_cit year , 
						t1($title, size(small))
						`xaxis' `xtitle'
						`yaxis' `ytitle'
						`color' `lpattern' `lwidth'
						`graph_region'	 
						legend(symxsize(7) rows(1) order(1 "on Labor" 2 "on Capital" 3 "on Corporate Profits") size(vsmall) region(style(none)))
						name(G`i', replace) 		; 
						
				#delim cr		
		} 
			
			* Graph combine the panels: FIGURE 4 in Paper
			#delim ; 
				grc1leg2 G1 G2 G3 G4 G5 G6  , 
				rows(3) graphr(margin(zero))  legendfrom(G6) position(12) 
				graphregion(color(white)) plotregion(color(white))   
				name(fig4, replace) ; 
			#delim cr 	
			
			graph display fig4, ysize(5) xsize(5)
			
			graph export output/Figure4.png, replace

	}
