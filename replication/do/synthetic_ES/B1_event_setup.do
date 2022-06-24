			
	*** Set up Events		
			
			encode country, gen(cty_id)
			drop if country=="COD"		

			
			gen K_libyear=.
			replace K_libyear=1989 if country_name=="Argentina"
			replace K_libyear=1988 if country_name=="Brazil"
			replace K_libyear=1987 if country_name=="Chile"
			replace K_libyear=1991 if country_name=="Colombia"
			replace K_libyear=1991 if country_name=="Egypt"
			replace K_libyear=1994 if country_name=="Greece"
			replace K_libyear=1986 if country_name=="India"
			replace K_libyear=1989 if country_name=="Indonesia"
			replace K_libyear=1989 if country_name=="Israel"
			replace K_libyear=1995 if country_name=="Jordan"
			replace K_libyear=1987 if country_name=="Malaysia"
			replace K_libyear=1989 if country_name=="Mexico"
			replace K_libyear=1992 if country_name=="Morocco"
			replace K_libyear=1995 if country_name=="Nigeria"
			replace K_libyear=1991 if country_name=="Pakistan"
			replace K_libyear=1986 if country_name=="Philippines"
			replace K_libyear=1993 if country_name=="Portugal"
			replace K_libyear=1995 if country_name=="South Africa"
			replace K_libyear=1987 if country_name=="Republic of Korea"
			replace K_libyear=1993 if country_name=="Spain"
			replace K_libyear=1986 if country_name=="Taiwan"
			replace K_libyear=1987 if country_name=="Thailand"
			replace K_libyear=1989 if country_name=="Turkey"
			replace K_libyear=1990 if country_name=="Venezuela (Bolivarian Republic of)"
			replace K_libyear=1993 if country_name=="Zimbabwe"
			

			gen treat=0
			replace treat=1 if K_libyear!=.

			rename K_libyear year_firstoutc

			drop if country=="MAR"		// openess only exists for 3 year
