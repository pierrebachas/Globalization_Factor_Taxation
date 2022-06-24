***************************************************************************************
*  	Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman								  
*  	program: analysis_1_binscatter.do		
* 	Task: Produces binned scatterplots to show correlation between outcomes and trade
***************************************************************************************
	
	***************************************************************************************		
	* Setup
	***************************************************************************************	
	
	set more off
	pause on
	
		use "data/master_$dateyear.dta", clear   // 	*use "data/master_15 Jun 2022.dta", clear 

		*first-difference over time horizons: 2, 5, 7, 10 years
			foreach var in trade k_open Ksh_ndp Ksh_corp ETR_K_ndp ETR_L_ndp ETR_K_alpha ETR_L_alpha ETR_K_ilo ETR_L_ilo ETR_K_mendoza ETR_L_mendoza ETR_L_dual ETR_K_dual ETR_L_prime ETR_K_prime { // /*ETR_cit Y_corp_Y*/ /*Ksh_net*/
			foreach t in 2 5 7 10 {
				gen d`t'_`var' = (`var' - L`t'.`var') / L`t'.`var'
						format %9.2fc d`t'_`var'
					winsor2 d`t'_`var', trim cuts(5 95) replace //winsorize at 5th and 95th percentiles of distribution of new first-diff variables
			}
			}
			
			gen opening = 1 if d5_k_open > 0 & d5_k_open!=.
				replace opening = 0 if d5_k_open <= 0 & d5_k_open!=.
			gen closing = 1 if d5_k_open < 0 & d5_k_open!=.
				replace closing = 0 if d5_k_open >= 0 & d5_k_open!=.
	
	
	***************************************************************************************	
	*** Figure 5 in paper 																***
	***************************************************************************************	

	*** Correlation change in trade on change in capital shares			
		*Ksh_ndp and _corp
			foreach a in ndp /*net*/ corp {
			foreach t in 5 {					// Time intervals over which we look at the differences:  2 5 7 10 
						reghdfe d`t'_Ksh_`a' d`t'_trade, abs(year)
						matrix m = r(table)
						local b : di %6.3f m[1,1]
						local se : di %6.3f m[2,1]					
				
				*** Locals used for the figure 
				local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
				local ylabel	"ylabel(0(0.02)0.08, labsize(medsmall) notick format(%3.2fc)) yscale(range(0 0.09)) yline(0(0.02)0.08, lstyle(minor_grid) lcolor(gs1))" 
				local xlabel	xlabel(-.4(.2).7,labsize(medsmall) notick format(%3.2fc))
				local colors 	"colors(midblue) lcolors(gs10)"				
				
				#delimit ;
				binscatter d`t'_Ksh_`a' d`t'_trade, 
					controls(year)
					nquantiles(20)
					text(0.075 -.40 "  b: `b'" "se: (`se')" , size(medsmall) place(se) /*box*/ just(left) margin(l+2 t+1 b+1) width(12) fcolor(white))
					// title("{it:{&theta}{subscript:K}{subscript:`a'}}", ring(0) pos(12) size(small))
					`colors'
					ytitle("`t'-year Change in Capital Share", size(medsmall) margin(medsmall)) 
					xtitle("`t'-year Change in Trade" ,size(medsmall)) 
					`ylabel'
					`xlabel'
					/*note("Note: Linear trend lines; unweighted means, controlling for year FE."
						"		Changes are measured with respect to five years prior, expressed as a percentage of the starting value."
						"		Outliers are winsorized at the 5th and 95th percentiles."
						"		Binned scatterplot: each point represents 1/20th of all observations.", size(vsmall))
					*/	
					`graph_region' 
					name(Ksh_`a'_`t', replace) 		;
					#delimit cr				
			}
			}	



		*ETR_L and _K
			foreach f in L K {
			foreach t in 5 { // 2 5 7 10 {
					reghdfe d`t'_ETR_`f'_prime d`t'_trade, abs(year)
					matrix m = r(table)
					local b : di %6.3f  m[1,1]
					local se : di %6.3f  m[2,1]
				
				*** Locals used for the figure 
				local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
				local ylabel	"ylabel(0(0.05)0.20, labsize(medsmall) notick format(%3.2fc)) yscale(range(0 0.22)) yline(0(0.05)0.20, lstyle(minor_grid) lcolor(gs1))" 
				local xlabel	xlabel(-.4(.2).7,labsize(medsmall) notick format(%3.2fc))
				local colors_K 	"colors(midblue) lcolors(gs10)"
				local colors_L 	"colors(red) lcolors(gs10)"
				
				#delimit ;
				binscatter d`t'_ETR_`f'_prime d`t'_trade,
					controls(year)
					reportreg
					nquantiles(20)
					text(.18 -.40 "  b: `b'" "se: (`se')" , size(medsmall) place(se) /*box*/ just(left) margin(l+2 t+1 b+1) width(12) fcolor(white))
					// title("{it:ETR{subscript:`f'}}", ring(0) pos(12) size(small))
					`colors_`f''
					ytitle("`t'-year Change in ETR `f'", size(medsmall) margin(medsmall)) 
					xtitle("`t'-year Change in Trade" ,	size(medsmall) margin(medsmall))
					`ylabel'
					`xlabel'
					/*note("Note: Linear trend lines; unweighted means, controlling for year FE."
						"		Changes are measured with respect to five years prior, expressed as a percentage of the starting value."
						"		Outliers are winsorized at the 5th and 95th percentiles."
						"		Binned scatterplot: each point represents 1/20th of all observations.", size(vsmall))
					*/	
					`graph_region' 
					name(ETR_`f'_`t', replace) ;
					#delimit cr					
			}
			}

		***************************************************************************************	
		** Export these first 4 graphs to be saved as panels for the paper Figure 5 		 **
		***************************************************************************************

		graph display Ksh_ndp_5
		graph export output/fig5_panelA.png, replace		
		
		graph display Ksh_corp_5
		graph export output/fig5_panelB.png, replace		
		
		graph display ETR_K_5
		graph export output/fig5_panelC.png, replace		
		
		graph display ETR_L_5
		graph export output/fig5_panelD.png, replace
		
			
	***************************************************************************************	
	*** Robustness: 	Changing time horizons											***
	***************************************************************************************
			
		*ETR_K time horizons
			foreach f in K { // L K {
			foreach t in 2 5 7 10 {
					reghdfe d`t'_ETR_`f'_prime d`t'_trade, abs(year)
						matrix m = r(table)
						local b : di %6.4f  m[1,1]
						local se : di %6.4f  m[2,1]
					#delimit ;
				binscatter d`t'_ETR_`f'_prime d`t'_trade
					,
					controls(year)
					reportreg
					nquantiles(20)
					text(.35 -.40 "  b: `b'" "se: (`se')" , size(medsmall) place(se) /*box*/ just(left) margin(l+2 t+1 b+1) width(12) fcolor(white))
					title("`t' years", ring(0) pos(12) size(small))
					ytitle("`t'-year {&Delta} {it:ETR{subscript:`f'}}", size(vsmall)) ylabel(0(.1).35,labsize(vsmall) notick format(%3.2fc))
					xtitle("`t'-year {&Delta} trade" ,size(vsmall)) xlabel(-.4(.2).7,labsize(vsmall) notick format(%3.2fc))
					/*note("Note: Linear trend lines; unweighted means, controlling for year FE."
						"		Changes are measured with respect to five years prior, expressed as a percentage of the starting value."
						"		Outliers are winsorized at the 5th and 95th percentiles."
						"		Binned scatterplot: each point represents 1/20th of all observations.", size(vsmall))
					*/	graphregion(color(white)) bgcolor(white) plotregion(color(white))
					name(ETR_`f'_`t'h, replace) ;
					#delimit cr
*pause					
			}
			}
graph close
	

	***************************************************************************************	
	*** Figure 6 in paper : ETRs by development level									***
	***************************************************************************************	
						
	*rich vs. developing, with graph titles					
		foreach r in 0 1 {
		foreach f in L K {			
		foreach t in 5 { 
				reghdfe d`t'_ETR_`f'_prime d`t'_trade if rich==`r', abs(year)
							matrix m = r(table)
							local b : di %6.3f  m[1,1]
							local se : di %6.3f  m[2,1]
				
				*** Locals used for the figure 
				local graph_region "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
				local ylabel	"ylabel(0(0.05)0.20, labsize(medsmall) notick format(%3.2fc)) yscale(range(-0.03 0.23)) yline(0(0.05)0.20, lstyle(minor_grid) lcolor(gs1))" 
				local xlabel	xlabel(-.4(.2).7,labsize(medsmall) notick format(%3.2fc))
				local colors_K 	"colors(midblue) lcolors(gs10)"
				local colors_L 	"colors(red) lcolors(gs10)"					
					
					#delimit ;
					binscatter d`t'_ETR_`f'_prime d`t'_trade if rich==`r' ,
						controls(year)
						reportreg
						nquantiles(20)
						text(.19 -.40 "  b: `b'" "se: (`se')" , size(medsmall) place(se) /*box*/ just(left) margin(l+2 t+1 b+1) width(12) fcolor(white))
						//title("ETR{sub:`f'}: High-Income Countries", ring(0) pos(12) size(small))
						`colors_`f''
						ytitle("`t'-year Change in ETR `f'", size(medsmall) margin(medsmall)) 
						xtitle("`t'-year Change in Trade" ,	size(medsmall) margin(medsmall))
						`ylabel'
						`xlabel'						
						`graph_region' 
						name(ETR_`f'_rich`r', replace) ;
						#delimit cr
			}
			}
			}
			
		***************************************************************************************	
		** Export these first 4 graphs to be saved as panels for the paper Figure 6 		 **
		***************************************************************************************

		graph display ETR_K_rich1
		graph export output/fig6_panelA.png, replace		
		
		graph display ETR_K_rich0
		graph export output/fig6_panelB.png, replace		
		
		graph display ETR_L_rich1
		graph export output/fig6_panelC.png, replace		
		
		graph display ETR_L_rich0
		graph export output/fig6_panelD.png, replace
		
		
		
	*large vs. small, with graph titles					
		foreach f in L K {			
		foreach t in 5 { 
				reghdfe d`t'_ETR_`f'_prime d`t'_trade if largepop==1, abs(year)
							matrix m = r(table)
							local b : di %6.4f  m[1,1]
							local se : di %6.4f  m[2,1]
						#delimit ;
					binscatter d`t'_ETR_`f'_prime d`t'_trade if largepop==1
						,
						controls(year)
						reportreg
						nquantiles(20)
						text(.35 -.40 "  b: `b'" "se: (`se')" , size(vsmall) place(se) /*box*/ just(left) margin(l+2 t+1 b+1) width(12) fcolor(white))
						title("ETR{sub:`f'}: Large Countries", ring(0) pos(12) size(small))
						ytitle("`t'-year {&Delta} {it:ETR{subscript:`f'}}", size(vsmall)) ylabel(0(.1).35,labsize(vsmall) notick format(%3.2fc))
						xtitle("`t'-year {&Delta} trade" ,size(vsmall)) xlabel(-.4(.2).7,labsize(vsmall) notick format(%3.2fc))
						graphregion(color(white)) bgcolor(white) plotregion(color(white))
							name(ETR_`f'_largepop1, replace)
						;
						#delimit cr
			}
			}
		foreach f in L K {			
		foreach t in 5 { 
				reghdfe d`t'_ETR_`f'_prime d`t'_trade if rich==0, abs(year)
							matrix m = r(table)
							local b : di %6.4f  m[1,1]
							local se : di %6.4f  m[2,1]
						#delimit ;
					binscatter d`t'_ETR_`f'_prime d`t'_trade if rich==0
						,
						controls(year)
						reportreg
						nquantiles(20)
						text(.35 -.40 "  b: `b'" "se: (`se')" , size(vsmall) place(se) /*box*/ just(left) margin(l+2 t+1 b+1) width(12) fcolor(white))
						title("ETR{sub:`f'}: Small Countries", ring(0) pos(12) size(small))
						ytitle("`t'-year {&Delta} {it:ETR{subscript:`f'}}", size(vsmall)) ylabel(0(.1).35,labsize(vsmall) notick format(%3.2fc))
						xtitle("`t'-year {&Delta} trade" ,size(vsmall)) xlabel(-.4(.2).7,labsize(vsmall) notick format(%3.2fc))
						graphregion(color(white)) bgcolor(white) plotregion(color(white))
							name(ETR_`f'_largepop0, replace)
						;
						#delimit cr
			}
			}	
graph close		
