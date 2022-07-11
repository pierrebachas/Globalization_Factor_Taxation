***************************************************************************************
*  	Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman								  
*  	program: analysis_2_ivreg.do		
* 	Task: Runs instrumental variable regressions (two instruments for trade)
***************************************************************************************
	***************************************************************************************		
	* Setup
	***************************************************************************************	
	set more off
	pause on
	
	use "data/master.dta", clear
		*use "data/master_$dateyear.dta", clear // use "data/master_15 Jun 2022.dta", clear 
		
	* Create sample restriction where all covariates exist (constant sample-size across regressions)
	gen insample=1 if xrate_wid!=. & iv_gravity!=. & trade_kopen!=. & iv_oildist!=. & gfcf!=. & ETR_K_prime!=.
	
********************************************************************************
****************************** Main Tables *************************************
********************************************************************************
	
	********************************** Table 1  ***********************************
		eststo clear

		eststo:			reghdfe Ksh_ndp trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe Ksh_ndp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_ndp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_ndp (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			reghdfe Ksh_corp trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe Ksh_corp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_corp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_corp (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			reghdfe ETR_L_prime trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		
		eststo:			reghdfe ETR_K_prime trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			reghdfe ETR_cit trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe ETR_cit (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_cit (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_cit (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
				
		*export
			esttab using output/T1_core.csv 									///
				, replace  keep(*trade*) ///
				star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
				noconstant nogaps depvar obslast scalars(rkf)
			
			eststo clear
			
	********************************************************************************


	********************************** Table 2 *************************************
		* Panel A: CIT rate
		eststo: reghdfe cit_change_winz trade  egger vv taxfdn if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo: ivreghdfe cit_change_winz (trade = iv_oildist iv_gravity) egger vv taxfdn if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo: ivreghdfe cit_change_winz (trade = iv_oildist iv_gravity) egger vv taxfdn if insample==1 [aw=1], abs(i.year i.cid) cluster(cid) ffirst
		eststo: ivreghdfe cit_change_winz (trade = iv_oildist iv_gravity) egger vv taxfdn xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		* Panel B: SE-share
		eststo:			reghdfe selfemployed trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe selfemployed (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe selfemployed (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe selfemployed (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst

		* Panel C: corp and non-corp shares of K and L
		eststo:			reghdfe os_corp trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe os_corp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe os_corp (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe os_corp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst

		eststo:			reghdfe ce_hh trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe ce_hh (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ce_hh (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ce_hh (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst

		eststo:			reghdfe mi_hh trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe mi_hh (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe mi_hh (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe mi_hh (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst

		eststo:			reghdfe os_hh trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe os_hh (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe os_hh (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe os_hh (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst

		eststo:			reghdfe va_corp trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			ivreghdfe va_corp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe va_corp (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe va_corp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		
		
		*export
			esttab using output/T2_mechanisms.csv 									///
				, replace  keep(*trade*) ///
				star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
				noconstant nogaps depvar obslast scalars(rkf)
			
			eststo clear
	********************************************************************************


	********************************** Table 3 *************************************
		eststo: ivreghdfe ETR_K_prime (trade trade_richalt = iv_oildist iv_gravity) if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'

		eststo: ivreghdfe ETR_L_prime (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
		
		eststo: ivreghdfe cit_change_winz (trade trade_richalt = iv_oildist iv_gravity) egger vv taxfdn [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'	
		
		eststo:	ivreghdfe Ksh_ndp (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'	

		eststo:	ivreghdfe selfemployed (trade trade_richalt = iv_oildist iv_gravity) if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'	
		
		eststo:	ivreghdfe os_corp (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'	
		
		eststo:	ivreghdfe va_corp (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'	
		
		*export
			esttab using output/T3_Heterogeneity_Dev.csv ///
				, replace  keep(*trade*) ///
				star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
				noconstant nogaps depvar obslast scalars(rkf lincom_coef lincom_se lincom_p)
				
			eststo clear
	********************************************************************************


	********************************** Table 4 *************************************
		* Small country versus large country
		eststo: ivreghdfe cit_change_winz (trade trade_smallpop = iv_oildist iv_gravity) egger vv taxfdn [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade + trade_smallpop
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'

		eststo:	ivreghdfe ETR_K_prime (trade trade_smallpop = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade + trade_smallpop
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
		
		eststo:	ivreghdfe ETR_L_prime (trade trade_smallpop = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade + trade_smallpop
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
		
		* Kopen vs Kclosed
		eststo: ivreghdfe cit_change_winz (trade trade_kopen = iv_oildist iv_gravity) egger vv taxfdn [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade + trade_kopen
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'

		eststo:	ivreghdfe ETR_K_prime (trade trade_kopen = iv_oildist iv_gravity) k_open imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade + trade_kopen
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
		
		eststo:	ivreghdfe ETR_L_prime (trade trade_kopen = iv_oildist iv_gravity) k_open imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		lincom trade + trade_kopen
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'

		*export
			esttab using output/T4_AdditionalHeterogeneity.csv 									///
				, replace  keep(*trade*) ///
				star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
				noconstant nogaps depvar obslast scalars(rkf lincom_coef lincom_se lincom_p)
			
			eststo clear
	********************************************************************************

	****************************** Table 5 *****************************************
	* K-related taxes
		eststo:		ivreghdfe pct_1200 (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) first
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
		eststo:		ivreghdfe pct_4000 (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) first
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
		eststo:		ivreghdfe Tau_K_prime (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) first
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
	* L-related taxes				
		eststo:		ivreghdfe pct_1100 (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) first
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
		eststo:		ivreghdfe pct_2000 (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) first
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
		eststo:		ivreghdfe Tau_L_prime (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) first
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'
	* Overall taxes
		eststo:		ivreghdfe taxKLC_pct (trade trade_richalt = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) first
		lincom trade+trade_richalt
		estadd scalar lincom_se = `r(se)'
		estadd scalar lincom_coef = `r(estimate)'
		estadd scalar lincom_p = `r(p)'

		esttab using output/T5_Taxgdpdevheterogeneity.csv 									///
			, replace  keep(*trade* *rade_richalt*) ///
			star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
			noconstant nogaps depvar obslast scalars(rkf lincom_coef lincom_se lincom_p)

		eststo clear	
	********************************************************************************

	
	
	
********************************************************************************
****************************** Appendix Tables *********************************
********************************************************************************

	************************** Appendix Table A3***********************************
			* create indices for each instrument to compare magnitudes across regressions
			egen mean_ivoil=mean(iv_oildist)
			egen sd_ivoil=sd(iv_oildist)
			gen ivoil_index=(iv_oildist-mean_ivoil)/sd_ivoil

			egen mean_ivgravity=mean(iv_gravity)
			egen sd_ivgravity=sd(iv_gravity)
			gen ivgravity_index=(iv_gravity-mean_ivgravity)/sd_ivgravity

		eststo: reghdfe trade ivgravity_index ivoil_index if insample==1, abs(i.year i.cid) cluster(cid)
		eststo:	reghdfe imports ivgravity_index ivoil_index if insample==1, abs(i.year i.cid) cluster(cid)
		eststo:	reghdfe exports ivgravity_index ivoil_index if insample==1, abs(i.year i.cid) cluster(cid)

		eststo:	reghdfe ETR_K_prime ivgravity_index ivoil_index if insample==1, abs(i.year i.cid) cluster(cid)
		eststo:	reghdfe ETR_L_prime ivgravity_index ivoil_index if insample==1, abs(i.year i.cid) cluster(cid)

		esttab using output/A3_reducedform.csv 									///
		, replace  keep(*ivgravity* *ivoil*) ///
		star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
		noconstant nogaps depvar obslast scalars(rkf lincom_coef lincom_se lincom_p)

		eststo clear	
	********************************************************************************
	

	************************** Appendix Table A4 ***********************************
					* Baseline
		eststo: 		ivreghdfe Ksh_ndp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_corp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

					* R1: winsorize trade variable at 95th percentile (b/c of outlier values)
		eststo: 		ivreghdfe Ksh_ndp (trade_winz = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_corp (trade_winz = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (trade_winz = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade_winz = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

					* R2: tradeshare-goods
		eststo:			ivreghdfe Ksh_ndp (goods_trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_corp (goods_trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (goods_trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (goods_trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

					* R3: log-level trade
		eststo:			ivreghdfe Ksh_ndp (log_trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_corp (log_trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (log_trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (log_trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		*export
		esttab using output/A4_tradevars.csv 									///
			, replace  keep(*trade*) ///
			star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
			noconstant nogaps depvar obslast scalars(rkf)

		eststo clear	
	********************************************************************************

	
	************************** Appendix Table A5 ***********************************
		* baseline without controls
		eststo:			ivreghdfe Ksh_ndp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_corp (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		* robustness with controls [xrate_wid gfcf log_pop lg_gdppc k_open]
		eststo:			ivreghdfe Ksh_ndp (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_corp (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		* robustness with time-varying controls + oil-rich*time FE
		eststo:			ivreghdfe Ksh_ndp (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year#i.oilrich i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe Ksh_corp (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year#i.oilrich i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year#i.oilrich i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year#i.oilrich i.cid) cluster(cid) ffirst
	
		*export
		esttab using output/A5_controls.csv 									///
			, replace  keep(*trade*) ///
			star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
			noconstant nogaps depvar obslast scalars(rkf)
			
		eststo clear
	********************************************************************************
	
	
	************************** Appendix Table A6 ***********************************
				* Mendoza 
		eststo:			reghdfe ETR_K_mendoza trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			reghdfe ETR_L_mendoza trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)

		eststo:			ivreghdfe ETR_K_mendoza (trade = iv_oildist iv_gravity) imputed interpolated if insample==1  [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_mendoza (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_mendoza (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_mendoza (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_mendoza (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_mendoza (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 , abs(i.year i.cid) cluster(cid) ffirst

				* Extreme K-L assignments
		eststo:			reghdfe ETR_K_0 trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			reghdfe ETR_L_0 trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)

		eststo:			ivreghdfe ETR_K_0 (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_0 (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_0 (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_0 (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_0 (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_0 (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		

		eststo:			reghdfe ETR_K_prime trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			reghdfe ETR_L_prime trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)

		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst

		
		
		eststo:			reghdfe ETR_K_30 trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo:			reghdfe ETR_L_30 trade imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid)

		eststo:			ivreghdfe ETR_K_30 (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_30 (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_30 (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_30 (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_30 (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_30 (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst

		
				* ILO factor shares

		eststo:			reghdfe ETR_K_ilo trade imputed interpolated if insample==1 [aw=wndpyear],  abs(i.year i.cid) cluster(cid)
		eststo:			reghdfe ETR_L_ilo trade imputed interpolated if insample==1  [aw=wndpyear], abs(i.year i.cid) cluster(cid)

		eststo:			ivreghdfe ETR_K_ilo (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_ilo (trade = iv_oildist iv_gravity) imputed interpolated if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_ilo (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1 [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_ilo (trade = iv_oildist iv_gravity) imputed interpolated xrate_wid gfcf log_pop lg_gdppc k_open if insample==1  [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_K_ilo (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_ilo (trade = iv_oildist iv_gravity) imputed interpolated if insample==1, abs(i.year i.cid) cluster(cid) ffirst

		
		*export
		esttab using output/A6_measures.csv 									///
			, replace  keep(*trade*) ///
			star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
			noconstant nogaps depvar obslast scalars(rkf)
			
		eststo clear				
	************************************************************************
	
	
	
	****************************** Appendix Table A7 ******************************
	*********************** Appendix Table: Individual IVs *************************
		** Panel A: Instruments together
		eststo:			ivreghdfe ETR_K_prime (trade = iv_gravity iv_oildist) imputed interpolated if insample==1 [aw=1], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_gravity iv_oildist) imputed interpolated if insample==1 [aw=1], abs(i.year i.cid) cluster(cid) ffirst


		
		* Panel B: Instruments separately
		* 1st stage
		replace iv_oildist = iv_oildist / 10^10 //for ease of interpretation			

		eststo:			reghdfe trade iv_gravity iv_oildist imputed interpolated if insample==1 /*[aw=1]*/, abs(i.year i.cid) cluster(cid)
		eststo:			reghdfe trade iv_gravity imputed interpolated if insample==1 /*[aw=1]*/, abs(i.year i.cid) cluster(cid)			
		eststo:			reghdfe trade iv_oildist imputed interpolated if insample==1 /*[aw=1]*/, abs(i.year i.cid) cluster(cid)

		* IVs
		eststo:			ivreghdfe ETR_K_prime (trade = iv_gravity) imputed interpolated if insample==1 [aw=1], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_K_prime (trade = iv_oildist) imputed interpolated if insample==1 [aw=1], abs(i.year i.cid) cluster(cid) ffirst

		eststo:			ivreghdfe ETR_L_prime (trade = iv_gravity) imputed interpolated if insample==1 [aw=1], abs(i.year i.cid) cluster(cid) ffirst
		eststo:			ivreghdfe ETR_L_prime (trade = iv_oildist) imputed interpolated if insample==1 [aw=1], abs(i.year i.cid) cluster(cid) ffirst

		replace iv_oildist = iv_oildist * 10^10 //revert

		*export
		esttab using output/A7_indivinstruments.csv 									///
			, replace  keep(*trade* *iv*) ///
			star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
			noconstant nogaps depvar obslast scalars(rkf)
			
		eststo clear
	********************************************************************************
	
	
	****************************** Appendix Table A8 ******************************
	*********** Appendix Table: Correlation between statutory and CIT collected ****

				eststo:		reghdfe ETR_K_prime cit_rate if insample==1, abs(i.year i.cid) cluster(cid) 
				eststo:		reghdfe ETR_K_prime cit_rate if insample==1 & richalt==1, abs(i.year i.cid) cluster(cid) 
				eststo:		reghdfe ETR_K_prime cit_rate if insample==1 & richalt==0, abs(i.year i.cid) cluster(cid) 
				
				eststo:		reghdfe pct_1200 cit_rate if insample==1, abs(i.year i.cid) cluster(cid) 
				eststo:		reghdfe pct_1200 cit_rate if insample==1 & richalt==1, abs(i.year i.cid) cluster(cid) 
				eststo:		reghdfe pct_1200 cit_rate if insample==1 & richalt==0, abs(i.year i.cid) cluster(cid) 
				
				*export
				esttab using output/A8_citstateffective.csv 									///
					, replace  keep(*cit_rate*) ///
					star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
					noconstant nogaps depvar obslast scalars(rkf)
				
				eststo clear
	********************************************************************************
			
			
	****************************** Appendix Table A9 ******************************
	****************** Appendix Table: Sectoral impacts ****************************

		replace industry_va=industry_va/100
		replace agric_va=agric_va/100
		replace services_va=services_va/100

		gen insamplev2=1 if services_va!=. & xrate_wid!=. & gfcf!=. & log_pop!=. & k_open!=.
		
		eststo: reghdfe agric_va trade if iv_gravity!=. & iv_oildist!=. & insamplev2!=. [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo: reghdfe industry_va trade if iv_gravity!=. & iv_oildist!=. & insamplev2!=. [aw=wndpyear], abs(i.year i.cid) cluster(cid)
		eststo: reghdfe services_va trade if iv_gravity!=. & iv_oildist!=. & insamplev2!=. [aw=wndpyear], abs(i.year i.cid) cluster(cid)

		eststo: ivreghdfe agric_va  (trade = iv_oildist iv_gravity) if insamplev2!=. [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo: ivreghdfe industry_va (trade = iv_oildist iv_gravity) if insamplev2!=. [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo: ivreghdfe services_va (trade = iv_oildist iv_gravity) if insamplev2!=. [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		
		eststo: ivreghdfe agric_va (trade = iv_oildist iv_gravity) if insamplev2!=. [aw=1], abs(i.year i.cid) cluster(cid) ffirst
		eststo: ivreghdfe industry_va (trade = iv_oildist iv_gravity) if insamplev2!=. [aw=1], abs(i.year i.cid) cluster(cid) ffirst
		eststo: ivreghdfe services_va (trade = iv_oildist iv_gravity) if insamplev2!=. [aw=1], abs(i.year i.cid) cluster(cid) ffirst

		eststo: ivreghdfe agric_va (trade = iv_oildist iv_gravity) xrate_wid gfcf log_pop k_open if insamplev2!=. [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo: ivreghdfe industry_va (trade = iv_oildist iv_gravity) xrate_wid gfcf log_pop k_open if insamplev2!=. [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst
		eststo: ivreghdfe services_va (trade = iv_oildist iv_gravity) xrate_wid gfcf log_pop k_open if insamplev2!=. [aw=wndpyear], abs(i.year i.cid) cluster(cid) ffirst


		*export
			esttab using output/A9_sectoral.csv 		 				///
				, replace  keep(*trade*) ///
				star(* 0.10 ** 0.05 *** 0.01) parentheses se r2 ///
				noconstant nogaps depvar obslast scalars(rkf)
				
			eststo clear
	********************************************************************************

	
********************************************************************************
****************************** Appendix Figures *********************************
********************************************************************************	
	
	****************************** Appendix Figure A8 ******************************
	********** Appendix Graph: Trends in CIT rates by development level ************
		gen cit_avg_highincome=.
		gen cit_avg_lowdmidincome=.

		xtset cid year
			tab year, gen(year_id)

		reghdfe cit_rate egger vv taxfdn year_id2 year_id3 year_id4 year_id5 year_id6 year_id7 year_id8 year_id9 year_id10 year_id11 year_id12 year_id13 year_id14 year_id15 year_id16 year_id17 year_id18 year_id19 year_id20 year_id21 year_id22 year_id23 year_id24 year_id25 year_id26 year_id27 year_id28 year_id29 year_id30 year_id31 year_id32 year_id33 year_id34 year_id35 year_id36 year_id37 year_id38 year_id39 year_id40 year_id41 year_id42 year_id43 year_id44 year_id45 year_id46 year_id47 year_id48 year_id49 year_id50 year_id51 year_id52 year_id53 year_id54 if year<=2018 & richalt==1 [aw=wndpyear], abs(i.cid)
		forval i =2(1)54{
		replace cit_avg_highincome=_b[_cons] + _b[year_id`i'] if year==1964+`i'
		}
		replace cit_avg_highincome=_b[_cons] if year==1965

		reghdfe cit_rate egger vv taxfdn year_id2 year_id3 year_id4 year_id5 year_id6 year_id7 year_id8 year_id9 year_id10 year_id11 year_id12 year_id13 year_id14 year_id15 year_id16 year_id17 year_id18 year_id19 year_id20 year_id21 year_id22 year_id23 year_id24 year_id25 year_id26 year_id27 year_id28 year_id29 year_id30 year_id31 year_id32 year_id33 year_id34 year_id35 year_id36 year_id37 year_id38 year_id39 year_id40 year_id41 year_id42 year_id43 year_id44 year_id45 year_id46 year_id47 year_id48 year_id49 year_id50 year_id51 year_id52 year_id53 year_id54 if year<=2018 & richalt==0 [aw=wndpyear], abs(i.cid)
		forval i =2(1)54{
		replace cit_avg_lowdmidincome=_b[_cons] + _b[year_id`i'] if year==1964+`i'
		}
		replace cit_avg_lowdmidincome=_b[_cons] if year==1965

		replace cit_avg_highincome=cit_avg_highincome*100
		replace cit_avg_lowdmidincome=cit_avg_lowdmidincome*100

		sort year
		twoway (connected cit_avg_highincome year if year<=2017 & year>=1966, lwidth(thick) lcolor(blue*1.5) msymbol(circle) mcolor(blue*1.5)) /// 
		(connected cit_avg_lowdmidincome year if year<=2017 & year>=1966, lwidth(thick) lcolor(blue*0.65) msymbol(X) mcolor(blue*0.)), ytitle("CIT rate (%)") ///
		xlabel(1965(10)2015) graphregion(color(white)) legend(rows(1)) legend(label(1 "High income countries") label(2 "Low and middle income countries")) ylabel(20(5)50)
		graph save "output/CITratestrend.gph", replace
		graph export "output/CITratestrend.png", replace

		* Sample size
		sum cit_rate if richalt==0 & year==2015
		sum cit_rate if richalt==1 & year==2015
		
			drop year_id*
	********************************************************************************
	
	
	
	****************************** Appendix Figure A9 ******************************
	************** Appendix Graph ETR by trade level in developing countries ************
			gen lowinc_pre95=1 if year<=1995
			gen lowinc_post95=1 if year>1995

			bysort cid: egen meanpre95trade=mean(trade) if lowinc_pre95==1
			bysort cid: egen counttradepre95=count(year) if trade!=. & lowinc_pre95==1
			bysort cid: egen countobspre95=mean(counttradepre95)

			bysort cid: egen meanpost95trade=mean(trade) if lowinc_post95==1
			bysort cid: egen counttradepost95=count(year) if trade!=. & lowinc_post95==1
			bysort cid: egen countobspost95=mean(counttradepost95)

		* Create distribution of trade-openness based on global trade levels pre and post-95
			xtile tradeopenv1=meanpre95trade if lowinc_pre95==1, nq(2)
			xtile tradeopenv2=meanpost95trade if lowinc_post95==1, nq(2)

			bysort cid: egen tradehighearly=max(tradeopenv1) if richalt==0
			bysort cid: egen tradehighlate=max(tradeopenv2) if richalt==0

			tab tradehighearly tradehighlate

		* Assign developing countries based on below/above global average in pre-1995 period
			gen trade_highearlylate=1 if tradehighearly==2
			replace trade_highearlylate=2 if tradehighearly==1

			xtset cid year

			tab year, gen(year_id)

			gen tradeagree1=1.4 if year>=1989 & year<=1995
			gen tradeagree2=0.25 if year>=1989 & year<=1995
			gen tradeagree3=0.4 if year>=1989 & year<=1995

			gen etrk_avg_highearly=.
			gen etrk_avg_lowearly=.

			reghdfe ETR_K_prime year_id2 year_id3 year_id4 year_id5 year_id6 year_id7 year_id8 year_id9 year_id10 year_id11 year_id12 year_id13 year_id14 year_id15 year_id16 year_id17 year_id18 year_id19 year_id20 year_id21 year_id22 year_id23 year_id24 year_id25 year_id26 year_id27 year_id28 year_id29 year_id30 year_id31 year_id32 year_id33 year_id34 year_id35 year_id36 year_id37 year_id38 year_id39 year_id40 year_id41 year_id42 year_id43 year_id44 year_id45 year_id46 year_id47 year_id48 year_id49 year_id50 year_id51 year_id52 year_id53 year_id54 if year<=2018 & trade_highearlylate==1 & richalt==0 & country!="COD", abs(i.cid)
			forval i =2(1)54{
			replace etrk_avg_highearly=_b[_cons] + _b[year_id`i'] if year==1964+`i'
			}
			replace etrk_avg_highearly=_b[_cons] if year==1965

			reghdfe ETR_K_prime year_id2 year_id3 year_id4 year_id5 year_id6 year_id7 year_id8 year_id9 year_id10 year_id11 year_id12 year_id13 year_id14 year_id15 year_id16 year_id17 year_id18 year_id19 year_id20 year_id21 year_id22 year_id23 year_id24 year_id25 year_id26 year_id27 year_id28 year_id29 year_id30 year_id31 year_id32 year_id33 year_id34 year_id35 year_id36 year_id37 year_id38 year_id39 year_id40 year_id41 year_id42 year_id43 year_id44 year_id45 year_id46 year_id47 year_id48 year_id49 year_id50 year_id51 year_id52 year_id53 year_id54 if year<=2018 & trade_highearlylate==2 & richalt==0 & country!="COD", abs(i.cid)
			forval i =2(1)54{
			replace etrk_avg_lowearly=_b[_cons] + _b[year_id`i'] if year==1964+`i'
			}
			replace etrk_avg_lowearly=_b[_cons] if year==1965

			sort year
			twoway (area tradeagree2 year, color(gs14)) (line etrk_avg_highearly year if trade_highearlylate==1 & year<=2018, lwidth(thick) lcolor(green)) (line etrk_avg_lowearly year if trade_highearlylate==2 & year<=2018, lwidth(thick) lcolor(orange)), ytitle("Effective Tax Rate on Capital (%)") ylabel(0.05(0.05)0.25) xlabel(1965(10)2015) graphregion(color(white)) legend(col(1)) legend(label(2 "High Trade Openness pre-1995") label(3 "Low Trade Openness pre-1995")) title("Effective Tax Rate on Capital", size(medsmall))  xtitle("")
			graph save "output/g1.gph", replace

			gen etrl_avg_highearly=.
			gen etrl_avg_lowearly=.

			reghdfe ETR_L_prime year_id2 year_id3 year_id4 year_id5 year_id6 year_id7 year_id8 year_id9 year_id10 year_id11 year_id12 year_id13 year_id14 year_id15 year_id16 year_id17 year_id18 year_id19 year_id20 year_id21 year_id22 year_id23 year_id24 year_id25 year_id26 year_id27 year_id28 year_id29 year_id30 year_id31 year_id32 year_id33 year_id34 year_id35 year_id36 year_id37 year_id38 year_id39 year_id40 year_id41 year_id42 year_id43 year_id44 year_id45 year_id46 year_id47 year_id48 year_id49 year_id50 year_id51 year_id52 year_id53 year_id54 if year<=2018 & trade_highearlylate==1 & richalt==0 & country!="COD", abs(i.cid)
			forval i =2(1)54{
			replace etrl_avg_highearly=_b[_cons] + _b[year_id`i'] if year==1964+`i'
			}
			replace etrl_avg_highearly=_b[_cons] if year==1965

			reghdfe ETR_L_prime year_id2 year_id3 year_id4 year_id5 year_id6 year_id7 year_id8 year_id9 year_id10 year_id11 year_id12 year_id13 year_id14 year_id15 year_id16 year_id17 year_id18 year_id19 year_id20 year_id21 year_id22 year_id23 year_id24 year_id25 year_id26 year_id27 year_id28 year_id29 year_id30 year_id31 year_id32 year_id33 year_id34 year_id35 year_id36 year_id37 year_id38 year_id39 year_id40 year_id41 year_id42 year_id43 year_id44 year_id45 year_id46 year_id47 year_id48 year_id49 year_id50 year_id51 year_id52 year_id53 year_id54 if year<=2018 & trade_highearlylate==2 & richalt==0 & country!="COD", abs(i.cid)
			forval i =2(1)54{
			replace etrl_avg_lowearly=_b[_cons] + _b[year_id`i'] if year==1964+`i'
			}
			replace etrl_avg_lowearly=_b[_cons] if year==1965

			sort year
			twoway (area tradeagree2 year, color(gs14)) (line etrl_avg_highearly year if trade_highearlylate==1 & year<=2018, lwidth(thick) lcolor(green)) (line etrl_avg_lowearly year if trade_highearlylate==2 & year<=2018, lwidth(thick) lcolor(orange)), ytitle("Effective Tax Rate on Labor (%)") ylabel(0.05(0.05)0.25) xlabel(1965(10)2015) graphregion(color(white)) legend(col(1)) legend(label(2 "High Trade Openness pre-1995") label(3 "Low Trade Openness pre-1995")) title("Effective Tax Rate on Labor", size(medsmall))   xtitle("")
			graph save "output/g2.gph", replace

			gen trade_avg_highearly=.
			gen trade_avg_lowearly=.

			reghdfe trade year_id2 year_id3 year_id4 year_id5 year_id6 year_id7 year_id8 year_id9 year_id10 year_id11 year_id12 year_id13 year_id14 year_id15 year_id16 year_id17 year_id18 year_id19 year_id20 year_id21 year_id22 year_id23 year_id24 year_id25 year_id26 year_id27 year_id28 year_id29 year_id30 year_id31 year_id32 year_id33 year_id34 year_id35 year_id36 year_id37 year_id38 year_id39 year_id40 year_id41 year_id42 year_id43 year_id44 year_id45 year_id46 year_id47 year_id48 year_id49 year_id50 year_id51 year_id52 year_id53 year_id54 if year<=2018 & trade_highearlylate==1 & richalt==0 & country!="COD", abs(i.cid)
			forval i =2(1)54{
			replace trade_avg_highearly=_b[_cons] + _b[year_id`i'] if year==1964+`i'
			}
			replace trade_avg_highearly=_b[_cons] if year==1965

			reghdfe trade year_id2 year_id3 year_id4 year_id5 year_id6 year_id7 year_id8 year_id9 year_id10 year_id11 year_id12 year_id13 year_id14 year_id15 year_id16 year_id17 year_id18 year_id19 year_id20 year_id21 year_id22 year_id23 year_id24 year_id25 year_id26 year_id27 year_id28 year_id29 year_id30 year_id31 year_id32 year_id33 year_id34 year_id35 year_id36 year_id37 year_id38 year_id39 year_id40 year_id41 year_id42 year_id43 year_id44 year_id45 year_id46 year_id47 year_id48 year_id49 year_id50 year_id51 year_id52 year_id53 year_id54 if year<=2018 & trade_highearlylate==2 & richalt==0 & country!="COD", abs(i.cid)
			forval i =2(1)54{
			replace trade_avg_lowearly=_b[_cons] + _b[year_id`i'] if year==1964+`i'
			}
			replace trade_avg_lowearly=_b[_cons] if year==1965

			sort year

			sort year
			twoway (area tradeagree1 year, color(gs14)) (line trade_avg_highearly year if trade_highearlylate==1 & year<=2017, lwidth(thick) lcolor(green)) (line trade_avg_lowearly year if trade_highearlylate==2 & year<=2017, lwidth(thick) lcolor(orange)), ytitle("Imports + Exports, share of NDP (%)") ylabel(0.2(0.2)1.4) xlabel(1965(10)2015) graphregion(color(white)) legend(col(1)) legend(order(2 3)) legend(label(2 "High Trade Openness pre-1995") label(3 "Low Trade Openness pre-1995")) title("Trade Openness", size(medsmall)) xtitle("")
			graph save "output/g3.gph", replace

		* Graph combine the three panels
			grc1leg "output/g3.gph" "output/g1.gph" "output/g2.gph", legendfrom("output/g3.gph") ring(0) pos(4) graphregion(color(white)) plotregion(color(white))
			gr_edit legend.xoffset = 2
			gr_edit legend.yoffset = 15
			graph export "output/ETRtrendtradelevel.png", replace

	********************************************************************************
	
	
	
	****************************** Appendix Figure A12 ******************************
	*************** 1st stage instrument strength across samples ******************	
		xtile ivpctile=lg_ndppc, nq(10)
			bysort ivpctile: egen mean_pctile=mean(lg_ndppc)
			gen toil=.
			gen tgravity=.

			xtset cid year

			forval i = 2(1)9{
			disp `i'
			reghdfe trade iv_oildist if ivpctile>=`i'-2 & ivpctile<=`i'+2 & insample==1,  abs(i.year i.cid) cluster(cid)
			replace toil=(_b[iv_oildist]/_se[iv_oildist])^2 if ivpctile==`i'
			}
			forval i = 2(1)9{
			reghdfe trade iv_gravity if ivpctile>=`i'-2 & ivpctile<=`i'+2 & insample==1, abs(i.year i.cid) cluster(cid)
			replace tgravity=(_b[iv_gravity]/_se[iv_gravity])^2 if ivpctile==`i'
			}
			sort ivpctile
			twoway (connected toil mean_pctile if mean_pctile>=7, mcolor(orange) lpattern(shortdash) lcolor(lightgrey)) ///
			(connected tgravity mean_pctile if mean_pctile>=7, mcolor(green) lpattern(shortdash) lcolor(lightgrey)), ///
			graphregion(color(white)) xtitle("Log NDP per capita") ytitle("1st Stage F-Statistic") xlabel(7.25(0.25)10.5) legend(label(1 "Oil price-distance instrument") label(2 "Gravity instrument")) ylabel(0(5)40)
		graph save "output/IVsubsamplegdp.gph", replace
		graph export "output/IVsubsamplegdp.png", replace

			drop toil tgravity mean_pctile ivpctile

			gen toil=.
			gen tgravity=.

			xtile ivpctile=year, nq(10)
			bysort ivpctile: egen mean_pctile=mean(year)

			forval i = 2(1)9{
			disp `i'
			reghdfe trade iv_oildist if ivpctile>=`i'-2 & ivpctile<=`i'+2, abs(i.year i.cid) cluster(cid)
			replace toil=(_b[iv_oildist]/_se[iv_oildist])^2 if ivpctile==`i'
			}
			forval i = 2(1)9{
			reghdfe trade iv_gravity if ivpctile>=`i'-2 & ivpctile<=`i'+2, abs(i.year i.cid) cluster(cid)
			replace tgravity=(_b[iv_gravity]/_se[iv_gravity])^2 if ivpctile==`i'
			}
			sort ivpctile
			twoway (connected toil mean_pctile if mean_pctile>=1975 & mean_pctile<=2015, mcolor(orange) lpattern(shortdash) lcolor(lightgrey)) ///
			(connected tgravity mean_pctile if mean_pctile>=1975 & mean_pctile<=2015, mcolor(green) lpattern(shortdash) lcolor(lightgrey)),  ///
			graphregion(color(white)) xtitle("Year") ytitle("1st Stage F-Statistic") xlabel(1975(10)2015) legend(label(1 "Oil price-distance instrument") label(2 "Gravity instrument")) ylabel(0(5)40)
			
		graph save "output/IVsubsampleyear.gph", replace
		graph export "output/IVsubsampleyear.png", replace
		
				drop toil tgravity mean_pctile ivpctile
	********************************************************************************
	
	
	
	
	************** Exercise to quantify trade impact on ETR-K in dev countries **********

	/* Here we estimate the increase in trade in developing countries in the past 25 years, to quantify what share of the ETR_K evolution can be assumed to be trade related. 
		Given that trade data can be noisy year to year, we take an average of trade values 1985-1994 versus an average 2010-2018 to show the increase in past 25 years 
	*/ 
				
		gen decade = .
		replace  decade =  1 if year >= 1985 & year <= 1994
		replace  decade = 2 if year >= 2010 & year <= 2018
		
	** Gen trade_decade1 and trade_decade2 which correspond to each of the periods we want to compare 
		
		forvalues i = 1(1)2 { 
			bysort country decade: egen mean_trade = mean(trade) if decade == `i'
			bysort country: egen trade_decade`i' = max(mean_trade)
			drop mean_trade
		}
		
			sum trade_decade1 trade_decade2 if richalt == 0 & year == 2018
			sum trade_decade1 trade_decade2 [aw=wndpyear] if richalt == 0 & year == 2018		
			
			list country if trade_decade1 == . & trade_decade2 != . & richalt == 0 & year == 2018	
			total wndpyear if trade_decade1 == . & trade_decade2 != . & richalt == 0 & year == 2018	 // Only 1% of world GDP is missing 
			
			sum trade_decade1 trade_decade2 if richalt == 0 & year == 2018  & trade_decade1!= . & 	trade_decade2!= .			// Unweighted means 
			sum trade_decade1 trade_decade2 [aw=wndpyear] if richalt == 0 & year == 2018 & trade_decade1!= . & 	trade_decade2!=. // weighted means 
			
		// --> There has been an aprox 17% increase in international trade in the past three decades, the weighted and unweighted means are similar.
		
	********************************************************************************
	
	
	


	
