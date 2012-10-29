require './lib/mq_slicer.rb'

slicer = MQSlicer::Slicer.new('css/screen.css')

puts slicer.slice!
