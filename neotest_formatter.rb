require "rspec/core/formatters/json_formatter"

class NeotestFormatter < RSpec::Core::Formatters::JsonFormatter
  RSpec::Core::Formatters.register self, :message, :dump_summary, :dump_profile, :stop, :seed, :close

  private

  def get_actual_inclusion_line_number(example)
    if example.metadata[:shared_group_inclusion_backtrace]&.any?
      example.metadata[:shared_group_inclusion_backtrace].first.inclusion_location[/(?<=:)\d+(?=:in)/]
    else
      example.metadata[:line_number]
    end
  end

  def format_example(example)
    result = super(example)
    result.merge(
      line_number: get_actual_inclusion_line_number(example)
    )
  end
end
