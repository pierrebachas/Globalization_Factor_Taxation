
		*********************************************************
		*  ETR figures for major countries 						*
		*********************************************************

		clear all 
		set more off
		
		***********************************************************************
		* ETRs for the largest Developing countries: 	
		***********************************************************************

				
		use output/figs1-3.dta, replace
		keep if rich == 0
		egen tag = tag(country)
		list country if large == 1 & oil_impt ==1 & tag == 1
		
		* Sort
		gsort -year -ndp_usd 
		gen rank_ndp = _n 
		gsort -year -pop
		gen rank_pop = _n 		
		
		list country rank_ndp rank_pop if rank_ndp <= 30
		
		gen rank_for_graph = (rank_ndp+rank_pop) / 2
		gsort -year rank_for_graph
		list country rank_for_graph if rank_ndp <= 30

		local country  "CHN IDN IND PAK BGD BRA NGA MEX ETH PHL EGY VNM COD TUR THA TZA COL ZAF ARG PER MYS IRN RUS UKR DZA MAR SAU" ///   20 largest developing countries 
		/// sort country year 

		** 20 Largest developing countries 
		
		foreach var in `country' {
		
			local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
			local yaxis "ylabel(0(10)40, angle(0) nogrid labsize(vsmall) format(%3.0fc)) yscale(range(0 41)) yline(0(10)40, lstyle(minor_grid) lcolor(gs1))" 			
			// local ytitle	"ytitle("Effective Tax Rate (%)", size(vsmall) margin(small))" 
			local xaxis "xlabel(1965(10)2018, labsize(vsmall))"				
			local xtitle xtitle("")
			local color color(red midblue)
			local lpattern lpattern(solid solid)
			local lwidth lwidth(thick thick)	
			// local size 	"xsize(7) ysize(7)"	
				
			#delim ; 
			
			twoway line ETR_L_prime ETR_K_prime  year if country == "`var'" , 		/// 	e_ETR_L_prime  e_ETR_K_prime 
						 title(`var', size(small) ring(0))
						 //t1(`var', size(small))
						`xaxis' `xtitle'
						`yaxis' `ytitle'
						`color' `lpattern' `lwidth'
						`graph_region'
						legend(col(1) title("Effective Tax Rate", size("tiny") color(black)) order(1 "on Labor" 2 "on Capital") size(vsmall) region(style(none)) symxsize(*.3) symysize(*.3))
						name(G_`var', replace) 		; 
						
				#delim cr	
				} 
				

			*** Figure for paper with main Developing Countries 	
				
			#delim ; 
			grc1leg2 G_CHN G_IND G_BRA G_IDN G_RUS G_MEX G_NGA G_TUR G_PHL				// G_ETH
			 G_PAK G_BGD G_THA G_EGY G_ZAF G_VNM G_ARG G_COL , 
			col(3)
			legendfrom(G_CHN) ring(0) pos(2) holes(3)  lsize(tiny)
			graphregion(color(white)) plotregion(color(white))
			name("fig_country", replace); 
			#delim cr			
			
			graph display fig_country, ysize(5) xsize(5)
			
			gr_edit legend.xoffset = -5
			gr_edit legend.yoffset = -2
			
			graph export output/Fig_ETR_Countries.png, replace
			

				
				
				
				
				
				
				
				
				
				
