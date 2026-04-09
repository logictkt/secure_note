Rails.application.config.after_initialize do
  Rails.event.subscribe(AuthEventSubscriber.new) do |event|
    event[:name].start_with?("auth.")
  end
end
