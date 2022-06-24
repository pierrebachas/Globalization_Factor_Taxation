	*PIT_k alpha != 15%, but rather vary it by country-year according to PIT exemption threshold
	
	*take thresholds from ADJ JMP
	*impute these to all country-years
	
	
	*start with master data
			u data/misc/temp/merge1, clear
			
			keep cid country year nnipc_ppp
			
			gen log_nnipc = log(nnipc_ppp) //will need this in imputations below
					format %9.2fc log_nnipc
	*merge ADJ AER 2021 data	
		merge 1:1 country year using data/misc/auxiliary/pit_thresholds
			//NB TJK, IRQ, PSE (and Puerto Rico) do not exist in master
				drop if _merge==2
				drop _merge
			
			ren percentile_K pit_thr
				label var pit_thr "PIT exemption threshold, percentile of pre-tax income distribution (Jensen AER 2021)"
				format %9.1fc pit_thr
		
	*impute using modified from code below
		reg pit_thr log_nnipc
			predict xb, xb
			
		*replace (re-scale) imputed values up or down based on difference with existing value (in the year of the difference)
			gen temp = pit_thr - xb
			egen diff = mode(temp), by(cid)
			replace xb = xb + diff if diff!=.	
			
		*cap the threshold at its maximum (p99.5) and minimum (p2)
			replace xb = 99.5 if xb > 99.5
			replace xb = 2 if xb < 2
			
		gen pit_thr_imputed=pit_thr==.
		replace pit_thr = xb if pit_thr==.	
			drop temp diff xb
		
	*alpha of capital income in PIT given thresholds
		gen alpha_pit = .15 if pit_thr <= 50
			label var alpha_pit "share of PIT from capital income (imputed)"
			format %9.2fc alpha_pit 
		replace alpha_pit = .30 if pit_thr > 99 //br if pit_thr!=. //0 obs
				sort pit_thr
		ipolate alpha_pit pit_thr, gen(temp)
			replace alpha_pit = temp if alpha_pit==.
				drop temp
				
		sort cid year
	*save	
	keep country year pit_thr* alpha_pit	
	save data/misc/rhs/pit_alpha, replace
		
		
