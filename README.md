# Globalization_Factor_Taxation
Data & codes for "Globalization and Factor Income Taxation", by Pierre Bachas, Matthew Fisher-Post, Anders Jensen & Gabriel Zucman.

The paper constructs an extended time series of macroeconomic effective tax rates (ETRs) on capital and labor, covering the 150 most populous countries from 1965 to present, with exceptions for command economy eras, pre-independence and civil wars. It then describes the evolution of ETRs in high-income vs low and middle-income countries and analyses the role of globalization (in particular trade integration) in explaining the observed patterns. 

DATA: Users interested in using the effective tax rates data should download the data file: **globalETR_bfjz**

The construction of effective tax rates is detailed in section 3 of the paper and in the Online Appendix.  
Users interested in seeing the steps for the construction of the dataset or changing assumptions can use the codes detailed in "replication/ETR_0_master.do" 
We aim at term to make the raw data of tax revenue we digitized available together with country case studies which permit to validate the accuracy of different sources. In the meantime, users interested in obtaining specific countries' raw revenue data sources which we digitized can contact us. 
We also welcome anyone with tax revenue data which can improve or correct the series to contact us to improve the series. 

REPLICATION: Users interested in replicating the results of the paper should follow the do-file: **XXX.do**
This is the master do-files which lists the names of the scripts used for each step of the analysis (in the "replication" folder) 
The master dataset used in the analysis of the paper is "name.dta" which combines the ETR dataset globalETR_bfjz.dta with several other public data sources needed for the analysis and appended in "name", the final script of ETR_0_master.do 






