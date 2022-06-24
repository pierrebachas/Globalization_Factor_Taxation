

*** 5.3 Robustness check outputs


		* 5.3.1 Joint ES graphs
		{
		cd "$usedata/synthetic_ES_intermediat_data/exclude_one"
		use trade, clear
		{
		local v trade
		twoway 	scatter est_es_`v'_1 rel_year, lcolor(gs14) msymbol(i) connect(l) || ///
				scatter est_es_`v'_2 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_3 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_4 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_5 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_6 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_7 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v' rel_year, lcolor(green) connect(l) mcolor(green)  ||, ///
				xline(-.5) xlabel(-10(2)10) xtitle("Years to/from Event") ytitle("Trade (% of NDP)") ///
				legend(off) graphregion(color(white)) ylabel(-.05(.05).15, gmin gmax)  yline(0, lcolor(black))
				
		cd "$outputs/robustness_check"
		graph export "`v'.eps", replace

		}
		****
		cd "$usedata/synthetic_ES_intermediat_data/exclude_one"
		use ETR_L_prime, clear
		{
		local v ETR_L_prime
		twoway 	scatter est_es_`v'_1 rel_year, lcolor(gs14) msymbol(i) connect(l) || ///
				scatter est_es_`v'_2 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_3 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_4 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_5 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_6 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_7 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v' rel_year, lcolor(green) connect(l) mcolor(green)  ||, ///
				xline(-.5) xlabel(-10(2)10) xtitle("Years to/from Event")  ///
				legend(off) graphregion(color(white)) yline(0, lcolor(black)) ///
				ylabel(-.01(.02).08, gmin gmax) ytitle("Effective Tax Rate on Labor") 
				
		cd "$outputs/robustness_check"
		graph export "`v'.eps", replace

		}
		****
		cd "$usedata/synthetic_ES_intermediat_data/exclude_one"
		use ETR_K_prime, clear
		{
		local v ETR_K_prime
		twoway 	scatter est_es_`v'_1 rel_year, lcolor(gs14) msymbol(i) connect(l) || ///
				scatter est_es_`v'_2 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_3 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_4 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_5 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_6 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_7 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v' rel_year, lcolor(green) connect(l) mcolor(green)  ||, ///
				xline(-.5) xlabel(-10(2)10) xtitle("Years to/from Event") ytitle("Effective Tax Rate on Capital") ///
				legend(off) graphregion(color(white)) ylabel(-.01(.02).08, gmin gmax) yline(0, lcolor(black))
				
		cd "$outputs/robustness_check"
		graph export "`v'.eps", replace
		}
		****
		cd "$usedata/synthetic_ES_intermediat_data/exclude_one"
		use Ksh_ndp, clear
		{
		local v Ksh_ndp
		twoway 	scatter est_es_`v'_1 rel_year, lcolor(gs14) msymbol(i) connect(l) || ///
				scatter est_es_`v'_2 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_3 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_4 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_5 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_6 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_7 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v' rel_year, lcolor(green) connect(l) mcolor(green)  ||, ///
				xline(-.5) xlabel(-10(2)10) xtitle("Years to/from Event") ytitle("Capital share of natonal domestic product") ///
				legend(off) graphregion(color(white)) ylabel(-.02(.02).06, gmin gmax) yline(0, lcolor(black))
				
		cd "$outputs/robustness_check"
		graph export "`v'.eps", replace
		}
		****
		cd "$usedata/synthetic_ES_intermediat_data/exclude_one"
		use Ksh_corp, clear
		{
		local v Ksh_corp
		twoway 	scatter est_es_`v'_1 rel_year, lcolor(gs14) msymbol(i) connect(l) || ///
				scatter est_es_`v'_2 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_3 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_4 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_5 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_6 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v'_7 rel_year, lcolor(gs14) msymbol(i)  connect(l) || ///
				scatter est_es_`v' rel_year, lcolor(green) connect(l) mcolor(green)  ||, ///
				xline(-.5) xlabel(-10(2)10) xtitle("Years to/from Event") ytitle("Capital share of corporate income") ///
				legend(off) graphregion(color(white)) ylabel(-.02(.02).06, gmin gmax) yline(0, lcolor(black))
				
		cd "$outputs/robustness_check"
		graph export "`v'.eps", replace
		}
		****



		}
		****


