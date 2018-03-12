require 'selenium-webdriver'

users = File.read("usersAndPasswords.txt")
@loginEmail = users[users.index("loginEmail:")+12..users.index("\n", users.index("loginEmail:"))]
@loginPass = users[users.index("loginPass:")+11..-1]
@loginPass.chomp
def updateInQQ
    #Opens up QQ
    driver = Selenium::WebDriver.for :chrome
    driver.navigate.to "https://app.qqcatalyst.com/Contacts/Search"
    #Logs in
    emailField = driver.find_element(name: 'txtEmail')
    emailField.send_keys @loginEmail
    passField = driver.find_element(id: 'txtPassword')
    passField.send_keys @loginPass
    #Searches for name
    search = driver.find_element(id: 'contact-search-text')
    search.send_keys @oh.searchTerm
    search.submit
end
