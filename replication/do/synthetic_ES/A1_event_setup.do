		
		
		
		
*** Set up Events

		* Drop Vietnam before 1991, so we can extrapolate its values from 1990 to 1994 later
		drop if country=="VNM" & year<1990

		encode country, gen(cty_id)
		drop if country=="COD"			// We have to drop the DRC. It causes sinificant problems in the synthetic matching, 
										// some of the outcoems (e.g. ETR_K) make no sense and jump from 0 to 50%

			* Colombia: 85
			* Mexico: 85
			* Argentina 89
			* Brazil: 88
			* India: 91
			* Vietnam: 01
			* China:01
			gen treat=0
			replace treat=1 if country=="BRA" | country=="COL" ///
				| country=="VNM" | country=="IND" | country=="MEX" | country=="ARG" | country=="CHN"

			gen year_firstoutc=.
			replace year_firstoutc=1985 if country=="COL" 
			replace year_firstoutc=1985 if country=="MEX"
			replace year_firstoutc=1989 if country=="ARG"
			replace year_firstoutc=1988 if country=="BRA"
			replace year_firstoutc=1991 if country=="IND" 
			replace year_firstoutc=2001 if country=="VNM"
			replace year_firstoutc=2001 if country=="CHN"


		
