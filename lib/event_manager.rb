require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'



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

def clean_phone_number(phone_number)
  phone_number = phone_number.gsub("-", "")
  phone_number = phone_number.gsub("(", "")
  phone_number = phone_number.gsub(")", "")

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

def count_max(array)
  array.max_by {|item| array.count(item)}
end  

puts "Event Manager Initialized"

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents = CSV.open(
    'event_attendees.csv', 
    headers: true,
    header_converters: :symbol
)
dates = []
hours_of_day = []
wdays = []
index = 0
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = clean_phone_number(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])

  reg_date = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M")
  hours_of_day[index] = reg_date.hour
  wdays[index] = reg_date.wday
  dates[index] = reg_date
  index += 1
  

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
  #puts phone_number
  # puts wdays[index]
end 
#convert wdays in actual day names of the week
days_of_week = []
wdays.each_with_index do |day, index|
  case day
  when 0
    days_of_week[index] = "Monday"
  when 1
    days_of_week[index] = "Tuesday"
  when 2
    days_of_week[index] = "Wednesday"
  when 3 
    days_of_week[index] = "Thursday"
  when 4
    days_of_week[index] = "Friday"
  when 5
    days_of_week[index] = "Saturday" 
  else 
    days_of_week[index] = "Sunday" 
  end       
end  

puts "The most active Hour is: #{count_max(hours_of_day)}:00 hours"
puts "The most active Day is #{count_max(days_of_week)}"




 