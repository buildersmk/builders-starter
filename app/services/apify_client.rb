# Run Apify actors and get their dataset rows back. `run` waits (sync, good for quick actors);
# `run_async` starts/polls/fetches (for heavier runs the sync endpoint 502s on). Stdlib net/http.
# Needs APIFY_API_TOKEN. Actor ids look like "apify~web-scraper".
#
#   ApifyClient.run(actor: "apify~web-scraper", input: { startUrls: [{ url: "https://example.com" }] })
require "net/http"
require "uri"
require "json"

class ApifyClient
  Error = Class.new(StandardError)

  ENDPOINT         = "https://api.apify.com/v2/acts/%<actor>s/run-sync-get-dataset-items".freeze
  START_ENDPOINT   = "https://api.apify.com/v2/acts/%<actor>s/runs".freeze
  RUN_ENDPOINT     = "https://api.apify.com/v2/actor-runs/%<id>s".freeze
  DATASET_ENDPOINT = "https://api.apify.com/v2/datasets/%<id>s/items".freeze

  def self.run(actor:, input:, timeout: 240)
    uri = URI(format(ENDPOINT, actor: actor))
    uri.query = URI.encode_www_form(token: api_token)
    response = post(uri, input.to_json, timeout)
    raise Error, "Apify #{actor} returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    rows = JSON.parse(response.body)
    raise Error, "Apify #{actor} returned a non-array payload" unless rows.is_a?(Array)
    rows
  rescue Net::ReadTimeout, Net::OpenTimeout => e
    raise Error, "Apify #{actor} timed out after #{timeout}s: #{e.message}"
  rescue JSON::ParserError => e
    raise Error, "Apify #{actor} returned invalid JSON: #{e.message}"
  end

  def self.run_async(actor:, input:, timeout: 300, poll_interval: 5)
    started = get_json(post(uri_with_token(format(START_ENDPOINT, actor: actor)), input.to_json, 30))
    run = started["data"] or raise Error, "Apify #{actor}: no run in start response"
    deadline = Time.current + timeout

    loop do
      status = get_json(get(uri_with_token(format(RUN_ENDPOINT, id: run["id"])), 60)).dig("data", "status")
      break if status == "SUCCEEDED"
      raise Error, "Apify #{actor} run #{status}" if %w[FAILED ABORTED TIMED-OUT TIMING-OUT].include?(status)
      raise Error, "Apify #{actor} did not finish within #{timeout}s" if Time.current > deadline

      sleep poll_interval
    end

    rows = get_json(get(uri_with_token(format(DATASET_ENDPOINT, id: run["defaultDatasetId"]), clean: "true"), 60))
    raise Error, "Apify #{actor} dataset was not an array" unless rows.is_a?(Array)
    rows
  end

  def self.api_token
    ENV["APIFY_API_TOKEN"].presence or raise Error, "APIFY_API_TOKEN not configured"
  end

  def self.uri_with_token(url, **params)
    uri = URI(url)
    uri.query = URI.encode_www_form({ token: api_token }.merge(params))
    uri
  end

  def self.post(uri, body, timeout)
    http = http_for(uri, timeout)
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request.body = body
    http.request(request)
  end

  def self.get(uri, timeout)
    http_for(uri, timeout).request(Net::HTTP::Get.new(uri.request_uri))
  end

  def self.http_for(uri, timeout)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = timeout
    http
  end

  def self.get_json(response)
    raise Error, "Apify returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise Error, "Apify returned invalid JSON: #{e.message}"
  end
end
