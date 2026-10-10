# Subscribe an email to Kit (ConvertKit) and tag it — the lead-capture boundary. Best-effort and
# idle-until-keyed: no-ops without KIT_API_KEY (or a placeholder tag id), and never raises into the
# caller, so a Kit hiccup can't break a signup.
#
#   KitTagger.tag(email: "you@example.com")
class KitTagger
  API = "https://api.convertkit.com/v3".freeze

  def self.tag(email:, tag_id: ENV["KIT_TAG_ID"], first_name: nil)
    new(email:, tag_id:, first_name:).call
  end

  def initialize(email:, tag_id:, first_name: nil)
    @email = email
    @tag_id = tag_id.to_s
    @first_name = first_name
    @api_key = ENV["KIT_API_KEY"]
  end

  def call
    return if @api_key.blank? || @tag_id.blank? || @tag_id.include?("your_")

    payload = { api_key: @api_key, email: @email }
    payload[:first_name] = @first_name if @first_name.present?

    response = Faraday.post("#{API}/tags/#{@tag_id}/subscribe", payload.to_json, "Content-Type" => "application/json")
    Rails.logger.warn("Kit tag #{@tag_id} failed: #{response.status}") unless response.success?
    response
  rescue Faraday::Error => e
    Rails.logger.warn("Kit tag error: #{e.message}")
    nil
  end
end
