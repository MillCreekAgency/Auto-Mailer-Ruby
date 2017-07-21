require_relative 'OceanHarbor.rb'
require_relative 'QQDriver.rb'
puts "Enter filename:"
fname = gets.chomp
fname = fname.strip

#puts "What type of policy are you looking to renew"
#puts "Ocean Harbor (OH) or Narraganset Bay (NB)"
#type_of_policy = gets.chomp
#Only one type right now
type_of_policy = "oh"
if type_of_policy.downcase == "oh" || type_of_policy.downcase == "ocean harbor"
  @oh = OceanHarbor.new
  @oh.getInfoFromPolicy fname
  @oh.printInfo
  #It's not time yet
  #updateInQQ
#elsif type_of_policy == "nb" || type_of_policy == "Narraganset Bay"

end
