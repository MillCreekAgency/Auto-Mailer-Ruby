
def printLetter nameOH, addressOH, policyNum
  policyNum = policyNum.chomp
  system("cp Renewal.rtf #{policyNum}.rtf")
  # load the file as a string
  data = File.read("Renewal.rtf")
  names = nameOH.split(" ")
  addresses = addressOH.split(" ", 2)
  number = addresses[0]
  street = addresses[1].split("\n")
  type = street[0].rpartition(' ').last
  namename = street[0].rpartition(' ').first.split(' ')
  data = data.gsub("DATE", DateTime.now.strftime('%A %B %d, %Y'))
  data = data.gsub("FIRST_NAME", names[0])
  data = data.gsub("FULL_NAME", name)
  data = data.gsub("STREET_NUMBER", number)
  data = data.gsub("STREET_ADDRESS", namename[0])
  if(namename.length >= 2)
    data = data.gsub("TREET_ADDRESS", namename[1])
  else
    data = data.gsub("TREET_ADDRESS", "")
  end
  if(namename.length >= 3)
    data = data.gsub("REET_ADDRESS", namename[2])
  else
    data = data.gsub("REET_ADDRESS", "")
  end
  if( namename.length >= 4)
    data = data.gsub("EET_ADDRESS", namename[3])
  else
    data = data.gsub("EET_ADDRESS", "")
  end
  data = data.gsub("STREET_TYPE", street[0].split(" ").last)
  data = data.gsub("TOWN", street[1].rpartition(' ')[0].rpartition(' ').first)
  data = data.gsub("STATE", street[1].rpartition(' ')[0].rpartition(' ').last)
  data = data.gsub("ZIP", street[1].rpartition(' ').last)
  data = data.gsub("NUMBER_OF_POLICY", policyNum[policyNum.index("H")+1..-1])
  # open the file for writing
  File.open("#{policyNum}.rtf", "w") do |f|
    f.write(data)
  end
  system("mv #{policyNum}.rtf /Users/brycethuilot/not-work/send-out/")
end
