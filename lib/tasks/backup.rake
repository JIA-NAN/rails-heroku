namespace :backup do

  desc 'Save all videos to AWS S3'
  task videos: [:environment] do
    puts "=== Saving videos to S3 ==="

    records = Record.not_on_s3

    records.each do |record|
      if record.video.exists?
        record.save_to_s3
        puts "-> Record #{record.id} saved"
      else
        record.update_attributes(video: nil, audio: nil)
        puts "-> Record #{record.id} file losted"
      end
    end

    puts "=== #{records.size} videos saved ==="
  end

end
