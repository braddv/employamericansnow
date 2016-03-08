import csv
import sys

def add_data(arg):
  newdata = []
  statedata = []
  fields = []
  with open(arg,'rb') as statefile:
    statereader = csv.reader(statefile)
    statereader.next()
    for row in statereader:
      statedata.append(row[1])
  with open('nst_2011.csv','rb') as datafile:
    reader = csv.reader(datafile)
    fields = reader.next()
    for x in range(0,5):
      reader.next()
    i = 0
    for row in reader:
      try:
        row.append(statedata[i])
        newdata.append(row)
      except:
        break
      i += 1
  datafile.close()
  statefile.close()
  print(newdata)
  with open('nst_2011n.csv','w') as newfile:
    writer = csv.writer(newfile)
    writer.writerow(fields)
    for row in newdata:
      print(row)
      writer.writerow(row)

  newfile.close()
    
if __name__ == "__main__":
  add_data(sys.argv[1])
