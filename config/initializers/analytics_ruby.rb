if ENV['SEGMENT_IO_KEY']
  Analytics = Segment::Analytics.new({
    write_key: ENV['SEGMENT_IO_KEY'],
    on_error: Proc.new { |status, msg| print msg }
  })
end