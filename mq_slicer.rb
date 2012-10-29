require 'active_support/core_ext/string'

class MQSlicer

  PATTERN = /(@media([^\{]+)\{([^\{\}]*\{[^\}\{]*\}[^\}\{])*\})/
  
  # if out_dir is nil, the path of the in_file is used
  def initialize(in_file, out_dir = nil)
    begin 
      css_file = File.open(in_file, "rb")
      css      = css_file.read
    rescue
      raise "ERROR: Bad file '#{in_file}'"# ArgumentError # TODO: custom error
    end
    media_queries, css = slice(css) 

    @media_queries = media_queries
      .group_by { |mq| mq[1].strip.parameterize }
      .sort_by  { |c, q| c                      }
    
    @media_queries.each do |file_name, queries|
      contents = queries.map { |q| q[2] }.join("\n")
      File.open("./css/mq/#{file_name}.css", 'w') { |f| f.write(contents) }
    end
    
    File.open(in_file, 'w') { |f| f.write(css) }
  end
  
  def render_links
  
  end
  
  def slice(string)
    matches = string.scan(PATTERN)
    string  = string.gsub(PATTERN, '')
    [matches, string]
  end

end