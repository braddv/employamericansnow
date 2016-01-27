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
egen youth_state = total(perwt * (age <= 25 & age >= 16)), by(statefip) 
egen youth_puma = total(perwt * (age <= 25 & age >= 16)), by(statefip puma) 
*sum youth_puma if statefip == 06 & puma == 3703 
*25371 youth in lancaster
gen youth_percentage = youth_puma / youth_state

egen unemployed_state = total(perwt * (empstat == 2)), by(statefip)
egen unemployed_puma = total(perwt * (empstat == 2)), by(statefip puma)

gen unemployed_percentage = unemployed_puma / unemployed_state

*sum youth_puma if statefip == 06 & puma == 3703 
*5797 youth in lancaster

egen disadvantaged_state = total(perwt * ((age <= 25 & age >= 16) & poverty <= 125)), by(statefip)
egen disadvantaged_puma = total(perwt * ((age <= 25 & age >= 16) & poverty <= 125)), by(statefip puma)

gen disadvantaged_percentage = disadvantaged_puma / disadvantaged_state

egen youth_total = total(perwt * (age <= 25 & age >= 16))
egen unemployed_total = total(perwt * (empstat == 2))
egen disadvantaged_total = total(perwt * ((age <= 25 & age >= 16) & poverty <= 125))

gen youth_percentage_state = youth_state/youth_total
gen unemployed_percentage_state = unemployed_state/unemployed_total
gen disadvantaged_percentage_state = disadvantaged_state/disadvantaged_total

gen state_money = 1000 * .02 + 1000 * youth_percentage_state + 1000 * unemployed_percentage_state + 1000 * disadvantaged_percentage_state 

egen npumas = nvals(puma), by(statefip)

gen puma_money = (state_money/4) * (1/npumas + youth_percentage + unemployed_percentage + disadvantaged_percentage)
gen numjobs = puma_money / .0105 //.0105 is a 10,500 dollar per yr job

*figure out households w/ youth in them
egen householdwithyouth = max(age >= 16 & age <= 26), by(serial)
*youth hh's living in poverty
gen youthinpov = (householdwithyouth & (poverty <= 150))

