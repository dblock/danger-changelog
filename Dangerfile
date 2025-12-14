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

  report = {
    pr_number: pr_number,
    errors: status_report[:errors],
    warnings: status_report[:warnings],
    messages: status_report[:messages]
  }

  File.write(report_path, JSON.pretty_generate(report))
end
