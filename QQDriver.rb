require 'selenium-webdriver'
class WebDriver

  def update_int_qq name, new_policy_num, old_policy_num, premium, coverages
   name=  name.gsub("&", "")

   puts old_policy_num

    # Opens up QQ
    driver = Selenium::WebDriver.for :chrome
    driver.navigate.to 'https://app.qqcatalyst.com/Contacts/Search'

    sleep(2)

    puts 'Please enter password:'
    pass = gets.chomp

    if driver.current_url.include? 'login.qqcatalyst.com'
      # Logs in
      emailField = driver.find_element(name: 'txtEmail')
      emailField.send_keys 'dean@millcreekagency.com'
      passField = driver.find_element(id: 'txtPassword')
      passField.send_keys pass
      driver.find_element(id: 'lnkSubmit').click

      sleep(2)

      if driver.current_url.include? 'login.qqcatalyst.com'
        yes_button = driver.find_element(id: 'lnkCancel')
        yes_button.click
      end
    end

    # Searches for name
    search = driver.find_element(id: 'contact-search-text')
    search.send_keys name
    driver.find_element(id: 'contact-search-go').click

    sleep(2)
    links = driver.find_elements(tag_name: 'a')

    sleep(3)

    first_name = name.split(' ')[0]
    last_name = name.split(' ')[1]
    last_name == '' if last_name == '&'
    links.each do |link|
      if ((link.property(:title).include?(first_name) && link.property(:title).include?(last_name))  or link.property(:title).include? (name.split(' ')[-1])) && link.displayed?
        link.click
        break
      end
    end

    sleep(3)

    driver.find_element(id: 'tab-Policies').click

    sleep(3)

    divs = driver.find_elements(tag_name: 'div')

    divs.each do |div|
      if div.property(:title).include?(old_policy_num) && div.displayed?
        div.click
        break
      end
    end

    sleep(2)

    renewal_button = driver.find_elements(class: 'PolicyActionRenew')

    until renewal_button[0].displayed?
      divs = driver.find_elements(class: 'Label')

      divs.each do |policy_action|
        if (policy_action.attribute('innerHTML') == 'Policy Action') && policy_action.displayed?
          policy_action.click
          end
      end
    end

    sleep(1)

    renewal_button[0].click

    sleep(2)

    submit_yes = driver.find_elements(class: 'yes')

    submit_yes.each do |submit_button|
      if (submit_button.attribute('innerHTML') == 'Yes') && submit_button.displayed?
        submit_button.click
        break
      end
    end

    until driver.current_url.include?('New=true&Mode=basic&extra=issue') && driver.current_url.include?('https://app.qqcatalyst.com/Policies/Policy/Details')
      sleep(2)
    end

    sleep(2)

    driver.find_element(id: 'pb-PolicyInfo').click

    sleep(2)

    policy_no = driver.find_element(name: 'PolicyNo')
    policy_no.clear
    policy_no.send_keys new_policy_num

    driver.find_element(id: 'pb-PolicyQuotes').click

    sleep(3)

    button = driver.find_elements(class: 'listBasedContextRow')[0]

    sleep(1) until button.displayed?

    button.click

    sleep(1)

    quote_info = driver.find_elements(class: 'context-default-edit')

    quote_info.each do |quote|
      if quote.attribute('innerHTML') == 'Edit'
        quote.click
        puts 'RAN'
      end
    end

    sleep(6)
    driver.find_element(name: 'BasePremium').clear
    driver.find_element(name: 'BasePremium').send_keys premium

    driver.find_element(name: 'QuoteSubStatus').find_element(:css, "option[value='S']").click

    home_tab = driver.find_element(id: 'pb-HomeLiabilityLimitsHOME')

    next_btn = driver.find_elements(class: 'basic-next')[0]

    until home_tab.displayed?
      next_btn.click
      sleep(0.5)
    end
    home_tab.click
    home = driver.find_element(id: 'HomeLiabilityLimits')

    sleep(1) until home.displayed?

    home.click

    sleep(2)

    submit_yes = driver.find_elements(name: 'CovLimDed')

    i = 0
    submit_yes.each do |submit_button|
      submit_button.clear
      submit_button.send_keys coverages[i]
      i += 1
    end

    buttonsss = driver.find_elements(name: 'Amount')
    buttonsss.each do |btn|
      next unless btn.displayed?
      btn.clear
      btn.send_keys coverages[i]
      i += 1
      break if i > coverages.size
    end

    finish_button = driver.find_elements(class: 'finish')

    finish_button.each do |button|
      button.click if button.attribute('innerHTML') == 'Finish'
    end

    sleep(3)

    finish_button = driver.find_elements(class: 'finish')

    finish_button.each do |button|
      if (button.attribute('innerHTML') == 'Finish') && button.displayed?
        button.click
        break
      end
    end

    sleep(3)

    driver.find_element(name: 'PremiumSent').find_element(css: "option[value='G']").click

    finish_button = driver.find_elements(class: 'finish')

    finish_button.each do |button|
      if button.attribute('innerHTML').include?('Finish') && button.displayed?
        button.click
        break
        end
    end

    sleep(2)

    submit_yes = driver.find_elements(class: 'btnYes')

    submit_yes.each do |submit_button|
      if submit_button.attribute('innerHTML').include?('Yes') && submit_button.displayed?
        submit_button.click
        break
      end
    end

    sleep(5)

    return_to_policy = driver.find_elements(class: 'returntoentity')[0]

    until return_to_policy.displayed? do
      if (return_to_policy.attribute('innerHTML') == 'Return to policy')
        retrun_to_policy.click
      end
    end

    sleep(10)
  end
end
