		
		
		
*** 3. Combine all events to form a single sample 
		
		
			* Reload the first data set. This is simply the first event used in the loop above. We then subsequently merge the remaining
			* events. Note that we already merge in realtive time to the event. 
			
			local var="$var"
			
			cd "$usedata/synthetic_ES_tempfiles"
			use sample1, clear
			forvalues y=2/7 {
				merge 1:1 rel_year using sample`y', nogen
			}
			forvalues i=1/7 {
				rename rmspe_`i'_1 rmspe_`i'
				rename synth_`i'_1 synth_`i'
				rename c_`i'_1 c_`i'
				rename year_`i'_ year_`i'
			}
			forvalues i=1/7 {
			local p=`i'+7
				rename c_`i' synth_`p'
				gen rmspe_`p'=rmspe_`i'
				gen year_`p'=year_`i'
			}

			reshape long synth_ rmspe_ year_, i(rel_year) j(id)

			drop if synth_==.
			drop if rel_year<-10
			drop if rel_year>10

			gen treat=0
			replace treat=1 if id>7
			rename synth_ `var'
			rename year_ year

			drop rmspe_
			
			cd "$usedata/synthetic_ES_tempfiles"
			save sample`var', replace 
