require 'json'

class NeovimFormatter
  RSpec::Core::Formatters.register self, :message, :stop, :close

  attr_reader :output_hash

  def initialize(output)
    @output = output
    @output_hash = {
      ruby_version: RUBY_VERSION,
      rspec_version: RSpec::Core::Version::STRING,
      neotest_rspec_version: '1.0.0'
    }
  end

  def message(notification)
    (@output_hash[:messages] ||= []) << notification.message
  end

  def stop(notification)
    @output_hash[:tests] = notification.examples.map do |test|
      format_test(test).tap do |hash|
        e = test.exception
        if e
          hash[:exception] = {
            class: e.class.name,
            message: e.message,
            backtrace: e.backtrace
          }
        end
      end
    end
  end

  def close(_notification)
    @output.write @output_hash.to_json
  end

  private

  def format_test(test)
    {
      rspec_id: test.id,
      treesitter_id: test.metadata[:absolute_file_path].to_s + '::' + (test.metadata[:line_number] - 1).to_s,
      # group: test.example_group,
      description: test.description,
      full_description: test.full_description,
      status: test.execution_result.status.to_s,
      file_path: test.metadata[:file_path],
      line_number: test.metadata[:line_number],
      run_time: test.execution_result.run_time,
      pending_message: test.execution_result.pending_message
    }
  end
end
