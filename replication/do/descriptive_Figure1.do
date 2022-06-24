
		*********************************************************
		*  Globalization and Factor Income Taxation				*
		*	Tax Revenue Figures  								*
		*   Produces Figure 1 in Paper							*
		* 	do.descriptive_Figure1								*
		*********************************************************
		
		/* This do-file generates the time-series 
		of Tax Revenue as a share of NDP
		
		Figure 1: stacked line graphs
		*total tax revenue as a share of NDP, by source
		*1100 
		*1200
		*1300
		*2000
		*4000
		*5000
		*6000
		
														*/
		*** CONTROL CENTER
		clear all 
		set more off	
		
		local figure1 = 0
		local figure_appendix = 1
	
		*********************************************************
		* (1) Produces FIGURE 1: Tax revenue as a share of NDP
		*********************************************************	
	
	if `figure1' {
	
		local conditions ""rich!=." "rich==1" "rich==0""  // ""rich!=." "rich==1" "rich==0""
		local titles ""Global" "High-Income Countries" "Low & Middle-Income Countries"" 
		local i = 0
	
	foreach condition in `conditions' { 
		local i = `i'+1
		
		global title `: word `i' of `titles''

		use output/figs1-3.dta, replace   // figs1-3  ; data_with_selectioncorrection.dta
			display "$title: `condition'"
			keep if `condition'
			
			* Numerator: worldwide tax revenue by type
			foreach x in /*tax*/ 1100 1200 1300 2000 4000 5000 6000 {
				gen usd_`x' = ( pct_`x' / 100 ) * ndp_usd //level per country-year
				egen total_`x' = total(usd_`x'), by(year)	//total per year 
				format %25.0fc usd_`x' total_`x'
				}
			
			* Denominator: worldwide NDP
				egen total_ndp = total(ndp_usd), by(year)
				format %25.0fc total_ndp
								
			foreach x in /*tax*/ 1100 1200 1300 2000 4000 5000 6000 {
				gen total_pct_`x' = 100*(total_`x' / total_ndp)
				format %9.2fc total_pct_`x'
				} 
				
			duplicates drop year, force	
			keep total_pct_* year
			sort year 		
				
			** Generate the layers, which will be shown in the figure: 			
				gen item_4 = total_pct_1200 + total_pct_1300 * 0.5					
				gen item_3 = total_pct_1200 + total_pct_1300 * 0.5 + total_pct_4000 
				gen item_2 = total_pct_1200 + total_pct_1300 + total_pct_4000 + total_pct_1100
				gen item_1 = total_pct_1200 + total_pct_1300 + total_pct_4000 + total_pct_1100 + total_pct_2000	
				gen item_0 = total_pct_1200 + total_pct_1300 + total_pct_4000 + total_pct_1100 + total_pct_2000 + total_pct_5000 + total_pct_6000		

		*graph
			local weight weight_global_year 	
			local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
			local yaxis "ylabel(0(10)40, angle(0) nogrid labsize(vsmall) format(%3.0fc)) yscale(range(0 41)) yline(0(10)40, lstyle(minor_grid) lcolor(gs1))" 			
			local ytitle "ytitle("Tax Revenue (% NDP)", size(small) margin(small))" 
			local xaxis "xlabel(1965(10)2018, labsize(vsmall))"			
			local xtitle xtitle("")
			local legend "legend(size(*.5) symysize(3) symxsize(7) col(1) order(1 "Indirect Tax" 2 "Payroll Tax" 3 "Personal Income Tax" 4 "Property Tax" 5 "Corporate Income Tax") region(style(none)))"
			local color color(stone*.75 cranberry red  navy midblue )
				
			
				#delim ; 
						twoway  area item_0 item_1 item_2 item_3 item_4 year		, 
						t1($title, size(small))
						`xaxis' `xtitle'
						`yaxis' `ytitle'
						`color' `lpattern' `lwidth'
						`graph_region'	 
						`legend'
						name(G`i', replace) 		; 
				
					#delim cr
					
			} 	// End of conditions loop 
			
			* Graph combine the three panels: FIGURE 1 in Paper
					#delim ; 
						grc1leg2 G1 G2 G3, 
						legendfrom(G3) ring(0) pos(2) holes(2)  
						graphregion(color(white)) plotregion(color(white)); 
					#delim cr		
						gr_edit legend.xoffset = -15
						gr_edit legend.yoffset = -12
		
				graph export output/Figure1.png, replace
		
	}		// End of Figure 1
	
			
	***************************************************************************************************
	* (1) Produces FIGURE 1 Appendix: Tax revenue as a share of NDP in Developing Countries
	***************************************************************************************************	

	if `figure_appendix' {
	
		local conditions ""rich==0" "rich==0 & excomm!=1" "rich==0 & oil_impt!=1" "rich==0 & oil_impt!=1 & excomm!=1" "rich==0 & oil_impt!=1 & large==1" "rich==0 & oil_impt!=1 & large==0""
		local titles ""Benchmark" "Excluding Ex-Communist" "Excluding Oil-Rich" "Excluding Ex-Communist & Oil-Rich" "Large Countries (pop>40M, Non-Oil Rich)" "Small Countries (pop<40M, Non-Oil Rich)"" 
		local i = 0
	
	foreach condition in `conditions' { 
		local i = `i'+1
		
		global title `: word `i' of `titles''

		use output/figs1-3.dta, replace   
			display "$title: `condition'"
			keep if `condition'
			
			* Numerator: worldwide tax revenue by type
			foreach x in /*tax*/ 1100 1200 1300 2000 4000 5000 6000 {
				gen usd_`x' = ( pct_`x' / 100 ) * ndp_usd 		//level per country-year
				egen total_`x' = total(usd_`x'), by(year)		//total per year 
				format %25.0fc usd_`x' total_`x'
				}
			
			* Denominator: worldwide NDP
				egen total_ndp = total(ndp_usd), by(year)
				format %25.0fc total_ndp
								
			foreach x in /*tax*/ 1100 1200 1300 2000 4000 5000 6000 {
				gen total_pct_`x' = 100*(total_`x' / total_ndp)
				format %9.2fc total_pct_`x'
				} 
				
			duplicates drop year, force	
			keep total_pct_* year
			sort year 		
				
			** Generate the layers, which will be shown in the figure: 			
				gen item_4 = total_pct_1200 + total_pct_1300 * 0.5					
				gen item_3 = total_pct_1200 + total_pct_1300 * 0.5 + total_pct_4000 
				gen item_2 = total_pct_1200 + total_pct_1300 + total_pct_4000 + total_pct_1100
				gen item_1 = total_pct_1200 + total_pct_1300 + total_pct_4000 + total_pct_1100 + total_pct_2000	
				gen item_0 = total_pct_1200 + total_pct_1300 + total_pct_4000 + total_pct_1100 + total_pct_2000 + total_pct_5000 + total_pct_6000		

		*graph
			local weight weight_global_year 	
			local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
			local yaxis "ylabel(0(10)40, angle(0) nogrid labsize(vsmall) format(%3.0fc)) yscale(range(0 41)) yline(0(10)40, lstyle(minor_grid) lcolor(gs1))" 			
			local ytitle	"ytitle("Tax Revenue (% NDP)", size(small) margin(small))" 
			local xaxis "xlabel(1965(10)2018, labsize(vsmall))"			
			local xtitle xtitle("")
			local legend "legend(size(*.5) symysize(3) symxsize(7) row(2) order(5 "Corporate Income Tax" 3 "Personal Income Tax" 1 "Indirect Tax" 4 "Property Tax" 2 "Payroll Tax") region(style(none)))"
			local color color(stone*.75 cranberry red  navy midblue)
				
			
				#delim ; 
						twoway  area item_0 item_1 item_2 item_3 item_4 year		, 
						t1($title, size(small))
						`xaxis' `xtitle'
						`yaxis' `ytitle'
						`color' `lpattern' `lwidth'
						`graph_region'	 
						`legend'
						name(G`i', replace) 		; 
				
					#delim cr
					
			} 	// End of conditions loop 
			
			
			* Graph combine the panels: FIGURE Appendix
			#delim ; 
				grc1leg2 G1 G2 G3 G4   , 
				rows(3) graphr(margin(zero))  legendfrom(G1) position(12) 
				graphregion(color(white)) plotregion(color(white))   
				name(fig1_appendix, replace) ; 
			#delim cr 	
			
			graph display fig1_appendix, ysize(5) xsize(5)
			
			graph export output/Figure1_appendix.png, replace	
			

	}		// End of Figure 1 Appendix
	
