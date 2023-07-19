require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'


def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,'0')[0..4]
end 

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key= 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
    
    begin
        legislators = civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody','legislatorLowerBody']
        )
        legislators = legislators.officials
        legislators_names = legislators.map(&:name)
        legislators_names.join(",")
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
     
    end
end

def goodorbad(number)
    if number.length > 11
        [number,"wrong number"]
    elsif number.length >10
        if number[0]==1
            [number[1..10],"good number"]
        else
            [number,"wrong number"]
        end 
    elsif number.length < 10
        [number,"wrong number"]
    else
        [number,"good number"]
    end
end


def clean_phonenumber(number)
    number_list=number.split("")
    org_num=""
    for num in number_list do
        if num.ord in 48..57
            org_num.insert(-1,num)
        end
    end
    org_num
end    



puts "Event manager initialised!"

contents= CSV.open('/home/naseeha/repos/event_manager/event_attendees.csv',headers:true, header_converters: :symbol)

template_letter = File.read('/home/naseeha/repos/event_manager/form_letter.erb')
erb_template = ERB.new template_letter
contents.each do |row|
    name= row[:firtsname]
    zipcode = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zipcode(zipcode)
    phone= clean_phonenumber(row[:homephone])
    row[:homephone],row[:phonequality]=goodorbad(phone)
    form_letter = erb_template.result(binding)
    puts phone,row[:phonequality]
end