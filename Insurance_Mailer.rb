#!/bin/usr/env ruby
require 'yomu'
require 'pony'
require 'io/console'
require_relative 'QQDriver.rb'

# Copyright Bryce Thuilot 2018

WORK_FOLDER="/Users/bryce/policies"

# mail_to_insured: String -> Void
# Takes a given PDF filename, reads pdf and sends an email to the insured
def mail_to_insured(filename)
  user_info = get_info_from_policy filename
  print 'Send email to insured? [Y/n] '
  send_email = gets.chomp
  if send_email == 'n'
    print 'Send letter to insured? [Y/n] '
    send_letter = gets.chomp
    if send_letter != 'n'
      make_letter user_info[:name], user_info[:address], user_info[:policy_num]
    end
  else
    print 'Enter email of insured: '
    email = gets.chomp
    renewal = user_info[:policy_num].strip.chomp[-2..-1] != '00'
    subject = renewal ? 'Insurance Renewal' : 'Insurance Policy'
    mail email, subject,
         format_body(user_info[:name], user_info[:policy_num],
                     user_info[:dates], renewal), { "#{user_info[:policy_num]}.pdf" => File.read(filename)}
  end
  print 'Send to Mill Creek to Mail? [Y/n] '
  send_to_mc = gets.chomp
  if send_to_mc != 'n'
    send_to_mill_creek filename, send_email == 'n', "#{WORK_FOLDER}/send-out/#{user_info[:policy_num].to_s}.rtf"
  end
  print_info user_info
  system("mv #{filename} #{WORK_FOLDER}/send-out/")
end

# get_info_from_policy: String -> Hash {String, String, String,
#   [List-of String], String, String, String, [List-of String]}
# Given a PDF filename, it will extract the data to a hash
def get_info_from_policy(filename)
  # Get file
  file = Yomu.new(filename).text

  # Get name and address
  name_and_address = file[(file.index("Insured\n") + 8)..-1]
  name_and_address = name_and_address[0..name_and_address.index("\n\n")]

  # put name and address into array (name first)
  name_and_address_arr = name_and_address.split("\n", 2)

  # Get the policy number
  policy_num = file[file.index('POLICY NUMBER') - 13..file.index('POLICY NUMBER') - 1].strip

  # Get all policy info
  policy_info = file[file.index('Name Insured:')..file.index('Additional Interest:')]


  ## Coverages (A, B, C, D, Personal Liability, Medical Payments)
  if policy_num[2] == 'H'
      coverages = get_ho_coverages(policy_info)
  else
      coverages = get_dwelling_coverages(policy_info)
  end

  #coverage_a = cut_section(policy_info, 'Building ', 11)
  #coverage_b = cut_section(policy_info, 'Other Structure ', 10)
  #coverage_c = cut_section(policy_info, 'Personal Property ', 11)
  #coverage_d = cut_section(policy_info, 'Loss of Use ', 11)
  #coverage_e = cut_section(policy_info, 'Personal Liability ', 8)
  #coverage_f = cut_section(policy_info,'Medical Payments to Others ', 7).chomp

  ## Deductible
  deductible = cut_section(policy_info, "otherwise\n\n", 6)

  ## Premium
  premium = cut_section(policy_info, 'Total Policy Premium: ', 8)

  ## Hurricane Deductible
  hurricane_ded = cut_section(policy_info, 'Ded.: ', 2)

  ## Mortgagee
  # TODO Add mortgagee support

  ## Find effective and expiration dates
  dates = file[file.index('FROM TO') + 9..
                   file.index("\n", file.index('FROM TO') + 10)]
  dates = dates.split(' ')

  ## Print name for searching
  puts ''
  puts 'Insured Name: ' + name_and_address_arr[0].to_s
  puts ''
  user_info = {
      name: name_and_address_arr[0].to_s,
      address: name_and_address_arr[1].to_s,
      policy_num: policy_num,
      coverages: coverages,
      deductible: deductible,
      premium: premium,
      hurricane_ded: hurricane_ded,
      dates: dates
  }
  return user_info
end

# cut_section: String, String, Int -> String
# Cuts a given string from after the index of the other given string for a given length
def cut_section(str, index, length)
  starting_index = str.index index
  if starting_index.nil?
    return nil
  end
  str[starting_index + index.length...starting_index + index.length + length]
end

# Cuts a string from index of from and to the index of to
# cut_to_from: String, String, String
def cut_to_from(str, from, to)
    from_index = str.index from
    to_index = str.index to, from_index
    str[from_index + from.length..to_index]
end

# get_ho_coverages: String -> [List-of String]
# Gets the coverages of homeowners
def get_ho_coverages(policy_info)
  coverage_a = cut_section(policy_info, 'Building ', 11)
  coverage_b = cut_section(policy_info, 'Other Structure ', 10)
  coverage_c = cut_section(policy_info, 'Personal Property ', 11)
  coverage_d = cut_section(policy_info, 'Loss of Use ', 11)
  coverage_e = cut_section(policy_info, 'Personal Liability ', 8)
  coverage_f = cut_section(policy_info,'Medical Payments to Others ', 7).chomp
  return [coverage_a, coverage_b, coverage_c, coverage_d, coverage_e, coverage_f]
end

# Gets the coverages of a Dwelling Policy
# get_dwelling_coverages: String -> [List-of String]
# TODO finish this
def get_dwelling_coverages(policy_info)
  dwelling = cut_section(policy_info, "Dwelling ", 12).chomp
  other_structure = cut_section(policy_info, "Other Structure ", 11).chomp
  personal_property = cut_to_from(policy_info, "Personal Property", "  ")
  fair_rental_value = cut_to_from(policy_info, "Fair Rental Value","\n")
  additional_living_expense = cut_to_from(policy_info, "Additional Living Expense", "\n").chomp
  personal_liability = cut_to_from(policy_info, "Personal Liability", "\n").chomp
  medical_payments = cut_to_from(policy_info, "Medical Payments to Others ", "\n").chomp
  personal_injury = cut_to_from(policy_info, "Personal Injury", "\n").chomp
  
  return [dwelling, other_structure, personal_property, fair_rental_value, additional_living_expense, personal_liability, medical_payments, personal_injury]
end

# format_body: String, String, [List-of String], boolean -> String
# Formats the user_info into
def format_body(name, policy_num, dates, renewal)
  if renewal
    message_body = "<p>Enclosed, please find a copy of your policy renewal.</p>
       <p></p>
      <p>Because we value you as a client and policyholder, we would appreciate the opportunity to continue serving all your insurances needs. This is also a great time to discuss your coverage options, any changes that may need to be made, and any discounts you may be qualified to receive.</p>
       <p></p>
      <p>Kindly review enclosed documents for accuracy. Please feel free to call us at (631)751-4653 any time Monday through Friday between 9 a.m.and 5 p.m. We can take care of everything by telephone, or schedule an appointment to meet at your convenience.</p>
       <p></p>
      <p>I hope we've done everything possible to earn your future insurance business. I look forward to speaking with you soon and would like to say thank you again for choosing The Mill Creek Agency, Inc. </p>
       <p></p>
      <p>If you have any further questions please contact Info@millcreekagency.com. Please do not reply to this email.</p>"
  else
    message_body = "<p>Thank you for choosing the Mill Creek Agency for your insurance necessities! We appreciate folks who share our sensibilities and believe there is value in keeping things personal. We believe that comfort is parallel to security, and we will always make sure that you feel protected by accurate coverage and friendly, familiar customer service. To us, you aren’t a number, you’re our valued client.</p>
       <p></p>
      <p>Enclosed, please find a copy of your new insurance policy with the effective date of #{dates[0]} and a expiration date of #{dates[1]}. If you ever need assistance understanding your policy, counsel on any life changes that may affect your coverage needs, or simply need to pay a bill, we will be more than happy to provide you with these services and anything else within our scope of knowledge if you give us a call at 631-751-4653.</p>
       <p></p>
      <p>Kindly review enclosed documents for accuracy. Please feel free to call us at (631)751-4653 any time Monday through Friday between 9 a.m.and 5 p.m. We can take care of everything by telephone, or schedule an appointment to meet at your convenience.</p>
       <p></p>
      <p>I hope we've done everything possible to earn your future insurance business. I look forward to speaking with you soon, and would like say thank you again for choosing The Mill Creek Agency, Inc. </p>
       <p></p>
      <p>If you have any further questions please contact Info@millcreekagency.com. Please do not reply to this email.</p>"
  end

  message = %Q(
      <span style='font-family: "Times New Roman", Times, serif'>
      <center><h2>**DO NOT REPLY TO THIS EMAIL**</h2></center>
      <p></p>
      <center><p>***ANY QUESTIONS/CONCERNS PLEASE CONTACT OUR OFFICE DIRECTLY***</p></center>
      <center><p>**Please ignore this message if you have already received this**</p></center>
       <p></p>
      <p>Dear #{name},</p>
       <p></p>
      <p>RE: Company: <strong>Ocean Harbor Casualty</strong></p>
       <p></p>
      <p>Policy Number: <strong>#{policy_num}</strong></p>
       <p></p>
       #{message_body}
      <p></p>
      <p></p>
      <span style='color: #64191E; line-height: 50%;'>
      <p>Thank you,</p>
      <h2>Bryce S. Thuilot</h2>
      <h3>Administrative Assistant</h3>
      <p>129A Main St.</p>
      <p>Stony Brook, NY 11790</p>
      <p>P-631-751-4653</p>
      <p>F-631-751-4512</p>
      </span>
      </span>
      <span style='font-size: 10px;'><p>This email was sent from an automated mail distrubutor. Please let us know if there are any issues <a href='mailto:info@maillcreekagency.com'>here</a></p>
      )
  return message
end

# send_letter: String, String, String -> Void
# Formats the Renewal.rtf to be sent to Mill Creek
def make_letter(name, address, policy_num)
  data = File.read('RenewalLetter.rtf')
  data = data.gsub('DATE', DateTime.now.strftime('%A %B %d, %Y'))
  data = data.gsub('FIRST_NAME', name.split(' ')[0])
  data = data.gsub('FULL_NAME', name)
  data = data.gsub('ADDRESS', address.gsub("\n", "\\\n"))
  data = data.gsub('NUMBER_OF_POLICY', policy_num)
  File.open("#{WORK_FOLDER}/send-out/#{policy_num}.rtf", "w") do |f|
    f.write(data)
  end
end

# mail: String, String, String, Hash { String => File} -> Void
# Sends mail to a given email with a given subject, body, attachment and location of attachment
def mail(to_address, subject, body, attachment_hash)
  sent = false
  while !sent
	  print 'Enter password to email: '
	  pass = STDIN.noecho(&:gets).chomp
	  puts "\nSending email..."
	  begin
	  Pony.mail(
	      to:  to_address,
	      from:  'Bryce Thuilot <bryce@millcreekagency.com>',
	      html_body:  body,
	      subject:  subject,
	      attachments: attachment_hash,
	      via:  :smtp,
	      via_options:  {
		  address:         'smtp.office365.com',
		  port:		   '587',
		  enable_starttls_auto:  true,
		  user_name:       'bryce@millcreekagency.com',
		  password:        pass,
		  authentication:  :login
		  #domain:          'localhost.localdomain' # Not important
	      }
	  )
	  rescue Net::SMTPAuthenticationError
		  puts 'the password you entered is wrong, want to try again [Y/n]'
		  if gets.chomp[0] == 'n'
			  sent = true
		  end
	  else
	  # Log mail sent
	  open('sentMail.log', 'a') do |f|
	    f.puts "#{Time.now.inspect}: Mail sent to #{to_address.chomp}, with subject #{subject.chomp} \n"
	  end
	  sent = true
	  puts 'Email successfully sent!'
	  end
  end
end

# send_to_mill_creek: String, boolean -> Void
# Emails the file to MillCreek to mail out
def send_to_mill_creek(filename, letter, letter_filename)
  file_hash = {filename.split('/')[-1] => File.read(filename)}
  if letter
    html_body = 'Can you please mail this to the insured and to the mortgagee if there is one'
    file_hash[letter_filename.split('/')[-1]] = letter_filename
  else
    html_body = 'Can you send this to the mortgagee if there is one'
  end
  mail 'brittany@millcreekagency.com', 'Policy', html_body, file_hash
end

# print_info: Hash {String, String, String,
#   [List-of String], String, String, String, [List-of String]} -> Void
# Prints the user info
def print_info(user_info)
  puts "
  Insured name: #{user_info[:name]}
  Policy number: #{user_info[:policy_num]}
  Address:
    #{user_info[:address].gsub("\n", "\n    ")}
  Coverages:
  "
  letter = 65
  user_info[:coverages].each do |coverage|
    puts "  #{letter.chr}: #{coverage}"
    letter += 1
  end
  puts "
  Premium: #{user_info[:premium]}
  Deductible: #{user_info[:deductible]}
  Hurrican Deductible #{user_info[:hurricane_ded]}
  Effective Date #{user_info[:dates][0]}
  Expiration Date #{user_info[:dates][1]}"

  qq = WebDriver.new
  qq.update_int_qq user_info[:name], user_info[:policy_num], get_previous_num(user_info[:policy_num]), user_info[:premium].gsub("$", ""), user_info[:coverages].push(user_info[:deductible].gsub('$', '').gsub(',', '')).push(user_info[:hurricane_ded].gsub('%', ''))
end

def get_previous_num policy_num
  return policy_num[0..-2] + (policy_num[-1].to_i - 1).to_s
end


# Main Loop
# Gets the filename from user if not supplied
if !ARGV.empty?
  fname = ARGV[0].strip
else
  puts 'Enter filename:'
  fname = gets.chomp.strip
end

mail_to_insured fname
