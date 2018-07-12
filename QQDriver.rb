require 'selenium-webdriver'

# Used for testing
policy_num = "CCH016155-05"
name = "Mary Mill" 
premium = "666"
coverages = [1,2,3,4,5,6,7,8]

#Opens up QQ
driver = Selenium::WebDriver.for :chrome
driver.navigate.to "https://app.qqcatalyst.com/Contacts/Search"

sleep(2)

puts "Please enter password:"
pass = gets.chomp

if driver.current_url.include? "login.qqcatalyst.com"
    #Logs in
    emailField = driver.find_element(name: 'txtEmail')
    emailField.send_keys "dean@millcreekagency.com"
    passField = driver.find_element(id: 'txtPassword')
    passField.send_keys pass 
    driver.find_element(id: "lnkSubmit").click

    sleep(2)

    if driver.current_url.include? "login.qqcatalyst.com"
        yes_button = driver.find_element(id: "lnkCancel")
        yes_button.click
    end
end

#Searches for name
search = driver.find_element(id: 'contact-search-text')
search.send_keys name
driver.find_element(id: "contact-search-go").click

sleep(2)
links = driver.find_elements(tag_name: "a")

sleep(3)
links.each do |link|
    if link.property(:title).include? name.split(" ")[-1] and link.displayed?
        link.click
        break
    end
end

sleep(3)

driver.find_element(id: "tab-Policies").click

sleep(3)

divs = driver.find_elements(tag_name: "div")

divs.each do |div|
    if div.property(:title).include? policy_num and div.displayed?
        div.click
        break
    end
end

sleep(2)

divs = driver.find_elements(class: "Label")

divs.each do |policy_action|
    if policy_action.attribute("innerHTML") == "Policy Action" and policy_action.displayed?
        policy_action.click
        policy_action.click
        puts "Ran"
    end
end

sleep(1)

renewal_button = driver.find_elements(class: "PolicyActionRenew")

renewal_button[0].click

sleep(2)

submit_yes = driver.find_elements(class: "yes")


submit_yes.each do |submit_button|
    if submit_button.attribute("innerHTML") == "Yes" and submit_button.displayed?
        submit_button.click
        break
    end
end

until driver.current_url.include? "New=true&Mode=basic&extra=issue" and driver.current_url.include? "https://app.qqcatalyst.com/Policies/Policy/Details"do
    sleep(2)
end

sleep(2)


driver.find_element(id: "pb-PolicyInfo").click

sleep(2) 

driver.find_element(name: "PolicyNo").send_keys "TEST"


driver.find_element(id: "pb-PolicyQuotes").click

sleep(3)

quote_info = driver.find_elements(class: "quotecarrier")

quote_info.each do |quote|
    if quote.property(:title) == "Ocean Harbor Casualty" and quote.displayed?
        quote.click
    end
end


quote_info = driver.find_elements(class: "context-default-edit")

quote_info.each do |quote|
    if quote.attribute("innerHTML") == "Edit"
        quote.click
    end
end

sleep(6)

driver.find_element(name: "basePremium").send_keys premium 

driver.find_element(name: "QuoteSubStatus").find_element(:css,"option[value='S']").click


submit_yes = driver.find_elements(class: "section_save")


submit_yes.each do |submit_button|
    if submit_button.attribute("innerHTML") == "Save" and submit_button.displayed?
        submit_button.click
        break
    end
end


sleep(2)

driver.find_element(id: "pb-HomeLiabilityLimitsHOME").click

sleep(3)

submit_yes = driver.find_elements(name: "CovLimDed")

i = 0
submit_yes.each do |submit_button|
    submit_button.send_keys coverages[i]
    i += 1
end

finish_button = driver.find_elements(class: "finish")

finish_button.each do |button| 
    if button.attribute("innerHTML") == "Finish"
        button.click
    end
end

sleep(3)

driver.find_element(name: "PremiumSent").find_element(css: "option[value='G']").click


finish_button = driver.find_elements(class: "finish")

finish_button.each do |button| 
    if button.attribute("innerHTML") == "Finish"
        button.click
    end
end

sleep(3)

submit_yes = driver.find_elements(class: "btnYes")


submit_yes.each do |submit_button|
    if submit_button.attribute("innerHTML").include? "Yes" and submit_button.displayed?
        submit_button.click
        break
    end
end

sleep(5)

return_to_policy = driver.find_elements(class: "returntoentity")

return_to_policy.each do |button|
    if button.attribute("innerHTML") == "Return to policy" and button.displayed?
        button.click
    end
end

sleep(10)
