# Globalization_Factor_Taxation
Data & codes for "Globalization and Factor Income Taxation", by Pierre Bachas, Matthew Fisher-Post, Anders Jensen & Gabriel Zucman.

The paper constructs an extended time series of macroeconomic effective tax rates (ETRs) on capital and labor, covering the 150 most populous countries from 1965 to present, with exceptions for command economy eras, pre-independence and civil wars. It then describes the evolution of ETRs in high-income vs low and middle-income countries and analyses the role of globalization (in particular trade integration) in explaining the observed patterns. 

DATA: Users interested in using the effective tax rates data should download the data file: **globalETR_bfjz**

The construction of effective tax rates is detailed in section 3 of the paper and in the Online Appendix.  
Users interested in seeing the steps for the construction of the dataset or changing assumptions can use the codes detailed in "data_construction/ETR_0_master.do" 
We aim at term to make the raw data of tax revenue we digitized available together with country case studies which permit to validate the accuracy of different sources. In the meantime, users interested in obtaining specific countries' raw revenue data sources which we digitized can contact us. 
We also welcome anyone with tax revenue data which can improve or correct the series to contact us to improve the series. 

REPLICATION: Users interested in replicating the paper can follow the do-file: **replication/analysis_0_master.do**

This is the master do-file which lists the names of the scripts used for each step of the analysis (scripts and data in the "replication" folder) 
The master dataset used in the analysis of the paper is "master_15 Jun 2022.dta". The data is created by combining the ETR dataset globalETR_bfjz.dta with several public datasets needed for the analysis (e.g. trade flows, oil production, etc.). It is created by dofile "ETR_5_preanalysis.do", the final script of ETR_0_master.do series. 






