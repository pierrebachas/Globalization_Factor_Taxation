

		*********************************************************
		*  Globalization and Factor Income Taxation				*
		*	Capital Share Figures  								*
		*   Produces Figure 2 In Paper							*
		* 	do.descriptive_Figure2								*
		*********************************************************

		*** CONTROL CENTER
		clear all 
		set more off	
		
		local figure2 = 0
		local figure_appendix = 1		

		*******************************************************************************
		* (1) Produces FIGURE 2: Capital Share and Capital share of Corporate Sector
		*******************************************************************************
	
	if `figure2' {	
	
		local conditions ""rich!=." "rich==1" "rich==0""  // ""rich!=." "rich==1" "rich==0""
		local titles ""Global" "High-Income Countries" "Low & Middle-Income Countries"" 
		local i = 0
	
	foreach condition in `conditions' { 
		local i = `i'+1
		
		global title `: word `i' of `titles''
		
		use output/figs1-3.dta, replace   // figs1-3  ; data_with_selectioncorrection.dta
			display "$title: `condition'"
			keep if `condition'		
		
		** Construct the totals
			* Numerator
				foreach x in Ksh_ndp {
					gen usd_`x' = ( `x' / 100 ) * ndp_usd 		//	level of capital stock per country-year
					egen num_`x' = total(usd_`x'), by(year)	// total across countries per year 
					format %25.0fc usd_`x' num_`x'
					}
				
				*Note Ksh_corp has different denominator ( = os_corp + ce_hh )
				foreach x in Ksh_corp	{
					gen usd_`x' = ( `x' / 100 ) * ((os_corp + ce_hh)/100 * ndp_usd ) //level per country-year, make sure this is in %NDP rather than %fpNDP
					egen num_`x' = total(usd_`x'), by(year)						//total per year 
					format %25.0fc usd_`x' num_`x'
					}

			* Denominators		
				gen corp_usd = (os_corp + ce_hh)/100 * ndp_usd 		// PB comment: seems like a useufl variable should it be created in master? 
				foreach y in ndp corp {
					egen den_Ksh_`y' = total(`y'_usd), by(year)
					}			
	
			** Combine numerator and Denominators 
				foreach x in ndp corp	{
					gen total_Ksh_`x' = 100*(num_Ksh_`x' / den_Ksh_`x')
					}
			
			duplicates drop year, force	
			keep total_Ksh_ndp  total_Ksh_corp  year	
			sort year 	
			
			
			* local for graphs	
						local weight weight_global_year 	
						local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
						local yaxis "ylabel(20(10)40, angle(0) nogrid labsize(vsmall) format(%3.0fc)) yscale(range(16 46)) yline(20(10)40, lstyle(minor_grid) lcolor(gs1))" 		
						local ytitle	"ytitle("Share of Net Domestic Product", size(small) margin(small))" 
						local xaxis "xlabel(1965(10)2018, labsize(vsmall))"			
						local xtitle xtitle("")
						local color color(midblue midblue)
						local lwidth lwidth(thick thin)
						local lpattern lpattern(solid dash)
						local legend "legend(size(*.5) symxsize(7) cols(1) order(1 "Capital Share (Overall)" 2 "Capital Share of Corporate Sector") region(style(none)))" 
			
			* Graphs		
				#delim ; 
				twoway  line total_Ksh_ndp  total_Ksh_corp  year		, 
						t1($title, size(small))
						`xaxis' `xtitle'
						`yaxis' `ytitle'
						`color' `lpattern' `lwidth'
						`graph_region'	 
						`legend'
						name(G`i', replace) 		; 
					#delim cr	
			
						
		} 		// End of conditions loop 
		
				* Graph combine the three panels: FIGURE 2 in Paper
				#delim ; 
						grc1leg2 G1 G2 G3, 
						legendfrom(G3) ring(0) pos(2) holes(2)  
						graphregion(color(white)) plotregion(color(white)); 
					#delim cr		
						gr_edit legend.xoffset = -8
						gr_edit legend.yoffset = -15
		
				graph export output/Figure2.png, replace
		
	}		// End of Figure 2 	
				
			
		*******************************************************************************
		* (2) Produces Appendix Figure 
		*******************************************************************************
		
		
	
	if `figure_appendix' {	
	
		local conditions ""rich==0" "rich==0 & excomm!=1" "rich==0 & oil_impt!=1" "rich==0 & oil_impt!=1 & excomm!=1" "rich==0 & oil_impt!=1 & large==1" "rich==0 & oil_impt!=1 & large==0""
		local titles ""Benchmark" "Excluding Ex-Communist" "Excluding Oil-Rich" "Excluding Ex-Communist & Oil-Rich" "Large Countries (pop>40M, Non-Oil Rich)" "Small Countries (pop<40M, Non-Oil Rich)"" 
		local i = 0
	
	foreach condition in `conditions' { 
		local i = `i'+1
		
		global title `: word `i' of `titles''
		
		use output/figs1-3.dta, replace   // figs1-3  ; data_with_selectioncorrection.dta
			display "$title: `condition'"
			keep if `condition'		
		
		** Construct the totals
			* Numerator
				foreach x in Ksh_ndp {
					gen usd_`x' = ( `x' / 100 ) * ndp_usd 		//	level of capital stock per country-year
					egen num_`x' = total(usd_`x'), by(year)	// total across countries per year 
					format %25.0fc usd_`x' num_`x'
					}
				
				*Note Ksh_corp has different denominator ( = os_corp + ce_hh )
				foreach x in Ksh_corp	{
					gen usd_`x' = ( `x' / 100 ) * ((os_corp + ce_hh)/100 * ndp_usd ) //level per country-year, make sure this is in %NDP rather than %fpNDP
					egen num_`x' = total(usd_`x'), by(year)						//total per year 
					format %25.0fc usd_`x' num_`x'
					}

			* Denominators		
				gen corp_usd = (os_corp + ce_hh)/100 * ndp_usd 		// PB comment: seems like a useufl variable should it be created in master? 
				foreach y in ndp corp {
					egen den_Ksh_`y' = total(`y'_usd), by(year)
					}			
	
			** Combine numerator and Denominators 
				foreach x in ndp corp	{
					gen total_Ksh_`x' = 100*(num_Ksh_`x' / den_Ksh_`x')
					}
			
			duplicates drop year, force	
			keep total_Ksh_ndp  total_Ksh_corp  year	
			sort year 	
			
			
			* local for graphs	
						local weight weight_global_year 	
						local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
						local yaxis "ylabel(20(10)40, angle(0) nogrid labsize(vsmall) format(%3.0fc)) yscale(range(20 47)) yline(20(10)40, lstyle(minor_grid) lcolor(gs1))" 		
						local ytitle	"ytitle("Share of Net Domestic Product", size(small) margin(small))" 
						local xaxis "xlabel(1965(10)2018, labsize(vsmall))"			
						local xtitle xtitle("")
						local color color(midblue midblue)
						local lwidth lwidth(thick thin)
						local lpattern lpattern(solid dash)
						local legend "legend(size(*.5) symxsize(7) row(1) order(1 "Capital Share (Overall)" 2 "Capital Share of Corporate Sector") region(style(none)))" 
			
			* Graphs		
				#delim ; 
				twoway  line total_Ksh_ndp  total_Ksh_corp  year		, 
						t1($title, size(small))
						`xaxis' `xtitle'
						`yaxis' `ytitle'
						`color' `lpattern' `lwidth'
						`graph_region'	 
						`legend'
						name(G`i', replace) 		; 
					#delim cr	
			
						
		} 		// End of conditions loop 
		
				* Graph combine the panels. 
				#delim ; 
					grc1leg2 G1 G2 G3 G4 G5 G6  , 
					rows(3) graphr(margin(zero))  legendfrom(G6) position(12) 
					graphregion(color(white)) plotregion(color(white))   
					name(fig2_appendix, replace) ; 
				#delim cr 	
			
			graph display fig2_appendix, ysize(5) xsize(5)
		
			graph export output/Figure2_appendix.png, replace
		
	}		// End of Figure Appendix	
						
		
