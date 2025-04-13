require 'vcr'
require 'webmock/rspec'

# Disable all real HTTP connections, except to localhost
WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |c|
  # Where VCR will store the recorded HTTP interactions
  c.cassette_library_dir = 'spec/cassettes'

  # Ignore localhost requests
  c.ignore_localhost = true

  # Tell VCR to use WebMock
  c.hook_into :webmock

  # Allow VCR to be configured through RSpec metadata
  c.configure_rspec_metadata!

  # Allow real HTTP connections when no cassette is in use
  c.allow_http_connections_when_no_cassette = true

  # Configure how requests are matched
  c.default_cassette_options = { 
    match_requests_on: [:method, :uri, :body] 
  }

  # Filter sensitive data before recording
  c.before_record do |interaction|
    interaction.request.headers['Authorization'] = '[FILTERED]'
  end

  # Ignore specific hosts
  ignored_hosts = ['codeclimate.com']
  c.ignore_hosts *ignored_hosts
end

# Configure RSpec to use VCR
RSpec.configure do |config|
  config.around(:each) do |example|
    options = example.metadata[:vcr] || {}
    options[:allow_playback_repeats] = true

    if options[:record] == :skip
      VCR.turned_off(&example)
    else
      custom_name = example.metadata[:vcr]&.delete(:cassette_name)
      generated_name = example.metadata[:full_description]
        .split(/\s+/, 2)
        .join('/')
        .underscore
        .tr('.', '/')
        .gsub(/[^\w\/]+/, '_')
        .gsub(/\/$/, '')

      name = custom_name || generated_name
      VCR.use_cassette(name, options, &example)
    end
  end
end
