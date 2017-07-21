require 'pony'

class Mailer
  def sendMail(name, company, policyNum, fname, effectiveDate, expireDate)
    if( policyNum.strip.chomp[-2..-1] != "00")
      html_body = %Q(
      <span style='font-family: "Times New Roman", Times, serif'>
      <center><h2>**DO NOT REPLY TO THIS EMAIL**</h2></center>
      <p></p>
      <center><p>***ANY QUESTIONS/CONCERNS PLEASE CONTACT OUR OFFICE DIRECTLY***</p></center>
      <center><p>**Please ignore this message if you have already received this**</p></center>
       <p></p>
      <p>Dear #{name},</p>
       <p></p>
      <p>RE: Company: <strong>#{company}</strong></p>
       <p></p>
      <p>Policy Number: <strong>#{policyNum}</strong></p>
       <p></p>
      <p>Enclosed, please find a copy of your policy renewal.</p>
       <p></p>
      <p>Because we value you as a client and policyholder, we would appreciate the opportunity to continue serving all your insurances needs. This is also a great time to discuss your coverage options, any changes that may need to be made, and any discounts you may be qualified to receive.</p>
       <p></p>
      <p>Kindly review enclosed documents for accuracy. Please feel free to call us at (631)751-4653 any time Monday through Friday between 9 a.m.and 5 p.m. We can take care of everything by telephone, or schedule an appointment to meet at your convenience.</p>
       <p></p>
      <p>I hope we've done everything possible to earn your future insurance business. I look forward to speaking with you soon, and would like say thank you again for choosing The Mill Creek Agency, Inc. </p>
       <p></p>
      <p>If you have any further questions please contact Info@millcreekagency.com. Please do not reply to this email.</p>
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
      type="Renewal"
    else
      html_body = %Q(
      <span style='font-family: "Times New Roman", Times, serif'>
      <center><h2>**DO NOT REPLY TO THIS EMAIL**</h2></center>
      <p></p>
      <center><p>***ANY QUESTIONS/CONCERNS PLEASE CONTACT OUR OFFICE DIRECTLY***</p></center>
      <center><p>**Please ignore this message if you have already received this**</p></center>
       <p></p>
      <p>Dear #{name},</p>
       <p></p>
      <p>RE: Company: <strong>#{company}</strong></p>
       <p></p>
      <p>Policy Number: <strong>#{policyNum}</strong></p>
       <p></p>
      <p>Thank you for choosing the Mill Creek Agency for your insurance necessities! We appreciate folks who share our sensibilities and believe there is value in keeping things personal. We believe that comfort is parallel to security, and we will always make sure that you feel protected by accurate coverage and friendly, familiar customer service. To us, you aren’t a number, you’re our valued client.</p>
       <p></p>
      <p>Enclosed, please find a copy of your new insurance policy with the effective date of #{effectiveDate} and a expiration date of #{expireDate}. If you ever need assistance understanding your policy, counsel on any life changes that may affect your coverage needs, or simply need to pay a bill, we will be more than happy to provide you with these services and anything else within our scope of knowledge if you give us a call at 631-751-4653.</p>
       <p></p>
      <p>Kindly review enclosed documents for accuracy. Please feel free to call us at (631)751-4653 any time Monday through Friday between 9 a.m.and 5 p.m. We can take care of everything by telephone, or schedule an appointment to meet at your convenience.</p>
       <p></p>
      <p>I hope we've done everything possible to earn your future insurance business. I look forward to speaking with you soon, and would like say thank you again for choosing The Mill Creek Agency, Inc. </p>
       <p></p>
      <p>If you have any further questions please contact Info@millcreekagency.com. Please do not reply to this email.</p>
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
      type ="New Buisness"
    end
    puts "Type: #{type}"
    puts " "
    puts "Enter email to send to: (If N/A please write 'n')"
    sendTo = gets.chomp
    puts ""
    if !(sendTo == "n")
      puts "Does #{name} and #{policyNum.chomp} seem correct?"
      puts " "
      puts "Enter your email password to continue"
      pass = gets.chomp
      puts ""
      type == "Renewal" ? subject = "Insurance Renewal" : subject = "Insurance Policy"
      Pony.mail({
        :to => sendTo,
        :from => 'Bryce Thuilot <bryce@millcreekagency.com>',
        :html_body => html_body,
        :subject => subject,
        :attachments => { "#{policyNum}.pdf" => File.read(fname) },
        :via => :smtp,
        :via_options => {
          :address        => 'smtp.office365.com',
          :port           => '587',
          :enable_starttls_auto => true,
          :user_name      => 'bryce@millcreekagency.com',
          :password       => pass,
          :authentication => :login,
          # :domain         => "localhost.localdomain" # Not important
        }
      })
      puts "Email succesfully sent"
      open('sentMail.log', 'a') do |f|
        f.puts "#{Time.now.inspect}: Mail sent to #{sendTo.chomp}, #{name.chomp}, #{policyNum.chomp}, #{type} \n"
      end
    end
  end
end
