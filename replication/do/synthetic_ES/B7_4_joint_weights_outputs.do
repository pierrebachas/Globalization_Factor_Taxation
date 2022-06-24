
* Outputs joint weights capital liberalization



		* 4.1 Joint ES graphs
		{
			cd "$usedata/synthetic_ES_intermediat_data/cap_lib_events_different_weights"
			use lg_open, clear
			{
			local v lg_open
			{
			* CIs based on estimates
			gen cilow3_`v'=est_es_`v'-2.16*se_es_`v'
			gen ciup3_`v'=est_es_`v'+2.16*se_es_`v'

			* Get estimates in local
			sum est_`v'
			local est1=round(`r(mean)',0.001)
			forvalues i=1/10 {
				sum est_es_`v' if rel_year==-`i'
				local pre`i'_1=round(`r(mean)',0.001)
				sum est_es_`v' if rel_year==`i'
				local post`i'_1=round(`r(mean)',0.001)
			}
			sum est_es_`v' if rel_year==0
			local zero_1=round(`r(mean)',0.001)
			}
			***

			sum est_`v'
			local est1=round(`r(mean)',0.001)
			sum est_pval_`v'
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local fstat= round(`r(mean)',0.01)
			gen fstat2_`v'="`fstat'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=`r(mean)'

			rename cilow4 ci4
			preserve
			drop ci4
			rename ciup4 ci4
			tempfile ciup
			save `ciup'
			restore
			append using `ciup'
			drop ciup4
			replace est_es_`v'=. in 22/42


			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on Log_open", margin(med) size(medlarge))"
			local yaxis "ylabel(-2(1)3, nogrid gmin gmax) yscale(range(-2 3)) yline(-2(1)3, lstyle(minor_grid) lcolor(gs1)) yline(0)"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 

			twoway 	rconnected ci4 ci4 rel_year if rel_year==-10, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==0, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==1, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==10, msymbol(i) color(dkgreen)  || 
					scatter est_es_`v' rel_year, lcolor(black) mcolor(dkgreen)  || , 
					text(2.5 -5.5 "Joint significance of event dummies:" "3.35" "(.001)", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_set5.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Log of openness (% of NDP)", margin(med) size(medlarge))"
			local yaxis "ylabel(3(2)11, nogrid gmin gmax) yscale(range(3 11)) yline(3(2)11, lstyle(minor_grid) lcolor(gs1))"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 	
				
				
			twoway 	scatter avg_`v'_t rel_year, connect(l) lpattern(dash) lcolor(gs12) color(green) || 
					scatter avg_`v'_nt rel_year, connect(l) lpattern(dash) lcolor(gs12) color(orange) ||,
					`xaxis' 
					`yaxis'
					`ytitle'
					`xtitle'
					legend(label(1 "Treated Countries") label(2 "Synthetic Control") ring(0) position(10) col(1)) 
					graphregion(color(white)) ; 
				
			#delim cr	

			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_avg_set5.eps", replace


			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/cap_lib_events_different_weights"
			use lg_eq, clear
			{
			local v lg_eq
			{
			* CIs based on estimates
			gen cilow3_`v'=est_es_`v'-2.16*se_es_`v'
			gen ciup3_`v'=est_es_`v'+2.16*se_es_`v'

			* Get estimates in local
			sum est_`v'
			local est1=round(`r(mean)',0.001)
			forvalues i=1/10 {
				sum est_es_`v' if rel_year==-`i'
				local pre`i'_1=round(`r(mean)',0.001)
				sum est_es_`v' if rel_year==`i'
				local post`i'_1=round(`r(mean)',0.001)
			}
			sum est_es_`v' if rel_year==0
			local zero_1=round(`r(mean)',0.001)
			}
			***

			sum est_`v'
			local est1=round(`r(mean)',0.001)
			sum est_pval_`v'
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local fstat= round(`r(mean)',0.01)
			gen fstat2_`v'="`fstat'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=`r(mean)'

			rename cilow4 ci4
			preserve
			drop ci4
			rename ciup4 ci4
			tempfile ciup
			save `ciup'
			restore
			append using `ciup'
			drop ciup4
			replace est_es_`v'=. in 22/42



			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on Log capital openness (% of NDP)", margin(med) size(medlarge))"
			local yaxis "ylabel(-.2(.2).8, nogrid gmin gmax) yscale(range(-.2 .8)) yline(-.2(.2).8, lstyle(minor_grid) lcolor(gs1)) yline(0)"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 

			twoway 	rconnected ci4 ci4 rel_year if rel_year==-10, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==0, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==1, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==10, msymbol(i) color(dkgreen)  || 
					scatter est_es_`v' rel_year, lcolor(black) mcolor(dkgreen)  || , 
					text(.7 -4.9 "Joint significance of year-since event dummies:" "`fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_set5.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Log of capital openness (% of NDP)", margin(med) size(medlarge))"
			local yaxis "ylabel(10(1)13, nogrid gmin gmax) yscale(range(10 13)) yline(10(1)13, lstyle(minor_grid) lcolor(gs1))"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 	
				
				
			twoway 	scatter avg_`v'_t rel_year, connect(l) lpattern(dash) lcolor(gs12) color(green) || 
					scatter avg_`v'_nt rel_year, connect(l) lpattern(dash) lcolor(gs12) color(orange) ||,
					`xaxis' 
					`yaxis'
					`ytitle'
					`xtitle'
					legend(label(1 "Treated Countries") label(2 "Synthetic Control") ring(0) position(10) col(1)) 
					graphregion(color(white)) ; 
				
			#delim cr	

			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_avg_set5.eps", replace

			}
			****
			cd "$usedata/synthetic_ES_intermediat_data/cap_lib_events_different_weights"
			use ETR_L_prime, clear
			{
			local v ETR_L_prime
			{
			* CIs based on estimates
			gen cilow3_`v'=est_es_`v'-2.16*se_es_`v'
			gen ciup3_`v'=est_es_`v'+2.16*se_es_`v'

			* Get estimates in local
			sum est_`v'
			local est1=round(`r(mean)',0.001)
			forvalues i=1/10 {
				sum est_es_`v' if rel_year==-`i'
				local pre`i'_1=round(`r(mean)',0.001)
				sum est_es_`v' if rel_year==`i'
				local post`i'_1=round(`r(mean)',0.001)
			}
			sum est_es_`v' if rel_year==0
			local zero_1=round(`r(mean)',0.001)
			}
			***

			sum est_ETR_L
			local est1=round(`r(mean)',0.001)
			sum est_pval_ETR_L
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local fstat= round(`r(mean)',0.01)
			gen fstat2_`v'="`fstat'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=`r(mean)'

			rename cilow4 ci4
			preserve
			drop ci4
			rename ciup4 ci4
			tempfile ciup
			save `ciup'
			restore
			append using `ciup'
			drop ciup4
			replace est_es_`v'=. in 22/42


			 
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on ETR_L", margin(med) size(medlarge))"
			local yaxis "ylabel(-.12(.04).12, nogrid gmin gmax) yscale(range(-.12 .12)) yline(-.12(.04).12, lstyle(minor_grid) lcolor(gs1)) yline(0)"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 

			twoway 	rconnected ci4 ci4 rel_year if rel_year==-10, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==0, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==1, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==10, msymbol(i) color(dkgreen)  || 
					scatter est_es_`v' rel_year, lcolor(black) mcolor(dkgreen)  || , 
					text(.10 -4.9 "Joint significance of year-since event dummies:" "`fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_set5.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Effective tax rate on labor (in %)", margin(med) size(medlarge))"
			local yaxis "ylabel(.08(.04).20, nogrid gmin gmax) yscale(range(.08 .20)) yline(.08(.04).20, lstyle(minor_grid) lcolor(gs1))"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 	
				
				
			twoway 	scatter avg_`v'_t rel_year, connect(l) lpattern(dash) lcolor(gs12) color(green) || 
					scatter avg_`v'_nt rel_year, connect(l) lpattern(dash) lcolor(gs12) color(orange) ||,
					`xaxis' 
					`yaxis'
					`ytitle'
					`xtitle'
					legend(label(1 "Treated Countries") label(2 "Synthetic Control") ring(0) position(10) col(1)) 
					graphregion(color(white)) ; 
				
			#delim cr	

			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_avg_set5.eps", replace

			}
			****
			cd "$usedata/synthetic_ES_intermediat_data/cap_lib_events_different_weights"
			use ETR_K_prime, clear
			{
			local v ETR_K_prime
			{
			* CIs based on estimates
			gen cilow3_`v'=est_es_`v'-2.16*se_es_`v'
			gen ciup3_`v'=est_es_`v'+2.16*se_es_`v'

			* Get estimates in local
			sum est_`v'
			local est1=round(`r(mean)',0.001)
			forvalues i=1/10 {
				sum est_es_`v' if rel_year==-`i'
				local pre`i'_1=round(`r(mean)',0.001)
				sum est_es_`v' if rel_year==`i'
				local post`i'_1=round(`r(mean)',0.001)
			}
			sum est_es_`v' if rel_year==0
			local zero_1=round(`r(mean)',0.001)
			}
			***

			sum est_ETR_K
			local est1=round(`r(mean)',0.001)
			sum est_pval_ETR_K
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local fstat= round(`r(mean)',0.01)
			dis `fstat'
			gen fstat2_`v'="`fstat'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=`r(mean)'

			rename cilow4 ci4
			preserve
			drop ci4
			rename ciup4 ci4
			tempfile ciup
			save `ciup'
			restore
			append using `ciup'
			drop ciup4
			replace est_es_`v'=. in 22/42

			 
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on ETR_K", margin(med) size(medlarge))"
			local yaxis "ylabel(-.12(.04).12, nogrid gmin gmax) yscale(range(-.12 .12)) yline(-.12(.04).12, lstyle(minor_grid) lcolor(gs1)) yline(0)"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 

			twoway 	rconnected ci4 ci4 rel_year if rel_year==-10, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==0, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==1, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==10, msymbol(i) color(dkgreen)  || 
					scatter est_es_`v' rel_year, lcolor(black) mcolor(dkgreen)  || , 
					text(.10 -4.9 "Joint significance of year-since event dummies:" "`fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_set5.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Effective tax rate on capital (in %)", margin(med) size(medlarge))"
			local yaxis "ylabel(.08(.04).20, nogrid gmin gmax) yscale(range(.08 .20)) yline(.08(.04).20, lstyle(minor_grid) lcolor(gs1))"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 	
				
				
			twoway 	scatter avg_`v'_t rel_year, connect(l) lpattern(dash) lcolor(gs12) color(green) || 
					scatter avg_`v'_nt rel_year, connect(l) lpattern(dash) lcolor(gs12) color(orange) ||,
					`xaxis' 
					`yaxis'
					`ytitle'
					`xtitle'
					legend(label(1 "Treated Countries") label(2 "Synthetic Control") ring(0) position(10) col(1)) 
					graphregion(color(white)) ; 
				
			#delim cr	

			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_avg_set5.eps", replace

			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/cap_lib_events_different_weights"
			use Ksh_ndp, clear
			{
			local v Ksh_ndp
			{
			* CIs based on estimates
			gen cilow3_`v'=est_es_`v'-2.16*se_es_`v'
			gen ciup3_`v'=est_es_`v'+2.16*se_es_`v'

			* Get estimates in local
			sum est_`v'
			local est1=round(`r(mean)',0.001)
			forvalues i=1/10 {
				sum est_es_`v' if rel_year==-`i'
				local pre`i'_1=round(`r(mean)',0.001)
				sum est_es_`v' if rel_year==`i'
				local post`i'_1=round(`r(mean)',0.001)
			}
			sum est_es_`v' if rel_year==0
			local zero_1=round(`r(mean)',0.001)
			}
			***

			sum est_Ksh_ndp
			local est1=round(`r(mean)',0.001)
			sum est_pval_Ksh_ndp
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local fstat= round(`r(mean)',0.01)
			gen fstat2_`v'="`fstat'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=`r(mean)'

			rename cilow4 ci4
			preserve
			drop ci4
			rename ciup4 ci4
			tempfile ciup
			save `ciup'
			restore
			append using `ciup'
			drop ciup4
			replace est_es_`v'=. in 22/42

			 
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on Ksh_ndp", margin(med) size(medlarge))"
			local yaxis "ylabel(-.08(.04).12, nogrid gmin gmax) yscale(range(-.08 .12)) yline(-.08(.04).12, lstyle(minor_grid) lcolor(gs1)) yline(0)"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 

			twoway 	rconnected ci4 ci4 rel_year if rel_year==-10, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==0, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==1, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==10, msymbol(i) color(dkgreen)  || 
					scatter est_es_`v' rel_year, lcolor(black) mcolor(dkgreen)  || , 
					text(.10 -4.9 "Joint significance of year-since event dummies:" "`fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_set5.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Capital share of national domestic product (in %)", margin(med) size(medlarge))"
			local yaxis "ylabel(.34(.02).42, nogrid gmin gmax) yscale(range(.34 .42)) yline(.34(.02).42, lstyle(minor_grid) lcolor(gs1))"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 	
				
				
			twoway 	scatter avg_`v'_t rel_year, connect(l) lpattern(dash) lcolor(gs12) color(green) || 
					scatter avg_`v'_nt rel_year, connect(l) lpattern(dash) lcolor(gs12) color(orange) ||,
					`xaxis' 
					`yaxis'
					`ytitle'
					`xtitle'
					legend(label(1 "Treated Countries") label(2 "Synthetic Control") ring(0) position(10) col(1)) 
					graphregion(color(white)) ; 
				
			#delim cr	

			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_avg_set5.eps", replace

			}
			****
			cd "$usedata/synthetic_ES_intermediat_data/cap_lib_events_different_weights"
			use Ksh_corp, clear
			{
			local v Ksh_corp
			{
			* CIs based on estimates
			gen cilow3_`v'=est_es_`v'-2.16*se_es_`v'
			gen ciup3_`v'=est_es_`v'+2.16*se_es_`v'

			* Get estimates in local
			sum est_`v'
			local est1=round(`r(mean)',0.001)
			forvalues i=1/10 {
				sum est_es_`v' if rel_year==-`i'
				local pre`i'_1=round(`r(mean)',0.001)
				sum est_es_`v' if rel_year==`i'
				local post`i'_1=round(`r(mean)',0.001)
			}
			sum est_es_`v' if rel_year==0
			local zero_1=round(`r(mean)',0.001)
			}
			***

			sum est_Ksh_corp
			local est1=round(`r(mean)',0.001)
			sum est_pval_Ksh_corp
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local fstat= round(`r(mean)',0.01)
			gen fstat2_`v'="`fstat'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=`r(mean)'

			rename cilow4 ci4
			preserve
			drop ci4
			rename ciup4 ci4
			tempfile ciup
			save `ciup'
			restore
			append using `ciup'
			drop ciup4
			replace est_es_`v'=. in 22/42


			 
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on Ksh_corp", margin(med) size(medlarge))"
			local yaxis "ylabel(-.08(.04).12, nogrid gmin gmax) yscale(range(-.08 .12)) yline(-.08(.04).12, lstyle(minor_grid) lcolor(gs1)) yline(0)"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 

			twoway 	rconnected ci4 ci4 rel_year if rel_year==-10, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==-2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==0, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==1, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==2, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==3, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==4, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==5, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==6, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==7, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==8, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==9, msymbol(i) color(dkgreen)  || 
					rconnected ci4 ci4 rel_year if rel_year==10, msymbol(i) color(dkgreen)  || 
					scatter est_es_`v' rel_year, lcolor(black) mcolor(dkgreen)  || , 
					text(.10 -4.9 "Joint significance of year-since event dummies:" "`fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_set5.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Capital share of corporate income (in %)", margin(med) size(medlarge))"
			local yaxis "ylabel(.26(.02).40, nogrid gmin gmax) yscale(range(.26 .40)) yline(.26(.02).40, lstyle(minor_grid) lcolor(gs1))"
			local xaxis "xline(-0.5) xlabel(-10(2)10)"	

			#delim ; 	
				
				
			twoway 	scatter avg_`v'_t rel_year, connect(l) lpattern(dash) lcolor(gs12) color(green) || 
					scatter avg_`v'_nt rel_year, connect(l) lpattern(dash) lcolor(gs12) color(orange) ||,
					`xaxis' 
					`yaxis'
					`ytitle'
					`xtitle'
					legend(label(1 "Treated Countries") label(2 "Synthetic Control") ring(0) position(10) col(1)) 
					graphregion(color(white)) ; 
				
			#delim cr	

			cd "$outputs/capital_lib_events_cross_weights/es_graphs"
			graph export "`v'_avg_set5.eps", replace


			}
			****
			}
		****

		* 4.2 Table 
		{
		cd "$usedata/synthetic_ES_intermediat_data/cap_lib_events_different_weights"
		use lg_open, clear
		merge 1:1 rel_year using lg_eq, nogen 
		merge 1:1 rel_year using ETR_L_prime, nogen 
		merge 1:1 rel_year using ETR_K_prime, nogen 
		merge 1:1 rel_year using Ksh_ndp, nogen 
		merge 1:1 rel_year using Ksh_corp, nogen 

		cd "$outputs/tables"


		esttab pt_lg_open pt_lg_eq pt_Ksh_ndp pt_Ksh_corp pt_ETR_K_prime pt_ETR_L_prime ///
				using synth_cap_lib_weights.tex ///
				, se replace keep(post_treat) nonotes ///
				nocons nonumber nomtitles star(* 0.1 ** 0.05 *** 0.01)


		esttab imp_lg_open imp_lg_eq imp_Ksh_ndp imp_Ksh_corp imp_ETR_K_prime imp_ETR_L_prime ///
				using synth_cap_lib_weights.tex ///
				, se append keep(tau) ///
				nocons nonumber  nomtitles star(* 0.1 ** 0.05 *** 0.01)
				
		}
		****
