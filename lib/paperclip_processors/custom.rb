# lib/paperclip_processors/custom.rb
require 'rubygems'
require 'aws/s3'
require 'securerandom'
require 'openssl'
require 'zip'



module Paperclip
  class Custom < Processor
    def make

      bucket_name = ENV.fetch('S3_BUCKET_NAME')
      access_key_id = ENV.fetch('S3_ACCESS_KEY')
      secret_access_key = ENV.fetch('S3_SECRET_ACCESS_KEY')
      region = ENV.fetch('S3_REGION')


      AWS.config(access_key_id: access_key_id, secret_access_key: secret_access_key, region: region)

      

      s3 = AWS::S3.new

      screenshot_folder = SecureRandom.hex(10)


      key = ENV.fetch('CIPHER_KEY')

      cipher = OpenSSL::Cipher.new('AES-128-ECB')
      cipher.decrypt
      cipher.key = [key].pack('H*');
     

      buf = ""
      File.open("#{file.path}_decrypt", "wb") do |outf|
        File.open(file.path, "rb") do |inf|
          while inf.read(4096, buf)
            outf << cipher.update(buf)
          end
          outf << cipher.final
        end
      end           

      rotation = `./exiftool/exiftool -rotation #{file.path}_decrypt`

      rotation = rotation.split(":").last.strip()

      puts rotation           

      output = `python ./python_script/screenshots.py #{file.path}_decrypt /app/tmp/output/#{screenshot_folder}  #{rotation}`

      

      path_array = output.split("\n")

      zipfile_name = "/app/tmp/output/#{screenshot_folder}.zip"


      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|

        path_array.each do |screenshot_path|

            if screenshot_path.include? "jpg"


                filename = File.basename(screenshot_path)

                zipfile.add(filename, screenshot_path)


            end 
        
        
        end
        
      end


      cipher = OpenSSL::Cipher.new('AES-128-ECB')
      cipher.encrypt
      cipher.key = [key].pack('H*')


      buf = ""
      File.open("#{zipfile_name}_encrypt", "wb") do |outf|
        File.open(zipfile_name, "rb") do |inf|
          while inf.read(4096, buf)
            outf << cipher.update(buf)
          end
          outf << cipher.final
        end
      end

      # upload zip file to amazon s3


      object = s3.buckets[bucket_name].objects["screenshots/#{screenshot_folder}"].write(:file => "#{zipfile_name}_encrypt")

      File.delete(zipfile_name) if File.exist?(zipfile_name)

      File.delete("#{zipfile_name}_encrypt") if File.exist?("#{zipfile_name}_encrypt")

      File.delete("#{file.path}_decrypt") if File.exist?("#{file.path}_decrypt")

      path_array.each do |screenshot_path|

          if screenshot_path.include? "jpg"


              File.delete(screenshot_path) if File.exist?(screenshot_path)

          end 
      
      
      end
            
      attachment.instance.screenshot_urls = ""+object.public_url.to_s


      File.new(@file.path)

    end
  end
end