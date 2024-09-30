clear
clear matrix
set maxvar 20000


**************************************************************foodinsecurity SCALE*******************************************************

capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\DATA_MANAGEMENT_foodinsecurity.smcl",replace


cd "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA"



*****STEP -1: foodinsecurity DATA, 2013: MERGE AND CREATE THE foodinsecurity VARIABLE**


***2013***

**              storage   display    value
**variable name   type    format     label      variable label
**--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
**HNB1_13         byte    %8.0g                 FOOD DID NOT LAST
**HNB2_13         byte    %8.0g                 CANT AFFORD BALANCED MEALS
**HNB3_13         byte    %8.0g                 CUT OR SKIP MEALS
**HNB4_13         byte    %8.0g                 EAT LESS NOT ENOUGH MONEY
**HNB5_13         byte    %8.0g                 GO HUNGRY NOT ENOUGH MONEY



use DATA_HCNS,clear
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save DATA_HCNSfin, replace



keep HHIDPN HNB1_13 HNB2_13  HNB3_13 HNB4_13 HNB19_13 HNB5_13 
save foodinsecurity_data2013, replace

use foodinsecurity_data2013,clear

tab1 HNB1_13 HNB2_13  HNB3_13 HNB4_13 HNB19_13 HNB5_13 

save foodinsecurity_data2013, replace


**Source: https://www.ers.usda.gov/media/8282/short2012.pdf


**This is what it says
**i.	Responses of “often” or “sometimes” on questions HH3 and HH4, and “yes” on AD1, AD2, and AD3 are coded as affirmative (yes). Responses of “almost every month” and “some months but not every month” on AD1a are coded as affirmative (yes). 
**Note, there is one question that you did not mention that has a skip pattern: (a) “How often did this happen—almost every month, some months but not every month, or in only 1 or 2 months?” which relies on an affirmative response to (b) “In the **last 12 months, since last (name of current month), did (you/you or other adults in your household) ever cut the size of your meals or skip meals because there wasn't enough money for food?”

**So the algorithm/logic would be as follows:
**1.	Convert all character string variable to numeric (1 or 0) based on the above description in (i) for the 6 questions
**2.	If there is an NA or missing value for the skip pattern question for those that responded “No” to question (b) above, it should be converted to 0.
**3.	Take the sum of the six questions
**4.	If sum >= 2, 1, else 0

tab1 HNB1_13 HNB2_13 HNB3_13 HNB4_13 HNB5_13

capture drop HNB1_13r
gen HNB1_13r=.
replace HNB1_13r=HNB1_13
replace HNB1_13r=. if HNB1_13==99
replace HNB1_13r=4 if HNB1_13==3


capture drop HNB2_13r
gen HNB2_13r=.
replace HNB2_13r=HNB2_13
replace HNB2_13r=. if HNB2_13==99
replace HNB2_13r=4 if HNB2_13==3


capture drop HNB3_13r
gen  HNB3_13r=.
replace HNB3_13r=HNB3_13
replace HNB3_13r=4 if HNB3_13==3
replace HNB3_13r=. if HNB3_13==99



capture drop HNB4_13r
gen HNB4_13r=.
replace HNB4_13r=HNB4_13
replace HNB4_13r=. if HNB4_13==99


capture drop HNB5_13r
gen HNB5_13r=.
replace HNB5_13r=HNB5_13
replace HNB5_13r=. if HNB5_13==99


capture drop foodinsecuritymiss
egen  foodinsecuritymiss=rowmiss(HNB1_13r HNB2_13r HNB3_13r HNB3_13r HNB4_13r HNB5_13r)

capture drop foodinsecurity_tot
egen foodinsecurity_tot=anycount(HNB1_13r HNB2_13r HNB3_13r HNB3_13r HNB4_13r HNB5_13r), values(1 2 3)
replace foodinsecurity_tot=. if foodinsecuritymiss>0 

tab foodinsecurity_tot

capture drop foodinsecurity_totbr
gen foodinsecurity_totbr=.
replace foodinsecurity_totbr=1 if foodinsecurity_tot>=2
replace foodinsecurity_totbr=0 if foodinsecurity_tot<2 & foodinsecurity_tot~=.

sort HHIDPN



save, replace


*********************************************************************************************************************************************

capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\DATA_MANAGEMENT.smcl",replace

**STEP 0: OPEN FILES AND CREATE HHIDPN VARIABLE, SORT BY THIS VARIABLE**

cd "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA"

use randhrs1992_2018v2,clear


capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

use trk2020tr_r,clear
capture rename HHID-VERSION,lower
save, replace

capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

**STEP 1: REDUCE RAND FILE TO RESPONDENT VARIABLE FILE****

use randhrs1992_2018v2,clear
 
keep HHIDPN r* inw* h*

save randhrs1992_2018v2_resp, replace



**STEP 2: MERGE REDUCED RAND FILE WITH TRACKER FILE****

use randhrs1992_2018v2_resp,clear
capture drop _merge
merge HHIDPN using trk2020tr_r
tab _merge
capture drop _merge
sort HHIDPN
save randhrs1992_2018v2_resp_tracker, replace




**STEP 3: DESCRIBE AND SUMMARIZE THE FILE****

describe 

su 

**STEP 4: IDENTIFY THE REQUIRED VARIABLES USING RAND AND TRACKER FILE DOCUMENTATION AND LIST THEM ****
use randhrs1992_2018v2_resp_tracker,clear


**LIST OF AGE VARIABLES (2006-2018):
**2006 is r8: r8agey_e
**2008 is r9: r9agey_e
**2010 is r10: r10agey_e
**2012 is r11: r11agey_e
**2014 is r12: r12agey_e
**2016 is r13: r13agey_e
**2018 is r14: r14agey_e

su r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e


**LIST OF VARIABLES NEEDED TO CREATE THE RACE/ETHNICITY (fixed):

**RACE: need to impute, n=5 missing**

capture drop RACE
gen RACE=rarace

tab RACE 

**Ethnicity: 1=Hispanic, 0=Non-Hispanic: n=1 missing

capture drop ETHNICITY
gen ETHNICITY=rahispan

tab ETHNICITY 

**RACE/ETHNICITY: 

capture drop RACE_ETHN
gen RACE_ETHN=.
replace RACE_ETHN=1 if RACE==1 & ETHNICITY==0
replace RACE_ETHN=2 if RACE==2 & ETHNICITY==0
replace RACE_ETHN=3 if ETHNICITY==1 & RACE~=.
replace RACE_ETHN=4 if RACE==3 & ETHNICITY==0

tab RACE_ETHN,missing
tab RACE_ETHN 


**GENDER (fixed):

capture drop SEX
gen SEX=ragender

tab SEX 


**EDUCATION (fixed):

tab raeduc, missing 

capture drop education
gen education = .
replace education = 1 if raeduc == 1 /*< HS*/
replace education = 2 if raeduc == 2 /*GED*/
replace education = 3 if raeduc == 3 /*HS GRADUATE*/
replace education = 4 if raeduc == 4 /*SOME COLLEGE*/
replace education = 5 if raeduc == 5 /*COLLEGE AND ABOVE*/

tab education , missing
tab education 

************************************************************2006*************************************************************


**INCOME VARIABLE (2006):

tab h8itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2006
gen totwealth_2006 = .
replace totwealth_2006 = 1 if h8itot < 25000
replace totwealth_2006 = 2 if h8itot >= 25000 & h8itot < 125000
replace totwealth_2006 = 3 if h8itot >= 125000 & h8itot < 300000
replace totwealth_2006 = 4 if h8itot >= 300000 & h8itot < 650000
replace totwealth_2006 = 5 if h8itot >= 650000 & h8itot ~= .


tab totwealth_2006 , missing
tab totwealth_2006 

save, replace

**MARITAL STATUS (2006)**

tab r8mstat, missing

capture drop marital_2006
gen marital_2006 = .
replace marital_2006 = 1 if r8mstat == 8 /*never married*/
replace marital_2006 = 2 if (r8mstat == 1 | r8mstat == 2 | r8mstat == 3) /*married / partnered*/
replace marital_2006 = 3 if (r8mstat == 4 | r8mstat == 5 | r8mstat == 6) /*separated / divorced*/
replace marital_2006 = 4 if (r8mstat == 7) /*widowed*/

tab marital_2006, missing
tab marital_2006

**EMPLOYMENT (2006):

tab r8work, missing

capture drop work_st_2006
gen work_st_2006 = .
replace work_st_2006 = 0 if r8work == 0
replace work_st_2006 = 1 if r8work == 1

tab work_st_2006, missing
tab work_st_2006


**CIGARETTE SMOKING (2006): 
tab r8smokev, missing
tab r8smoken, missing

capture drop smoking_2006
gen smoking_2006 = .
replace smoking_2006 = 1 if r8smokev == 0
replace smoking_2006 = 2 if r8smokev == 1 & r8smoken == 0
replace smoking_2006 = 3 if r8smokev == 1 & r8smoken == 1

tab smoking_2006, missing
tab smoking_2006 

save, replace



*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2006* n=173 missing/


tab r8drink, missing
tab r8drinkd, missing


capture drop alcohol_2006
gen alcohol_2006 = .
replace alcohol_2006 = 1 if r8drink == 0
replace alcohol_2006 = 2 if r8drink == 1 & r8drinkd == 0
replace alcohol_2006 = 3 if r8drink == 1 & (r8drinkd == 1 | r8drinkd == 2)
replace alcohol_2006 = 4 if r8drink == 1 & (r8drinkd > 3 & r8drinkd ~= . & r8drinkd ~= .d & r8drinkd ~= .m & r8drinkd ~= .r)

tab alcohol_2006, missing


**PHYSICAL ACTIVITY (2006):
tab r8vgactx, missing
tab r8mdactx, missing

capture drop physic_act_2006
gen physic_act_2006 = .
replace physic_act_2006 = 1 if (r8vgactx ==  5 & r8mdactx == 5)
replace physic_act_2006 = 2 if (r8vgactx ==  3 | r8mdactx == 3 | r8vgactx ==  4 | r8mdactx == 4)
replace physic_act_2006 = 3 if (r8vgactx ==  1 | r8mdactx == 1 | r8vgactx ==  2 | r8mdactx == 2)

tab physic_act_2006, missing
tab physic_act_2006


**SELF-RATED HEALTH (2006):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r8shlt, missing

capture drop srh_2006
gen srh_2006 = .
replace srh_2006 = 1 if (r8shlt == 1 | r8shlt == 2 | r8shlt == 3)
replace srh_2006 = 2 if (r8shlt == 4 | r8shlt == 5)

tab srh_2006, missing
tab srh_2006 

save, replace


**WEIGTH STATUS, 2006**
/*body mass index*/

/*2006*/

*<25 
**  25-29.9
**  ≥30


tab r8pmbmi, missing
tab r8bmi, missing
tab r8bmi , missing
tab r8bmi 
su r8bmi ,det


capture drop bmi_2006
gen bmi_2006 = r8pmbmi if r8pmbmi < 100
else replace bmi_2006 = r8bmi if r8bmi < 100

tab bmi_2006, missing
tab bmi_2006 , missing
tab bmi_2006 
su bmi_2006 , det



capture drop bmibr_2006
gen bmibr_2006 = 1 if bmi_2006 < 25
replace bmibr_2006 = 2 if bmi_2006 >= 25 & bmi_2006 < 30
replace bmibr_2006 = 3 if bmi_2006 >= 30 & bmi_2006 ~= .

tab bmibr_2006, missing


/*cardiometabolic risk factors and chronic conditions, 2006*/

/*HYPERTENSION*/

tab r8hibpe, missing

capture drop hbp_ever_2006sv
gen hbp_ever_2006 = .
replace hbp_ever_2006 = 0 if r8hibpe == 0
replace hbp_ever_2006 = 1 if r8hibpe == 1

tab hbp_ever_2006, missing
tab hbp_ever_2006 


/*DIABETES*/

tab r8diabe, missing

capture drop diab_ever_2006
gen diab_ever_2006 = .
replace diab_ever_2006 = 0 if r8diabe == 0
replace diab_ever_2006 = 1 if r8diabe == 1

tab diab_ever_2006, missing
tab diab_ever_2006 


/*HEART PROBLEMS*/

tab r8hearte, missing

capture drop heart_ever_2006
gen heart_ever_2006 = .
replace heart_ever_2006 = 0 if r8hearte == 0
replace heart_ever_2006 = 1 if r8hearte == 1

tab heart_ever_2006, missing
tab heart_ever_2006 


/*STROKE*/

tab r8stroke, missing

capture drop stroke_ever_2006
gen stroke_ever_2006 = .
replace stroke_ever_2006 = 0 if r8stroke == 0
replace stroke_ever_2006 = 1 if r8stroke == 1

tab stroke_ever_2006, missing
tab stroke_ever_2006 , missing
tab stroke_ever_2006 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2006
gen cardiometcond_2006 = .
replace cardiometcond_2006 = hbp_ever_2006 + diab_ever_2006 + heart_ever_2006 + stroke_ever_2006

tab cardiometcond_2006, missing
tab cardiometcond_2006 , missing
tab cardiometcond_2006 


capture drop cardiometcondbr_2006
gen cardiometcondbr_2006 = .
replace cardiometcondbr_2006 = 1 if cardiometcond_2006 ==0
replace cardiometcondbr_2006 = 2 if (cardiometcond_2006 == 1 | cardiometcond_2006 == 2)
replace cardiometcondbr_2006 = 3 if (cardiometcond_2006 == 3 | cardiometcond_2006 == 4)

tab cardiometcondbr_2006, missing
tab cardiometcondbr_2006 

**2006 CESD**
capture drop cesd_2006
gen cesd_2006=r8cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2006-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 


************************************************2008****************************************************************************************************

**INCOME VARIABLE (2008):

tab h9itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2008
gen totwealth_2008 = .
replace totwealth_2008 = 1 if h9itot < 25000
replace totwealth_2008 = 2 if h9itot >= 25000 & h9itot < 125000
replace totwealth_2008 = 3 if h9itot >= 125000 & h9itot < 300000
replace totwealth_2008 = 4 if h9itot >= 300000 & h9itot < 650000
replace totwealth_2008 = 5 if h9itot >= 650000 & h9itot ~= .


tab totwealth_2008 , missing
tab totwealth_2008 

save, replace

**MARITAL STATUS (2008)**

tab r9mstat, missing

capture drop marital_2008
gen marital_2008 = .
replace marital_2008 = 1 if r9mstat == 8 /*never married*/
replace marital_2008 = 2 if (r9mstat == 1 | r9mstat == 2 | r9mstat == 3) /*married / partnered*/
replace marital_2008 = 3 if (r9mstat == 4 | r9mstat == 5 | r9mstat == 6) /*separated / divorced*/
replace marital_2008 = 4 if (r9mstat == 7) /*widowed*/

tab marital_2008, missing
tab marital_2008

**EMPLOYMENT (2008):

tab r9work, missing

capture drop work_st_2008
gen work_st_2008 = .
replace work_st_2008 = 0 if r9work == 0
replace work_st_2008 = 1 if r9work == 1

tab work_st_2008, missing
tab work_st_2008


**CIGARETTE SMOKING (2008): 
tab r9smokev, missing
tab r9smoken, missing

capture drop smoking_2008
gen smoking_2008 = .
replace smoking_2008 = 1 if r9smokev == 0
replace smoking_2008 = 2 if r9smokev == 1 & r9smoken == 0
replace smoking_2008 = 3 if r9smokev == 1 & r9smoken == 1

tab smoking_2008, missing
tab smoking_2008 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2008* n=173 missing/


tab r10drink, missing
tab r10drinkd, missing


*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2008* n=173 missing/


tab r9drink, missing
tab r9drinkd, missing


capture drop alcohol_2008
gen alcohol_2008 = .
replace alcohol_2008 = 1 if r9drink == 0
replace alcohol_2008 = 2 if r9drink == 1 & r9drinkd == 0
replace alcohol_2008 = 3 if r9drink == 1 & (r9drinkd == 1 | r9drinkd == 2)
replace alcohol_2008 = 4 if r9drink == 1 & (r9drinkd > 3 & r9drinkd ~= . & r9drinkd ~= .d & r9drinkd ~= .m & r9drinkd ~= .r)

tab alcohol_2008, missing


**PHYSICAL ACTIVITY (2008):
tab r9vgactx, missing
tab r9mdactx, missing

capture drop physic_act_2008
gen physic_act_2008 = .
replace physic_act_2008 = 1 if (r9vgactx ==  5 & r9mdactx == 5)
replace physic_act_2008 = 2 if (r9vgactx ==  3 | r9mdactx == 3 | r9vgactx ==  4 | r9mdactx == 4)
replace physic_act_2008 = 3 if (r9vgactx ==  1 | r9mdactx == 1 | r9vgactx ==  2 | r9mdactx == 2)

tab physic_act_2008, missing
tab physic_act_2008


**SELF-RATED HEALTH (2008):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r9shlt, missing

capture drop srh_2008
gen srh_2008 = .
replace srh_2008 = 1 if (r9shlt == 1 | r9shlt == 2 | r9shlt == 3)
replace srh_2008 = 2 if (r9shlt == 4 | r9shlt == 5)

tab srh_2008, missing
tab srh_2008 

save, replace


**WEIGTH STATUS, 2008**
/*body mass index*/

/*2008*/

*<25 
**  25-29.9
**  ≥30


tab r9pmbmi, missing
tab r9bmi, missing
tab r9bmi , missing
tab r9bmi 
su r9bmi ,det


capture drop bmi_2008
gen bmi_2008 = r9pmbmi if r9pmbmi < 100
else replace bmi_2008 = r9bmi if r9bmi < 100

tab bmi_2008, missing
tab bmi_2008 , missing
tab bmi_2008 
su bmi_2008 , det



capture drop bmibr_2008
gen bmibr_2008 = 1 if bmi_2008 < 25
replace bmibr_2008 = 2 if bmi_2008 >= 25 & bmi_2008 < 30
replace bmibr_2008 = 3 if bmi_2008 >= 30 & bmi_2008 ~= .

tab bmibr_2008, missing


/*cardiometabolic risk factors and chronic conditions, 2008*/

/*HYPERTENSION*/

tab r9hibpe, missing

capture drop hbp_ever_2008
gen hbp_ever_2008 = .
replace hbp_ever_2008 = 0 if r9hibpe == 0
replace hbp_ever_2008 = 1 if r9hibpe == 1

tab hbp_ever_2008, missing
tab hbp_ever_2008 


/*DIABETES*/

tab r9diabe, missing

capture drop diab_ever_2008
gen diab_ever_2008 = .
replace diab_ever_2008 = 0 if r9diabe == 0
replace diab_ever_2008 = 1 if r9diabe == 1

tab diab_ever_2008, missing
tab diab_ever_2008 


/*HEART PROBLEMS*/

tab r9hearte, missing

capture drop heart_ever_2008
gen heart_ever_2008 = .
replace heart_ever_2008 = 0 if r9hearte == 0
replace heart_ever_2008 = 1 if r9hearte == 1

tab heart_ever_2008, missing
tab heart_ever_2008 


/*STROKE*/

tab r9stroke, missing

capture drop stroke_ever_2008
gen stroke_ever_2008 = .
replace stroke_ever_2008 = 0 if r9stroke == 0
replace stroke_ever_2008 = 1 if r9stroke == 1

tab stroke_ever_2008, missing
tab stroke_ever_2008 , missing
tab stroke_ever_2008 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2008
gen cardiometcond_2008 = .
replace cardiometcond_2008 = hbp_ever_2008 + diab_ever_2008 + heart_ever_2008 + stroke_ever_2008

tab cardiometcond_2008, missing
tab cardiometcond_2008 , missing
tab cardiometcond_2008 


capture drop cardiometcondbr_2008
gen cardiometcondbr_2008 = .
replace cardiometcondbr_2008 = 1 if cardiometcond_2008 ==0
replace cardiometcondbr_2008 = 2 if (cardiometcond_2008 == 1 | cardiometcond_2008 == 2)
replace cardiometcondbr_2008 = 3 if (cardiometcond_2008 == 3 | cardiometcond_2008 == 4)

tab cardiometcondbr_2008, missing
tab cardiometcondbr_2008 

**2008 CESD**
capture drop cesd_2008
gen cesd_2008=r9cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2008-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 


**********************************************2010***************************************************************


**INCOME VARIABLE (2010):

tab h10itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2010
gen totwealth_2010 = .
replace totwealth_2010 = 1 if h10itot < 25000
replace totwealth_2010 = 2 if h10itot >= 25000 & h10itot < 125000
replace totwealth_2010 = 3 if h10itot >= 125000 & h10itot < 300000
replace totwealth_2010 = 4 if h10itot >= 300000 & h10itot < 650000
replace totwealth_2010 = 5 if h10itot >= 650000 & h10itot ~= .


tab totwealth_2010 , missing
tab totwealth_2010 

save, replace

**MARITAL STATUS (2010)**

tab r10mstat, missing

capture drop marital_2010
gen marital_2010 = .
replace marital_2010 = 1 if r10mstat == 8 /*never married*/
replace marital_2010 = 2 if (r10mstat == 1 | r10mstat == 2 | r10mstat == 3) /*married / partnered*/
replace marital_2010 = 3 if (r10mstat == 4 | r10mstat == 5 | r10mstat == 6) /*separated / divorced*/
replace marital_2010 = 4 if (r10mstat == 7) /*widowed*/

tab marital_2010, missing
tab marital_2010

**EMPLOYMENT (2010):

tab r10work, missing

capture drop work_st_2010
gen work_st_2010 = .
replace work_st_2010 = 0 if r10work == 0
replace work_st_2010 = 1 if r10work == 1

tab work_st_2010, missing
tab work_st_2010


**CIGARETTE SMOKING (2010): 
tab r10smokev, missing
tab r10smoken, missing

capture drop smoking_2010
gen smoking_2010 = .
replace smoking_2010 = 1 if r10smokev == 0
replace smoking_2010 = 2 if r10smokev == 1 & r10smoken == 0
replace smoking_2010 = 3 if r10smokev == 1 & r10smoken == 1

tab smoking_2010, missing
tab smoking_2010 

save, replace


*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2010* n=173 missing/


tab r10drink, missing
tab r10drinkd, missing


capture drop alcohol_2010
gen alcohol_2010 = .
replace alcohol_2010 = 1 if r10drink == 0
replace alcohol_2010 = 2 if r10drink == 1 & r10drinkd == 0
replace alcohol_2010 = 3 if r10drink == 1 & (r10drinkd == 1 | r10drinkd == 2)
replace alcohol_2010 = 4 if r10drink == 1 & (r10drinkd > 3 & r10drinkd ~= . & r10drinkd ~= .d & r10drinkd ~= .m & r10drinkd ~= .r)

tab alcohol_2010, missing


**PHYSICAL ACTIVITY (2010):
tab r10vgactx, missing
tab r10mdactx, missing

capture drop physic_act_2010
gen physic_act_2010 = .
replace physic_act_2010 = 1 if (r10vgactx ==  5 & r10mdactx == 5)
replace physic_act_2010 = 2 if (r10vgactx ==  3 | r10mdactx == 3 | r10vgactx ==  4 | r10mdactx == 4)
replace physic_act_2010 = 3 if (r10vgactx ==  1 | r10mdactx == 1 | r10vgactx ==  2 | r10mdactx == 2)

tab physic_act_2010, missing
tab physic_act_2010


**SELF-RATED HEALTH (2010):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r10shlt, missing

capture drop srh_2010
gen srh_2010 = .
replace srh_2010 = 1 if (r10shlt == 1 | r10shlt == 2 | r10shlt == 3)
replace srh_2010 = 2 if (r10shlt == 4 | r10shlt == 5)

tab srh_2010, missing
tab srh_2010 

save, replace


**WEIGTH STATUS, 2010**
/*body mass index*/

/*2010*/

*<25 
**  25-29.9
**  ≥30


tab r10pmbmi, missing
tab r10bmi, missing
tab r10bmi , missing
tab r10bmi 
su r10bmi ,det


capture drop bmi_2010
gen bmi_2010 = r10pmbmi if r10pmbmi < 100
else replace bmi_2010 = r10bmi if r10bmi < 100

tab bmi_2010, missing
tab bmi_2010 , missing
tab bmi_2010 
su bmi_2010 , det



capture drop bmibr_2010
gen bmibr_2010 = 1 if bmi_2010 < 25
replace bmibr_2010 = 2 if bmi_2010 >= 25 & bmi_2010 < 30
replace bmibr_2010 = 3 if bmi_2010 >= 30 & bmi_2010 ~= .

tab bmibr_2010, missing


/*cardiometabolic risk factors and chronic conditions, 2010*/

/*HYPERTENSION*/

tab r10hibpe, missing

capture drop hbp_ever_2010
gen hbp_ever_2010 = .
replace hbp_ever_2010 = 0 if r10hibpe == 0
replace hbp_ever_2010 = 1 if r10hibpe == 1

tab hbp_ever_2010, missing
tab hbp_ever_2010 


/*DIABETES*/

tab r10diabe, missing

capture drop diab_ever_2010
gen diab_ever_2010 = .
replace diab_ever_2010 = 0 if r10diabe == 0
replace diab_ever_2010 = 1 if r10diabe == 1

tab diab_ever_2010, missing
tab diab_ever_2010 


/*HEART PROBLEMS*/

tab r10hearte, missing

capture drop heart_ever_2010
gen heart_ever_2010 = .
replace heart_ever_2010 = 0 if r10hearte == 0
replace heart_ever_2010 = 1 if r10hearte == 1

tab heart_ever_2010, missing
tab heart_ever_2010 


/*STROKE*/

tab r10stroke, missing

capture drop stroke_ever_2010
gen stroke_ever_2010 = .
replace stroke_ever_2010 = 0 if r10stroke == 0
replace stroke_ever_2010 = 1 if r10stroke == 1

tab stroke_ever_2010, missing
tab stroke_ever_2010 , missing
tab stroke_ever_2010 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2010
gen cardiometcond_2010 = .
replace cardiometcond_2010 = hbp_ever_2010 + diab_ever_2010 + heart_ever_2010 + stroke_ever_2010

tab cardiometcond_2010, missing
tab cardiometcond_2010 , missing
tab cardiometcond_2010 


capture drop cardiometcondbr_2010
gen cardiometcondbr_2010 = .
replace cardiometcondbr_2010 = 1 if cardiometcond_2010 ==0
replace cardiometcondbr_2010 = 2 if (cardiometcond_2010 == 1 | cardiometcond_2010 == 2)
replace cardiometcondbr_2010 = 3 if (cardiometcond_2010 == 3 | cardiometcond_2010 == 4)

tab cardiometcondbr_2010, missing
tab cardiometcondbr_2010 

**2010 CESD**
capture drop cesd_2010
gen cesd_2010=r10cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2010-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 

save,replace


**********************************************2012***************************************************************


**INCOME VARIABLE (2012):

tab h11itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2012
gen totwealth_2012 = .
replace totwealth_2012 = 1 if h11itot < 25000
replace totwealth_2012 = 2 if h11itot >= 25000 & h11itot < 125000
replace totwealth_2012 = 3 if h11itot >= 125000 & h11itot < 300000
replace totwealth_2012 = 4 if h11itot >= 300000 & h11itot < 650000
replace totwealth_2012 = 5 if h11itot >= 650000 & h11itot ~= .


tab totwealth_2012 , missing
tab totwealth_2012 

save, replace

**MARITAL STATUS (2012)**

tab r11mstat, missing

capture drop marital_2012
gen marital_2012 = .
replace marital_2012 = 1 if r11mstat == 8 /*never married*/
replace marital_2012 = 2 if (r11mstat == 1 | r11mstat == 2 | r11mstat == 3) /*married / partnered*/
replace marital_2012 = 3 if (r11mstat == 4 | r11mstat == 5 | r11mstat == 6) /*separated / divorced*/
replace marital_2012 = 4 if (r11mstat == 7) /*widowed*/

tab marital_2012, missing
tab marital_2012

**EMPLOYMENT (2012):

tab r11work, missing

capture drop work_st_2012
gen work_st_2012 = .
replace work_st_2012 = 0 if r11work == 0
replace work_st_2012 = 1 if r11work == 1

tab work_st_2012, missing
tab work_st_2012


**CIGARETTE SMOKING (2012): 
tab r11smokev, missing
tab r11smoken, missing

capture drop smoking_2012
gen smoking_2012 = .
replace smoking_2012 = 1 if r11smokev == 0
replace smoking_2012 = 2 if r11smokev == 1 & r11smoken == 0
replace smoking_2012 = 3 if r11smokev == 1 & r11smoken == 1

tab smoking_2012, missing
tab smoking_2012 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2012* n=173 missing/


tab r11drink, missing
tab r11drinkd, missing


capture drop alcohol_2012
gen alcohol_2012 = .
replace alcohol_2012 = 1 if r11drink == 0
replace alcohol_2012 = 2 if r11drink == 1 & r11drinkd == 0
replace alcohol_2012 = 3 if r11drink == 1 & (r11drinkd == 1 | r11drinkd == 2)
replace alcohol_2012 = 4 if r11drink == 1 & (r11drinkd > 3 & r11drinkd ~= . & r11drinkd ~= .d & r11drinkd ~= .m & r11drinkd ~= .r)

tab alcohol_2012, missing


**PHYSICAL ACTIVITY (2012):
tab r11vgactx, missing
tab r11mdactx, missing

capture drop physic_act_2012
gen physic_act_2012 = .
replace physic_act_2012 = 1 if (r11vgactx ==  5 & r11mdactx == 5)
replace physic_act_2012 = 2 if (r11vgactx ==  3 | r11mdactx == 3 | r11vgactx ==  4 | r11mdactx == 4)
replace physic_act_2012 = 3 if (r11vgactx ==  1 | r11mdactx == 1 | r11vgactx ==  2 | r11mdactx == 2)

tab physic_act_2012, missing
tab physic_act_2012


**SELF-RATED HEALTH (2012):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r11shlt, missing

capture drop srh_2012
gen srh_2012 = .
replace srh_2012 = 1 if (r11shlt == 1 | r11shlt == 2 | r11shlt == 3)
replace srh_2012 = 2 if (r11shlt == 4 | r11shlt == 5)

tab srh_2012, missing
tab srh_2012 

save, replace


**WEIGTH STATUS, 2012**
/*body mass index*/

/*2012*/

*<25 
**  25-29.9
**  ≥30


tab r11pmbmi, missing
tab r11bmi, missing
tab r11bmi , missing
tab r11bmi 
su r11bmi ,det


capture drop bmi_2012
gen bmi_2012 = r11pmbmi if r11pmbmi < 100
else replace bmi_2012 = r11bmi if r11bmi < 100

tab bmi_2012, missing
tab bmi_2012 , missing
tab bmi_2012 
su bmi_2012 , det



capture drop bmibr_2012
gen bmibr_2012 = 1 if bmi_2012 < 25
replace bmibr_2012 = 2 if bmi_2012 >= 25 & bmi_2012 < 30
replace bmibr_2012 = 3 if bmi_2012 >= 30 & bmi_2012 ~= .

tab bmibr_2012, missing


/*cardiometabolic risk factors and chronic conditions, 2012*/

/*HYPERTENSION*/

tab r11hibpe, missing

capture drop hbp_ever_2012
gen hbp_ever_2012 = .
replace hbp_ever_2012 = 0 if r11hibpe == 0
replace hbp_ever_2012 = 1 if r11hibpe == 1

tab hbp_ever_2012, missing
tab hbp_ever_2012 


/*DIABETES*/

tab r11diabe, missing

capture drop diab_ever_2012
gen diab_ever_2012 = .
replace diab_ever_2012 = 0 if r11diabe == 0
replace diab_ever_2012 = 1 if r11diabe == 1

tab diab_ever_2012, missing
tab diab_ever_2012 


/*HEART PROBLEMS*/

tab r11hearte, missing

capture drop heart_ever_2012
gen heart_ever_2012 = .
replace heart_ever_2012 = 0 if r11hearte == 0
replace heart_ever_2012 = 1 if r11hearte == 1

tab heart_ever_2012, missing
tab heart_ever_2012 


/*STROKE*/

tab r11stroke, missing

capture drop stroke_ever_2012
gen stroke_ever_2012 = .
replace stroke_ever_2012 = 0 if r11stroke == 0
replace stroke_ever_2012 = 1 if r11stroke == 1

tab stroke_ever_2012, missing
tab stroke_ever_2012 , missing
tab stroke_ever_2012 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2012
gen cardiometcond_2012 = .
replace cardiometcond_2012 = hbp_ever_2012 + diab_ever_2012 + heart_ever_2012 + stroke_ever_2012

tab cardiometcond_2012, missing
tab cardiometcond_2012 , missing
tab cardiometcond_2012 


capture drop cardiometcondbr_2012
gen cardiometcondbr_2012 = .
replace cardiometcondbr_2012 = 1 if cardiometcond_2012 ==0
replace cardiometcondbr_2012 = 2 if (cardiometcond_2012 == 1 | cardiometcond_2012 == 2)
replace cardiometcondbr_2012 = 3 if (cardiometcond_2012 == 3 | cardiometcond_2012 == 4)

tab cardiometcondbr_2012, missing
tab cardiometcondbr_2012 

**2012 CESD**
capture drop cesd_2012
gen cesd_2012=r11cesd


save, replace




**********************************************2014***************************************************************


**INCOME VARIABLE (2014):

tab h12itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2014
gen totwealth_2014 = .
replace totwealth_2014 = 1 if h12itot < 25000
replace totwealth_2014 = 2 if h12itot >= 25000 & h12itot < 125000
replace totwealth_2014 = 3 if h12itot >= 125000 & h12itot < 300000
replace totwealth_2014 = 4 if h12itot >= 300000 & h12itot < 650000
replace totwealth_2014 = 5 if h12itot >= 650000 & h12itot ~= .


tab totwealth_2014 , missing
tab totwealth_2014 

save, replace

**MARITAL STATUS (2014)**

tab r12mstat, missing

capture drop marital_2014
gen marital_2014 = .
replace marital_2014 = 1 if r12mstat == 8 /*never married*/
replace marital_2014 = 2 if (r12mstat == 1 | r12mstat == 2 | r12mstat == 3) /*married / partnered*/
replace marital_2014 = 3 if (r12mstat == 4 | r12mstat == 5 | r12mstat == 6) /*separated / divorced*/
replace marital_2014 = 4 if (r12mstat == 7) /*widowed*/

tab marital_2014, missing
tab marital_2014

**EMPLOYMENT (2014):

tab r12work, missing

capture drop work_st_2014
gen work_st_2014 = .
replace work_st_2014 = 0 if r12work == 0
replace work_st_2014 = 1 if r12work == 1

tab work_st_2014, missing
tab work_st_2014


**CIGARETTE SMOKING (2014): 
tab r12smokev, missing
tab r12smoken, missing

capture drop smoking_2014
gen smoking_2014 = .
replace smoking_2014 = 1 if r12smokev == 0
replace smoking_2014 = 2 if r12smokev == 1 & r12smoken == 0
replace smoking_2014 = 3 if r12smokev == 1 & r12smoken == 1

tab smoking_2014, missing
tab smoking_2014 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2014* n=173 missing/


tab r12drink, missing
tab r12drinkd, missing


capture drop alcohol_2014
gen alcohol_2014 = .
replace alcohol_2014 = 1 if r12drink == 0
replace alcohol_2014 = 2 if r12drink == 1 & r12drinkd == 0
replace alcohol_2014 = 3 if r12drink == 1 & (r12drinkd == 1 | r12drinkd == 2)
replace alcohol_2014 = 4 if r12drink == 1 & (r12drinkd > 3 & r12drinkd ~= . & r12drinkd ~= .d & r12drinkd ~= .m & r12drinkd ~= .r)

tab alcohol_2014, missing


**PHYSICAL ACTIVITY (2014):
tab r12vgactx, missing
tab r12mdactx, missing

capture drop physic_act_2014
gen physic_act_2014 = .
replace physic_act_2014 = 1 if (r12vgactx ==  5 & r12mdactx == 5)
replace physic_act_2014 = 2 if (r12vgactx ==  3 | r12mdactx == 3 | r12vgactx ==  4 | r12mdactx == 4)
replace physic_act_2014 = 3 if (r12vgactx ==  1 | r12mdactx == 1 | r12vgactx ==  2 | r12mdactx == 2)

tab physic_act_2014, missing
tab physic_act_2014


**SELF-RATED HEALTH (2014):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r12shlt, missing

capture drop srh_2014
gen srh_2014 = .
replace srh_2014 = 1 if (r12shlt == 1 | r12shlt == 2 | r12shlt == 3)
replace srh_2014 = 2 if (r12shlt == 4 | r12shlt == 5)

tab srh_2014, missing
tab srh_2014 

save, replace


**WEIGTH STATUS, 2014**
/*body mass index*/

/*2014*/

*<25 
**  25-29.9
**  ≥30


tab r12pmbmi, missing
tab r12bmi, missing
tab r12bmi , missing
tab r12bmi 
su r12bmi ,det


capture drop bmi_2014
gen bmi_2014 = r12pmbmi if r12pmbmi < 100
else replace bmi_2014 = r12bmi if r12bmi < 100

tab bmi_2014, missing
tab bmi_2014 , missing
tab bmi_2014 
su bmi_2014 , det



capture drop bmibr_2014
gen bmibr_2014 = 1 if bmi_2014 < 25
replace bmibr_2014 = 2 if bmi_2014 >= 25 & bmi_2014 < 30
replace bmibr_2014 = 3 if bmi_2014 >= 30 & bmi_2014 ~= .

tab bmibr_2014, missing


/*cardiometabolic risk factors and chronic conditions, 2014*/

/*HYPERTENSION*/

tab r12hibpe, missing

capture drop hbp_ever_2014
gen hbp_ever_2014 = .
replace hbp_ever_2014 = 0 if r12hibpe == 0
replace hbp_ever_2014 = 1 if r12hibpe == 1

tab hbp_ever_2014, missing
tab hbp_ever_2014 


/*DIABETES*/

tab r12diabe, missing

capture drop diab_ever_2014
gen diab_ever_2014 = .
replace diab_ever_2014 = 0 if r12diabe == 0
replace diab_ever_2014 = 1 if r12diabe == 1

tab diab_ever_2014, missing
tab diab_ever_2014 


/*HEART PROBLEMS*/

tab r12hearte, missing

capture drop heart_ever_2014
gen heart_ever_2014 = .
replace heart_ever_2014 = 0 if r12hearte == 0
replace heart_ever_2014 = 1 if r12hearte == 1

tab heart_ever_2014, missing
tab heart_ever_2014 


/*STROKE*/

tab r12stroke, missing

capture drop stroke_ever_2014
gen stroke_ever_2014 = .
replace stroke_ever_2014 = 0 if r12stroke == 0
replace stroke_ever_2014 = 1 if r12stroke == 1

tab stroke_ever_2014, missing
tab stroke_ever_2014 , missing
tab stroke_ever_2014 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2014
gen cardiometcond_2014 = .
replace cardiometcond_2014 = hbp_ever_2014 + diab_ever_2014 + heart_ever_2014 + stroke_ever_2014

tab cardiometcond_2014, missing
tab cardiometcond_2014 , missing
tab cardiometcond_2014 


capture drop cardiometcondbr_2014
gen cardiometcondbr_2014 = .
replace cardiometcondbr_2014 = 1 if cardiometcond_2014 ==0
replace cardiometcondbr_2014 = 2 if (cardiometcond_2014 == 1 | cardiometcond_2014 == 2)
replace cardiometcondbr_2014 = 3 if (cardiometcond_2014 == 3 | cardiometcond_2014 == 4)

tab cardiometcondbr_2014, missing
tab cardiometcondbr_2014 

**2014 CESD**
capture drop cesd_2014
gen cesd_2014=r12cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2014-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 

save,replace




*****************************************************************************************************************

**STEP 5: GENERATE THE MAIN VARIABLES NEEDED FOR THE ANALYSIS, CHANGE THEIR NAMES FOR EASE OF USE**



**AGE VARIABLES**

su r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e 


**REMAINING COVARIATES**

tab1 SEX RACE_ETHN education  totwealth_2012 marital_2012 work_st_2012 smoking_2012 physic_act_2012 srh_2012  bmibr_2012 cardiometcondbr_2012 cesd_2012

save, replace





**STEP 6: foodinsecurity DATA, 2013**
***2013***

**              storage   display    value
**variable name   type    format     label      variable label
**--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
**HNB1_13         byte    %8.0g                 FOOD DID NOT LAST
**HNB2_13         byte    %8.0g                 CANT AFFORD BALANCED MEALS
**HNB3_13         byte    %8.0g                 CUT OR SKIP MEALS
**HNB4_13         byte    %8.0g                 EAT LESS NOT ENOUGH MONEY
**HNB5_13         byte    %8.0g                 GO HUNGRY NOT ENOUGH MONEY



use DATA_HCNS,clear
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save DATA_HCNSfin, replace



keep HHIDPN HNB1_13 HNB2_13  HNB3_13 HNB4_13 HNB19_13 HNB5_13 
save foodinsecurity_data2013, replace

use foodinsecurity_data2013,clear

tab1 HNB1_13 HNB2_13  HNB3_13 HNB4_13 HNB19_13 HNB5_13 

save foodinsecurity_data2013, replace


**Source: https://www.ers.usda.gov/media/8282/short2012.pdf


**This is what it says
**i.	Responses of “often” or “sometimes” on questions HH3 and HH4, and “yes” on AD1, AD2, and AD3 are coded as affirmative (yes). Responses of “almost every month” and “some months but not every month” on AD1a are coded as affirmative (yes). 
**Note, there is one question that you did not mention that has a skip pattern: (a) “How often did this happen—almost every month, some months but not every month, or in only 1 or 2 months?” which relies on an affirmative response to (b) “In the **last 12 months, since last (name of current month), did (you/you or other adults in your household) ever cut the size of your meals or skip meals because there wasn't enough money for food?”

**So the algorithm/logic would be as follows:
**1.	Convert all character string variable to numeric (1 or 0) based on the above description in (i) for the 6 questions
**2.	If there is an NA or missing value for the skip pattern question for those that responded “No” to question (b) above, it should be converted to 0.
**3.	Take the sum of the six questions
**4.	If sum >= 2, 1, else 0

tab1 HNB1_13 HNB2_13 HNB3_13 HNB4_13 HNB5_13

capture drop HNB1_13r
gen HNB1_13r=.
replace HNB1_13r=HNB1_13
replace HNB1_13r=. if HNB1_13==99
replace HNB1_13r=4 if HNB1_13==3


capture drop HNB2_13r
gen HNB2_13r=.
replace HNB2_13r=HNB2_13
replace HNB2_13r=. if HNB2_13==99
replace HNB2_13r=4 if HNB2_13==3


capture drop HNB3_13r
gen  HNB3_13r=.
replace HNB3_13r=HNB3_13
replace HNB3_13r=4 if HNB3_13==3
replace HNB3_13r=. if HNB3_13==99



capture drop HNB4_13r
gen HNB4_13r=.
replace HNB4_13r=HNB4_13
replace HNB4_13r=. if HNB4_13==99


capture drop HNB5_13r
gen HNB5_13r=.
replace HNB5_13r=HNB5_13
replace HNB5_13r=. if HNB5_13==99


capture drop foodinsecuritymiss
egen  foodinsecuritymiss=rowmiss(HNB1_13r HNB2_13r HNB3_13r HNB3_13r HNB4_13r HNB5_13r)

capture drop foodinsecurity_tot
egen foodinsecurity_tot=anycount(HNB1_13r HNB2_13r HNB3_13r HNB3_13r HNB4_13r HNB5_13r), values(1 2 3)
replace foodinsecurity_tot=. if foodinsecuritymiss>0 

tab foodinsecurity_tot

capture drop foodinsecurity_totbr
gen foodinsecurity_totbr=.
replace foodinsecurity_totbr=1 if foodinsecurity_tot>=2
replace foodinsecurity_totbr=0 if foodinsecurity_tot<2 & foodinsecurity_tot~=.

sort HHIDPN



save, replace


use foodinsecurity_data2013
capture drop _merge
sort HHIDPN
save, replace


merge HHIDPN using  randhrs1992_2018v2_resp_tracker
tab _merge
capture drop _merge
sort HHIDPN

save HRS_PROJECTfoodinsecurityCONGMORT_fin, replace




***********************************************************************************************************

**STEP 7: DEMENTIA PROBABILITY DATA 2006 THROUGH 2012*****

use HRS_PROJECTfoodinsecurityCONGMORT_fin,clear

sort HHIDPN
capture drop _merge

use Dementia_prob2000_2016,clear

destring HHID, replace
destring PN, replace

capture rename HHID-HRS_year,lower
save, replace

capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace


capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN



sort HHIDPN
save, replace

**HRS year 2014**
keep if hrs_year==2014

save Dementia_prob2014, replace


use HRS_PROJECTfoodinsecurityCONGMORT_fin,clear
sort HHIDPN
capture drop _merge
save, replace


merge HHIDPN using Dementia_prob2014

save HRS_PROJECTfoodinsecurityCONGMORT_fin, replace


**NUTRIENTS AND FOODS DATASET**
use HCNS13_R_NT,clear
destring HHID, replace
destring PN, replace


capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

use HRS_PROJECTfoodinsecurityCONGMORT_fin,clear
sort HHIDPN
capture drop _merge
save, replace

merge HHIDPN using HCNS13_R_NT


save HRS_PROJECTfoodinsecurityCONGMORT_finWIDE, replace

capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\FIGURE1.smcl",replace


**STEP 8: DETERMINE SAMPLE WITH COMPLETE DATA ON foodinsecurity IN 2006-2008, DEMENTIA PROBABILITY DATA AT 2012, AND WHERE RESPONDENT'S AGE IS >50 IN 2012**

use "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HRS_PROJECTfoodinsecurityCONGMORT_finWIDE",clear


capture drop sample50plus2012
gen sample50plus2012=.
replace sample50plus2012=1 if r11agey_e>50 & r11agey_e~=.
replace sample50plus2012=0 if sample50plus2012~=1 & r10agey_e~=.

tab sample50plus2012

capture drop samplealivein2014
gen samplealivein2014=.
replace samplealivein2014=1 if inw12==1
replace samplealivein2014=0 if samplealivein2014~=1

tab samplealivein2014




capture drop samplefoodinsecurity2013
gen samplefoodinsecurity2013=.
replace samplefoodinsecurity2013=1 if foodinsecurity_tot~=. 
replace samplefoodinsecurity2013=0 if samplefoodinsecurity2013~=1

tab samplefoodinsecurity2013


capture drop samplefoodnutrients
gen samplefoodnutrients=.
replace samplefoodnutrients=1 if CALOR_SUM~=.
replace samplefoodnutrients=0 if samplefoodnutrients~=1


capture drop sampledementia
gen sampledementia=.
replace sampledementia=1 if hrs_year==2014 & hurd_p!=. & expert_p!=. & lasso_p!=. 
replace sampledementia=0 if sampledementia~=1

tab sampledementia

su AGE2012 if sampledementia==1

save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HRS_PROJECTfoodinsecurityCONGMORT_finWIDE", replace

capture drop sample2
gen sample2=.
replace sample2=1 if sample50plus2012==1 & samplealivein2014==1
replace sample2=0 if sample2~=1

capture drop sample3
gen sample3=.
replace sample3=1 if sample50plus2012==1 & samplealivein2014==1 & samplefoodinsecurity2013==1 & samplefoodnutrients==1
replace sample3=0 if sample3~=1


capture drop sample4
gen sample4=.
replace sample4=1 if sample50plus2012==1 & samplealivein2014==1 & samplefoodinsecurity2013==1 & samplefoodnutrients==1 & sampledementia==1
replace sample4=0 if sample4~=1


capture drop sample_final
gen sample_final=.
replace sample_final=1 if sample50plus2012==1 & samplealivein2014==1 & samplefoodinsecurity2013==1 & sampledementia==1 & HCNSWGTR_NT~=. & samplefoodnutrients==1 
replace sample_final=0 if sample_final~=1

tab sample_final

su AGE2012 if sample_final==1




save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HRS_PROJECTfoodinsecurityCONGMORT_finWIDE", replace


**STEP 9: MORTALITY VARIABLES FROM 2008 THROUGH 2020: TRACKER FILE INW**

**dead vs. alive: 2014-2020

capture drop died
gen died=.
replace died=1 if (sample_final==1 & knowndeceasedyr~=. & knowndeceasedmo~=.)
replace died=0 if died!=1 & sample_final==1

tab died if sample_final==1


**Date of death: dod**

su knowndeceasedmo knowndeceasedyr if sample_final==1
tab1 knowndeceasedmo knowndeceasedyr if sample_final==1

capture drop deathmonth
gen deathmonth=knowndeceasedmo if knowndeceasedmo~=98

capture drop deathyear
gen deathyear=knowndeceasedyr

capture drop deathday
gen deathday=14

capture drop dod
gen dod=mdy(deathmonth, deathday, deathyear)

**Date of entry: doenter**
capture drop doenter
gen doenter=mdy(01,01,2014)

**Date of exit if still alive: doexit**
capture drop doexit
gen doexit=mdy(12,31,2020) 

**Date of exit for censor or dead**
capture drop doevent
gen doevent=.
replace doevent=dod if died==1 & sample_final==1
replace doevent=doexit if died==0 & sample_final==1

su doevent

***Estimated birth date**

capture drop dob
gen dob=mdy(birthmo,14,birthyr)



capture drop ageevent
gen ageevent=(doevent-dob)/365.5

capture drop ageenter
gen ageenter=r12agey_e

save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HRS_PROJECTfoodinsecurityCONGMORT_finWIDE", replace

**STEP 10: STSET FOR MORTALITY OUTCOME***

capture drop AGE2014
gen AGE2014=ageenter

save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HRS_PROJECTfoodinsecurityCONGMORT_finWIDE", replace

stset ageevent if sample_final==1, failure(died==1) enter(AGE2014) origin(AGE2014) scale(1)


stdescribe if sample_final==1
stsum if sample_final==1
strate if sample_final==1

save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HRS_PROJECTfoodinsecurityCONGMORT_finWIDE", replace

capture log close

capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\HEI2015.smcl",replace

************************************************HEI 2015********************

**STEP A: RUN STATA SCRIPTS FOR LEGUMES:

use "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HCNS13_R_NT",clear
save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HEI2015", replace


**STEP A: RUN STATA SCRIPTS FOR LEGUMES:

capture drop m_mpf m_egg m_nutsd m_soy m_fish_hi m_fish_lo legumes kcal v_total v_drkgr 
  
gen m_mpf=C6D_FF_13+C6E_FF_13+C6F_FF_13+C6G_FF_13+C6H_FF_13+C6I_FF_13+C6J_FF_13+C6K_FF_13+C6L_FF_13+C6M_FF_13+C6N_FF_13+C6O_FF_13+C6P_FF_13+C6R_FF_13+C6S_FF_13+C6T_FF_13+C6U_FF_13+C6V_FF_13+C6W_FF_13+C6Q_FF_13
gen m_egg=C6A_FF_13+C6B_FF_13+C6C_FF_13
gen m_nutsd=C9V_FF_13+C9W_FF_13+C9X_FF_13+C9F_FF_13 
gen m_soy=C5E_FF_13+C3D_FF_13
gen m_fish_hi=C6V_FF_13+C6S_FF_13
gen m_fish_lo=C6T_FF_13+C6U_FF_13+C6W_FF_13
gen legumes=C5N_FF_13+C5P_FF_13 
gen kcal=CALOR_SUM
gen v_total = C5A_FF_13+C5B_FF_13+C5C_FF_13+C5D_FF_13+ C5F_FF_13+C5G_FF_13+C5H_FF_13+C5I_FF_13+C5J_FF_13+C5K_FF_13+C5L_FF_13+C5M_FF_13+C5N_FF_13+C5O_FF_13+C5P_FF_13+C5Q_FF_13+C5R_FF_13+ C5S_FF_13+C5T_FF_13+C5U_FF_13+C5V_FF_13+C5W_FF_13+C5X_FF_13+C5Y_FF_13+C5Z_FF_13+C5AA_FF_13+C5AB_FF_13 
gen v_drkgr=C5T_FF_13+C5U_FF_13+C5V_FF_13
 



**pf_mps_total: m_mpf
**pf_eggs: m_egg 
**pf_nutsds: m_nutsd
*pf_soy: m_soy

/* This program calculates legumes that get counted as meat and those that get
counted as veggies*/
/** This macro gets called into the program that calculates HEI 2015 scores**/

capture drop allmeat 
capture drop seaplant
capture drop mbmax
capture drop meatleg
capture drop legume_added_*
capture drop meatveg
capture drop extrmeat
capture drop extrleg


gen allmeat=m_mpf+m_egg+m_nutsd+m_soy
gen seaplant=m_fish_hi+m_fish_lo+m_nutsd + m_soy
gen mbmax=2.5*(kcal/1000)
gen needmeat=mbmax-allmeat if allmeat<mbmax
gen meatleg=4*legumes
/*Needs more meat, and all beans go to meat*/
gen all2meat=1 if meatleg<=needmeat /*folks who don't meet meat max and the amount
of legumes they consume is less than the amount they need to reach mbmax*/
foreach var in allmeat seaplant {
gen legume_added_`var'=`var'+meatleg if all2meat==1
}
foreach var in v_total v_drkgr {
gen legume_added_`var'=`var' if all2meat==1
}
/*Needs more meat, and some beans go to meat, some go to veggies*/
gen meatveg=1 if meatleg>needmeat
gen extrmeat=meatleg-needmeat
gen extrleg=extrmeat/4
foreach var in allmeat seaplant {
replace legume_added_`var'=`var'+needmeat if meatveg==1 /*folks who don't meet
meat max and the amount of legumes they consume is more than the amount they need
to reach mbmax--rest go to veggies*/
}
foreach var in v_total v_drkgr {
replace legume_added_`var'=`var'+extrleg if meatveg==1
}
gen all2veg=1 if allmeat>=mbmax /*Folks who meet the meat requirement so all
legumes count as veggies*/
foreach var in allmeat seaplant {
replace legume_added_`var'=`var' if all2veg==1
}
foreach var in v_total v_drkgr {
replace legume_added_`var'=`var'+legumes if all2veg==1
}

save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HEI2015", replace


**STEP B: RUN STATA SCRIPT FOR HEI-2015


use "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HEI2015", clear

capture drop monofat 
capture drop polyfat 
capture drop add_sug 
capture drop discfat_sol 
capture drop alcohol 
capture drop f_total 
capture drop frtjuice 
capture drop wholefrt 
capture drop g_whl 
capture drop d_total 
capture drop Satfat 
capture drop sodi 
capture drop g_nwhl 
capture drop sfat 

gen monofat=MONFAT_SUM
gen polyfat=POLY_SUM
gen add_sug=C9AH_FF_13 
gen discfat_sol=ADDFAT_SOL_SUM
gen alcohol=ALCO_SUM
gen f_total= C4A_FF_13+C4B_FF_13+C4C_FF_13+C4D_FF_13+C4E_FF_13+C4F_FF_13+C4G_FF_13+C4H_FF_13+C4I_FF_13+C4J_FF_13+C4K_FF_13+C4L_FF_13+C4M_FF_13+C4N_FF_13+C4O_FF_13+C4P_FF_13+C4Q_FF_13+C4R_FF_13+ C4S_FF_13+C4C_FF_13 
gen frtjuice=C4I_FF_13+C4K_FF_13+C4L_FF_13+C4N_FF_13+C4O_FF_13
gen wholefrt=f_total-frtjuice
gen g_whl=C7B_FF_13+C7F_FF_13+C7G_FF_13+C7J_FF_13+C7SA_FF_13+C9AB_FF_13+C9AC_FF_13+C9AD_FF_13+C9G_FF_13+C9H_FF_13 
gen d_total= C3A_FF_13+C3B_FF_13+C3C_FF_13 + C3E_FF_13+C3G_FF_13+C3H_FF_13+C3I_FF_13+C3J_FF_13+C3L_FF_13+ C3M_FF_13+C3N_FF_13+C3D_FF_13 
gen Satfat=SATFAT_SUM 
gen sodi=SODIUM_SUM
gen g_nwhl=C7A_FF_13+C7C_FF_13+C7E_FF_13+C7H_FF_13+C7I_FF_13+C7K_FF_13+C7L_FF_13+C7M_FF_13+C7N_FF_13+C7O_FF_13+C7SB_FF_13+C7T_FF_13+C9J_FF_13+C9K_FF_13+C9L_FF_13+C9M_FF_13+C9N_FF_13+C9O_FF_13+C9P_FF_13+C9Q_FF_13+C9R_FF_13+C9S_FF_13+C9T_FF_13+C9U_FF_13+C9Y_FF_13+C9Z_FF_13+C9AA_FF_13
gen sfat=SATFAT_SUM 
gen SatFat=SATFAT_SUM

save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HEI2015", replace

capture drop monopoly
capture drop addsugc
capture drop solfatc
capture drop maxalcgr
capture drop ethcal
capture drop exalccal
capture drop emptycal10
capture drop vegden
capture drop hei*
capture drop grbnden
capture drop frtden
capture drop wholefrt
capture drop whfrden
capture drop wgrnden
capture drop monopoly
capture drop farmin
capture drop farmax
capture drop sodden
capture drop sodmin
capture drop sodmax
capture drop rgden
capture drop rgmin
capture drop rgmax
capture drop sofa*
capture drop addedsugar_perc 
capture drop addsugmin 
capture dorp addsugmax 
capture drop heix12_addedsugar
capture drop saturatedfat_perc 
capture drop saturatedfatmin 
capture drop saturatedfatmax 
capture drop heix13_saturatedfat



/*This do file creates HEI-2015 component densities and scores*/
gen monopoly=monofat+polyfat
gen addsugc=16*add_sug
gen solfatc=9*discfat_sol
gen maxalcgr=13*(kcal/1000)
gen ethcal=7*alcohol
gen exalccal=7*(alcohol-maxalcgr)
replace exalccal=0 if alcohol<=maxalcgr
gen emptycal10=addsugc+solfatc+exalccal
gen vegden=legume_added_v_total/(kcal/1000)
gen heix1_totalveg=5*(vegden/1.1)
replace heix1_totalveg=5 if heix1_totalveg>5
replace heix1_totalveg=0 if heix1_totalveg<0
gen grbnden=legume_added_v_drkgr/(kcal/1000)
gen heix2_greens_and_bean=5*(grbnden/.2)
replace heix2_greens_and_bean=5 if heix2_greens_and_bean>5
replace heix2_greens_and_bean=0 if heix2_greens_and_bean<0
gen frtden=f_total/(kcal/1000)
gen heix3_totalfruit=5*(frtden/.8)
replace heix3_totalfruit=5 if heix3_totalfruit>5
replace heix3_totalfruit=0 if heix3_totalfruit<0
gen wholefrt=f_total-frtjuice
gen whfrden=wholefrt/(kcal/1000)
gen heix4_wholefruit=5*(whfrden/.4)
replace heix4_wholefruit=5 if heix4_wholefruit>5
replace heix4_wholefruit=0 if heix4_wholefruit<0
gen wgrnden=g_whl/(kcal/1000)
gen heix5_wholegrain=10*(wgrnden/1.5)
replace heix5_wholegrain=10 if heix5_wholegrain>10
replace heix5_wholegrain=0 if heix5_wholegrain<0
gen dairyden=d_total/(kcal/1000)
gen heix6_totaldairy=10*(dairyden/1.3)
replace heix6_totaldairy=10 if heix6_totaldairy>10
replace heix6_totaldairy=0 if heix6_totaldairy<0
gen meatden=legume_added_allmeat/(kcal/1000)
gen heix7_totprot=5*(meatden/2.5)
replace heix7_totprot=5 if heix7_totprot>5
replace heix7_totprot=0 if heix7_totprot<0
gen seaplden=legume_added_seaplant/(kcal/1000)
gen heix8_seaplant_prot=5*(seaplden/.8)
replace heix8_seaplant_prot=5 if heix8_seaplant_prot>5
replace heix8_seaplant_prot=0 if heix8_seaplant_prot<0
gen faratio=monopoly/SatFat if SatFat>0




gen farmin=1.2
gen farmax=2.5
gen heix9_fattyacid=0 if SatFat==0 & monopoly==0
replace heix9_fattyacid=10 if SatFat==0 & monopoly>0
replace heix9_fattyacid=10 if faratio>=farmax & faratio !=.
replace heix9_fattyacid=0 if faratio<=farmin & faratio !=.
replace heix9_fattyacid=10*((faratio-farmin)/(farmax-farmin)) if faratio !=.
gen sodden=sodi/kcal
gen sodmin=1.1
gen sodmax=2
gen heix10_sodium=10
replace heix10_sodium=0 if sodden>=sodmax
replace heix10_sodium=10-(10*(sodden-sodmin)/(sodmax-sodmin))
gen rgden=g_nwhl/(kcal/1000)
gen rgmin=1.8
gen rgmax=4.3
gen heix11_refinedgrain=10
replace heix11_refinedgrain=0 if rgden>=rgmax
replace heix11_refinedgrain=10-(10*(rgden-rgmin)/(rgmax-rgmin))


gen addedsugar_perc=100*add_sug*16/kcal
gen addsugmin=6.5
gen addsugmax=26
gen heix12_addedsugar=0 if addedsugar_perc>=addsugmax
replace heix12_addedsugar=10 if addedsugar_perc<=addsugmin
replace heix12_addedsugar=10-(10*(addedsugar_perc-addsugmin)/(addsugmax-addsugmin))



gen saturatedfat_perc=100*sfat*9/kcal
gen saturatedfatmin=7
gen saturatedfatmax=15
gen heix13_saturatedfat=0 if saturatedfat_perc>=saturatedfatmax
replace heix13_saturatedfat=10 if saturatedfat_perc<=saturatedfatmin
replace heix13_saturatedfat=10-(10*(saturatedfat_perc-saturatedfatmin)/(saturatedfatmax-saturatedfatmin))


foreach var in vegden grbnden frtden whfrden wgrnden dairyden meatden seaplden faratio sodden rgden {
replace `var'=0 if `var'==.
}




foreach var in 1_totalveg 2_greens_and_bean 3_totalfruit 4_wholefruit 5_wholegrain 6_totaldairy 7_totprot 8_seaplant 9_fattyacid 10_sodium 11_refinedgrain 12_addedsugar 13_saturatedfat {
replace heix`var'=0 if kcal==0
}
foreach var in 1_totalveg 2_greens_and_bean 3_totalfruit 4_wholefruit 5_wholegrain 6_totaldairy 7_totprot 8_seaplant 9_fattyacid 10_sodium 11_refinedgrain 12_addedsugar 13_saturatedfat {
replace heix`var'=0 if heix`var'<0 & heix`var'!=.
}
foreach var in 9_fattyacid 10_sodium 11_refinedgrain {
replace heix`var'=10 if heix`var'>10 & heix`var'!=.
}
replace heix12_addedsugar=10 if heix12_addedsugar>10 & heix12_addedsugar!=.
replace heix13_saturatedfat=10 if heix13_saturatedfat>10 & heix13_saturatedfat!=.


gen hei2015_total_score=heix1_totalveg+heix2_greens_and_bean+heix3_totalfruit+ ///
heix4_wholefruit+heix5_wholegrain+heix6_totaldairy+heix7_totprot+heix8_seaplant ///
+heix9_fattyacid+heix10_sodium+heix11_refinedgrain+heix12_addedsugar+heix13_saturatedfat



label var hei2015_total_score "total hei-2015 score"
label var heix1_totalveg "hei-2015 component 1 total vegetables"
label var heix2_greens_and_bean "hei-2015 component 2 greens and beans"
label var heix3_totalfruit "hei-2015 component 3 total fruit"
label var heix4_wholefruit "hei-2015 component 4 whole fruit"
label var heix5_wholegrain "hei-2015 component 5 whole grains"
label var heix6_totaldairy "hei-2015 component 6 dairy"
label var heix7_totprot "hei-2015 component 7 total protein foods"

label var heix8_seaplant_prot "hei-2015 component 8 seafood and plant protein"
label var heix9_fattyacid "hei-2015 component 9 fatty acid ratio"
label var heix10_sodium "hei-2015 component 10 sodium"
label var heix11_refinedgrain "hei-2015 component 11 refined grains"
label var heix12_addedsugar "hei-2015 component 12 added sugar"
label var heix13_saturatedfat "hei-2015 component 13 saturated fat"

label var vegden "density of mped total vegetables per 1000 kcal"
label var grbnden "density of mped of dark green veg and beans per 1000 kcal"
label var frtden "density of mped total fruit per 1000 kcal"
label var whfrden "density of mped whole fruit per 1000 kcal"
label var wgrnden "density of mped of whole grain per 1000 kcal"
label var dairyden "density of mped of dairy per 1000 kcal"
label var meatden "density of mped total meat/protein per 1000 kcal"
label var seaplden "denstiy of mped of seafood and plant protein per 1000 kcal"
label var faratio "fatty acid ratio"
label var sodden "density of sodium per 1000 kcal"
label var rgden "density of mped of refined grains per 1000 kcal"
label var addedsugar_perc "percent of calories from added sugar"
label var saturatedfat_perc "percent of calories from saturated fat"

save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HEI2015", replace

keep HHID PN hei* vegden grbnden frtden whfrden dairyden meatden seaplden faratio sodden rgden addedsugar_perc saturatedfat_perc-saturatedfat_perc 

destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

su hei*


save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HEI2015_small", replace

use "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HRS_PROJECTfoodinsecurityCONGMORT_finWIDE",clear
capture drop _merge
sort HHIDPN
merge HHIDPN using "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HEI2015_small"
tab _merge
capture drop _merge
save "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA\HRS_PROJECTfoodinsecurityCONGMORT_finWIDE", replace






capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\IMPUTATION.smcl",replace


**STEP 12: MULTIPLE IMPUTATION FOR COVARIATES: MARCH 14TH: USE THE AD PGS PAPER********************** 

**//RUN IMPUTATIONS FOR 2006 COVARIATE DATA: 


**DESIGN VARIABLES**
**svyset secu [pweight=HCNSWGTR_NT], strata(stratum) 

**SAMPLING VARIABLES**
**sample*

**OUTCOME AND OTHER RELATED VARIABLES**
**died  doexit doevent doenter dob _t _st _d _t0 

**EXPOSURE AND MEDIATOR VARIABLES**
**poorsleep_2006  hurd_p hurd_dem expert_p expert_dem lasso_p lasso_dem 

**Year variable and age variables**
**hrs_year r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e 


**COVARIATES USED FOR OR REQUIRING IMPUTATION:
**marital_2012 education work_st_2012 totwealth_2012 smoking_2012 alcohol_2012 physic_act_2012 bmi_2012 hbp_ever_2012 diab_ever_2012 heart_ever_2012 stroke_ever_2012 srh_2012 cesd_2012

**OTHER COVARIATES:
**AGE2012 SEX RACE ETHNICITY RACE_ETHN

**--> re-compute categorical BMI and cardiometabolic risk variables after imputation

use HRS_PROJECTfoodinsecurityCONGMORT_finWIDE,clear

capture drop AGE2012
gen AGE2012=r11agey_e

save, replace

keep HHIDPN HHID hhid pn mwgtr nwgtr owgtr stratum secu sample* died  doexit doevent doenter dob _t _st _d _t0  foodinsecurity_tot foodinsecurity_totbr  hurd_p hurd_dem expert_p expert_dem lasso_p lasso_dem hrs_year AGE2012 AGE2014 SEX RACE ETHNICITY RACE_ETHN marital_2012 education work_st_2012 totwealth_2012 smoking_2012 alcohol_2012 physic_act_2012 bmi_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 heart_ever_2012 stroke_ever_2012 cardiometcond_2012 cardiometcondbr_2012 srh_2012 cesd_2012  r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e ageevent ageenter AGE-C16BM3_FF_13 hei* vegden grbnden frtden whfrden dairyden meatden seaplden faratio sodden rgden addedsugar_perc saturatedfat_perc-saturatedfat_perc


save finaldata_unimputed, replace

sort HHIDPN 

save, replace

set matsize 11000

capture mi set, clear

mi set flong

capture mi svyset, clear

mi svyset secu [pweight=HCNSWGTR_NT], strata(stratum) vce(linearized) singleunit(missing)

mi stset ageevent if sample_final==1, failure(died==1) enter(AGE2014) origin(AGE2014) scale(1)


mi unregister HHIDPN HHID hhid pn mwgtr nwgtr owgtr stratum secu sample* died  doexit doevent doenter dob _t _st _d _t0 foodinsecurity_tot foodinsecurity_totbr  hurd_p hurd_dem expert_p expert_dem lasso_p lasso_dem hrs_year AGE2012 AGE2014 SEX RACE ETHNICITY RACE_ETHN marital_2012 education work_st_2012 totwealth_2012 smoking_2012 alcohol_2012 physic_act_2012 bmi_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 heart_ever_2012 stroke_ever_2012 cardiometcond_2012 cardiometcondbr_2012 srh_2012 cesd_2012  r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e ageevent ageenter AGE-C16BM3_FF_13


mi register imputed  marital_2012 education work_st_2012 totwealth_2012 smoking_2012 alcohol_2012 physic_act_2012 bmi_2012 hbp_ever_2012 diab_ever_2012 heart_ever_2012 stroke_ever_2012 srh_2012 cesd_2012

mi register passive foodinsecurity_tot foodinsecurity_totbr hurd_p hurd_dem expert_p expert_dem lasso_p lasso_dem hrs_year 

tab1 marital_2012 education work_st_2012 totwealth_2012 smoking_2012 physic_act_2012 bmi_2012 hbp_ever_2012 diab_ever_2012 heart_ever_2012 stroke_ever_2012 srh_2012

mi impute chained (mlogit) marital_2012 education work_st_2012  totwealth_2012 smoking_2012 alcohol_2012 physic_act_2012 hbp_ever_2012 diab_ever_2012 heart_ever_2012 stroke_ever_2012 srh_2012 (regress) bmi_2012 cesd_2012 = AGE2012 SEX i.RACE_ETHN  if AGE2012>=50 , force augment noisily  add(5) rseed(1234) savetrace(tracefile, replace) 



save finaldata_imputed, replace

sort HHIDPN


capture drop male
mi passive: gen male=.
mi passive: replace male=1 if SEX==1 & sample_final==1
mi passive: replace male=0 if SEX==2 & sample_final==1

capture drop female
mi passive: gen female=.
mi passive: replace female=1 if SEX==2 & sample_final==1
mi passive: replace female=0 if SEX==1 & sample_final==1



capture drop cardiometcond_2012
mi passive: gen cardiometcond_2012 = .
mi passive: replace cardiometcond_2012 = hbp_ever_2012 + diab_ever_2012 + heart_ever_2012 + stroke_ever_2012


capture drop bmibr_2012
mi passive: gen bmibr_2012 = 1 if bmi_2012 < 25
mi passive: replace bmibr_2012 = 2 if bmi_2012 >= 25 & bmi_2012 < 30
mi passive: replace bmibr_2012 = 3 if bmi_2012 >= 30 & bmi_2012 ~= .


capture drop NonWhite
mi passive: gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passive: replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1

save finaldata_imputed_FINAL, replace


capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\TABLE1.smcl",replace



**STEP 13: DESCRIPTIVE TABLE BY SEX AND RACE/ETHNICITY, WITHOUT TAKING INTO ACCOUNT SAMPLING DESIGN COMPLEXITY, ON UNIMPUTED DATA***

use finaldata_imputed_FINAL,clear

***********UNIMPUTED DATA ANALYSIS***************************************
mi extract 0

save finaldata_unimputed_FINAL, replace

su AGE2012 if sample_final==1 

tab1 SEX RACE_ETHN education  totwealth_2012 marital_2012 work_st_2012 smoking_2012 alcohol_2012 physic_act_2012 srh_2012  bmibr_2012 cardiometcondbr_2012 if sample_final==1 

reg AGE2012 i.SEX if sample_final==1 
reg hei2015_total_score SEX if sample_final==1
tab SEX RACE_ETHN if sample_final==1 , row col chi
tab SEX education if sample_final==1 , row col chi
tab SEX totwealth_2012 if sample_final==1 , row col chi
tab SEX marital_2012 if sample_final==1 , row col chi
tab SEX work_st_2012 if sample_final==1 , row col chi
tab SEX smoking_2012 if sample_final==1 , row col chi
tab SEX physic_act_2012 if sample_final==1 , row col chi
tab SEX srh_2012 if sample_final==1, row col chi
tab SEX bmibr_2012 if sample_final==1, row col chi
tab SEX cardiometcondbr_2012 if sample_final==1, row col chi
tab SEX foodinsecurity_totbr if sample_final==1, row col chi

reg AGE2012 i.RACE_ETHN if sample_final==1
reg cesd_2012 i.RACE_ETHN if sample_final==1
tab RACE_ETHN SEX if sample_final==1, row col chi
reg hei2015_total_score i.RACE_ETHN if sample_final==1

**TAKE INTO ACCOUNT SAMPLING DESIGN COMPLEXITY, ON IMPUTED DATA*** 
use finaldata_imputed_FINAL,clear

mi xeq 1: svydescribe if sample_final==1
keep if stratum~=53

save, replace

mi svyset secu [pweight=HCNSWGTR_NT], strata(stratum)
 
foreach x1 of varlist SEX RACE_ETHN NonWhite education  totwealth_2012 marital_2012 work_st_2012 smoking_2012 alcohol_2012 physic_act_2012 srh_2012  bmibr_2012 cardiometcondbr_2012 hurd_dem expert_dem lasso_dem foodinsecurity_totbr {
	mi estimate: svy, subpop(sample_final): prop `x1'
}
 

foreach x2 of varlist AGE2012 cesd_2012 foodinsecurity_tot  hurd_p expert_p  lasso_p hei2015_total_score {
	mi estimate: svy, subpop(sample_final): mean `x2'
}


mi xeq 0: strate if sample_final==1  

capture drop Men
mi passive: gen Men=1 if SEX==1 & sample_final==1
mi passive: replace Men=0 if Men~=1 & SEX~=. & sample_final==1

capture drop Women
mi passive: gen Women=1 if SEX==2 & sample_final==1
mi passive: replace Women=0 if Women~=1 & SEX~=. & sample_final==1

capture drop NHW
mi passive: gen NHW=1 if RACE_ETHN==1 & sample_final==1
mi passive: replace NHW=0 if NHW~=1 & RACE_ETHN~=. & sample_final==1

capture drop NHB
mi passive: gen NHB=1 if RACE_ETHN==2 & sample_final==1
mi passive: replace NHB=0 if NHB~=1 & RACE_ETHN~=. & sample_final==1


capture drop HISP
mi passive: gen HISP=1 if RACE_ETHN==3 & sample_final==1
mi passive: replace HISP=0 if HISP~=1 & RACE_ETHN~=. & sample_final==1 


capture drop OTHER
mi passive: gen OTHER=1 if RACE_ETHN==4 & sample_final==1
mi passive: replace OTHER=0 if OTHER~=1 & RACE_ETHN~=. & sample_final==1


capture drop NonWhite
mi passive: gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passive: replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1


save, replace



**************STRATIFIED ANALYSIS***************************

**Men**

foreach x1 of varlist SEX RACE_ETHN NonWhite education  totwealth_2012 marital_2012 work_st_2012 smoking_2012 alcohol_2012 physic_act_2012 srh_2012  bmibr_2012 cardiometcondbr_2012 hurd_dem expert_dem lasso_dem foodinsecurity_totbr {
	mi estimate: svy, subpop(Men): prop `x1' 
}
 

foreach x2 of varlist AGE2012 cesd_2012 foodinsecurity_tot  hurd_p expert_p  lasso_p hei2015_total_score {
	mi estimate: svy, subpop(Men): mean `x2'
}


mi xeq 0: strate if Men==1  

**Women**


foreach x1 of varlist SEX RACE_ETHN NonWhite education  totwealth_2012 marital_2012 work_st_2012 smoking_2012 alcohol_2012 physic_act_2012 srh_2012  bmibr_2012 cardiometcondbr_2012 hurd_dem expert_dem lasso_dem foodinsecurity_totbr {
	mi estimate: svy, subpop(Women): prop `x1' 
}
 

foreach x2 of varlist AGE2012 cesd_2012 foodinsecurity_tot  hurd_p expert_p  lasso_p hei2015_total_score {
	mi estimate: svy, subpop(Women): mean `x2'
}


mi xeq 0: strate  if Women==1


**NHW**

foreach x1 of varlist SEX education  totwealth_2012 marital_2012 work_st_2012 smoking_2012 alcohol_2012 physic_act_2012 srh_2012  bmibr_2012 cardiometcondbr_2012 hurd_dem expert_dem lasso_dem foodinsecurity_totbr {
	mi estimate: svy, subpop(NHW): prop `x1' 
}
 

foreach x2 of varlist AGE2012 cesd_2012 foodinsecurity_tot  hurd_p expert_p  lasso_p hei2015_total_score {
	mi estimate: svy, subpop(NHW): mean `x2'
}


mi xeq 0: strate if NHW==1 


**NonWhite**

foreach x1 of varlist SEX  education  totwealth_2012 marital_2012 work_st_2012 smoking_2012 alcohol_2012 physic_act_2012 srh_2012  bmibr_2012 cardiometcondbr_2012 hurd_dem expert_dem lasso_dem foodinsecurity_totbr {
	mi estimate: svy, subpop(NonWhite): prop `x1' 
}
 

foreach x2 of varlist AGE2012 cesd_2012 foodinsecurity_tot  hurd_p expert_p  lasso_p hei2015_total_score {
	mi estimate: svy, subpop(NonWhite): mean `x2'
}


mi xeq 0: strate  if NonWhite==1


save, replace


************************DIFFERENCES BY SEX AND BY RACE**************************

foreach x1 of varlist RACE_ETHN NonWhite education  totwealth_2012 marital_2012 work_st_2012 smoking_2012 alcohol_2012 physic_act_2012 srh_2012  bmibr_2012 cardiometcondbr_2012 hurd_dem expert_dem lasso_dem  {
	mi estimate: svy, subpop(sample_final): mlogit `x1' SEX
}

 
foreach x1 of varlist SEX education totwealth_2012  marital_2012 work_st_2012 smoking_2012 alcohol_2012 physic_act_2012 srh_2012  bmibr_2012 cardiometcondbr_2012 hurd_dem expert_dem lasso_dem foodinsecurity_totbr {
	mi estimate: svy, subpop(sample_final): mlogit `x1' NonWhite
}


foreach x2 of varlist AGE2012 cesd_2012 foodinsecurity_tot  hurd_p expert_p  lasso_p hei2015_total_score {
	mi estimate: svy, subpop(sample_final): reg `x2' SEX
}


foreach x2 of varlist totwealth_2012 AGE2012 cesd_2012 foodinsecurity_tot  hurd_p expert_p  lasso_p hei2015_total_score {
	mi estimate: svy, subpop(sample_final): reg `x2' NonWhite
}


save, replace



capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\FIGURE2_3.smcl",replace

use finaldata_imputed_FINAL,clear


**STEP 14: FIGURE 2: COMPARE SURVIVAL PROBABILITIES ACROSS EXPOSURE (foodinsecurity_tot, create tertiles) AND MEDIATOR LEVELS (hurd_dem expert_dem lasso_dem)**

mi extract 0

save finaldata_unimputed_FINAL, replace


stset ageevent if sample_final==1, failure(died==1) enter(AGE2012) origin(AGE2012) scale(1)


stdescribe if sample_final==1
stsum if sample_final==1
strate if sample_final==1

save, replace


bysort foodinsecurity_totbr: su foodinsecurity_tot if sample_final==1,detail

save, replace

sts test foodinsecurity_totbr if sample_final==1, logrank
sts graph if sample_final==1, by(foodinsecurity_totbr) 

graph save "FIGURE2A.gph", replace

sts test hurd_dem if sample_final==1, logrank
sts graph if sample_final==1, by(hurd_dem) 


graph save "FIGURE2B.gph", replace


sts test expert_dem if sample_final==1, logrank
sts graph if sample_final==1, by(expert_dem) 


graph save "FIGURE2C.gph", replace


sts test lasso_dem if sample_final==1, logrank
sts graph if sample_final==1, by(lasso_dem) 


graph save "FIGURE2D.gph", replace

graph combine "FIGURE2A.gph" "FIGURE2B.gph" "FIGURE2C.gph" "FIGURE2D.gph"
graph save "FIGURE2.gph", replace


capture drop HEI2015_group
gen HEI2015_group=.
replace HEI2015_group=1 if hei2015_total_score<51  & hei2015_total_score~=.
replace HEI2015_group=2 if hei2015_total_score>=51  & hei2015_total_score<81
replace HEI2015_group=3 if hei2015_total_score>=81  & hei2015_total_score~=.

bysort HEI2015_group: su hei2015_total_score

sts test HEI2015_group if sample_final==1, logrank
sts graph if sample_final==1, by(HEI2015_group) 


capture drop HEI2015_tert
xtile HEI2015_tert= hei2015_total_score,nq(3) 


bysort HEI2015_tert: su hei2015_total_score

sts test HEI2015_tert if sample_final==1, logrank
sts graph if sample_final==1, by(HEI2015_tert) 


graph save "FIGURE3.gph", replace

save, replace

capture log close

capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\TABLE2.smcl",replace

use finaldata_imputed_FINAL,clear

keep if stratum~=53

bysort foodinsecurity_totbr: su foodinsecurity_tot if sample_final==1,detail

save finaldata_imputed_FINAL, replace



**STEP 15: TABLE 2: COX PH MODELS FOR EXPOSURE (foodinsecurity and dementia probabilities, loge transformed) VS. OUTCOME AND MEDIATOR VS. OUTCOME, OVERALL AND STRATIFIED BY SEX AND RACE: REDUCE AND FULL MODELS; INTERACTION BY SEX AND BY RACE*******


capture drop lnhurd_odds
mi passive: gen lnhurd_odds=ln((hurd_p)/(1-hurd_p))

capture drop lnexpert_odds
mi passive: gen lnexpert_odds=ln((expert_p)/(1-expert_p))


capture drop lnlasso_odds
mi passive: gen lnlasso_odds=ln((lasso_p)/(1-lasso_p))


capture drop Men
mi passive: gen Men=1 if SEX==1 & sample_final==1
mi passive: replace Men=0 if Men~=1 & SEX~=. & sample_final==1

capture drop Women
mi passive: gen Women=1 if SEX==2 & sample_final==1
mi passive: replace Women=0 if Women~=1 & SEX~=. & sample_final==1

capture drop NHW
mi passive: gen NHW=1 if RACE_ETHN==1 & sample_final==1
mi passive: replace NHW=0 if NHW~=1 & RACE_ETHN~=. & sample_final==1

capture drop NHB
mi passive: gen NHB=1 if RACE_ETHN==2 & sample_final==1
mi passive: replace NHB=0 if NHB~=1 & RACE_ETHN~=. & sample_final==1


capture drop HISP
mi passive: gen HISP=1 if RACE_ETHN==3 & sample_final==1
mi passive: replace HISP=0 if HISP~=1 & RACE_ETHN~=. & sample_final==1 


capture drop OTHER
mi passive: gen OTHER=1 if RACE_ETHN==4 & sample_final==1
mi passive: replace OTHER=0 if OTHER~=1 & RACE_ETHN~=. & sample_final==1


capture drop NonWhite
mi passive: gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passive: replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1

save, replace


*****************TEST OF PH ASSUMPTION FOR FOOD INSECURITY**
use finaldata_imputed_FINAL,clear


mi extract 0
save STPHTEST, replace

stcox foodinsecurity_tot AGE2012 SEX NonWhite if sample_final==1 

capture drop scaledsch1demA scaledsch1demB scaledsch1demC scaledsch1demD 
predict scaledsch1demA scaledsch1demB scaledsch1demC scaledsch1demD, scaledsch
lowess scaledsch1demA  _t, mean noweight title("") note("") m(o)
graph save "E:\HRS_MANUSCRIPT_MAY_FI\MANUSCRIPT\FIGURES\scaledschFI.gph",replace


save STPHTEST, replace


use finaldata_imputed_FINAL,clear


****************OVERALL*********************

***MODEL 1****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(sample_final): stcox `x' AGE2012 SEX NonWhite
	
}

foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(sample_final): stcox `x' AGE2012 SEX NonWhite
	
}


***MODEL 2****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(sample_final): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}

foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(sample_final): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


*****************MEN************************


***MODEL 1****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(Men): stcox `x' AGE2012 SEX NonWhite
	
}


foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(Men): stcox `x' AGE2012 SEX NonWhite
	
}


***MODEL 2****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(Men): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}

foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(Men): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


*****************WOMEN**********************

***MODEL 1****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(Women): stcox `x' AGE2012 SEX NonWhite
	
}


foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(Women): stcox `x' AGE2012 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(Women): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(Women): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score

	
}

****************NHW*************************


***MODEL 1****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(NHW): stcox `x' AGE2012 SEX NonWhite
	
}


foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(NHW): stcox `x' AGE2012 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(NHW): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(NHW): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


****************NHB*************************


***MODEL 1****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(NHB): stcox `x' AGE2012 SEX NonWhite
	
}



foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(NHB): stcox `x' AGE2012 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(NHB): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}

foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(NHB): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}



****************HISP************************



***MODEL 1****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(HISP): stcox `x' AGE2012 SEX NonWhite
	
}


foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(HISP): stcox `x' AGE2012 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(HISP): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(HISP): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


**************NonWhite*************************

***MODEL 1****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(NonWhite): stcox `x' AGE2012 SEX NonWhite
	
}


foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(NonWhite): stcox `x' AGE2012 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(NonWhite): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}



foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(NonWhite): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}

****************INTERACTION BY SEX*********

***MODEL 1****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2012 SEX NonWhite
	
}

foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2012 SEX NonWhite
	
}



***MODEL 2****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}

****************INTERACTION BY RACE*********


***MODEL 1****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(sample_final): stcox c.`x'##NonWhite AGE2012 SEX 
	
}

foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(sample_final): stcox c.`x'##NonWhite AGE2012 SEX 
	
}



***MODEL 2****
foreach x of varlist foodinsecurity_tot lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(sample_final): stcox c.`x'##NonWhite AGE2012 SEX  i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}



foreach x of varlist foodinsecurity_totbr hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(sample_final): stcox c.`x'##NonWhite AGE2012 SEX  i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}

save, replace


capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\TABLE3.smcl",replace


**STEP 16: COX PH MODEL OF DEMENTIA STATUS VS. MORTALITY BY foodinsecurity TERTILE****

save, replace

capture drop FOOD_SECURE
gen FOOD_SECURE=.
replace FOOD_SECURE=1 if foodinsecurity_totbr==0 & sample_final==1
replace FOOD_SECURE=0 if foodinsecurity_totbr==1 & sample_final==1


capture drop FOOD_INSECURE
gen FOOD_INSECURE=.
replace FOOD_INSECURE=1 if foodinsecurity_totbr==1 & sample_final==1
replace FOOD_INSECURE=0 if foodinsecurity_totbr==0 & sample_final==1


************************FOOD SECURE***************************************

***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(FOOD_SECURE): stcox `x' AGE2012 SEX NonWhite 
	
}

foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(FOOD_SECURE): stcox `x' AGE2012 SEX NonWhite 
	
}


***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(FOOD_SECURE): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score 
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(FOOD_SECURE): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012  hei2015_total_score
	
}



************************FOOD INSECURE***************************************

***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(FOOD_INSECURE): stcox `x' AGE2012 SEX NonWhite 
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(FOOD_INSECURE): stcox `x' AGE2012 SEX NonWhite 
	
}


***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(FOOD_INSECURE): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(FOOD_INSECURE): stcox `x' AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}


**************************************INTERACTION WITH FOOD INSECURITY**********************************


***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(sample_final): stcox c.`x'##c.foodinsecurity_totbr AGE2012 SEX NonWhite 
	
}


***MODEL 1****
foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(sample_final): stcox c.`x'##c.foodinsecurity_totbr AGE2012 SEX NonWhite 
	
}

***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimate: svy, subpop(sample_final): stcox c.`x'##c.foodinsecurity_totbr AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}

***MODEL 2****


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimate: svy, subpop(sample_final): stcox c.`x'##c.foodinsecurity_totbr AGE2012 SEX NonWhite i.education  i.totwealth_2012 i.marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012 cesd_2012 hei2015_total_score
	
}

capture log close


capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\TABLE4.smcl",replace


**STEP 17: TABLE 3: MED4WAY FOR foodinsecurity AS EXPOSURE, DIFFERENT PROBABILITIES OF DEMENTIA AS MEDIATORS, AND ALL-CAUSE DEATH AS OUTCOME: FULL MODEL; OVERALL AND STRATIFIED BY SEX AND BY RACE/ETHNICITY***

**COVARIATES: NonWhite AGE2012 SEX  i.education  i.totwealth_2012 marital_2012 work_st_2012 i.smoking_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012

use finaldata_imputed_FINAL,clear



capture drop lnhurd_odds
mi passive: gen lnhurd_odds=ln((hurd_p)/(1-hurd_p))

capture drop lnexpert_odds
mi passive: gen lnexpert_odds=ln((expert_p)/(1-expert_p))


capture drop lnlasso_odds
mi passive: gen lnlasso_odds=ln((lasso_p)/(1-lasso_p))


capture drop Men
mi passive: gen Men=1 if SEX==1 & sample_final==1
mi passive: replace Men=0 if Men~=1 & SEX~=. & sample_final==1

capture drop Women
mi passive: gen Women=1 if SEX==2 & sample_final==1
mi passive: replace Women=0 if Women~=1 & SEX~=. & sample_final==1

capture drop NHW
mi passive: gen NHW=1 if RACE_ETHN==1 & sample_final==1
mi passive: replace NHW=0 if NHW~=1 & RACE_ETHN~=. & sample_final==1

capture drop NHB
mi passive: gen NHB=1 if RACE_ETHN==2 & sample_final==1
mi passive: replace NHB=0 if NHB~=1 & RACE_ETHN~=. & sample_final==1


capture drop HISP
mi passive: gen HISP=1 if RACE_ETHN==3 & sample_final==1
mi passive: replace HISP=0 if HISP~=1 & RACE_ETHN~=. & sample_final==1 


capture drop OTHER
mi passive: gen OTHER=1 if RACE_ETHN==4 & sample_final==1
mi passive: replace OTHER=0 if OTHER~=1 & RACE_ETHN~=. & sample_final==1


capture drop NonWhite
mi passive: gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passive: replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1

save, replace

capture mi stset ageevent [pweight = HCNSWGTR_NT] if sample_final==1, failure(died==1) enter(AGE2012) origin(AGE2012) id(HHIDPN) scale(1)

capture drop educationg* totalwealth_2012g* marital_2012g* smoking_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* alcohol_2012g*

tab education,generate(educationg)

tab totwealth_2012, generate(totalwealth_2012g)

tab marital_2012, generate(marital_2012g)

tab smoking_2012, generate(smoking_2012g)

tab physic_act_2012, generate(physic_act_2012g)

tab alcohol_2012, generate(alcohol_2012g)

tab srh_2012, generate(srh_2012g)

tab bmibr_2012, generate(bmibr_2012g)
 
tab cardiometcondbr_2012, generate(cardiometcondbr_2012g)

save, replace

***************************TABLE 4: MODEL 2*********************************

*****************************OVERALL*******************************

capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds 
capture drop zcesd_2012
capture drop zhei2015_total_score
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds cesd_2012 hei2015_total_score {
	mi passive: egen z`x'=std(`x') if sample_final==1
}

save, replace

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g*  physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zhei2015_total_score if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****************************MEN*******************************


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zhei2015_total_score if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****************************WOMEN*******************************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zhei2015_total_score if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***************************NHW*****************************************


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zhei2015_total_score if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear)   
}



***************************Non-White*************************************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zhei2015_total_score if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

save finaldata_imputed_FINAL, replace




capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\TABLE5.smcl",replace


**STEP 17: TABLE 5: MED4WAY FOR DIFFERENT PROBABILITIES OF DEMENTIA AS MEDIATOR, DIET QUALITY AS EXPOSURE, AND ALL-CAUSE DEATH AS OUTCOME: FULL MODEL BY SEX AND BY RACE/ETHNICITY***


use finaldata_imputed_FINAL,clear

*****************************OVERALL*******************************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012  if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****************************MEN*******************************


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012  if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****************************WOMEN*******************************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012  if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***************************NHW*****************************************


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012  if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************************Non-White*************************************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite  educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012  if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


save, replace

capture log close


********************************************************SENSITIVITY ANALYSIS: REDUCED MODELS***********************************************

capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\TABLES3.smcl",replace


**STEP 18: TABLE 3: MED4WAY FOR foodinsecurity AS EXPOSURE, DIFFERENT PROBABILITIES OF DEMENTIA AS MEDIATORS, AND ALL-CAUSE DEATH AS OUTCOME: FULL MODEL; OVERALL AND STRATIFIED BY SEX AND BY RACE/ETHNICITY***

**COVARIATES: NonWhite AGE2012 SEX  i.education  i.totwealth_2012 marital_2012 work_st_2012 i.smoking_2012 i.alcohol_2012 physic_act_2012 i.srh_2012  i.bmibr_2012 cardiometcondbr_2012

use finaldata_imputed_FINAL,clear


capture drop lnhurd_odds
mi passive: gen lnhurd_odds=ln((hurd_p)/(1-hurd_p))

capture drop lnexpert_odds
mi passive: gen lnexpert_odds=ln((expert_p)/(1-expert_p))


capture drop lnlasso_odds
mi passive: gen lnlasso_odds=ln((lasso_p)/(1-lasso_p))


capture drop Men
mi passive: gen Men=1 if SEX==1 & sample_final==1
mi passive: replace Men=0 if Men~=1 & SEX~=. & sample_final==1

capture drop Women
mi passive: gen Women=1 if SEX==2 & sample_final==1
mi passive: replace Women=0 if Women~=1 & SEX~=. & sample_final==1

capture drop NHW
mi passive: gen NHW=1 if RACE_ETHN==1 & sample_final==1
mi passive: replace NHW=0 if NHW~=1 & RACE_ETHN~=. & sample_final==1

capture drop NHB
mi passive: gen NHB=1 if RACE_ETHN==2 & sample_final==1
mi passive: replace NHB=0 if NHB~=1 & RACE_ETHN~=. & sample_final==1


capture drop HISP
mi passive: gen HISP=1 if RACE_ETHN==3 & sample_final==1
mi passive: replace HISP=0 if HISP~=1 & RACE_ETHN~=. & sample_final==1 


capture drop OTHER
mi passive: gen OTHER=1 if RACE_ETHN==4 & sample_final==1
mi passive: replace OTHER=0 if OTHER~=1 & RACE_ETHN~=. & sample_final==1


capture drop NonWhite
mi passive: gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passive: replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1

save, replace



capture mi stset ageevent [pweight = HCNSWGTR_NT] if sample_final==1, failure(died==1) enter(AGE2012) origin(AGE2012) id(HHIDPN) scale(1)



***************************TABLE S3: MODEL 1*********************************

*****************************OVERALL*******************************
capture drop zlnhurd_odds zlnexpert_odds zlnlasso_odds 
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passive: egen z`x'=std(`x') if sample_final==1
}

save, replace

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite   if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****************************MEN*******************************



foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite   if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****************************WOMEN*******************************


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite   if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***************************NHW*****************************************



foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite   if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************************Non-White*************************************


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way foodinsecurity_totbr `m' AGE2012 SEX NonWhite   if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

save finaldata_imputed_FINAL, replace



capture log close

**STEP 19: TABLE S4: MED4WAY FOR DIFFERENT PROBABILITIES OF DEMENTIA AS MEDIATOR, DIET QUALITY AS EXPOSURE, AND ALL-CAUSE DEATH AS OUTCOME: FULL MODEL BY SEX AND BY RACE/ETHNICITY***

**************MODEL 1*****************************

capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\TABLES4.smcl",replace


use finaldata_imputed_FINAL,clear

*****************************OVERALL*******************************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite    if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****************************MEN*******************************


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite    if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****************************WOMEN*******************************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite    if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***************************NHW*****************************************


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite    if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************************Non-White*************************************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zhei2015_total_score `m'  foodinsecurity_totbr  AGE2012 SEX NonWhite   if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


save, replace

*******************************************************************************************


capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\FIGURE3A_SENSITIVITY.smcl",replace


**MED4WAY FOR DIFFERENT PROBABILITIES OF DEMENTIA AS EXPOSURE, foodinsecurity AS MEDIATORS, AND ALL-CAUSE DEATH AS OUTCOME: REDUCED MODEL + EACH SES, LIFESTYLE AND HEALTH-RELATED FACTORS***


use finaldata_imputed_FINAL,clear

*****************************OVERALL*******************************
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passive: egen z`x'=std(`x') if sample_final==1
}

save, replace

***MODEL 1A************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  educationg*  if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***MODEL 1B************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  totwealth_2012  if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***MODEL 1C************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  marital_2012g*  if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1D************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  smoking_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1E************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  physic_act_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1F************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  srh_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1G************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite   bmibr_2012g*   if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1H************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  cardiometcondbr_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1I************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  zcesd_2012 if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1J*********

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  alcohol_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1K*********

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' foodinsecurity_totbr  AGE2012 SEX NonWhite  zhei2015_total_score if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}




capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\FIGURE3B_SENSITIVITY.smcl",replace


**MED4WAY FOR DIFFERENT PROBABILITIES OF DEMENTIA AS EXPOSURE, foodinsecurity AS MEDIATORS, AND ALL-CAUSE DEATH AS OUTCOME: REDUCED MODEL + EACH SES, LIFESTYLE AND HEALTH-RELATED FACTORS***


use finaldata_imputed_FINAL,clear

*****************************OVERALL*******************************
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passive: egen z`x'=std(`x') if sample_final==1
}


***MODEL 1A************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'  AGE2012 SEX NonWhite  educationg*  if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***MODEL 1B************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'   AGE2012 SEX NonWhite  totwealth_2012  if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***MODEL 1C************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'  AGE2012 SEX NonWhite  marital_2012g*  if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1D************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'   AGE2012 SEX NonWhite  smoking_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1E************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'   AGE2012 SEX NonWhite  physic_act_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1F************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'  AGE2012 SEX NonWhite  srh_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1G************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'   AGE2012 SEX NonWhite   bmibr_2012g*   if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1H************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'   AGE2012 SEX NonWhite  cardiometcondbr_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***MODEL 1I************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'  AGE2012 SEX NonWhite  zcesd_2012 if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***MODEL 1J************

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'  AGE2012 SEX NonWhite  alcohol_2012g* if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


**MODEL 1K*********

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way  foodinsecurity_totbr `m'  AGE2012 SEX NonWhite  zhei2015_total_score if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}





capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\FIGURE3A_SENSITIVITY_FIG.smcl",replace

use FIGURE3A_DEMENTIA_TE,clear

************************************FIGURE 3*****************************************************************

**1=Reduced
**2=Reduced+Education
**3=Reduced+Wealth/Income
**4=Reduced+Marital Status
**5=Reduced+Smoking Status
**6=Reduced+Physical Activity
**7=Reduced+Self-Rated Health 2012
**8=Reduced+BMIBR 2012
**9=Reduced+cardiometcondbr_2012
**10=Reduced+zcesd_2012
**11=Reduced+alcohol_2012

capture label drop MODELlab
label define MODELlab 1 "Reduced" 2 "Reduced+Education" 3 "Reduced+Wealth/Income" 4 "Reduced+Marital Status" 5 "Reduced+Smoking Status" 6 "Reduced+Physical Activity" 7 "Reduced+Self-Rated Health 2012" 8 "Reduced+BMIBR 2012" 9 "Reduced+cardiometcondbr_2012" 10 "Reduced+zcesd_2012" 11 "Reduced+alcohol_2012"

capture drop algorithm_num
gen algorithm_num=.
replace algorithm_num=1 if algorithm=="Hurd"
replace algorithm_num=2 if algorithm=="Expert"
replace algorithm_num=3 if algorithm=="LASSO"

capture drop ID
gen ID=.
replace ID=algorithm_num*100+model_num

**Hurd algorithm**

twoway rcap te_lcl	te_ucl model_num if algorithm_num==1,  title("TE") ytitle(TE OF DEMENTIA) xtitle("Model/Hurd") xlab(1 "Reduced" 2 "Reduced+Education" 3 "Reduced+Wealth/Income" 4 "Reduced+Marital Status" 5 "Reduced+Smoking Status" 6 "Reduced+Physical Activity" 7 "Reduced+Self-Rated Health 2012" 8 "Reduced+BMIBR 2012" 9 "Reduced+cardiometcondbr_2012" 10 "Reduced+zcesd_2012" 11 "Reduced+alcohol_2012" 12"Reduced+HEI2015" , angle(90))  || scatter te_estimate model_num if algorithm_num==1 

graph save FIGURE3A1_DEMENTIAHURD.gph,replace



**Expert**
twoway rcap te_lcl	te_ucl model_num if algorithm_num==2, title("TE") ytitle(TE OF DEMENTIA) xtitle("Model/Expert") xlab(1 "Reduced" 2 "Reduced+Education" 3 "Reduced+Wealth/Income" 4 "Reduced+Marital Status" 5 "Reduced+Smoking Status" 6 "Reduced+Physical Activity" 7 "Reduced+Self-Rated Health 2012" 8 "Reduced+BMIBR 2012" 9 "Reduced+cardiometcondbr_2012" 10 "Reduced+zcesd_2012" 11 "Reduced+alcohol_2012" 12"Reduced+HEI2015", angle(90))  || scatter te_estimate model_num if algorithm_num==2 

graph save FIGURE3A2_DEMENTIAEXPERT.gph,replace


**LASSO**
twoway rcap te_lcl	te_ucl model_num if algorithm_num==3, title("TE") ytitle(TE OF DEMENTIA) xtitle("Model/LASSO") xlab(1 "Reduced" 2 "Reduced+Education" 3 "Reduced+Wealth/Income" 4 "Reduced+Marital Status" 5 "Reduced+Smoking Status" 6 "Reduced+Physical Activity" 7 "Reduced+Self-Rated Health 2012" 8 "Reduced+BMIBR 2012" 9 "Reduced+cardiometcondbr_2012" 10 "Reduced+zcesd_2012" 11 "Reduced+alcohol_2012" 12"Reduced+HEI2015", angle(90))  || scatter te_estimate model_num if algorithm_num==3

graph save FIGURE3A3_DEMENTIALASSO.gph,replace

save, replace


***********************TOTAL EFFECT OF foodinsecurity****************************

use FIGURE3B_foodinsecurity_TE,clear


**Hurd algorithm**

twoway rcap te_lcl	te_ucl model_num if algorithm_num==1,  title("TE") ytitle(TE OF foodinsecurity) xtitle("Model/Hurd") xlab(1 "Reduced" 2 "Reduced+Education" 3 "Reduced+Wealth/Income" 4 "Reduced+Marital Status" 5 "Reduced+Smoking Status" 6 "Reduced+Physical Activity" 7 "Reduced+Self-Rated Health 2012" 8 "Reduced+BMIBR 2012" 9 "Reduced+cardiometcondbr_2012" 10 "Reduced+zcesd_2012" 11 "Reduced+alcohol_2012" 12"Reduced+HEI2015", angle(90))  || scatter te_estimate model_num if algorithm_num==1 

graph save FIGURE3A1_foodinsecurityHURD.gph,replace


**Expert**
twoway rcap te_lcl	te_ucl model_num if algorithm_num==2, title("TE") ytitle(TE OF foodinsecurity) xtitle("Model/Expert") xlab(1 "Reduced" 2 "Reduced+Education" 3 "Reduced+Wealth/Income" 4 "Reduced+Marital Status" 5 "Reduced+Smoking Status" 6 "Reduced+Physical Activity" 7 "Reduced+Self-Rated Health 2012" 8 "Reduced+BMIBR 2012" 9 "Reduced+cardiometcondbr_2012" 10 "Reduced+zcesd_2012" 11 "Reduced+alcohol_2012" 12"Reduced+HEI2015", angle(90))  || scatter te_estimate model_num if algorithm_num==2 

graph save FIGURE3A2_foodinsecurityEXPERT.gph,replace


**LASSO**
twoway rcap te_lcl	te_ucl model_num if algorithm_num==3, title("TE") ytitle(TE OF foodinsecurity) xtitle("Model/LASSO") xlab(1 "Reduced" 2 "Reduced+Education" 3 "Reduced+Wealth/Income" 4 "Reduced+Marital Status" 5 "Reduced+Smoking Status" 6 "Reduced+Physical Activity" 7 "Reduced+Self-Rated Health 2012" 8 "Reduced+BMIBR 2012" 9 "Reduced+cardiometcondbr_2012" 10 "Reduced+zcesd_2012" 11 "Reduced+alcohol_2012" 12"Reduced+HEI2015", angle(90))  || scatter te_estimate model_num if algorithm_num==3

graph save FIGURE3A3_foodinsecurityLASSO.gph,replace



capture log close
capture log using "E:\HRS_MANUSCRIPT_MAY_FI\OUTPUT\GSEM_SENSITIVITY.smcl",replace




use finaldata_imputed_FINAL,clear




*****************************************HURD DEMENTIA ODDS****************************************************************


*******************************FOOD INSECURITY --> DEMENTIA ODDS, HURD --> MORTALITY*****************************************

******************************GSEM MODELS***********************************************

capture drop zHEI2015
gen zHEI2015=zhei2015_total_score


capture drop educationg* totalwealth_2012g* marital_2012g* smoking_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* alcohol_2012g*

tab education,generate(educationg)

tab totwealth_2012, generate(totalwealth_2012g)

tab marital_2012, generate(marital_2012g)

tab smoking_2012, generate(smoking_2012g)

tab physic_act_2012, generate(physic_act_2012g)

tab alcohol_2012, generate(alcohol_2012g)

tab srh_2012, generate(srh_2012g)

tab bmibr_2012, generate(bmibr_2012g)
 
tab cardiometcondbr_2012, generate(cardiometcondbr_2012g)

save finaldata_imputed_FINAL, replace


***********REDUCED MODEL*********************

**GSEM model without mediator**

mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr, family(weibull, failure(_d)) link(log) nocapslatent) ///
if sample_final==1, nocapslatent method(ml) 



mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX zlnhurd_odds, family(weibull, failure(_d)) link(log) nocapslatent) ///
if sample_final==1, nocapslatent method(ml) 


mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
if sample_final==1, nocapslatent method(ml) 



**GSEM model with mediator**

mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds, family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 



**GSEM model with two mediators**
mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015, family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 



*********Mediating pathways per imputation******************

***********FIRST IMPUTATION*********************

mi xeq 1: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015, family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 


**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])



***********SECOND IMPUTATION*********************

mi xeq 2: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015, family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 


**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


***********THIRD IMPUTATION*********************

mi xeq 3: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015, family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 


**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


***********FOURTH IMPUTATION*********************

mi xeq 4: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015, family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 


**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zHEI2015])


***********FIFTH IMPUTATION*********************

mi xeq 5: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015, family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) (zHEI2015 -> zlnhurd_odds, family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 


**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**********************************************************FULL MODEL*********************************************************************************************

**GSEM model without mediator**
mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012, family(weibull, failure(_d)) link(log) nocapslatent) ///
if sample_final==1, nocapslatent method(ml) 

mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX zHEI2015 educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012, family(weibull, failure(_d)) link(log) nocapslatent) ///
if sample_final==1, nocapslatent method(ml) 


mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX zlnhurd_odds educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012, family(weibull, failure(_d)) link(log) nocapslatent) ///
if sample_final==1, nocapslatent method(ml) 


******GSEM model with mediator**
mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g*  physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg2  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg3  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg4  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg5  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(totwealth_2012 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g4 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(srh_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(zcesd_2012 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(alcohol_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 

******GSEM model with two mediators****
mi estimate, cmdok: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg2  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg3  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg4  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg5  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(totwealth_2012 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g4 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(srh_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(zcesd_2012 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(zHEI2015 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg2  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg3  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg4  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg5  -> zHEI2015 , family(gaussian) link(identity)) ///
(totwealth_2012 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g4 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zHEI2015 , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(srh_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(zcesd_2012 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 



******************MEDIATING EFFECTS PER IMPUTATION*****************
*********Mediating pathways per imputation******************

***********FIRST IMPUTATION*********************

mi xeq 1: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg2  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg3  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg4  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg5  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(totwealth_2012 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g4 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(srh_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(zcesd_2012 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(zHEI2015 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg2  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg3  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg4  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg5  -> zHEI2015 , family(gaussian) link(identity)) ///
(totwealth_2012 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g4 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zHEI2015 , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(srh_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(zcesd_2012 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 


**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])



***********SECOND IMPUTATION*********************

mi xeq 2: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg2  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg3  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg4  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg5  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(totwealth_2012 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g4 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(srh_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(zcesd_2012 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(zHEI2015 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg2  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg3  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg4  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg5  -> zHEI2015 , family(gaussian) link(identity)) ///
(totwealth_2012 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g4 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zHEI2015 , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(srh_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(zcesd_2012 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 

 


**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


***********THIRD IMPUTATION*********************

mi xeq 3: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg2  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg3  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg4  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg5  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(totwealth_2012 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g4 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(srh_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(zcesd_2012 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(zHEI2015 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg2  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg3  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg4  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg5  -> zHEI2015 , family(gaussian) link(identity)) ///
(totwealth_2012 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g4 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zHEI2015 , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(srh_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(zcesd_2012 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 

 


**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


***********FOURTH IMPUTATION*********************

mi xeq 4: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg2  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg3  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg4  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg5  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(totwealth_2012 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g4 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(srh_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(zcesd_2012 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(zHEI2015 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg2  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg3  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg4  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg5  -> zHEI2015 , family(gaussian) link(identity)) ///
(totwealth_2012 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g4 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zHEI2015 , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(srh_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(zcesd_2012 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 



**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


***********FIFTH IMPUTATION*********************

mi xeq 5: gsem (_t <- NonWhite AGE2012 SEX foodinsecurity_totbr zlnhurd_odds educationg* totwealth_2012 marital_2012g* smoking_2012g* alcohol_2012g* physic_act_2012g* srh_2012g* bmibr_2012g*  cardiometcondbr_2012g* zcesd_2012 zHEI2015, family(weibull, failure(_d)) link(log) nocapslatent) ///
(NonWhite -> zlnhurd_odds, family(gaussian) link(identity)) ///  
(AGE2012 -> zlnhurd_odds, family(gaussian) link(identity)) (SEX -> zlnhurd_odds, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zlnhurd_odds , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg2  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg3  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg4  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(educationg5  -> zlnhurd_odds , family(gaussian) link(identity)) ///
(totwealth_2012 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(marital_2012g4 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(srh_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(zcesd_2012 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zlnhurd_odds , family(gaussian) link(identity))        ///
(zHEI2015 -> zlnhurd_odds , family(gaussian) link(identity)) ///
(NonWhite -> zHEI2015, family(gaussian) link(identity)) ///  
(AGE2012 -> zHEI2015, family(gaussian) link(identity)) (SEX -> zHEI2015, family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(foodinsecurity_totbr -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg1 -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg2  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg3  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg4  -> zHEI2015 , family(gaussian) link(identity)) ///
(educationg5  -> zHEI2015 , family(gaussian) link(identity)) ///
(totwealth_2012 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(marital_2012g4 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(smoking_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(physic_act_2012g3 -> zHEI2015 , family(gaussian) link(identity)) /// 
(srh_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(srh_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(bmibr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g2 -> zHEI2015 , family(gaussian) link(identity)) ///
(cardiometcondbr_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
(zcesd_2012 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g1 -> zHEI2015 , family(gaussian) link(identity)) ///
(alcohol_2012g2 -> zHEI2015 , family(gaussian) link(identity))        ///
(alcohol_2012g3 -> zHEI2015 , family(gaussian) link(identity)) ///
if sample_final==1, nocapslatent method(ml) 

 


**Pathway A: Food insecurity --> diet quality --> dementia --> mortality

nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


**Pathway B: food insecurity --> dementia --> mortality
nlcom (_b[zlnhurd_odds:foodinsecurity_totbr]*_b[_t:zlnhurd_odds])


**Pathway C: food insecurity --> diet quality --> mortality
nlcom (_b[zHEI2015:foodinsecurity_totbr]*_b[_t:zHEI2015])


**Pathway D: Diet quality --> dementia --> mortality
nlcom (_b[zlnhurd_odds:zHEI2015]*_b[_t:zlnhurd_odds])


capture log close

cd "E:\HRS_MANUSCRIPT_MAY_FI\FINAL_DATA"

************************REVISION****************************

use HRS_PROJECTSLEEPCONGMORT_finWIDE,clear

svyset secu [pweight=HCNSWGTR_NT], strata(stratum) 

svy, subpop(sample_final): prop r10nrshom 