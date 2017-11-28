def sendLetterToInsured policyNum, fname, pass
  Pony.mail({
    :to => "Brittany@millcreekagency.com",#"Brittany@millcreekagency.com",
    :from => 'Bryce Thuilot <bryce@millcreekagency.com>',
    :html_body => "Could you please mail this letter and pages 2 - 4 of this policy to the insured. If there is a mortgage please mail pages 3 & 4 to them. Thank you",
    :subject => "Letter to mail",
    :attachments => { "#{policyNum}.pdf" => File.read(fname), "#{policyNum.chomp}.rtf" => File.read("/Users/brycethuilot/Work/send-out/#{policyNum.chomp}.rtf") },
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
end

def sendLetterToMortgage policyNum, fname, pass
  Pony.mail({
    :to => "Brittany@millcreekagency.com",
    :from => 'Bryce Thuilot <bryce@millcreekagency.com>',
    :html_body => "Could you please mail pages 3 & 4 to the mortgage please, thank you",
    :subject => "Letter to mail",
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
end
