require './mq_slicer.rb'

slicer = MQSlicer.new('./css/screen.css')
puts slicer.render_links
