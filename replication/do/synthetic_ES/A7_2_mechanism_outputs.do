

*** 5.2 Mechanism outputs


		* 5.2.1 Joint ES graphs
		{
			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"
			use cit_rate_winz, clear
			{
			local v cit_rate_winz
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
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat "`r(mean)'"

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
			local ytitle "ytitle("Coefficient on CIT rate", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.1(0.05)0.1, nogrid gmin gmax) yscale(range(-0.1 0.1)) yline(-0.1(0.05)0.1, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.075 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_set.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("CIT rate", margin(med) size(medlarge))"
			local yaxis "ylabel(.2(.05).5, nogrid gmin gmax) yscale(range(0.2 0.5)) yline(.2(.05).5, lstyle(minor_grid) lcolor(gs1))"
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
				
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_avg_set.eps", replace
			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"
			use selfemployed, clear
			{
			local v selfemployed
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
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat "`r(mean)'"

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
			local ytitle "ytitle("Coefficient on selfemployed", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.1(0.05)0.1, nogrid gmin gmax) yscale(range(-0.1 0.1)) yline(-0.1(0.05)0.1, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.075 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_set.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Selfemployed", margin(med) size(medlarge))"
			local yaxis "ylabel(.45(.05).65, nogrid gmin gmax) yscale(range(.45 .65)) yline(.45(.05).65, lstyle(minor_grid) lcolor(gs1))"
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
				
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_avg_set.eps", replace
			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"
			use os_corp, clear
			{
			local v os_corp
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
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat "`r(mean)'"

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
			local ytitle "ytitle("Coefficient on corp. profits", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.1(0.05)0.1, nogrid gmin gmax) yscale(range(-0.1 0.1)) yline(-0.1(0.05)0.1, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.075 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_set.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Corp. profits", margin(med) size(medlarge))"
			local yaxis "ylabel(.1(.05).3, nogrid gmin gmax) yscale(range(.1 .3)) yline(.1(.05).3, lstyle(minor_grid) lcolor(gs1))"
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
				
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_avg_set.eps", replace
			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"
			use os_hh, clear
			{
			local v os_hh
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
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat "`r(mean)'"

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
			local ytitle "ytitle("Coefficient on os_hh", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.1(0.05)0.1, nogrid gmin gmax) yscale(range(-0.1 0.1)) yline(-0.1(0.05)0.1, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.075 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_set.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("os_hh", margin(med) size(medlarge))"
			local yaxis "ylabel(0(.05).2, nogrid gmin gmax) yscale(range(.0 .2)) yline(.0(.05).2, lstyle(minor_grid) lcolor(gs1))"
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
				
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_avg_set.eps", replace
			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"
			use ce_hh, clear
			{
			local v ce_hh
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
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat "`r(mean)'"

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
			local ytitle "ytitle("Coefficient on ce_hh", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.1(0.05)0.1, nogrid gmin gmax) yscale(range(-0.1 0.1)) yline(-0.1(0.05)0.1, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.075 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_set.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("ce_hh", margin(med) size(medlarge))"
			local yaxis "ylabel(.3(.05).6, nogrid gmin gmax) yscale(range(.3 .6)) yline(.3(.05).6, lstyle(minor_grid) lcolor(gs1))"
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
				
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_avg_set.eps", replace
			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"
			use mi_hh, clear
			{
			local v mi_hh
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
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat "`r(mean)'"

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
			local ytitle "ytitle("Coefficient on mixed income", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.1(0.05)0.1, nogrid gmin gmax) yscale(range(-0.1 0.1)) yline(-0.1(0.05)0.1, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.075 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_set.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("Mixed income", margin(med) size(medlarge))"
			local yaxis "ylabel(.15(.05).35, nogrid gmin gmax) yscale(range(.15 .35)) yline(.15(.05).35, lstyle(minor_grid) lcolor(gs1))"
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
				
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_avg_set.eps", replace
			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"
			use industry_va, clear
			{	
			local v industry_va
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
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat "`r(mean)'"

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
			local ytitle "ytitle("Coefficient on industry_va", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.1(0.05)0.1, nogrid gmin gmax) yscale(range(-0.1 0.1)) yline(-0.1(0.05)0.1, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.075 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_set.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("industry_va", margin(med) size(medlarge))"
			local yaxis "ylabel(.25(.05).45, nogrid gmin gmax) yscale(range(.25 .45)) yline(.25(.05).45, lstyle(minor_grid) lcolor(gs1))"
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
				
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_avg_set.eps", replace
			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"
			use services_va, clear
			{
			local v services_va
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
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat "`r(mean)'"

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
			local ytitle "ytitle("Coefficient on services_va", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.1(0.05)0.1, nogrid gmin gmax) yscale(range(-0.1 0.1)) yline(-0.1(0.05)0.1, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.075 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_set.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("services_va", margin(med) size(medlarge))"
			local yaxis "ylabel(.35(.05).55, nogrid gmin gmax) yscale(range(.35 .55)) yline(.35(.05).55, lstyle(minor_grid) lcolor(gs1))"
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
				
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_avg_set.eps", replace
			}
			****

			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"
			use agric_va, clear
			{
			local v agric_va
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
			local p= round(`r(mean)',0.01)
			gen fstat2_`v'="`p'"
			replace fstat2_`v'=substr(fstat2_`v',1,5)
			gen pos=strpos(fstat2_`v',".")
			replace fstat2_`v'=subinstr(fstat2_`v',"0","",.) if pos==2
			destring fstat2_`v', replace
			sum fstat2_`v'
			local fstat "`r(mean)'"

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
			local ytitle "ytitle("Coefficient on agric_va", margin(med) size(medlarge))"
			local yaxis "ylabel(-0.1(0.05)0.1, nogrid gmin gmax) yscale(range(-0.1 0.1)) yline(-0.1(0.05)0.1, lstyle(minor_grid) lcolor(gs1)) yline(0) "
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
					text(.075 -5 "Joint significance of event dummies:" " `fstat'" "(`pval')", justification(left) size(2.8)) 
					`xtitle' 
					`ytitle'	
					`xaxis'
					`yaxis'
					graphregion(color(white)) legend(off) 
					; 
					
			#delim cr		
					
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_set.eps", replace

			keep in 1/21 //this drop the extra obs needed to draw the CIs created from the bootstrap
				
			local xtitle "xtitle("Years to/from Event", margin(med) size(medlarge))"
			local ytitle "ytitle("agric_va", margin(med) size(medlarge))"
			local yaxis "ylabel(.10(.05).25, nogrid gmin gmax) yscale(range(.1 .25)) yline(.1(.05).25, lstyle(minor_grid) lcolor(gs1))"
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
				
			cd "$outputs/es_graphs_additional_outcomes"
			graph export "`v'_avg_set.eps", replace
			}
			****

		}
		****

		* 5.2.2 Table
		{
			cd "$usedata/synthetic_ES_intermediat_data/additional_outcomes"

			use cit_rate_winz, clear
			merge 1:1 rel_year using selfemployed, nogen 
			merge 1:1 rel_year using os_corp, nogen 
			merge 1:1 rel_year using os_hh, nogen 
			merge 1:1 rel_year using ce_hh, nogen 
			merge 1:1 rel_year using mi_hh, nogen 
			merge 1:1 rel_year using industry_va, nogen 
			merge 1:1 rel_year using services_va, nogen 
			merge 1:1 rel_year using agric_va, nogen 


			cd "$outputs/tables"


			esttab pt_cit_rate_winz pt_selfemployed pt_os_corp pt_os_hh pt_ce_hh pt_mi_hh ///
					pt_industry_va pt_services_va ///
					pt_agric_va using synth_post_treat_additiona_vars.tex ///
					, se replace keep(post_treat) nonotes ///
					nocons nonumber nomtitles star(* 0.1 ** 0.05 *** 0.01)


			esttab imp_cit_rate_winz imp_selfemployed imp_os_corp imp_os_hh imp_ce_hh imp_mi_hh ///
					imp_industry_va imp_services_va ///
					imp_agric_va using synth_post_treat_additiona_vars.tex ///
					, se append keep(tau) ///
					nocons nonumber  nomtitles star(* 0.1 ** 0.05 *** 0.01)		
					
		}
		****
