require 'date'
require 'time'

module Beaver
  # Represents a single request from the logs. The base class for Beaver::Parsers::Rails and Beaver::Parsers::HTTP.
  # Attributes common to both are defined here.
  class Request
    BLANK_STR = '' # :nodoc:
    BLANK_HASH = {} # :nodoc:

    # Holds the Parser classes used to parser requests
    @types = []

    # Add a child Request parser
    def self.inherited(klass)
      @types << klass
    end

    # Returns a new Request object for the given log line, or nil if one cannot be found.
    def self.for(line)
      klass = @types.detect { |t| t.match? line }
      klass ? klass.new(line) : nil
    end

    # Returns true if the given line look like a request of this class
    def self.match?(line)
      self::REGEX_MATCH =~ line rescue false
    end

    # Accepts a String of log data, presumably ones which belong to a single request.
    def initialize(data=nil)
      @data = data || ''
      @final = false
    end

    # Returns the log data that make up this Request.
    def to_s; @data; end

    # Append a log line
    def <<(line)
      @data << line
    end

    # Returns the request path
    def path
      @path ||= parse_path
    end

    # Returns the request method
    def method
      @method ||= parse_method
    end

    # Returns the response status
    def status
      @status ||= parse_status
    end

    # Returns the request parameters as a String
    def params_str
      @params_str ||= parse_params_str
    end

    # Returns the IP address of the request
    def ip
      @ip ||= parse_ip
    end

    # Returns the date on which the request was made
    def date
      @date ||= parse_date
    end

    # Returns the time at which the request was made
    def time
      @time ||= parse_time
    end

    # When called inside of a Beaver::Dam#hit block, this Request will *not* be matched.
    def skip!
      throw :skip
    end

    # When called inside of a Beaver::Dam#hit block, this Request will not match against any other Beaver::Dam.
    def final!
      @final = true
    end

    # Returns true if this Request should not be matched against any more Dams.
    def final?
      @final
    end

    # Returns true if this request has become invalid during reconstitution
    def invalid?; false; end

    # Returns true if the request has all the information it needs to be properly parsed
    def completed?; true; end

    protected

    # Parses and returns the request path
    def parse_path; BLANK_STR; end

    # Parses and returns the request method
    def parse_method; :unknown; end

    # Parses and returns the response status
    def parse_status; 0; end

    # Parses and returns the request params as a String
    def parse_params_str; BLANK_STR; end

    # Parses and returns the request IP address
    def parse_ip; BLANK_STR; end

    # Parses and returns the date on which the request was made
    def parse_date; nil; end

    # Parses and returns the time at which the request was made
    def parse_time; nil; end
  end
end
