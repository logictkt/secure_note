class AuthEventSubscriber
  def initialize
    @logger = Logger.new(Rails.root.join("log/events.log"))
    @logger.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }
  end

  def emit(event)
    @logger.info(JSON.generate(
      name: event[:name],
      payload: event[:payload],
      timestamp: event[:timestamp],
      at: "#{event.dig(:source_location, :filepath)}:#{event.dig(:source_location, :lineno)}"
    ))
  end
end
