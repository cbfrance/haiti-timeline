require 'rubygems'
require 'json'
require 'crack'
require 'ap'
require 'ostruct'
require 'ap'
require 'chronic'

input_file_name= "ushahidi-export-june42010.json"
output_file_name= "_content.html"

# If you are rendering the html to an image (say, with webkit2png) you will need to parse in batches unless you have a supercomputer. Adjust start and last values accordingly, I have to parse 1k at a time to get images.
# Regardless, you will need to set last with the last id of the records you have to parse.
last= 4040
start= 0

# The walls for the ushahidi installation are:
# 71.5" (71.5 inches * 300 pixels per inch => 21450.0 pixels)
# 119.5"
# 71.5"


json_data= File.open(input_file_name, "r")
results= json_data.read
p "parsing json"
parsed_items= Crack::JSON.parse(results)
incidents= parsed_items["incidents"]
p "closing up"
json_data.close

if File.exists?(output_file_name)
  p "erase existing file first? Press n to about, any key to continue ..."
  if gets == "n"
    p "aborting"
  else
    File.delete(output_file_name)
  end
end

content= File.new(output_file_name, "a")
  prev_id ||= "unset" #for removing dupes
  incidents.each do |i|
    current_id= i["incident"]["incidentid"]
    if current_id == prev_id || current_id == nil || current_id.to_i < start
      p "skipping ..."
    elsif current_id.to_i > last
      p "done."
      content.close
      p "catting the files"
      `cat _header.html _content.html _footer.html > index.html`
      `open index.html`
      exit
    else
      p "starting to write an incident ..."
      description= i["incident"]["incidentdescription"]
      p description
      size ||= "col2"
      if description.length > 1000 
        size="col4"
      end 
      content.write("<div class='box #{size}'>")
      content.write("<div class='title'>")
      content.write(i["incident"]["incidenttitle"])
      content.write("</div> <!-- close title --> ")
      content.write(i["incident"]["incidentdescription"])
      content.write("<div class='timestamp'>")
      content.write(Chronic.parse(i["incident"]["incidentdate"]).strftime('%d %b %Y'))
      content.write('</div <!-- close time --> ')      
      content.write('</div> <!-- close box -->')  
      p "incrementing prev_id ....."
      prev_id = current_id
    end
  end


