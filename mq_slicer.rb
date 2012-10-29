require 'active_support/core_ext/string'
require 'pathname'

class MQSlicer

  PATTERN = /(@media([^\{]+)\{([^\{\}]*\{[^\}\{]*\}[^\}\{])*\})/

  def initialize(in_file)
    begin
      @base_path = File.dirname(in_file)
      css_file   = File.open(in_file, "rb")
      css        = css_file.read
    rescue
      raise "ERROR: Bad file '#{in_file}'" # TODO: custom error
    end
    media_queries, css = slice(css)

    @media_queries = media_queries
      .group_by { |mq| mq[1].strip }
      .sort_by  { |c, q| c         }

    @media_queries.each do |condition, queries|
      contents = queries.map { |q| q[2] }.join("\n")
      File.open(condition_file_path(condition), 'w') do |f|
        f.write(contents)
      end
    end

    File.open(in_file, 'w') { |f| f.write(css) }
  end

  def render_links
    links = @media_queries.map do |condition, _|
      %{<link rel="stylesheet" type="text/css" media="#{condition}" href="#{condition_file_path(condition)}">}
    end
    links.join("\n")
  end

  def base_path
    @base_path
  end

  def condition_file_path(condition)
    File.join(base_path, "#{condition.parameterize}.css")
  end

  def slice(string)
    matches = string.scan(PATTERN)
    string  = string.gsub(PATTERN, '')
    [matches, string]
  end

end
