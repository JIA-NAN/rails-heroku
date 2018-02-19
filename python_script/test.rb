 require 'json'

 #this script is to test call python script from ruby
 # run: ruby test.rb 


 pill_rect = "(10,900,200,200)"
 upper_pill_color = "(30 ,255 ,255)"
 lower_pill_color = "(20, 100, 100)"


 output = `python screenshots.py data/video8.mov output/ 90`

 puts output 

 output = `python face_recognition.py data/video8.mov output/0.jpg 90`


 begin
      result = JSON.parse(output)
      boolTest = result["is_face_recognized"]

   

       puts result["is_face_recognized"]
       puts result["face_recognition_score"]

       if result["is_face_recognized"]

           output = `python pill_tracking.py data/video8.mov 90  "#{pill_rect}"  "#{upper_pill_color}" "#{lower_pill_color}"`

           puts output


       end 

 rescue JSON::ParserError

    puts ("json error")
  # Handle error
 end

 
