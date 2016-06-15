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
use "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie10.dta", clear

drop if year == 2013
drop if gq == 4 | gq == 3

gen youth = (age <= 24 & age >= 16)
gen povline = 11670 + (famsize-1)*4060
gen disadvantaged = (ftotinc < povline)
gen unemployed = (empstat == 2)
gen notemployed = (empstat != 1)
gen unemployed_youth = youth * unemployed
gen notemployed_youth = youth * notemployed
gen disadvantaged_youth = youth * disadvantaged

egen youth_in_hh = max(youth), by(serial)
egen unemployed_in_hh = max(unemployed), by(serial)
egen disadvantaged_hh = max(disadvantaged), by(serial)

egen youth_in_fam = max(youth), by(serial famunit)
egen unemployed_in_fam = max(unemployed), by(serial famunit)
egen disadvantaged_fam = max(disadvantaged), by(serial famunit)
gen disadvantagedyouth_fam = disadvantaged_fam*youth_in_fam 
gen unemployedyouth_fam = youth_in_fam*unemployed_youth
gen notemployedyouth_fam = youth_in_fam*notemployed_youth


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
gen familyheadyouth = familyhead*youth_in_fam
gen familyheadyouthunemployed = familyhead*unemployedyouth_fam
gen familyheadyouthnotemployed = familyhead*notemployedyouth_fam
gen familyheadyouthdisadvantaged = familyhead*disadvantagedyouth_fam

egen finccut = cut(ftotinc), at(0,5000,10000,25000,50000,100000,250000,2000000) icodes

histogram finccut if familyheadyouth [fweight=perwt], discrete

gen employed = empstat == 1

probit employed i.educ i.famsize i.finccut i.sex i.racesing i.metro i.statefip if youth [fweight=perwt]
predict employedp
gen modelemployed = employedp > .5
gen correctmodel = modelemployed == employed
tab correctmodel if youth [fweight=perwt]

egen youthempprob = max(employedp) if youth, by(serial famunit)
egen headmaxyouthempp = max(youthempprob), by(serial famunit) 
gen invheadmaxyouthempp = 1-headmaxyouthempp if !missing(headmaxyouthempp)

save "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie10-egen.dta", replace


