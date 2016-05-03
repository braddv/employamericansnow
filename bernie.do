* 1 billion divided equally between states
* 1 billion distributed on the basis of relative 16-25 y/o compared to total in all states
* 1 billion on relative unemployed compared to toal in all states
* 1 billion on the basis of the rleative # disadvantaged youth compared to total in all states

*STEPS:
* # of 16-25 y/o's per state
* total # of 16-25 y/os
* # of unemployed per state
* total # unemployed
* # disdvantaged youth
* total # disadvantaged youth

*then by puma w/in state 
*
*tabulate age if statefip == 06 & puma == 3703 [fweight=perwt]
use "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie08.dta", clear

drop if year == 2013
drop if gq == 4 | gq == 3
drop if statefip == 36 & puma == 3309
drop if statefip == 25 & puma == 1300

gen youth = (age <= 25 & age >= 16)
gen povline = 11670 + (famsize-1)*4060
gen disadvantaged = (ftotinc < povline)
gen unemployed = (empstat == 2)
gen unemployed_youth = youth * unemployed
gen disadvantaged_youth = youth * disadvantaged

egen youth_in_hh = max(youth), by(serial)
egen unemployed_in_hh = max(unemployed), by(serial)
egen disadvantaged_hh = max(disadvantaged), by(serial)

egen youth_in_fam = max(youth), by(serial famunit)
egen unemployed_in_fam = max(unemployed), by(serial famunit)
egen disadvantaged_fam = max(disadvantaged), by(serial famunit)
gen disadvantagedyouth_fam = disadvantaged_fam*youth_in_fam 
gen unemployedyouth_fam = youth_in_fam*unemployed_youth


egen youth_state = total(perwt * youth), by(statefip) 
egen youth_puma = total(perwt * youth), by(statefip puma) 
*sum youth_puma if statefip == 06 & puma == 3703 
*25371 youth in lancaster
gen youth_percentage = youth_puma / youth_state

egen unemployed_state = total(perwt * unemployed), by(statefip)
egen unemployed_puma = total(perwt * unemployed), by(statefip puma)

gen unemployed_percentage = unemployed_puma / unemployed_state

egen unemployed_youth_state = total(perwt * unemployedyouth), by(statefip)

*sum youth_puma if statefip == 06 & puma == 3703 
*5797 youth in lancaster

egen disadvantaged_state = total(perwt * disadvantaged_youth), by(statefip)
egen disadvantaged_puma = total(perwt * disadvantaged_youth), by(statefip puma)

gen disadvantaged_percentage = disadvantaged_puma / disadvantaged_state

egen youth_total = total(perwt * youth)
egen unemployed_total = total(perwt * unemployed)
egen disadvantaged_total = total(perwt * disadvantaged_youth)

gen youth_percentage_state = youth_state/youth_total
gen unemployed_percentage_state = unemployed_state/unemployed_total
gen disadvantaged_percentage_state = disadvantaged_state/disadvantaged_total

gen state_money = 1000 * .02 + 1000 * youth_percentage_state + 1000 * unemployed_percentage_state + 1000 * disadvantaged_percentage_state 

egen npumas = nvals(puma), by(statefip)

gen puma_money = (state_money/3) * (youth_percentage + unemployed_percentage + disadvantaged_percentage)
gen numjobspuma = puma_money / .0105 //.0105 is a 10,500 dollar per yr job ($15*30hrs*12weeks in summer and $15*10hrs*34weeks in schoolyr)
//alternatively, could be doled out as 48 weeks of $15/hr pay 15 hrs a week
gen numjobsstate = state_money / .0105

*gen numjobspumamin = puma_money / state_minwage
*gen numjobsstatemin = state_money / state_minwage

*figure out households w/ youth in them
egen householdwithyouth = max(youth), by(serial)
*youth hh's living in poverty
gen youthinpov = (householdwithyouth & (poverty <= 100) & pernum == 1)

egen familyheadnum = min(pernum), by(serial famunit)
gen familyhead = (familyheadnum == pernum) 
gen familyheadyouthunemployed = familyhead*unemployedyouth_fam
gen familyheadyouthdisadvantaged = familyhead*disadvantagedyouth_fam


save "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie08-egen.dta", replace

use "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie08-egen.dta", clear
gen runningwt = 0
gen prevwt = 0 
save "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie5-1.dta", replace
keep if familyheadyouthdisadvantaged
bysort statefip puma: gen pumaid = _n
bysort statefip puma: replace runningwt = sum(perwt)
replace prevwt = runningwt - perwt if runningwt > numjobspuma
gen jobsleft = numjobspuma - prevwt
replace jobsleft = 0 if jobsleft < 0
replace jobsleft = 0 if runningwt < jobsleft
gen jobrecipient = 0
replace jobrecipient = 1 if runningwt < numjobspuma | jobsleft > 0
keep serial pernum jobrecipient jobsleft
joinby serial pernum using "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie5-1.dta", unmatched(both)

replace jobrecipient = 0 if missing(jobrecipient)
replace jobsleft = 0 if missing(jobsleft)

gen newperwt = perwt
egen maxrunningwt = max(runningwt), by(statefip puma)

expand 2 if jobsleft > 0, generate(duplicate)
replace newperwt = int(jobsleft) if duplicate == 1
replace newperwt = max(int(perwt-jobsleft),0) if duplicate == 0 & jobsleft > 0
replace jobrecipient = 0 if duplicate == 0 & jobsleft > 0

egen jobsreceived = sum(jobrecipient*newperwt)

gen job_money = 0 
replace job_money = 10500 if jobrecipient

gen numjobsafter = numjobspuma
replace numjobsafter = maxrunningwt if maxrunningwt < numjobspuma 

gen familyincome = ftotinc

gen newincome = familyincome+job_money

gen outofpov = (ftotinc <= povline) & (newincome > povline) & (newincome < 9999999)

egen outofpovfam = max(outofpov), by(serial famunit)

*sgini newincome if familyhead == 1 & familyincome < 9999999 [fweight=newperwt]
*sgini familyincome if familyhead == 1 & familyincome < 9999999 [fweight=newperwt]

gen povgap = povline - familyincome if familyincome < povline
gen newpovgap = povline - newincome if newincome < povline

gen poor = familyincome < povline
gen newpoor = newincome < povline

tab poor [fweight=newperwt]
tab newpoor [fweight=newperwt]

egen moneyspent = sum(job_money*newperwt) if familyhead 

tabulate job_money if familyhead [fweight=newperwt]

egen totalfam = sum(newperwt) if familyhead == 1
egen p0 = sum(newperwt) if poor & familyhead == 1
egen newp0 = sum(newperwt) if newpoor & familyhead == 1

egen p1 = sum((povgap*newperwt)/povline) if familyhead == 1
disp p1/totalfam
egen newp1 = sum((newpovgap*newperwt)/povline) if familyhead == 1
disp newp1/totalfam 

egen p2 = sum((povgap/povline)^2*newperwt) if familyhead == 1
egen newp2 = sum((newpovgap/povline)^2*newperwt) if familyhead == 1

disp p2[7]/totalfam[7] 
disp newp2[7]/totalfam[7]

/*. keep if youthinpov
(2,915,463 observations deleted)

. bysort statefip puma: gen runningwt = sum(hhwt)

. keep serial pernum runningwt

. joinby serial pernum using "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie4-11.dta", unmatched(both)
*/

/* collapse (mean) state_money, by(statefip)
. export delimited using "/Users/braddv/Desktop/BERNIE/state_money.csv",
how to collapse without losing data? or i guess just use file again. 
*/
//tab occ2010 if statefip==06 & youth [fweight=perwt] (california young jobs distribution)
//
/*collapse (mean) youth_state, by(statefip)
export delimited using "/Users/braddv/Desktop/BERNIE/youth_state.csv"*/
/*collapse (mean) disadvantaged_state, by(statefip)
export delimited using "/Users/braddv/Desktop/BERNIE/disadvantaged_state.csv"*/
/*collapse (mean) unemployed_state, by(statefip)
export delimited using "/Users/braddv/Desktop/BERNIE/unemployed_state.csv"*/
/*collapse (mean) unemployed_youth_state, by(statefip)
export delimited using "/Users/braddv/Desktop/BERNIE/unemployed_youth_state.csv"*/
/*collapse (mean) numjobsstate, by(statefip)
export delimited using "/Users/braddv/Desktop/BERNIE/numjobs_state.csv"*/

//tab job_money if pernum == 1 [fweight = hhwt]
