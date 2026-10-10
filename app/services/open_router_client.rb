# One client for any LLM, via OpenRouter. Idle-until-keyed: returns nil when OPENROUTER_API_KEY is
# absent, so callers can treat "no key" and "no answer" the same. Stdlib net/http — no gem.
#
#   OpenRouterClient.chat("Summarize this", system: "You are concise.")
require "net/http"
require "uri"
require "json"

class OpenRouterClient
  URL = URI("https://openrouter.ai/api/v1/chat/completions")
  DEFAULT_MODEL = ENV.fetch("OPENROUTER_MODEL", "openai/gpt-4o-mini")

  def self.chat(prompt, model: DEFAULT_MODEL, system: nil, max_tokens: 4096, temperature: 0.7)
    key = ENV["OPENROUTER_API_KEY"]
    return nil if key.blank?

    messages = []
    messages << { role: "system", content: system } if system.present?
    messages << { role: "user", content: prompt }

    http = Net::HTTP.new(URL.host, URL.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 120

    request = Net::HTTP::Post.new(URL.request_uri)
    request["Content-Type"]  = "application/json"
    request["Authorization"] = "Bearer #{key}"
    request["HTTP-Referer"]  = ENV.fetch("APP_HOST", "http://localhost:3100")
    request["X-Title"]       = ENV.fetch("OPENROUTER_APP_NAME", "Builders Starter")
    request.body = { model:, messages:, max_tokens:, temperature: }.to_json

    response = http.request(request)
    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).dig("choices", 0, "message", "content")
  rescue Net::OpenTimeout, Net::ReadTimeout, JSON::ParserError => e
    Rails.logger.warn("OpenRouter error: #{e.class} - #{e.message}")
    nil
  end
end
