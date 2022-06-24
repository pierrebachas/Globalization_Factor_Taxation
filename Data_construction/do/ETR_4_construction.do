***************************************************************************************
*  Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman - December 2020								  
*  	program: ETR_4_construction.do			
* 	Task: Construct ETRs								  
***************************************************************************************

	clear all 
	set more off

	* Load data 
	use data/misc/merged, clear
	
	**************************************************************************************	
	* 1.	Tax incidence assumptions (alphas) on taxes --> share of PIT attributed to Labor
	**************************************************************************************
		global alpha_1100 = 0.85 			//share on labor within PIT, assume 15% is capital income in one component of the benchmark below (refer to Methodology section of the paper)
			//NB: the variable alpha_pit below refers to incidence on K, so it is inverse (e.g., alpha_pit = .15 [instead of .85] assumes 15% of PIT revenue is from capital income)
		global alpha_1300 = 0.50 			//share on labor of unknown income taxes
			*global alpha_indirect = 		//share on labor of 5000 ie indirect taxes = proportional to f.share ; or excluded from analysis (like pct_6000 and nontax revenue)
			*global alpha_other =	 		//share on labor of unknown "other" taxes ; excluded from analysis
			*global alpha_nontax = 		 	//share on labor of other "nontax" revenues	
	
		*We assume that 'unallocable' income tax (data sources do not confirm whether PIT or CIT) are 50% PIT, 50% CIT
			replace pct_1100 = pct_1100 + 0.5*pct_1300 if pct_1300!=. & pct_1100!=.
				replace pct_1100 = 0.5*pct_1300 if pct_1300!=. & pct_1100==.
			replace pct_1200 = pct_1200 + 0.5*pct_1300 if pct_1300!=. & pct_1200!=.	
				replace pct_1200 = 0.5*pct_1300 if pct_1300!=. & pct_1200==.	
			replace pct_1300 = . if pct_1300!=.	
	
	*allocate taxes on labor vs. capital
		*assign direct taxes to factors
			gen Tau_L = 0 if pct_tax!=.
		replace Tau_L = Tau_L + $alpha_1100 * pct_1100 if pct_1100 !=. 			//note that PIT includes capital gains, see global above
		replace Tau_L = Tau_L + $alpha_1300 * pct_1300 if pct_1300 != .
		replace Tau_L = Tau_L + pct_2000 if pct_2000 != . 						//all of social security and payroll tax is on L	
		
			gen Tau_K = 0 if pct_tax!=.
		replace Tau_K = Tau_K + (1 - $alpha_1100 ) * pct_1100 if pct_1100 !=. 	//PIT includes capital gains, see global above
		replace Tau_K = Tau_K + pct_1200 if pct_1200 != . 						//all of CIT is on K
		replace Tau_K = Tau_K + (1 - $alpha_1300 ) * pct_1300 if pct_1300 != .
		replace Tau_K = Tau_K + pct_4000 if pct_4000 != . 						//all of property tax is on K
			
		*Here we program a robustness check variable for 'extreme' tax incidence assumptions (where PIT is either 0% or 30% capital income)
				gen Tau_L_0 = Tau_L
			replace Tau_L_0 = Tau_L + ( 1 - $alpha_1100 ) * pct_1100 if pct_1100 !=. //add back the 15 percent of PIT assumed on K above
			gen Tau_L_30 = Tau_L
			replace Tau_L_30 = Tau_L - ( 1 - $alpha_1100 ) * pct_1100 if pct_1100 !=. //subtract another 15 percent of PIT assumed on K above
			
				gen Tau_K_0 = Tau_K
			replace Tau_K_0 = Tau_K- ( 1 - $alpha_1100 ) * pct_1100 if pct_1100 !=. //subtract the 15 percent of PIT assumed on K above
				gen Tau_K_30 = Tau_K
			replace Tau_K_30 = Tau_K + ( 1 - $alpha_1100 ) * pct_1100 if pct_1100 !=. //add another 15 percent of PIT assumed on K above
					
		*Here we estimate how alpha varies based on the PIT exemption threshold (Jensen 2019)
				gen Tau_L_alpha = 0 if pct_tax!=.
			replace Tau_L_alpha = Tau_L_alpha + (1 - alpha_pit) * pct_1100 if pct_1100 !=. 		//note that PIT includes capital gains -- varies by country-year according to pit_thr
			replace Tau_L_alpha = Tau_L_alpha + $alpha_1300 * pct_1300 if pct_1300 != .
			replace Tau_L_alpha = Tau_L_alpha + pct_2000 if pct_2000 != . 						// all of social security and payroll tax is on L	
			
				gen Tau_K_alpha = 0 if pct_tax!=.
			replace Tau_K_alpha = Tau_K_alpha + alpha_pit * pct_1100 if pct_1100 !=. 			//PIT includes capital gains -- varies by country-year according to pit_thr
			replace Tau_K_alpha = Tau_K_alpha + pct_1200 if pct_1200 != . 						//all of CIT is on K
			replace Tau_K_alpha = Tau_K_alpha + (1 - $alpha_1300 ) * pct_1300 if pct_1300 != .
			replace Tau_K_alpha = Tau_K_alpha + pct_4000 if pct_4000 != . 						//all of property tax is on K
			
		*To this we add a further nuance (see Methodology section): we estimate ETRs with div_pit_oecd ratio, in 37 countries with current or historical OECD data on statutory rates of dividend taxation			
			*alpha varies based on this OECD ratio in these countries
			*alpha if dual PIT system (one rates on salaries etc, another rate on dividends/capital gains) 
					gen alpha_dual = 1 - $alpha_1100 
				replace alpha_dual = (alpha_dual*.5)*(1 + div_pit_oecd) if div_pit_oecd!=.
					format %9.2fc alpha_dual
					label var alpha_dual "share of PIT from capital income (noting dual income taxation systems in OECD data)"
					order alpha_dual div_pit_oecd div_pit_extrapolated, after(alpha_pit)
				gen Tau_L_dual = 0 if pct_tax!=.
				
			replace Tau_L_dual = Tau_L_dual + (1 - alpha_dual) * pct_1100 if pct_1100 !=. 			//note that PIT includes capital gains -- varies by country-year according to OECD data
			replace Tau_L_dual = Tau_L_dual + $alpha_1300 * pct_1300 if pct_1300 != .
			replace Tau_L_dual = Tau_L_dual + pct_2000 if pct_2000 != . 						// all of social security and payroll tax is on L	
			
				gen Tau_K_dual = 0 if pct_tax!=.
			replace Tau_K_dual = Tau_K_dual + alpha_dual * pct_1100 if pct_1100 !=. 	//PIT includes capital gains -- varies by country-year according to OECD data
			replace Tau_K_dual = Tau_K_dual + pct_1200 if pct_1200 != . 					//all of CIT is on K
			replace Tau_K_dual = Tau_K_dual + (1 - $alpha_1300 ) * pct_1300 if pct_1300 != .
			replace Tau_K_dual = Tau_K_dual + pct_4000 if pct_4000 != . 						//all of property tax is on K
			

		*put those two pieces together to estimate our benchmark ETRs, with both the threshold adjustment (a la Jensen 2019) and the dual PIT system adjustment (from OECD data on statutory dividend rates)
					gen alpha_prime = alpha_pit 
				replace alpha_prime = (alpha_prime*.5)*(1 + div_pit_oecd) if div_pit_oecd!=.
					format %9.2fc alpha_prime
					label var alpha_prime "share of PIT from K: PIT thresholds & dual PIT systems (Jensen 2021 & OECD data)"
					order alpha_prime, after(alpha_pit)
					
				gen Tau_L_prime = 0 if pct_tax!=.
			replace Tau_L_prime = Tau_L_prime + (1 - alpha_prime) * pct_1100 if pct_1100 !=. 			//note that PIT includes capital gains -- varies by country-year according to pit_thr & OECD data
			replace Tau_L_prime = Tau_L_prime + $alpha_1300 * pct_1300 if pct_1300 != .
			replace Tau_L_prime = Tau_L_prime + pct_2000 if pct_2000 != . 						// all of social security and payroll tax is on L	
			
				gen Tau_K_prime = 0 if pct_tax!=.
			replace Tau_K_prime = Tau_K_prime + alpha_prime * pct_1100 if pct_1100 !=. 	//PIT includes capital gains -- varies by country-year according to pit_thr & OECD data
			replace Tau_K_prime = Tau_K_prime + pct_1200 if pct_1200 != . 					//all of CIT is on K
			replace Tau_K_prime = Tau_K_prime + (1 - $alpha_1300 ) * pct_1300 if pct_1300 != .
			replace Tau_K_prime = Tau_K_prime + pct_4000 if pct_4000 != . 						//all of property tax is on K
			

		*for robustness: include indirect taxes	proportional to factor share												
			foreach f in L K {	
				gen Tau_`f'_indirect = Tau_`f'_prime 
			replace Tau_`f'_indirect = Tau_`f'_indirect + (`f'sh_ndp * pct_5000) if pct_5000!=. & `f'sh_ndp!=.
			replace Tau_`f'_indirect = Tau_`f'_indirect + (`f'sh_ndp * pct_6000) if pct_6000!=. & `f'sh_ndp!=.
			}	
			
			
						
		*adjustment to all of the above: taxes as percent of factor-price NDP (f-p NDP) rather than as a percent of total NDP
			*Note: we are only looking at direct taxes as the numerator of ETR (excluding indirect taxes, except where otherwise indicated)
				*factor income shares, as the denominator of ETRs, are also measures on same f-p NDP denominator
			foreach x in L K L_0 K_0 L_30 K_30 L_alpha K_alpha L_dual K_dual L_prime K_prime {
				replace Tau_`x' = Tau_`x' / (1 - nit)
			}
	
	**************************************************************************************	
	* 2. Calculate Effective Tax Rates
	**************************************************************************************		

	*effective tax rates on labor vs. capital
		*our first specification takes ETRs as a percent of NNI (see below for NDP)
		*divide T / Y for each of L and K, for ETRs
			foreach x in L L_0 L_30 L_alpha L_dual	L_prime L_indirect {
				gen ETR_`x' = ( Tau_`x' * ndp ) / Lsh_nni
			}
			foreach x in K K_0 K_30	K_alpha K_dual K_prime K_indirect {
				gen ETR_`x' = ( Tau_`x' * ndp ) / Ksh_nni
			}
			
		*effective tax rate on corporate profits (sans and with KG within PIT): ETR_cit and ETR_cit_kg
			gen ETR_cit  = 0 if pct_tax!=.
				replace ETR_cit = ETR_cit + pct_1200 if pct_1200!=.
				replace ETR_cit = ETR_cit + 0.5*pct_1300 if pct_1300!=.
				replace ETR_cit = ETR_cit  / (os_corp ) 						//do not include nfi_K (eg for Ireland that would be strange: the tax base includes foreign firms' profits)
			clonevar ETR_cit_kg = ETR_cit  
				replace ETR_cit_kg = ETR_cit_kg + ( (( 1 - $alpha_1100 ) * pct_1100) / (os_corp ) ) if pct_1100!=.
					
			*effective tax rate on wages and salaries in the formal sector
				gen ETR_pit = 0 if pct_tax!=.
					replace ETR_pit = ETR_pit + pct_1100 if pct_1100!=.
					replace ETR_pit = ETR_pit + $alpha_1300 * pct_1300 if pct_1300!=.
					replace ETR_pit = ETR_pit / ce_hh								//do not include nfi_L
				
		*effective tax rates in NDP not NNI (abstracts from NFI flows)
			*incl. ETRs with different PIT incidence assumption (either 0% or 30% of PIT on K, instead of benchmark 15%), as above
				foreach x in L L_0 L_30 L_alpha L_dual L_prime L_indirect {
					gen ETR_`x'_ndp = Tau_`x' / Lsh_ndp 
				}
				foreach x in K K_0 K_30 K_alpha K_dual K_prime K_indirect {
					gen ETR_`x'_ndp = Tau_`x' / Ksh_ndp 
				}	
					*preliminary data cleaning (see further below for more)
						*renaming (we do not need ETRs in NNI)
								drop ETR_L_0 ETR_L_30 ETR_K_0 ETR_K_30 ETR_L_alpha ETR_K_alpha ETR_L_dual ETR_K_dual ETR_L_prime ETR_K_prime ETR_L_indirect ETR_K_indirect Tau_L_0 Tau_L_30 Tau_K_0 Tau_K_30 //don't need these (nni)
							foreach x in L K {	
								ren ETR_`x'_0_ndp ETR_`x'_0
								ren ETR_`x'_30_ndp ETR_`x'_30
								ren ETR_`x'_alpha_ndp ETR_`x'_alpha
								ren ETR_`x'_dual_ndp ETR_`x'_dual
								ren ETR_`x'_prime_ndp ETR_`x'_prime
								ren ETR_`x'_indirect_ndp ETR_`x'_indirect
							}
						*replace if erroneously zero in latest year
							foreach var of varlist ETR* Tau* {
								replace `var' = . if `var'==0 & year==2019
							}
						
		*additional ETR concepts
			*ETRs re ILO factor shares (in NDP terms)	
				gen ETR_L_ilo = ( Tau_L ) / Lsh_ilo
				gen ETR_K_ilo = ( Tau_K ) / Ksh_ilo

			
			*factor shares net of direct taxes on income and wealth 
				foreach x in L K {
					gen `x'sh_net = ( `x'sh_ndp - Tau_`x' ) / (1 - Tau_L - Tau_K)
				}
				*Note that we do not subtract social security as taxes here, because these are deferred labor compensation
					replace Lsh_net = ( Lsh_ndp - Tau_L + pct_2000 ) / (1 - Tau_L - Tau_K + pct_2000) if pct_2000!=. //NB May 2021: NDP not NNI
					replace Ksh_net = ( Ksh_ndp - Tau_K ) / (1 - Tau_L - Tau_K + pct_2000) if pct_2000!=. //NB May 2021: NDP not NNI

	*******************************************************************		
	* 3. Final Data Cleaning and Labels
	*******************************************************************	
		
		
		*additional calculations on factor shares
			*factor shares strictly within the corporate sector (excludes mixed income and imputed rent of the household sector)
				gen Lsh_corp = ce_hh   / (ce_hh + os_corp)
				gen Ksh_corp = os_corp / (ce_hh + os_corp)
				
			*put factor shares and tax revenues and trade share in levels (from % nni), as log currency values (constant 2019 LCU)
				foreach var in Lsh_nni Ksh_nni {
					 gen log_`var' = log(`var' * nni_usd) 
				}
					
		*log levels for several important variables
			*log of factor shares or taxes or trade = level in total economy (2019 constant USD)
				foreach var in Lsh_ndp Ksh_ndp Tau_L Tau_K trade {
					 gen log_`var' = log(`var' * ndp_usd) 
				}
				foreach var in Lsh_corp Ksh_corp	{
						gen temp = `var' * os_corp * nni_usd //NB os_corp is expressed in percent of NNI (not NDP)
						gen log_`var' = log(temp) 			
							drop temp						
					}
			*further log variables: corporate sector within total capital income, and corporate vs. noncorporate income levels
				*log_K_corp vs. log_K_noncorp
					gen corp_win_K = os_corp / (os_corp + os_hh /*+ nfi_K*/ + 0.3*mi_hh) //exclude NFI
					gen log_K_corp = log(os_corp * nni_usd)
					gen log_K_noncorp = log( (os_hh + 0.3*mi_hh) * nni_usd)

		
		*winsorize at p1 p99
			*ETRs outliers
				foreach x in L K cit cit_kg pit L_ndp K_ndp L_ilo K_ilo L_0 K_0 L_30 K_30 L_alpha K_alpha L_dual K_dual L_prime K_prime L_indirect K_indirect {
					*winsor2 ETR_`x', replace cuts(1 99)
					replace ETR_`x' = 1 if ETR_`x' > 1 & ETR_`x'!=.
					replace ETR_`x' = 0 if ETR_`x' < 0 & ETR_`x'!=.
				}
				
			*factor shares outliers
				foreach x in L K {		
						*winsor2 `x'sh_net, replace cuts(1 99)
						*winsor2 `x'sh_corp, replace cuts(1 99)
						replace `x'sh_net = 1 if `x'sh_net > 1 & `x'sh_net!=.
						replace `x'sh_corp = 1 if `x'sh_corp > 1 & `x'sh_corp!=.
						replace `x'sh_net = 0 if `x'sh_net < 0 & `x'sh_net!=.
						replace `x'sh_corp = 0 if `x'sh_corp < 0 & `x'sh_corp!=.
				}

		*format, order and labels
			format %9.2fc Tau* ETR* *_net *_corp log* corp_win_K
			format %16.0g region
			order Tau_L Tau_K Tau_L_alpha Tau_K_alpha Tau_L_dual Tau_K_dual Tau_L_prime Tau_K_prime Tau_L_indirect Tau_K_indirect, after(Ksh_nni)
			order ETR_L ETR_K, before(source_tax)
			order ETR_cit ETR_cit_kg ETR_pit, after(ETR_K)
			order ETR_L_ndp ETR_K_ndp ETR_L_prime ETR_K_prime ETR_L_indirect ETR_K_indirect ETR_L_alpha ETR_K_alpha ETR_L_dual ETR_K_dual ETR_L_0 ETR_K_0 ETR_L_30 ETR_K_30, before(ETR_cit)
			order Lsh_nni Ksh_nni Lsh_corp Ksh_corp, after(Tau_K)
			order Lsh_net Ksh_net, after(Ksh_gdp) 
			order log_Lsh_nni log_Ksh_nni, before(nnipc_ppp)
			order log_K_corp log_K_noncorp corp_win_K, after(log_Ksh_nni)
			order log_Lsh_corp log_Ksh_corp, after(Ksh_corp)
			order log_trade, after(trade)
			order ETR_L_ilo ETR_K_ilo, before(Lsh_ilo)
			label var Tau_L "tax revenue (% of NDP at factor prices), taxes on labor" //NB May 2021: NDP not NNI
			label var Tau_K "tax revenue (% of NDP at factor prices), taxes on capital" //NB May 2021: NDP not NNI
			label var Tau_L_alpha "tax revenue (% of NDP at factor prices), taxes on labor [PIT==(1-alpha)% L]" //NB May 2021: NDP not NNI
			label var Tau_K_alpha "tax revenue (% of NDP at factor prices), taxes on capital [PIT==(alpha)% K]" //NB May 2021: NDP not NNI
			label var Tau_L_dual "tax revenue (% of NDP at factor prices), taxes on labor [PIT==dual]" //NB May 2021: NDP not NNI
			label var Tau_K_dual "tax revenue (% of NDP at factor prices), taxes on capital [PIT==dual]" //NB May 2021: NDP not NNI
			label var Tau_L_prime "tax revenue (% of NDP at factor prices), taxes on labor [noting PIT thresholds & dual PIT systems]" //NB May 2021: NDP not NNI
			label var Tau_K_prime "tax revenue (% of NDP at factor prices), taxes on capital [noting PIT thresholds & dual PIT systems]" //NB May 2021: NDP not NNI
			label var Tau_L_indirect "tax revenue (% of NDP; incl. indirect taxes), taxes on labor [noting PIT thresholds & dual PIT systems]" //NB May 2021: NDP not NNI
			label var Tau_K_indirect "tax revenue (% of NDP; incl. indirect taxes), taxes on capital [noting PIT thresholds & dual PIT systems]" //NB May 2021: NDP not NNI
			label var ETR_L "effective tax rate on labor income L_nni (excluding indirect taxes)"
			label var ETR_K "effective tax rate on capital income K_nni (excluding indirect taxes)"
			label var ETR_cit "effective corporate income tax rate (excluding individual capital gains taxation)"
			label var ETR_cit_kg "effective corporate income tax rate (including individual capital gains taxation)"
			label var ETR_pit "effective personal income tax rate on corporate sector wages (including individual capital gains taxation)"
			label var ETR_L_ndp "effective tax rate on L_ndp (excl. NFI and NIT)"
			label var ETR_K_ndp "effective tax rate on K_ndp (excl. NFI and NIT)"
			label var ETR_L_alpha "effective tax rate on L_ndp (excl. NFI and NIT, PIT==(1-alpha)% L"
			label var ETR_K_alpha "effective tax rate on K_ndp (excl. NFI and NIT, PIT==(alpha)% K"
			label var ETR_L_dual "effective tax rate on L_ndp (excl. NFI and NIT, PIT==(1-alpha)% L [dual PIT system]"
			label var ETR_K_dual "effective tax rate on K_ndp (excl. NFI and NIT, PIT==(alpha)% K [dual PIT system]"
			label var ETR_L_prime "effective tax rate on L_ndp [excl. NFI and NIT, noting PIT thresholds & dual PIT systems]"
			label var ETR_K_prime "effective tax rate on K_ndp [excl. NFI and NIT, noting PIT thresholds & dual PIT systems]"
			label var ETR_L_indirect "effective tax rate on L_ndp [incl. NIT, excl. NFI, noting PIT thresholds & dual PIT systems]"
			label var ETR_K_indirect "effective tax rate on K_ndp [incl. NIT, excl. NFI, noting PIT thresholds & dual PIT systems]"
			label var ETR_L_0 "effective tax rate on L_ndp (excl. NFI and NIT), PIT==100% L"
			label var ETR_K_0 "effective tax rate on K_ndp (excl. NFI and NIT), PIT==0% K"
			label var ETR_L_30 "effective tax rate on L_ndp (excl. NFI and NIT), PIT==70% L"
			label var ETR_K_30 "effective tax rate on K_ndp (excl. NFI and NIT), PIT==30% K"
			label var ETR_L_ilo "effective tax rate on L_ndp (excl. NFI and NIT), a la ILO 2019"
			label var ETR_K_ilo "effective tax rate on K_ndp (excl. NFI and NIT), a la ILO 2019"
			label var Lsh_corp "labor share in the corporate sector"
			label var Ksh_corp "capital share in the corporate sector"
			label var Lsh_net "L share net of [NB: non-payroll] direct taxes = (Y_L - T_L) / (Y - T)"
			label var Ksh_net "K share net of [NB: non-payroll] direct taxes = (Y_K - T_K) / (Y - T)"
			label var corp_win_K "net OS_corp as % of net Y_K (at factor prices)"
			label var log_K_corp "log domestic corporate net operating surplus (2019 USD)"
			label var log_K_noncorp "log non-corporate capital income (2019 USD) = os_hh + 0.3*mi_hh, sans os_corp" //NB May 2021: NDP not NNI
			label var log_Lsh_corp "log Lsh_corp (levels in 2019 USD)"
			label var log_Ksh_corp "log Ksh_corp (levels in 2019 USD)"
			label var log_trade "log of trade qty (levels in 2019 USD) [NB can exceed NDP] (World Bank WDI)" //NB May 2021: NDP not NNI
		
		*rename and re-order
			foreach x in L K {
				ren log_`x'sh_ndp log_`x'
					label var log_`x' "log `x' income (2019 USD)"
				ren log_Tau_`x' log_T_`x'
					label var log_T_`x' "log tax revenue from `x' (2019 USD)"
				order log_`x', before(Lsh_corp)
				order log_T_`x', before(Lsh_nni)
			}
			order Lsh_gdp Ksh_gdp, before(nnipc_ppp)
			order Lsh_ndp Ksh_ndp, before(Lsh_nni)
	
				
		*extend to entire panel some of the variables		
			ren name_un	country_name
			order country_name M49code
			format %18s country_name
			foreach var of varlist country_name { //string
				egen temp = mode(`var'), by(country)
				replace `var' = temp if `var'==""
				drop temp
			}
			foreach var of varlist M49code landlocked - d3_coastal { //numeric
				egen temp = mode(`var'), by(country)
				replace `var' = temp if `var'==.
				drop temp
			}
		*the below were missing in WTI where UN names and M49 were imported (see 'covariates' do-file) so we manually import here
			replace country_name = "Afghanistan" if country=="AFG"
			replace M49code = 4 if country=="AFG"
				replace country_name = "Kosovo" if country=="KOS"
				replace M49code = 412 if country=="KOS"
			replace country_name = "Sudan" if country=="SDN"
			replace M49code = 729 if country=="SDN"
				replace country_name = "Seychelles" if country=="SYC"
				replace M49code = 690 if country=="SYC"
			replace country_name = "Timor-Leste" if country=="TLS"
			replace M49code = 626 if country=="TLS"
				replace country_name = "Taiwan" if country=="TWN"
				replace M49code = 158  if country=="TWN"

	*******************************************************************		
	* 4. Finish setup and save
	*******************************************************************	
	
		* save with all variables for analysis
			sort cid year
			local dateyear = c(current_date)
			save "data/ETR_`dateyear'.dta", replace
			
		*save clean public-use dataset 
			#delimit  ;
			keep 	country_name country year region wb_inc ndp_usd
					ETR_L_prime ETR_K_prime Tau_L_prime Tau_K_prime Lsh_ndp Ksh_ndp
					pct_tax pct_1000 pct_1100 pct_1200 pct_2000 pct_4000 pct_5000 pct_6000
					source_tax source_sna 		;
			
			order country_name country year region wb_inc ndp_usd
					ETR_L_prime ETR_K_prime Tau_L_prime Tau_K_prime Lsh_ndp Ksh_ndp
					pct_tax pct_1000 pct_1100 pct_1200 pct_2000 pct_4000 pct_5000 pct_6000
					source_tax source_sna 	; 	

			#delim cr		
			
			ren *_prime *			// We only keep our main definition of Effective Tax Rates (ETR_prime)  		
				
			drop if ETR_L ==. | ETR_K==.
				
			replace source_tax = "Archives" if source_tax == "HA"
			replace source_tax = "Archives" if source_tax == "NS"
			replace source_tax = "Archives" if source_tax == "IMF"

			************** 	Save the data in several format **************	
			** Save as .dta	
			save "data/globalETR_bfjz.dta", replace
			
			** Save as .csv
			export delimited using  "data/globalETR_bfjz", replace
			
			** Save as .xls
			export excel using "data/globalETR_bfjz.xls", firstrow(variables) replace
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
