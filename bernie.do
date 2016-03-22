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
gen youthinpov = (householdwithyouth & (poverty <= 100))
tab youthinpov if pernum == 1 [fweight = perwt]
*162 jobs for 5287 households

gen job_money = 0
replace job_money = 10500 if youthinpov & pernum == 1
gen newincome = inctot+job_money if inctot < 9999999
replace newincome = ftotinc+job_money if ftotinc < 9999999

sgini newincome if pernum == 1 & newincome < 9999999 [fweight=hhwt]
sgini ftotinc if pernum == 1 & ftotinc < 9999999 [fweight=hhwt]

gen povline = 11670 + (numprec-1)*4060
gen outofpov = poverty & (newincome > povline) & (newincome < 9999999)

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

