		
		
*** 4. Regression 
	
	local var="$var"

			cd "$usedata/synthetic_ES_tempfiles"
			use sample`var', clear 
			
			* We start by constructing simple averages across groups
			bysort rel_year treat: egen avg_`var'=mean(`var')
			gen x=avg_`var' if treat==1
			gen z=avg_`var' if treat==0
			bysort rel_year: egen avg_`var'_t=mean(x)
			bysort rel_year: egen avg_`var'_nt=mean(z)
			drop x z avg_`var'

			* Time dummies
			gen post_treat=0
			replace post_treat=1 if treat==1 & rel_year>=0

			forvalues i=1/10 {
				gen pre`i'=0 
				replace pre`i'=1 if rel_year==-`i' & treat==1
			}
			gen zero=0
			replace zero=1 if rel_year==0 & treat==1
			forvalues i=1/10 {
				gen post`i'=0 
				replace post`i'=1 if rel_year==`i' & treat==1
			}

			* 4.1: Bootstrap CIs
			{
			replace rel_year=rel_year+20

			reghdfe `var' pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 ///
				zero post1 post2 post3 post4 post5 post6 post7 post8 post9 post10 pre1 /// 
				i.year i.rel_year ,abs(i.id ) vce(cluster id)

			gen cilow4=.
			gen ciup4=.
			gen se_boot_dummies=.

			forvalues i=2/10 {
			set seed 25
			boottest pre`i', nograph
			matrix define A=r(CI)
			matrix define B=r(V)
			replace cilow4=A[1,1] if rel_year==-`i'+20
			replace ciup4=A[1,2] if rel_year==-`i'+20
			replace se_boot_dummies=sqrt(B[1,1]) if rel_year==-`i'+20
			boottest post`i', nograph
			matrix define A=r(CI)
			matrix define B=r(V)
			replace cilow4=A[1,1] if rel_year==`i'+20
			replace ciup4=A[1,2] if rel_year==`i'+20
			replace se_boot_dummies=sqrt(B[1,1]) if rel_year==`i'+20

			}
			boottest post1, nograph
			matrix define A=r(CI)
			matrix define B=r(V)
			replace cilow4=A[1,1] if rel_year==1+20
			replace ciup4=A[1,2] if rel_year==1+20
			replace se_boot_dummies=sqrt(B[1,1]) if rel_year==1+20
			boottest zero, nograph
			matrix define A=r(CI)
			matrix define B=r(V)
			replace cilow4=A[1,1] if rel_year==0+20
			replace ciup4=A[1,2] if rel_year==0+20
			replace se_boot_dummies=sqrt(B[1,1]) if rel_year==0+20

			eststo pt_`var': reghdfe `var' post_treat /// 
				i.year i.rel_year,abs(i.id) vce(cluster id)
			boottest post_treat, nograph
			matrix define A=r(V)
			gen septboot_`var'=sqrt(A[1,1])

			replace rel_year=rel_year-20
			}
			****

			* 4.2: Estimations
			{
			eststo pt_`var': reghdfe `var' post_treat /// 
				i.year ,abs(i.id i.rel_year) vce(cluster id)
				
			gen est_`var'=round(_b[post_treat],0.0001)
			*gen est_pval_`var'=round(ttail(e(df_r),abs(_b[post_treat]/_se[post_treat]))*2,0.0001)
			*gen est_pval_`var'=round(_se[post_treat],0.0001)

			reghdfe `var' pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 ///
				zero post1 post2 post3 post4 post5 post6 post7 post8 post9 post10 pre1 /// 
				i.year,abs(i.id i.rel_year) vce(cluster id)

			gen est_es_`var'=.
			forvalues i=1/10 {
				replace est_es_`var'=_b[pre`i'] if rel_year==-`i'
				replace est_es_`var'=_b[post`i'] if rel_year==`i'
			}
			replace est_es_`var'=_b[zero] if rel_year==0

			gen se_es_`var'=.
			forvalues i=1/10 {
				replace se_es_`var'=_se[pre`i'] if rel_year==-`i'
				replace se_es_`var'=_se[post`i'] if rel_year==`i'
			}
			replace se_es_`var'=_se[zero] if rel_year==0

			reghdfe `var' pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 ///
				zero post1 post2 post3 post4 post5 post6 post7 post8 post9 post10 pre1 /// 
				,abs(i.id i.rel_year) vce(cluster id)

			* F Test on joint insignificance
			test zero post1 post2 post3 post4 post5 post6 post7 post8 post9 post10
			gen fstat_`var'=round(`r(F)',0.01)
			gen est_pval_`var'=round(`r(p)',0.0000001)

			* Now store results
			eststo es_`var': reghdfe `var' pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 ///
				zero post1 post2 post3 post4 post5 post6 post7 post8 post9 post10 pre1 /// 
				i.year,abs(i.id i.rel_year) vce(cluster id)

			sum fstat_`var'
			estadd scalar ftest_stat=`r(mean)'
			sum est_pval_`var'
			estadd scalar ftest=`r(mean)'
			sum septboot_`var'
			estadd scalar boots_se=`r(mean)'

			forvalues i=2/10 {
			sum se_boot_dummies if rel_year==-`i'
			estadd scalar boots_se_pre`i'=`r(mean)'
			sum se_boot_dummies if rel_year==`i'
			estadd scalar boots_se_post`i'=`r(mean)'
			}
			sum se_boot_dummies if rel_year==1
			estadd scalar boots_se_post1=`r(mean)'
			sum se_boot_dummies if rel_year==0
			estadd scalar boots_se_zero=`r(mean)'



			}
			****

			* 4.3: Imputation method
			{
			gen x=year if rel_year==0 & treat==1
			bysort id: egen tyear=mean(x)
			drop x


			eststo imp_`var': did_imputation `var' id year tyear, fe(id year rel_year)

			eststo imp_es_`var': did_imputation `var' id year tyear, allhorizon autosample minn(0) ///
								 pretrends(6) fe(id year rel_year)

			}
			****

			bysort rel_year: keep if _n==1

			* We store all the relevant estimation results and other results that we stored in forms of variables
			keep est_`var' est_es_`var' rel_year est_pval_`var' avg_`var'_t avg_`var'_nt _est_pt_`var' ///
					_est_es_`var' se_es_`var' cilow4 ciup4 septboot_`var' _est_imp_`var' _est_imp_es_`var' fstat_`var'
			
			cd "$usedata"
			save "synthetic_ES_intermediat_data/main_outcomes/`var'.dta", replace



		
