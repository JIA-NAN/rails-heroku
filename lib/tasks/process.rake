namespace :process do

  desc 'Merge record audios to their videos'
  task merge: [:environment] do
    puts "=== Merging audios to videos ==="

    records = Record.not_processed

    records.each do |record|
      record.merge_audio_to_video!
      puts "-> Record #{record.id} merged"
    end

    puts "=== #{records.size} records merged ==="
  end

  desc 'Steplize record length based to steps'
  task steplize: [:environment] do
    puts "=== Steplizing record length ==="

    records = Record.not_steplized

    records.each do |record|
      record.steplize_video!
      puts "-> Record #{record.id} steplized"
    end

    puts "=== #{records.size} records steplized ==="
  end

  desc 'Clear all processing flag'
  task clear: [:environment] do
    puts "=== Clearing processing flags ==="

    records = Record.where(video_processing: true)

    records.each do |record|
      record.update_attributes video_processing: false
      puts "-> Record #{record.id} processing flag cleared"
    end

    puts "=== #{records.size} records processing flag cleared ==="
  end

end
