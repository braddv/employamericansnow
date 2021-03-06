
use "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie16-egen2.dta", clear
gen runningwt = 0
gen prevwt = 0 
save "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie5-1.dta", replace
keep if disadvantaged & youth 
bysort statefip puma: gen pumaid = _n
bysort statefip puma (youthempprob): replace runningwt = sum(perwt)
//use (headmaxyouthempp) or (invheadmaxyouthempp) above depending if you want min or max likelihood
replace prevwt = runningwt - perwt if runningwt > numjobspuma2
gen jobsleft = numjobspuma2 - prevwt
replace jobsleft = 0 if jobsleft < 0
replace jobsleft = 0 if runningwt < jobsleft
gen jobrecipient = 0
replace jobrecipient = 1 if runningwt < numjobspuma2 | jobsleft > 0
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
replace job_money = minwage*1000 if jobrecipient

gen numjobsafter = numjobspuma2
replace numjobsafter = maxrunningwt if maxrunningwt < numjobspuma2

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

egen moneyspent = sum(job_money*newperwt) if jobrecipient
disp moneyspent[1]

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

gen bigregion = 0 
replace bigregion = 1 if region >= 10 & region <= 20
replace bigregion = 2 if region >= 20 & region <= 30
replace bigregion = 3 if region >= 30 & region <= 40
replace bigregion = 4 if region >= 40 & region <= 50

gen hs = educ >= 6
//RACE
egen p1race = sum((povgap*newperwt)/povline) if familyhead == 1, by(racef)
egen newp1race = sum((newpovgap*newperwt)/povline) if familyhead == 1, by(racef)
egen totalfamrace = sum(newperwt) if familyhead == 1, by(racef)

egen p2race = sum((povgap/povline)^2*newperwt) if familyhead == 1, by(racef)
egen newp2race = sum((newpovgap/povline)^2*newperwt) if familyhead == 1, by(racef)
//REGION
egen p1region = sum((povgap*newperwt)/povline) if familyhead == 1, by(bigregion)
egen newp1region = sum((newpovgap*newperwt)/povline) if familyhead == 1, by(bigregion)
egen totalfamregion = sum(newperwt) if familyhead == 1, by(bigregion)

egen p2region = sum((povgap/povline)^2*newperwt) if familyhead == 1, by(bigregion)
egen newp2region = sum((newpovgap/povline)^2*newperwt) if familyhead == 1, by(bigregion)
//INCOME
egen p1income = sum((povgap*newperwt)/povline) if familyhead == 1, by(finccut)
egen newp1income = sum((newpovgap*newperwt)/povline) if familyhead == 1, by(finccut)
egen totalfamincome = sum(newperwt) if familyhead == 1, by(finccut)

egen p2income = sum((povgap/povline)^2*newperwt) if familyhead == 1, by(finccut)
egen newp2income = sum((newpovgap/povline)^2*newperwt) if familyhead == 1, by(finccut)


gen povgaprace = p1race/totalfamrace
gen newpovgaprace = newp1race/totalfamrace
gen povincrace = p2race/totalfamrace
gen newpovincrace = newp2race/totalfamrace

gen povgapincome = p1income/totalfamincome
gen newpovgapincome = newp1income/totalfamincome
gen povincincome = p2income/totalfamincome
gen newpovincincome = newp2income/totalfamincome

gen povgapregion = p1region/totalfamregion
gen newpovgapregion = newp1region/totalfamregion
gen povincregion = p2region/totalfamregion
gen newpovincregion = newp2region/totalfamregion

//EDUC
gen neweduc = 0 if educ == 0
replace neweduc = 1 if educ > 0 & educ <= 2
replace neweduc = 2 if educ > 2 & educ <= 6
replace neweduc = 3 if educ > 6

gen hseduc = 0 if educ <= 5
replace hseduc = 1 if educ == 6 
replace hseduc = 2 if educ > 6

egen p1educ = sum((povgap*newperwt)/povline) if familyhead == 1, by(coleduc)
egen newp1educ = sum((newpovgap*newperwt)/povline) if familyhead == 1, by(coleduc)
egen totalfameduc = sum(newperwt) if familyhead == 1, by(coleduc)

egen p2educ = sum((povgap/povline)^2*newperwt) if familyhead == 1, by(coleduc)
egen newp2educ = sum((newpovgap/povline)^2*newperwt) if familyhead == 1, by(coleduc)

gen povgapeduc = p1educ/totalfameduc
gen newpovgapeduc = newp1educ/totalfameduc
gen povinceduc = p2educ/totalfameduc
gen newpovinceduc = newp2educ/totalfameduc

gen marhh = marst == 1

gen newempstat = empstat
replace newempstat = 1 if empstat != 1 & jobrecipient 

//RACE YD GAP
egen p1raceyd = sum((povgap*newperwt)/povline) if youth & disadvantaged, by(racef)
egen newp1raceyd = sum((newpovgap*newperwt)/povline) if youth & disadvantaged, by(racef)
egen totalfamraceyd = sum(newperwt) if youth & disadvantaged, by(racef)

gen povgapraceyd = p1raceyd/totalfamraceyd
gen newpovgapraceyd = newp1raceyd/totalfamraceyd

bysort racef: tab povgapraceyd
bysort racef: tab newpovgapraceyd

egen p1educyd = sum((povgap/povline)*newperwt) if youth & disadvantaged, by(coleduc)
egen newp1educyd = sum((newpovgap*newperwt)/povline) if youth & disadvantaged, by(coleduc)
egen totalfameducyd = sum(newperwt) if youth & diadvantaged, by(coleduc)

gen povgapeducyd = p1educyd/totalfameducyd
gen newpovgapeducyd = newp1educyd/totalfameducyd

bysort coleduc: tab povgapeducyd
bysort coleduc: tab newpovgapeducyd

egen newfinccut = cut(newincome), at(0,5000,10000,25000,50000,100000,250000,2000000) icodes

save "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie16-finalD2.dta", replace

/*bysort sex: tab jobrecipient [fweight=newperwt]
bysort racesing: tab jobrecipient [fweight=newperwt]
bysort finccut: tab jobrecipient [fweight=newperwt]
bysort educ: tab jobrecipient [fweight=newperwt]*/
