# danger.systems

toc.check!
changelog.check!

# Export report for danger-comment workflow
require 'json'
event_path = ENV.fetch('GITHUB_EVENT_PATH', nil)
report_path = ENV.fetch('DANGER_REPORT_PATH', nil)
if report_path && event_path && File.exist?(event_path)
  event = JSON.parse(File.read(event_path))
  pr_number = event.dig('pull_request', 'number')
  if pr_number
    to_messages = lambda do |items|
      Array(items).map do |item|
        item.respond_to?(:message) ? item.message : item.to_s
      end
    end

    report = {
      pr_number: pr_number,
      errors: to_messages.call(status_report[:errors]),
      warnings: to_messages.call(status_report[:warnings]),
      messages: to_messages.call(status_report[:messages]),
      markdowns: to_messages.call(status_report[:markdowns])
    }

    File.write(report_path, JSON.pretty_generate(report))
  end
end
