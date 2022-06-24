

*** Outputs joint weights, trade liberalization events

		* 4.1 ES graphs 
		{
			cd "$usedata/synthetic_ES_intermediat_data/different_weights"
			use trade, clear
			{
			local v trade

			sum est_trade
			local est1=round(`r(mean)',0.001)
			sum est_pval_trade
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace force
			sum fstat2_`v'
			local fstat=string(fstat2_`v'[1], "%3.2f")

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
			local ytitle "ytitle("Coefficient on Trade", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.2(0.1)0.4, nogrid gmin gmax) yscale(range(-0.2 0.4)) yline(-0.2(0.1)0.4, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.35 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		

			cd "$outputs/cross_weights"
			graph export "`v'_weighKLshT.eps", replace
			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap


			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Trade (% of NDP)", margin(med) size(medlarge))"
			local yaxis "ylabel(.2(.1).6, nogrid gmin gmax) yscale(range(0.2 0.65)) yline(.2(.1).6, lstyle(minor_grid) lcolor(gs1))"
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

			cd "$outputs/cross_weights"
			graph export "`v'_avg_weighKLshT.eps", replace
			}
			****
			cd "$usedata/synthetic_ES_intermediat_data/different_weights"
			use ETR_L_prime, clear
			{
			local v ETR_L_prime

			sum est_`v'
			local est1=round(`r(mean)',0.001)
			sum est_pval_`v'
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=string(fstat2_`v'[1], "%3.2f")

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


			local xtitle "xtitle("Years to/from Event",  margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on ETR_L",  margin(med) size(medlarge))"
			local yaxis "ylabel(-0.08(0.04)0.12, nogrid gmin gmax) yscale(range(-0.08 0.12)) yline(-0.08(0.04)0.12, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.1 -5 "Joint significance of event dummies:" " `fstat'" "(0.001)", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr	


			cd "$outputs/cross_weights"
			graph export "`v'_weighKLshT.eps", replace
			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap

			local xtitle "xtitle("Years to/from Event",  margin(med) size(medlarge))"
			local ytitle "ytitle("Effective Tax Rate on Labor",  margin(med) size(medlarge))"
			local yaxis "ylabel(.04(.04).18, nogrid gmin gmax) yscale(range(0.04 0.18)) yline(.04(.04).18, lstyle(minor_grid) lcolor(gs1))"
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

			cd "$outputs/cross_weights"
			graph export "`v'_avg_weighKLshT.eps", replace
			}
			****
			cd "$usedata/synthetic_ES_intermediat_data/different_weights"
			use ETR_K_prime, clear
			{
			local v ETR_K_prime

			sum est_`v'
			local est1=round(`r(mean)',0.001)
			sum est_pval_`v'
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=string(fstat2_`v'[1], "%3.2f")


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


			local xtitle "xtitle("Years to/from Event",  margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on ETR_K",  margin(med) size(medlarge))"
			local yaxis "ylabel(-0.08(0.04)0.12, nogrid gmin gmax) yscale(range(-0.08 0.12)) yline(-0.08(0.04)0.12, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.1 -4.8 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) ; 
					
			#delim cr	

			cd "$outputs/cross_weights"
			graph export "`v'_weighKLshT.eps", replace
			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap


			local xtitle "xtitle("Years to/from Event",  margin(med) size(medlarge))"
			local ytitle "ytitle("Effective Tax Rate on Capital",  margin(med) size(medlarge))"
			local yaxis "ylabel(.04(.04).18, nogrid gmin gmax) yscale(range(0.04 0.18)) yline(.04(.04).18, lstyle(minor_grid) lcolor(gs1))"
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

			cd "$outputs/cross_weights"
			graph export "`v'_avg_weighKLshT.eps", replace
			}
			****
			cd "$usedata/synthetic_ES_intermediat_data/different_weights"
			use Ksh_ndp, clear
			{
			local v Ksh_ndp

			sum est_`v'
			local est1=round(`r(mean)',0.001)
			sum est_pval_`v'
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=string(fstat2_`v'[1], "%3.2f")

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

			local xtitle "xtitle("Years to/from Event",  margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on K-share",  margin(med) size(medlarge))"
			local yaxis "ylabel(-0.08(0.04)0.12, nogrid gmin gmax) yscale(range(-0.08 0.12)) yline(-0.08(0.04)0.12, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.1 -4.8 "Joint significance of event dummies:" " `fstat'" "(0.001)", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) ; 
					
			#delim cr	

			cd "$outputs/cross_weights"
			graph export "`v'_weighKLshT.eps", replace
			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap

			local xtitle "xtitle("Years to/from Event",  margin(med) size(medlarge))"
			local ytitle "ytitle("Capital Share",  margin(med) size(medlarge))"
			local yaxis "ylabel(.26(.04).40, nogrid gmin gmax) yscale(range(0.25 0.41)) yline(.26(.04).40, lstyle(minor_grid) lcolor(gs1))"
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

			cd "$outputs/cross_weights"
			graph export "`v'_avg_weighKLshT.eps", replace
			}
			****
			cd "$usedata/synthetic_ES_intermediat_data/different_weights"
			use Ksh_corp, clear
			{
			local v Ksh_corp

			sum est_Ksh_corp
			local est1=round(`r(mean)',0.001)
			sum est_pval_Ksh_corp
			local pval=round(`r(mean)',0.001)
			sum fstat_`v'
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat=string(fstat2_`v'[1], "%3.2f")

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

			local xtitle "xtitle("Years to/from Event",  margin(med) size(medlarge))"
			local ytitle "ytitle("Coefficient on K-Share Corporate",  margin(med) size(medlarge))"
			local yaxis "ylabel(-0.08(0.04)0.12, nogrid gmin gmax) yscale(range(-0.08 0.12)) yline(-0.08(0.04)0.12, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.1 -4.8 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) ; 
					
			#delim cr	


			cd "$outputs/cross_weights"
			graph export "`v'_weighKLshT.eps", replace
			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap

			local xtitle "xtitle("Years to/from Event", margin(medsmall))"
			local ytitle "ytitle("Capital Share of Corporate Sector", margin(medsmall))"
			local yaxis "ylabel(.26(.04).40, nogrid gmin gmax) yscale(range(0.25 0.41)) yline(.26(.04).40, lstyle(minor_grid) lcolor(gs1))"
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

			cd "$outputs/cross_weights"
			graph export "`v'_avg_weighKLshT.eps", replace
			}
			****

		}
		****

		* 4.2 Table 
		{
			cd "$usedata/synthetic_ES_intermediat_data/different_weights"
			use trade, clear
			merge 1:1 rel_year using ETR_L_prime, nogen 
			merge 1:1 rel_year using ETR_K_prime, nogen 
			merge 1:1 rel_year using Ksh_ndp, nogen 
			merge 1:1 rel_year using Ksh_corp, nogen 

			cd "$outputs/tables"

			esttab es_trade es_Ksh_ndp es_Ksh_corp es_ETR_K_prime es_ETR_L_prime ///
					using synth_post_treat_all.tex ///
					, se replace  ///
					keep(pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 zero ///
					post1 post2 post3 post4 post5 post6 post7 post8 post9 post10) ///
					scalar(ftest_stat ftest boots_se ///
					boots_se_pre10 boots_se_pre9 boots_se_pre8 boots_se_pre7 boots_se_pre6 ///
					boots_se_pre5 boots_se_pre4 boots_se_pre3 boots_se_pre2 boots_se_zero ///
					boots_se_post1 boots_se_post2 boots_se_post3 boots_se_post4 boots_se_post5 ///
					boots_se_post6 boots_se_post7 boots_se_post8 boots_se_post9 boots_se_post10) nonotes ///
					nocons nonumber star(* 0.1 ** 0.05 *** 0.01) 

			esttab pt_trade pt_Ksh_ndp pt_Ksh_corp pt_ETR_K_prime pt_ETR_L_prime ///
					using synth_post_treat_all.tex ///
					, se append keep(post_treat) nonotes ///
					nocons nonumber nomtitles star(* 0.1 ** 0.05 *** 0.01)


			esttab imp_trade imp_Ksh_ndp imp_Ksh_corp imp_ETR_K_prime imp_ETR_L_prime ///
					using synth_post_treat_all.tex ///
					, se append keep(tau) ///
					nocons nonumber  nomtitles star(* 0.1 ** 0.05 *** 0.01)
				
		}
		****
