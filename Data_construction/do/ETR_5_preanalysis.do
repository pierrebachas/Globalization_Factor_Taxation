***************************************************************************************
*  	Globalization and Factor Income Taxation			
*	Authors: Bachas, Fisher-Post, Jensen, Zucman 					  
*  	program: ETR_5_preanalysis.do			
* 	Task: Calculations of some variables for analyses and graphs									  
***************************************************************************************
					
	
	*load data
		set more off
		pause on
		clear all 
		local dateyear = c(current_date)
		cap use "data/ETR_`dateyear'.dta", replace 	//latest dataset (from ETR_4_construction, step 4)

********************************************
*	Add several measures and weights
********************************************	
		
	*winsorize several variables of interest
		*winsorize at p1 p99
			*ETRs outliers
				foreach x in L K cit cit_kg pit L_ndp K_ndp L_ilo K_ilo L_0 K_0 L_30 K_30 L_alpha K_alpha L_dual K_dual L_prime K_prime L_indirect K_indirect {
					winsor2 ETR_`x', replace cuts(1 99)
				}
			*factor shares outliers
				foreach x in L K {		
						winsor2 `x'sh_net, replace cuts(1 99)
						winsor2 `x'sh_corp, replace cuts(1 99)
				}
			*trade outliers
				gen trade_winz=trade
				forval i = 0(1)52{
					xtile pctiletrade`i'=trade if year==1965+`i', nq(20) 
					egen meanpctile`i'top=mean(trade) if pctiletrade`i'==19 & year==1965+`i'
					egen tousemeanpctile`i'top=mean(meanpctile`i'top) if year==1965+`i'
					replace trade_winz=tousemeanpctile`i'top if year==1965+`i' & pctiletrade`i'==20
				}

		*set up additional outcome variables, controls and log variables
			foreach f in K L {
				gen log_`f'_net = log(`f'sh_net	 * (ndp_usd - nit*nni_usd - log_T_`f'))
					cap drop log_`f'_corp //held different definition in the basic dataset above (was: corporate sector within K income; now: corp-sector K within national income)
				gen log_`f'_corp = 	log(`f'sh_corp * ((ce_hh + os_corp)*nni_usd))
					label var log_`f'_net "log total income to `f', net of taxes (levels in 2019 USD)"
					label var log_`f'_corp "log total income to `f', corporate sector (levels in 2019 USD)"
			}
				gen log_ndp = log(ndp_usd)
					label var log_ndp "log net domestic product (levels in 2019 USD)"
				gen log_ndppc = log(ndppc_usd)
					label var log_ndppc "log net domestic product per capita (levels in 2019 USD)"
				gen log_pop = log(pop)
					label var log_pop "log population"
				gen log_xrate = log(xrate)
				gen log_fdi_net = log(fdi_net*ndp_usd)
				gen log_gfcf = log(gfcf*ndp_usd)
				foreach var in xrate fdi_net gfcf {
					label var log_`var' "log `var'"
				}
				format %9.2fc log*		
					
			egen taxKLC_pct=rowtotal(pct_1000 pct_2000 pct_4000 pct_5000)
			egen taxKL_pct=rowtotal(pct_1000 pct_2000 pct_4000)	
			
		*CIT rate variables	
				egen citrate=rowmin(cit_rate_egger cit_rate_taxfdn cit_rate_vv)
				gen egger=1 if citrate==cit_rate_egger
				replace egger=0 if citrate!=cit_rate_egger

				gen taxfdn=1 if citrate==cit_rate_taxfdn
				replace taxfdn=0 if citrate!=cit_rate_taxfdn
						
				gen vv=1 if citrate==cit_rate_vv
				replace vv=0 if citrate!=cit_rate_vv
					
				xtset cid year
				bysort cid: gen citincrease=1 if cit_rate>l1.cit_rate & cit_rate!=. & l1.cit_rate!=.
				bysort cid: replace citincrease=0 if cit_rate==l1.cit_rate & cit_rate!=. & l1.cit_rate!=.
				bysort cid: replace citincrease=-1 if cit_rate<l1.cit_rate & cit_rate!=. & l1.cit_rate!=.
					
				xtset cid year
				bysort cid: gen cit_change=cit_rate-l1.cit_rate
						
				winsor2 cit_change, by(year) cut(1 99) suffix(_winz)
				winsor2 cit_rate, by(year) cut(1 90) suffix(_winz)
					
		*Mendoza ETRs								
				*from ndp denominator to gdp on tax revenues		
					foreach x in 1100 1200 1300 2000 4000 5000 6000 {		//from ndp to gdp	
						cap replace pct_`x' = pct_`x' * (ndp / gdp)
						}
				*from nni denominator to gdp on national income components
					foreach x in os_hh mi_hh ce_hh os_corp os_gov mios_hh {		//from nni to gdp
						cap replace `x' = `x' * gdp
						}
				
			*mendoza definitions (gdp denominator)		
				gen pitrate_mendoza = ( (pct_1100) /  (os_hh + mi_hh + ce_hh) )	
					replace pitrate_mendoza=0 if pct_1100==.
				gen ETR_L_mendoza = (pitrate_mendoza*ce_hh + pct_2000) / (ce_hh + .5*pct_2000)
					replace ETR_L_mendoza = (pitrate_mendoza*ce_hh + 0) / (ce_hh + .5*0) if pct_2000==.
				gen ETR_K_mendoza = (pitrate_mendoza*(os_hh + mi_hh) + pct_1200 + pct_4000) / (os_corp + mios_hh + os_gov)
					replace ETR_K_mendoza = (pitrate_mendoza*(os_hh + mi_hh) + 0 + pct_4000) / (os_corp + mios_hh + os_gov) if pct_1200==.
					replace ETR_K_mendoza = (pitrate_mendoza*(os_hh + mi_hh) + pct_1200 + 0) / (os_corp + mios_hh + os_gov) if pct_4000==.
					replace ETR_K_mendoza = (pitrate_mendoza*(os_hh + mi_hh) + 0 + 0) / (os_corp + mios_hh + os_gov) if pct_1200==. & pct_4000==.
				gen trade_rodrik = trade * (1 / gdp) //trade as a share of gdp not nni
				
			
				*now back to ndp and nni denominators, respectively
					foreach x in 1100 1200 1300 2000 4000 5000 6000 {	//gdp back to ndp
						cap replace pct_`x' = pct_`x' * (gdp / ndp)
						}
					foreach x in os_hh mi_hh ce_hh os_corp os_gov mios_hh {		//gdp back to nni
						cap replace `x' = `x' / gdp
						}
			
					
		*heterogeneity
			*by income: richness, as region
				gen rich = 0
					replace rich = 1 if wb_inc == 3 & region == 4 // Assigns WB High income + OECD to rich, 
					replace rich = 1 if country == "TWN"	|  country == "SGP"		// re-integrates Taiwan and Singapore
					label var rich "high-income OECD countries (plus Taiwan and Singapore)"
				*OECD
					gen OECD=1 if region==4
					replace OECD=0 if region!=4 & region!=.
				gen richalt=1 if wb_inc==3 & OECD==1
					replace richalt=0 if richalt!=1
				
			*by population
				gen largepop=1 if pop>=40000000
					replace largepop=0 if largepop!=1 & pop!=.
				gen smallpop=1 if largepop==0
					replace smallpop=0 if largepop==1
			
			*oil-rich marker
				gen oilrich=1 if oil_impt==1
				replace oilrich=0 if oil_impt!=1
			
			*per capita gdp
				gen gdppc = ( gdp*nni_usd ) / pop
				gen lg_gdppc=log(gdppc)
				gen lg_ndppc=log(ndppc_ppp)
				
			*re 1995
				gen pre_95=1 if year<=1995
				replace pre_95=0 if year>=1995 & year!=.
				gen post_95=1 if pre_95==0
				replace post_95=0 if pre_95==1
				gen trade_post95=trade*post_95

			*trade interactions
				gen trade_kopen=trade*k_open
				gen trade_richalt=richalt*trade_winz
				gen trade_oecd=trade*OECD
				gen trade_largepop=trade*largepop
				gen trade_smallpop=trade_winz*smallpop
								
			
		*weights
			*weights, global (or region) by year
				bysort year: egen totlndp =sum(ndp_usd)
				bysort year: egen totlndp_ppp =sum(ndp_ppp)		
				gen weight_global_year =  ndp_usd / totlndp
				gen weight_global_year_ppp =  ndp_ppp / totlndp_ppp
				bysort rich year: egen totlndp_region =sum(ndp_usd)
				bysort rich year: egen totlndp_region_ppp =sum(ndp_ppp)
				gen weight_region_year =  ndp_usd / totlndp_region
				gen weight_region_year_ppp =  ndp_ppp / totlndp_region_ppp
				
			*weights fixed at 2010 value 
					local year  = 2010
				foreach var in global region  { 
					gen weight_`var'_fixed = .
					replace weight_`var'_fixed = weight_`var'_year  if year == `year'
					bysort country: egen tmp_max = max(weight_`var'_fixed )
					replace weight_`var'_fixed  = tmp_max
					drop tmp_max
				} 
				
			*ndp weights which sum to 1 within each year
				gen wndpyear=.
				forval i =0(1)53{
				bysort cid: gen ndp_year`i'=ndp_ppp if year==1965+`i'
				egen totlwndp`i'=sum(ndp_year`i') if year==1965+`i'
				replace wndpyear=ndp_year`i'/totlwndp`i' if year==1965+`i'
				}
				bysort year: egen checkweight=sum(wndpyear)
				sum checkweight
								
********************************************
*	Build price*distance instrument
********************************************
		
		*mean distance (sea definition)
			gen mean_dist /*_sea*/ = ( d1 /*_coastal*/ + d2 /*_coastal*/ + d3 /*_coastal*/ ) / 3 //excludes MUS SGP KWT (less than 3 major cities)
			label var mean_dist "mean distance to container terminal [SeaRates]"
		*sample variance (sea definition)
			gen vce_dist /*_sea*/ = ((d1 /*_coastal*/ - mean_dist /*_sea*/ )^2 + (d2 /*_coastal*/ - mean_dist /*_sea*/ )^2  + (d3 /*_coastal*/ - mean_dist /*_sea*/ )^2) / 2
			label var vce_dist "variance of distances to container terminal [SeaRates]"
		
		*instrument: (variance of distance) * price
			gen iv_oildist = opec_price^2 * vce_dist /*_sea*/

			*put opec into constant
				gen opec_index = nni_index if country=="USA"
						egen temp = max(opec_index), by(year)
					replace	opec_index	= temp if opec_index==.
						drop temp
					gen opec_constant = opec_price / opec_index 
						label var opec_index "USD national income price index (convert to 2019 USD)"
						label var opec_constant "crude oil price, constant 2019 USD per barrel (OPEC reference basket)"
				order opec_index opec_constant, after(opec_price)	

			gen iv_oildist_constant = opec_constant ^ 2 * vce_dist
			gen iv_oildist_log = (log(opec_price)) ^ 2 * vce_dist
			gen iv_oildist_constant_log = (log(opec_constant)) ^ 2 * vce_dist

			label var iv_oildist "variance of [price*distance to nearest port]; price in current USD per barrel"
			label var iv_oildist_log "variance of [price*distance to nearest port]; price in (log of) current USD per barrel"
			label var iv_oildist_constant "variance of [price*distance to nearest port]; price in constant 2019 USD per barrel"
			label var iv_oildist_constant_log "variance of [price*distance to nearest port]; price in (log of) constant 2019 USD per barrel"
		
		order mean_dist vce_dist iv_oildist iv_oildist_log iv_oildist_constant iv_oildist_constant_log, after(d3_coastal)
				
		format %12.0fc *dist* iv_oildist*				
				
********************************************	
*	Save
********************************************

	*save dataset with China (for event-study), before dropping China
		sort cid year
		local dateyear = c(current_date)
		save "data/archive/master_CHN_`dateyear'.dta", replace
				
		*drop China pre-1994
			foreach var of varlist ETR_L - ETR_pit pct_tax - pct_6000 stitch_tax imputed Tau_L - Ksh_gdp Lsh_net Ksh_net gdp - output_imputed ce_gov - checkweight {
				replace `var'=. if year<1994 & country=="CHN"
			}
			foreach var of varlist source_tax source_sna { 
				replace `var' = "" if year<1994 & country=="CHN"
			}
				
	*save 'master'
		sort cid year
		local dateyear = c(current_date)
		save "data/master_`dateyear'.dta", replace	

						
