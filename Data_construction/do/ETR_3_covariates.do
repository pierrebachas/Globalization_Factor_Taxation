
***************************************************************************************
*  Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman - December 2020								  
*  	program: ETR_3_covariates.do			
* 	Task: Merges revenue and factor shares data with covariates										  
***************************************************************************************
	
		set more off
		clear all
		use data/misc/revenue_FS_combined , clear

	*******************************************************************		
	* 1. Merge Covariates and Characteristics of Country-Years
	*******************************************************************	
		*Region and World Bank income level - classifications slightly modified for conciseness (fewer categories)
			merge m:1 country using data/misc/rhs/classification
				drop if _merge==2
					drop _merge
		*population
			merge 1:1 country year using data/misc/rhs/population
				drop if _merge==2
					drop _merge
					
		*constant 2018 PPP to constant 2018 USD conversion factor
			merge m:1 country using data/misc/rhs/ppp_usd_2018
				drop if _merge==2
					drop _merge
				replace ppp_usd_2018=1 if ppp_usd_2018==. //best approximation	
			save data/misc/temp/merge1, replace
			
		*PIT exemption threshold (including imputations) and PIT_alpha, based on Jensen AER 2021
			do do/auxiliary/pit_thr_imputation
			u data/misc/temp/merge1, clear
			merge 1:1 country year using data/misc/rhs/pit_alpha
				drop if _merge==2
					drop _merge		
					
		*OECD statutory rates data: ratio of tax rate on dividends to top marginal PIT rate
			merge 1:1 country year using data/misc/rhs/div_pit_oecd, keepusing(div_pit_oecd div_pit_extrapolated)
				drop if _merge==2
					drop _merge
			*extend this estimate backward to the first year of country being in the dataset
					sort cid year
				egen sample = count(div_pit_oecd), by(country)
					replace sample = 1 if sample>0 & sample!=.
				replace div_pit_extrapolated=1 if sample==1 & div_pit_oecd==.	
				forval year = 2018 (-1) 1965 {
					replace div_pit_oecd = F.div_pit_oecd if div_pit_oecd==. & sample==1 /*& pct_tax!=.*/ & year==`year' //there are no gaps, so this only fills the pre-period
				}
					drop sample
					
		*WID 'headline' inequality data
			merge 1:1 country year using data/misc/rhs/wid_headline_exclude //the 'exclude' function excludes interpolated and extrapolated values
				foreach var of varlist s_* {
					local lbl : var label `var'
					label var `var' "`lbl' [WID]"
				}
				drop if _merge==2
					drop _merge
			*interpolate missing years within WID
						sort country year
					gen wid_interpolated=.
				foreach var of varlist s_* {
					by country: ipolate	`var' year, gen(temp)	
							replace wid_interpolated=1 if temp!=. & `var'==.
						replace `var' = temp if `var'==.
							drop temp
				}
					egen check = rowtotal(s_bot50 s_mid40 s_top10) if wid_interpolated==1
				foreach var of varlist s_* {
					replace `var' = `var' / check if wid_interpolated==1 //re-scaling interpolations to equal 100
				}	
						drop check // wid_interpolated
					label var wid_interpolated "observation is interpolated: World Inequality Database pre-tax income distribution"
*stop					
		*ILO factor shares
			merge 1:1 country year using data/misc/rhs/ILO_master
				drop if _merge==2
					drop _merge
				gen Lsh_ndp_ilo = Lsh_ilo * (gdp/(ndp-nit))
					drop Lsh_ilo
				gen Ksh_ndp_ilo = 1 - Lsh_ndp_ilo
						foreach f in L K {
					lab var `f'sh_ndp_ilo "`f' share of (factor-price) net domestic product [ILO estimate]"
					format %9.2fc `f'sh_ndp_ilo
						}
					lab var ilo_imputed "factors shares from ILO are imputed"
			save data/misc/temp/merge2, replace		
			
		*ILO: imputed factor shares, using their factor shares method, their historical self-employment data, and our imputation method (see factorshares routine)
			do do/auxiliary/ilo_imputation
			u data/misc/temp/merge2, clear
			merge 1:1 country year using data/misc/rhs/Lsh_ilo, update replace
				drop if _merge==2
					drop _merge			
					
				gen Ksh_ilo = 1 - Lsh_ilo
					format %9.2fc Ksh_ilo
					order Lsh_ilo Ksh_ilo, after(wid_interpolated)
					replace ilo_imputed = 1 if ilo_imputed!=0
					label var Lsh_ilo "labor share of (factor-price) NDP, following ILO (2019) method and ILOSTAT data"
					label var Ksh_ilo "capital share of (factor-price) NDP, following ILO (2019) method and ILOSTAT data"
					label var coef_ilo_imputed "flag: ILO statistic on salary ratios (self-employed to employed) is imputed"
					label var emp_ilo_imputed "flag: ILO statistic on employee vs. self-employed shares of workforce is imputed"
					order ilo_imputed coef_ilo_imputed emp_ilo_imputed, after(selfemployed_family)			
					
*China correction on mixed income
	*components currently expressed as % nni
	*need to replace `f'sh_nni, `f'sh_ndp, `f'sh_gdp		
	
	*clonevar Lsh_ndp1 = Lsh_ndp

	br country year employees Ksh_ndp Lsh_ndp* Lsh_ilo nit ndp ce_hh mi_hh  if country=="CHN" // & year==1995
		gen mi_ilo_implied = ( Lsh_ilo * (ndp - nit) ) - ce_hh //diff between Lsh_ilo (from fp_ndp --> nni denominator) and ce_hh is  implicit (labor component of) mixed income
			replace mi_ilo_implied = mi_ilo_implied / .7 //include the 30% capital component of mixed income
	
	sum employees mi_hh mi_ilo_implied [aw=nni_usd] 			, d //overall, ILO implicit mixed income is lower
	sum employees mi_hh mi_ilo_implied [aw=nni_usd] if region!=4, d  //non-OECD, it is higher
	
	replace ce_hh = ce_hh + mi_hh - mi_ilo_implied if country=="CHN"
	replace mi_hh = mi_ilo_implied if country=="CHN"
		drop mi_ilo_implied
	
	replace va_corp = (ce_hh - ce_gov) + os_corp if country=="CHN"
	replace mios_hh = mi_hh + os_hh if country=="CHN"
	replace mios_total = mi_hh + os_hh + os_corp + os_gov if country=="CHN"

	*labor share
		replace Lsh_nni = ( ce_hh + ( 0.7 * mi_hh ) + nfi_L ) / ( 1 - nit ) if country=="CHN"
		replace Lsh_ndp = ( ce_hh + ( 0.7 * mi_hh ) ) / ( gdp - cfc - nit ) if country=="CHN"
		replace Lsh_gdp = ( ce_hh + ( 0.7 * mi_hh ) ) / ( gdp - nit ) if country=="CHN"
			
	*capital share
		replace Ksh_nni = ( ( 0.3 * mi_hh ) + os_hh + os_corp + os_gov + nfi_K ) / ( 1 - nit )  if country=="CHN"
		replace Ksh_ndp = ( ( 0.3 * mi_hh ) + os_hh + os_corp + os_gov ) / ( gdp - cfc - nit )  if country=="CHN"
		replace Ksh_gdp = ( ( 0.3 * mi_hh ) + os_hh + os_corp + os_gov + cfc ) / ( gdp - nit )  if country=="CHN"

		
		
		*PSZ 2018 data for robustness on USA factor shares; all other values are from ILO
			merge 1:1 country year using data/misc/rhs/Ksh_psz, keepusing(Ksh_psz Lsh_psz)
				drop if _merge==2
				drop _merge
			
			replace Ksh_psz = Ksh_ilo if country!="USA"
			replace Lsh_psz = Lsh_ilo if country!="USA"
			label var Ksh_psz "capital share of NDP (ILO 2019 except USA from PSZ 2018)"
			label var Lsh_psz "labor share of NDP (ILO 2019 except USA from PSZ 2018)"
		
		*UN SNA tax and revenue levels
			merge 1:1 country year using "${root}/data/misc/rhs/SNA direct indirect social.dta", keepusing(tax_sna direct indirect social)
				drop if _merge==2
					drop _merge
			merge 1:1 country year using "${root}/data/misc/rhs/SNA total revenue.dta", keepusing(revenue_sna)
				drop if _merge==2
					drop _merge
		
		*Haggarty-Shirley (1997) SOE production
			merge 1:1 country year using data/misc/rhs/haggarty_shirley, keepusing(soe_pct)
				drop if _merge==2
					drop _merge
		
		*Ross-Mahdavi (2015) oil & gas
			merge 1:1 country year using data/misc/rhs/ross_mahdavi, keepusing(oil_pct)
					replace oil_pct=. if oil_pct>=1
				drop if _merge==2
					drop _merge
			merge m:1 country using data/misc/rhs/oil_sample, keepusing(oil_impt) //oil important dummy, also from Ross-Mahdavi
				drop if _merge==2
					drop _merge
		
		*oil and fdi expropriation events
			merge 1:1 country year using data/misc/rhs/exprop
				drop if _merge==2
					drop _merge
		
		*privatizations
			merge 1:1 country year using data/misc/rhs/privatization
				drop if _merge==2
					drop _merge
		
		*trade share
			merge 1:1 country year using data/misc/rhs/trade_share
					ren trade_share trade
				drop if _merge==2
					drop _merge
		
		*merchandise (goods) trade share
			merge 1:1 country year using data/misc/rhs/goods_trade
				drop if _merge==2
					drop _merge
		
		*imports exports
			merge 1:1 country year using data/misc/rhs/imports_exports
				drop if _merge==2
					drop _merge
		
		*net trade & net goods trade			
				gen net_trade = exports - imports
					format %9.2fc net_trade
			merge 1:1 country year using data/misc/rhs/net_goods_trade
				drop if _merge==2
					drop _merge
		
		*instruments a la Egger-Nigai-Strecker (AER 2019)
			merge 1:1 country year using data/misc/rhs/egger_nigai_strecker
				drop if _merge==2
					drop _merge
			merge 1:1 country year using data/misc/rhs/egger_iv_expanded, keepusing(instr_trade2)
				drop if _merge==2
				label var instr_trade2 "expanded trade IV I (Egger et al AER 2019)"
				order instr_trade2, after(instr_trade)
					drop _merge
		
		*CIT rates from Tax Foundation (2019)
			merge 1:1 country year using data/misc/rhs/cit_rate_taxfdn
				drop if _merge==2 
					drop _merge
		
		*CIT rates, PIT rates & VAT info from Vegh and Vuletin (2015, updated to 2019)
			merge 1:1 country year using data/misc/rhs/rates_VV2015
				drop if _merge==2 
					drop _merge
		
		*VAT info from Treasury data
			merge 1:1 country year using data/misc/rhs/vat
				drop if _merge==2 
					drop _merge
		
		*PIT data from World Tax Indicators (dataset used in Martinez-Vazquez, Peter, Duncan papers - see esp Peter et al NTJ 2010)
			merge 1:1 country year using data/misc/rhs/wti, keepusing(name_un M49code pit_toprate_wti ARP_all ARP_mid MRP_all MRP_mid AR_y AR_2y AR_3y AR_4y MR_y MR_2y MR_3y MR_4y)
				drop if _merge==2
					drop _merge
		
		*CIT, PIT rates
			egen cit_rate=rowmin(cit_rate_taxfdn cit_rate_vv cit_rate_egger)
				label var cit_rate "CIT rate (multiple sources; use lower rate if conflicting estimates)"
			egen pit_toprate=rowmin(pit_toprate_vv pit_toprate_wti)
				label var pit_toprate "PIT top rate (multiple sources; use lower rate if conflicting estimates)"
		
		*additional covariates from WB WDI & WID
			merge 1:1 country year using data/misc/rhs/wb_covar
				drop if _merge==2
					drop _merge
		
		*sector data from WB WDI & WID
			merge 1:1 country year using data/misc/rhs/sectordata_wdi
				drop if _merge==2
					drop _merge
		
		*democracy indicator variable from Quality of Government dataset
			merge 1:1 country year using data/misc/rhs/qog_democracy
				replace democracy = 1 if country=="KOS" //_merge==1
				drop if _merge==2
				drop _merge
		
		*educational attainment data from Barro-Lee (JDE 2013), expanded via cubic spline interpolation			
			merge 1:1 country year using data/misc/rhs/barro-lee
				drop if _merge==2
					drop _merge
		
		*oil price (to build instrument)
			merge m:1 year using data/misc/rhs/oilprice, keepusing(opec)
				drop if _merge==2
					drop _merge
		
		*city distances (to build instrument)
			merge m:1 country using data/misc/rhs/citydist, keepusing(landlocked d1 d2 d3 *_coastal) nogen
		
		*GATT accession & membership
			merge m:1 country using data/misc/rhs/gatt_member
				drop if _merge==2
				gen gatt_member = year>=year_gatt if year_gatt!=.
				replace gatt_member = 0 if year_gatt==. | country=="SRB" //Yugoslavia was in GATT, not Serbia
				drop year_gatt _merge
		
		*WTO accession & membership
			merge 1:1 country year using data/misc/rhs/wto_member
				drop if _merge==2
				replace wto_member = year>=1997 if country=="PAN" //PAN missing in dataset
				replace wto_member = wto_member[_n-1] if year==2019 & wto_member==.
					drop _merge
		
		*WTO & GATT combined variable
														//gen flag=1 if gatt==1 & wto==0 & year>1994 //egen max_flag = max(flag), by(country) //replace flag=max_flag //drop max_flag
			replace wto_member = 1 if gatt_member == 1 	//9 of the 128 GATT countries (by 1994) joined WTO in 1996 instead of 1995; 2 in 1997; the other 119 joined in 1995
													//we only count accession once, so joining WTO is not an *additional* 'event' for the 128 existing GATT countries (even the 'late' GATT-->WTO entrants)
													//joining GATT is the event for those 128; joining WTO an event only for the non-GATT countries, after 1994 (to date, 36 more countries entered WTO)
				drop gatt_member
		
		*currency union & regional trade agreemeent membership (Glick-Rose 2016)
			merge 1:1 country year using data/misc/rhs/glick_rose
					drop if _merge==2 //many obs
				*extend forward the obs	(extrapolating -- the events would have been previous, i.e., no new events)
					foreach var in cu_member rta_count rta_member {
						forval year = 2013 / 2019	{
							replace `var' = `var'[_n-1] if country==country[_n-1] & year==`year' & _merge==1
						}
					}
				drop _merge	
		
		*Chinn-Ito (JDE 2006) on capital controls and financial openness
			merge 1:1 country year using data/misc/rhs/chinn_ito, keepusing(kaopen kaopen_01)
				ren kaopen_01 k_open
				drop if _merge==2
					drop /*kaopen*/ _merge
			*define any change as an event
					sort cid year
				gen moreopen = 	k_open > L.k_open if k_open!=. & L.k_open!=.
					label var moreopen "capital account restrictions ease in year of record (Chinn-Ito index)"
				gen lessopen = 	k_open < L.k_open if k_open!=. & L.k_open!=.
					label var lessopen "capital account restrictions tighten in year of record (Chinn-Ito index)"
						/*could also define a 10% change as an event
							replace moreopen = 	d_k_open >= .10 if d_k_open!=.
							replace lessopen = 	d_k_open <= -.10 if d_k_open!=.
						*/
				
		
		*tariff rates (MFN unweighted and weighted - from TRAINS and Buettner et al (2018); and Furceri / WDI, respectively)
			merge 1:1 country year using data/misc/rhs/tariffs, keepusing(mfn orig_trains mfn_weighted orig_furceri)
				drop if _merge==2
					drop _merge
		
		*Graebner et al (2020) openness measures
			merge 1:1 country year using data/misc/rhs/graebner, keepusing(LMF_EQ LMF_open)
				drop if _merge==2
					drop _merge
				gen lg_eq = log(LMF_EQ)
					label var lg_eq "log of openness variable LMF_EQ (Graebner et al 2020)"
						drop LMF_EQ
				gen lg_open = log(1 + LMF_open)
					label var lg_open "log of openness variable LMF_open (Graebner et al 2020)"
				
		
	*******************************************************************		
	* 2. Data Cleaning and Labels
	*******************************************************************	
		
		*put everything in percent of NNI instead of GDP (convert from %GDP to %NNI)
			foreach x of varlist pct* tax_sna - oil_pct pvtzn_pct trade goods_trade exports imports net_trade net_goods_trade {
				replace `x' = `x' * gdp 	// alternatively, replace [gdp] with [ (gdp / (1 - nit) ] for factor-price NNI: [ GDP / (1 - NIT) ] is the conversion factor from GDP to factor-price NNI, since GDP and NIT are already expressed as % of NNI [ NNI = 100% = 1]
			}
		
		
		*put everything in ndp instead of nni	
		foreach var of varlist pct_tax - pct_6000 tax_sna - oil_pct pvtzn_pct trade goods_trade exports imports net_trade net_goods_trade fdi_net remit gfcf {
		replace `var' = `var' * (1 / ndp)
		}
		
		*update ilo factor shares
		
		*re stitching
			*SNA stitch flag
				gen stitch_sna = 1 if stitch_sna_2008==1 | stitch_sna_series==1
					drop stitch_sna_*
			*stitching dummies
				foreach var of varlist stitch stitch_sna interpolated imputed {
					replace `var' = 0 if `var' != 1
				}
				
		*national income standard, as well as population, for weighting
		
		*include all national income observations
		merge 1:1 country year using data/misc/rhs/wid_nni, nogen //many missing obs
			sort country year
			drop if year<1965
				egen everhastaxdata = count(pct_tax), by(country) //order everhastaxdata
			drop if everhastaxdata == 0 	
				drop everhastaxdata

		*update region / cid, etc.
		foreach var of varlist region wb_inc cid {
				egen temp = mode(`var'), by(country)
			replace `var' = temp if `var'==.
				drop temp
		}
																	
																					
		
	*			gen nni_ppp = nnipc_ppp * pop
	gen ndp_ppp = nni_ppp * ndp
	gen ndppc_ppp = nnipc_ppp * ndp
	
	*gen nnipc_usd = nnipc_ppp / ppp_usd_2018
	gen ndp_usd = nni_usd * ndp
	gen ndppc_usd = nnipc_usd * ndp //

/*
	replace ndp_usd = ndp_ppp / ppp_usd_2018
	replace ndppc_usd = ndppc_ppp / ppp_usd_2018
	
	replace nni_usd = nni_ppp / ppp_usd_2018
	replace nnipc_usd = nnipc_ppp / ppp_usd_2018
*/	
	
*gen nni_usd = nni_ppp / ppp_usd_2018
*gen ndp_usd = ndp_ppp / ppp_usd_2018
			
																	
			format %18.0fc nni_ppp 	ndp_ppp ndppc_ppp nnipc_usd nni_usd ndppc_usd ndp_usd
				
			foreach x in pop nni_ppp nnipc_ppp 	ndp_ppp ndppc_ppp nnipc_usd nni_usd ndppc_usd ndp_usd {
				replace `x' = round(`x') //rounds var to nearest integer	(for weighting with frequency weights, fw in Stata: see below)
				}
			
		*do not use year 2019 yet (still incomplete, globally)
			 drop if year==2019
			
																			
		*labels
			label var nni_ppp "national income (constant 2019 USD at PPP)"
			label var ndp_ppp "net domestic product (constant 2019 USD at PPP)"
			label var nni_usd "national income (constant 2019 USD)"
			label var ndp_usd "net domestic product (constant 2019 USD)"
			label var ndppc_ppp "NDP per capita at 2019 USD PPP (WB)"
			label var nnipc_usd "NNI per capita in constant 2019 USD (WB)"
			label var	ndppc_usd "NDP per capita in constant 2019 USD (WB)"
			ren source source_tax
			label var source_tax "tax revenue data source (HA = historical archive, local, and scholarly sources)"
			ren stitch stitch_tax
			label var stitch_tax "flag: tax data source changes in this year"
			label var interpolated "flag: revenue quantities for this year are significantly or entirely interpolated"
			label var pct_tax "total tax revenue, as % of NDP" //ndp not nni
			label var pct_1000 "total income tax 1000 series) revenue, as % of NDP" //ndp not nni
			label var pct_1100 "PIT (1100 series) revenue, as % of NDP" //ndp not nni
			label var pct_1200 "CIT (1200 series) revenue, as % of NDP" //ndp not nni
			label var pct_1300 "other/unallocable income tax (1300 series) revenue, as % of NDP" //ndp not nni
			label var pct_2000 "social contributions (2000 series) revenue, as % of NDP" //ndp not nni
			label var pct_4000 "property and wealth tax (4000 series) revenue, as % of NDP" //ndp not nni
			label var pct_5000 "indirect tax (5000 series) revenue, as % of NDP" //ndp not nni
			label var pct_6000 "other tax (6000 series) revenue, as % of NDP" //ndp not nni
			label var stitch_sna "flag: UN SNA source or series changes in this year"
			label var tax_sna "tax revenue, as % of NDP (UN SNA, general government)" 				//re-label re NDP instead of GDP or NNI
			label var direct_sna "direct tax revenue (D5), as % of NDP (UN SNA, general government)" //ndp not nni
			label var indirect_sna "indirect tax revenue (D2), as % of NDP (UN SNA, general government)" //ndp not nni
			label var social_sna "social contributions (D61), as % of NDP (UN SNA, total economy)" //ndp not nni
			label var revenue_sna "total govt revenue, as % of NDP (UN SNA)" //ndp not nni
			label var oil_pct "oil & gas, as % of NDP (Ross-Mahdavi 2015 & WID)" //ndp not nni
			label var soe_pct "SOE production, as % of NDP (Haggarty-Shirley 1997, World Bank)" //ndp not nni
			label var pvtzn_pct "Privatizations' magnitude, as % of NDP (WDI archive data, 1988-2008)" //ndp not nni
			label var trade "trade as % of NDP [NB can exceed 100%] (World Bank WDI)" //ndp not nni
			label var goods_trade "merchandise trade as % of NDP [NB can exceed 100%] (World Bank WDI)" //ndp not nni
			label var exports "exports of goods and services as % of NDP [NB can exceed 100%] (World Bank WDI)" //ndp not nni
			label var imports "imports of goods and services as % of NDP [NB can exceed 100%] (World Bank WDI)" //ndp not nni
			label var net_trade "net exports of goods and services as % of NDP (World Bank WDI)" //ndp not nni
			label var net_goods_trade "net exports of goods as % of NDP (World Bank WDI)" //ndp not nni
			label var fdi_net "FDI net inflow (% of NDP) (WB & WID)"
			label var gfcf "gross fixed capital formation (% of NDP) (WB & WID)"
			cap label var gatt_member "country membership in GATT in year of record"
			label var wto_member "country membership in WTO (or earlier GATT) in year of record"
			label var excomm "ex-communist economy and/or historical Soviet influence"
			label var agric_emp "share of labor force in agriculture, as % [WB WDI]"
			label var industry_emp "share of labor force in industry, as % [WB WDI]"
			label var services_emp "share of labor force in services, as % [WB WDI]"
			label var emppop_ratio "employed, as % of population [WB WDI]"
			label var unemp_sharelf "unemployed, as % of labor force [WB WDI]"
			label var agric_va "share of value added in agriculture, as % [WB WDI]"
			label var industry_va "share of value added in industry, as % [WB WDI]"
			label var manuf_va "share of value added in manufacturing, as % [WB WDI]"
			label var services_va "share of value added in services, as % [WB WDI]"
			label var services_vaperworker "value added per worker, in services (% of total value added / % of labor force) [WB WDI]"

			
				
		*order
			*order Lsh_nni, before(pct_tax)
			order cid country year region wb_inc
			order Lsh_ndp Ksh_ndp, before(Lsh_nni)
			order nni_ppp nni_usd ndp_ppp ndp_usd pop, before(source_sna)
			order nnipc_usd ndppc_ppp ndppc_usd, after(nnipc_ppp)
			order source_sna stitch_tax stitch_sna interpolated imputed, after(pct_6000)
			order excomm, after(pvtzn_oil)
			order vat_ust, before(vat_year_vv)
			
		*format
			format %3s country
			sort country year
			
		*save
			save data/misc/merged, replace				
