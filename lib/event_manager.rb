require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'



def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
    # legislators = legislators.officials

    # legislator_names = legislators.map do |legislator|
    #   legislator.name
    # end

    # legislators_string = legislator_names.join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials' 
  end
end  

def clean_zipcode(zipcode)
  if zipcode.nil?
    zipcode = "00000"
  elsif zipcode.length < 5
    zipcode = zipcode.rjust(5, "0")
  elsif zipcode.length > 5
    zipcode = zipcode[0..4]
  else 
    zipcode  
  end
end

def claen_phone_number(phone_number)
  phone_number = phone_number.gsub("-", "")
  
  if phone_number.length < 10
    phone_number = "Bad number"
  elsif phone_number.length == 10
    phone_number = phone_number
  elsif phone_number.length == 11 && phone_number[0] == 1
    phone_number = phone_number[1..11]  
  elsif phone_number.length == 11 && phone_number[0] != 1
    phone_number = "Bad number" 
  elsif phone_number.length > 11
    phone_number = "Bad number" 
  else
    phone_number  
  end
end


def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "Event Manager Initialized"

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents = CSV.open(
    'event_attendees.csv', 
    headers: true,
    header_converters: :symbol
)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = claen_phone_number(row[:homephone])


  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  #save_thank_you_letter(id,form_letter)
  puts phone_number
end  



# If the phone number is less than 10 digits, assume that it is a bad number
# If the phone number is 10 digits, assume that it is good
# If the phone number is 11 digits and the first number is 1, trim the 1 and use the remaining 10 digits
# If the phone number is 11 digits and the first number is not 1, then it is a bad number
# If the phone number is more than 11 digits, assume that it is a bad number

#Cleaning phone numbers


 