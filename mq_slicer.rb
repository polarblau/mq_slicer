require 'active_support/core_ext/string'

class MQSlicer

  PATTERN = /(@media([^\{]+)\{([^\{\}]*\{[^\}\{]*\}[^\}\{])*\})/

  attr_accessor :styles, :media_queries

  def initialize(file)
    @file, @styles = file, read_styles(file)
    find_media_queries(@styles)
  end

  def media_queries
    MediaQuery.all
  end

  def slice!
    media_queries.map {|mq| mq.write_to_file(base_path) }
    File.open(@file, 'w') do |file|
      contents = @styles.gsub(PATTERN, '').gsub(/^$\n\n/, '')
      file.write(contents)
    end
    media_queries.map {|mq| mq.to_link(base_path) }
  end

  class ParserError < StandardError; end

private

  def base_path
    File.dirname(@file)
  end

  def read_styles(file)
    begin
      File.open(file, "rb").read
    rescue
      raise ParserError, "Bad file '#{file}'"
    end
  end

  def find_media_queries(styles)
    matches = styles.scan(PATTERN)
    matches.each do |match, condition, rules|
      mq = MediaQuery.find_or_create(condition.strip)
      mq.rules << rules
    end
  end

  class MediaQuery

    @@media_queries = []

    attr_accessor :condition, # e.g. `screen and (min-width: 320px)`
                  :rules      # Array of CSS rules

    def self.find_or_create(condition)
      mq = @@media_queries.find {|q| q.condition == condition }
      mq || MediaQuery.new(condition)
    end

    def self.all
      @@media_queries.sort_by(&:condition)
    end

    def initialize(condition, rules = '')
      @condition = condition
      @rules     = [rules].flatten
      @@media_queries << self
    end

    def to_file_name
      "#{@condition.parameterize}.css"
    end

    def to_file_path(base_path = nil)
      File.join([base_path, self.to_file_name].compact)
    end

    def to_import_rule(base_path = nil)
       "@import url(#{self.to_file_path(base_path)}) #{@condition};"
    end

    def to_link(base_path = nil)
      %{<link rel="stylesheet" type="text/css" media="#{@condition}" href="#{self.to_file_path(base_path)}">}
    end

    def write_to_file(base_path = nil)
      File.open(self.to_file_path(base_path), 'w') do |file|
        file.write(@rules.join("\n").gsub(/^$\n/, ''))
      end
    end

  end

end
