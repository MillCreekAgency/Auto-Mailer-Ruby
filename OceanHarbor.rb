require 'yomu' #Used for getting text
require_relative 'sendRenewal.rb'
require_relative 'PrintLetter.rb'
require_relative 'sendLetterToPrint.rb'

class OceanHarbor
  attr_accessor :name, :address, :policyNum, :coverageA, :coverageB, :coverageC, :coverageD, :coverageE, :coverageF, :deductable, :premium, :hurriDed, :effectiveDate, :expireDate, :searchTerm, :mortgagee
  def getInfoFromPolicy(fname)
    # Get file
    file = Yomu.new(fname).text

    # Get name and address
    nameAddress = file[(file.index("Insured\n") + 8)..-1]
    nameAddress = nameAddress[0..nameAddress.index("\n\n")]

    ## Get the name of the insured
    @name = nameAddress[0..nameAddress.index("\n")].strip

    ## Get the address of the insured
    @address = nameAddress[nameAddress.index("\n") + 1..-1]


    # Get the policy number
    @policyNum = file[file.index("POLICY NUMBER")-13..file.index("POLICY NUMBER") -1]

    # Get all policy info
    policyInfo = file[file.index("Name Insured:")..file.index("HO Dec Page")]

    ## Coverages (A, B, C, D, Personal Liability, Medical Payments)
    @coverageA = policyInfo[policyInfo.index("Building ")+9..policyInfo.index("Building ")+20]
    @coverageB = policyInfo[policyInfo.index("Other Structure ")+16..policyInfo.index("Other Structure ")+26]
    @coverageC = policyInfo[policyInfo.index("Personal Property ")+18..policyInfo.index("Personal Property ")+28]
    @coverageD = policyInfo[policyInfo.index("Loss of Use ")+12..policyInfo.index("Loss of Use ")+23]
    @coverageE = policyInfo[policyInfo.index("Personal Liability ")+19..policyInfo.index("Personal Liability ")+27]
    @coverageF = policyInfo[policyInfo.index("Medical Payments to Others ")+27..policyInfo.index("Medical Payments to Others ")+34].chomp

    ## Deductable
    @deductable = policyInfo[policyInfo.index("otherwise")+11..policyInfo.index("otherwise")+16]

    ## Permium
    @premium = policyInfo[policyInfo.index("Total Policy Premium: ")+22..policyInfo.index("Total Policy Premium: ")+30].chomp

    ## Hurricane Deductable
    @hurriDed = policyInfo[policyInfo.index("Ded.: ")+6..policyInfo.index("Ded.: ")+8]

    ## Mortgagee
    if file.include?("& Provisions\n")
      @mortgagee = file[file.index("& Provisions\n")+14..file.index("IMPORTANT NOTICE TO POLICY")-3]
    else
      @mortgagee = " N/A "
    end

    ## Find effective and experation dates
    dates = file[file.index("FROM TO")+9..file.index("\n",file.index("FROM TO")+10)]
    dates = dates.split(" ")


    ## Print name for searching
    puts ""
    puts "Insured Name: " + @name.chomp
    puts ""
    @effectiveDate = dates[0]
    @expireDate = dates[1]

    ## Ask to mail
    puts "\n Do you wish to email insured or send a letter? (e for email / l for letter)"
    response = gets.chomp
    if response == "e"
      puts " "
      pass = ask("Password: ") { |q| q.echo="*"}
      mail = Mailer.new
      mail.sendMail(@name, "Ocean Harbor Casualty", @policyNum, fname, @effectiveDate, @expireDate, pass)
      brit = ask("Send to Mill Creek to mail? (y/n)")
      if brit == "y"
        sendLetterToMortgage @policyNum, fname, pass
      else
        puts "not sending"
      end
    elsif response == "l"
      printLetter @name, @address, @policyNum
      puts " "
      pass = ask("Password: ") { |q| q.echo="*"}
      brit = ask("Send to Mill Creek to mail? (y/n)")
      if brit == "y"
        sendLetterToInsured @policyNum, fname, pass
      else
        puts "not sending"
      end
    end
  end
  def printInfo
    puts "Name Insured:\n" + @name + "\n\n"
    puts "Address:\n" + @address + "\n"
    puts "Policy Number:\n" + @policyNum + "\n"
    puts "Coverages:\n" + "Coverage A: " + @coverageA + "\nCoverage B: " + @coverageB + "\nCoverage C: " +@coverageC +"\nCoverage D: " +@coverageD +"\nCoverage E: " + @coverageE + "\nCoverage F: " + @coverageF + "\n"
    puts "Deductible: " + @deductable + ", Premium: " + @premium + ", Hurricane Deductible: " + @hurriDed
    puts "Effective Date: " + @effectiveDate + ", Expiration Date: " + @expireDate + "\n"
    puts "Mortgagee: " + @mortgagee + "\n"
  end
end
