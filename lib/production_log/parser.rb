##
# LogParser parses a Syslog log file looking for lines logged by the 'rails'
# program.  A typical log line looks like this:
#
#   Mar  7 00:00:20 online1 rails[59600]: Person Load (0.001884)   SELECT * FROM people WHERE id = 10519 LIMIT 1
#
# LogParser does not work with Rails' default logger because there is no way
# to group all the log output of a single request.  You must use SyslogLogger.

module LogParser

  ##
  # LogEntry contains a summary of log data for a single request.

  class LogEntry

    ##
    # Controller and action for this request

    attr_reader :page

    ##
    # Requesting IP

    attr_reader :ip

    ##
    # Time the request was made

    attr_reader :time

    ##
    # Array of SQL queries containing query type and time taken.  The
    # complete text of the SQL query is not saved to reduct memory usage.

    attr_reader :queries

    ##
    # Total request time, including database, render and other.

    attr_reader :request_time

    ##
    # Total render time.

    attr_reader :render_time

    ##
    # Total database time

    attr_reader :db_time

    ##
    # Creates a new LogEntry from the log data in +entry+.

    attr_reader :row_count, :query_count, :request_size, :response_size

    def initialize(entry)
      @page = nil
      @ip = nil
      @time = nil
      @queries = []
      @request_time = 0
      @render_time = 0
      @db_time = 0
      @in_component = 0

      parse entry
    end

    ##
    # Extracts log data from +entry+, which is an Array of lines from the
    # same request.

    def parse(entry)
      entry.each do |line|
        case line
        when /^Parameters/, /^Cookie set/, /^Rendering/,
          /^Redirected/ then
          # nothing
        when /^Processing ([\S]+) \(for (.+) at (.*)\)/ then
          next if @in_component > 0
          @page = $1
          @ip   = $2
          @time = $3
        when /^Completed in ([\S]+) \(\d* reqs\/sec\) \| (.+)/,
          /^Completed in ([\S]+) \((.+)\)/ then

          next if @in_component > 0
          # handle millisecond times as well as fractional seconds
          @times_in_milliseconds = $1[-2..-1] == 'ms'

          @request_time = @times_in_milliseconds ? ($1.to_i/1000.0) : $1.to_f
          log_info = $2

          log_info = log_info.split(/[,|]/)
          log_info = log_info.map do |entry|
            next nil unless entry.index(': ')
            result = entry.strip.split(': ')
            if result.size > 2
              result = [result[0], result[1..-1].join(':')]
            end
            result
          end.compact.flatten

          log_info = Hash[*log_info]

          @row_count = log_info['Rows'].to_i
          @query_count = log_info['Queries'].to_i
          @request_size = log_info['Request Size'].to_i
          @response_size = log_info['Response Size'].to_i

          @page = log_info['Processed'] if log_info['Processed']
          @page += ".#{log_info['Response Format']}" if log_info['Response Format']

          if x = (log_info['DB'])
            x = x.split(' ').first
            @db_time = @times_in_milliseconds ? (x.to_i/1000.0) : x.to_f
          end

          if x = (log_info['Rendering'] || log_info['View'])
            x = x.split(' ').first
            @render_time = @times_in_milliseconds ? (x.to_i/1000.0) : x.to_f
          end

        when /(.+?) \(([^)]+)\)   / then
          @queries << [$1, $2.to_f]
        when /^Start rendering component / then
          @in_component += 1
        when /^End of component rendering$/ then
          @in_component -= 1
        when /^Fragment hit: / then
        else # noop
#          raise "Can't handle #{line.inspect}" if $TESTING
        end
      end
    end

    def ==(other) # :nodoc:
      other.class == self.class and
      other.page == self.page and
      other.ip == self.ip and
      other.time == self.time and
      other.queries == self.queries and
      other.request_time == self.request_time and
      other.render_time == self.render_time and
      other.db_time == self.db_time
    end

  end

  ##
  # Parses IO stream +stream+, creating a LogEntry for each recognizable log
  # entry.
  #
  # Log entries are recognised as starting with Processing, continuing with
  # the same process id through Completed.

  def self.parse(stream) # :yields: log_entry
    buckets = Hash.new { |h,k| h[k] = [] }
    comp_count = Hash.new 0

    stream.each_line do |line|
      line =~ / ([^ ]+) ([^ ]+)\[(\d+)\]: (.*)/
      next if $2.nil? or $2 == 'newsyslog'
      bucket = [$1, $2, $3].join '-'
      data = $4

      buckets[bucket] << data

      case data
      when /^Start rendering component / then
        comp_count[bucket] += 1
      when /^End of component rendering$/ then
        comp_count[bucket] -= 1
      when /^Completed/ then
        next unless comp_count[bucket] == 0
        entry = buckets.delete bucket
#        next unless entry.any? { |l| l =~ /^Processing/ }
        yield LogEntry.new(entry)
      end
    end

    buckets.each do |bucket, data|
      yield LogEntry.new(data)
    end
  end

end

