module MQSlicer
  class Slicer

    PATTERN = /(@media([^\{]+){((?:[^{}]|{[^{}]*})*)})/
      #/(@media([^\{]+)\{([^\{\}]*\{[^\}\{]*\}[^\}\{])*\})/

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

  end
end
