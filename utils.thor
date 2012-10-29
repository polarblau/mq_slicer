require './lib/mq_slicer.rb'

class Utils < Thor
  desc "slice_media_queries FILE", "Slice the media queries out of FILE and store in separate files"
  def slice_media_queries(file)
    slicer = MQSlicer::Slicer.new(file)
    links  = slicer.slice!
    say
    say "The file '#{file}' has been updated.", :green
    say "Include the following stylesheets after the include for '#{file}':"
    say
    links.each {|link| say link }
    say
  end
end
