
use "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie13-egen.dta", clear
gen runningwt = 0
gen prevwt = 0 
save "/Users/braddv/Desktop/BERNIE/employamericansnow/bernie5-1.dta", replace
keep if familyheadydandnotemp
bysort statefip puma: gen pumaid = _n
bysort statefip puma (headmaxyouthempp): replace runningwt = sum(perwt)
//use (headmaxyouthempp) or (invheadmaxyouthempp) above depending if you want min or max likelihood
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

bysort sex: tab jobrecipient [fweight=newperwt]
bysort racesing: tab jobrecipient [fweight=newperwt]
bysort finccut: tab jobrecipient [fweight=newperwt]
bysort educ: tab jobrecipient [fweight=newperwt]
