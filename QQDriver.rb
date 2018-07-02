require 'selenium-webdriver'

#Opens up QQ
driver = Selenium::WebDriver.for :chrome
driver.navigate.to "https://app.qqcatalyst.com/Contacts/Search"

sleep(2)

policy_num = "CCH016155-04"
name = "Mary Mill" 

if driver.current_url.include? "login.qqcatalyst.com"
    #Logs in
    emailField = driver.find_element(name: 'txtEmail')
    emailField.send_keys "dean@millcreekagency.com"
    passField = driver.find_element(id: 'txtPassword')
    passField.send_keys "Mill1225"
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

sleep(4)

driver.find_element(id: "tab-Policies").click

sleep(4)

divs = driver.find_elements(tag_name: "div")

divs.each do |div|
    if div.property(:title).include? policy_num and div.displayed?
        div.click
        break
    end
end




