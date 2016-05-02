* the world is crumbling. solutions are being introduced. they wont pass without radical political change
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
drop if year == 2013

gen youth = (age <= 25 & age >= 16)
gen disadvantaged = (poverty <= 100)
gen disadvantaged_youth = (youth & disadvantaged)
gen unemployed = (empstat == 2)
gen unemployedyouth = youth & unemployed

egen youth_in_hh = max(youth), by(serial)
egen unemployed_in_hh = max(unemployed), by(serial)
egen disadvantaged_hh = max(disadvantaged_youth), by(serial)

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


*figure out households w/ youth in them
egen householdwithyouth = max(youth), by(serial)
*youth hh's living in poverty
gen youthinpov = (householdwithyouth & (poverty <= 100) & pernum == 1)
tab youthinpov if pernum == 1 [fweight = perwt]
*162 jobs for 5287 households
save "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie5-1.dta", replace
keep if youthinpov
bysort statefip puma: gen runningwt = sum(hhwt)
keep serial pernum runningwt
joinby serial pernum using "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie5-1.dta", unmatched(both)
gen jobsleft = 0 
gen prevwt = 0
replace prevwt = runningwt - hhwt if runningwt > numjobspuma 
replace jobsleft = numjobspuma - prevwt if (prevwt < numjobspuma & prevwt > 0)
gen newhhwt = hhwt
expand 2 if jobsleft > 0, generate(duplicate)
replace newhhwt = jobsleft if duplicate == 1
replace newhhwt = hhwt-jobsleft if duplicate == 0

gen job_money = 0 
replace job_money = 10500 if (runningwt < numjobspuma) | (jobsleft > 0 & duplicate == 1)

gen familyincome = inctot 
replace familyincome = ftotinc if ftotinc < 9999999 
replace familyincome = 0 if familyincome < 0

gen newincome = familyincome+job_money

gen povline = 11670 + (numprec-1)*4060
gen outofpov = disadvantaged & (newincome > povline) & (newincome < 9999999)

egen outofpovfam = max(outofpov), by(serial)

sgini newincome if pernum == 1 & familyincome < 9999999 [fweight=newhhwt]
sgini familyincome if pernum == 1 & familyincome < 9999999 [fweight=newhhwt]

gen povgap = povline - familyincome if familyincome < povline
gen newpovgap = povline - newincome if newincome < povline

egen totalhh = sum(newhhwt) if pernum == 1
egen p0 = sum(newhhwt) if poverty < 100 & pernum == 1

egen p1 = sum((povgap*newhhwt)/povline)
disp p1/totalhh 
//.22842
egen newp1 = sum((newpovgap*newhhwt)/povline)
disp newp1/totalhh 
//.19363

egen p2 = sum((povgap/povline)^2*newhhwt)
egen newp2 = sum((newpovgap/povline)^2*newhhwt)

disp p2/totalhh 
//.1659
disp newp2/totalhh 
//.1356

disp p0[23]/totalhh 
//.19710145

egen newp0 = sum(newhhwt) if ((poverty < 100 & pernum == 1) & !(outofpov == 1 & pernum == 1))
disp newp0[23]/totalhh 
//.1978997

egen totalhhstate = sum(newhhwt) if pernum == 1, by(statefip)
egen p0state = sum(newhhwt) if poverty < 100 & pernum == 1, by(statefip)
egen newp0state = sum(newhhwt) if ((poverty < 100 & pernum == 1) & !(outofpov == 1 & pernum == 1)), by(statefip)


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
