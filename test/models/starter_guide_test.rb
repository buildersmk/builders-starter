require "test_helper"

class StarterGuideTest < ActiveSupport::TestCase
  test "catalog lists the integrations, each with a key, source and logo" do
    assert_equal %w[ stripe resend kit openrouter apify ], StarterGuide.integrations.map(&:key)

    StarterGuide.integrations.each do |integration|
      assert integration.env_var.present?, "#{integration.key} needs an env var"
      assert integration.where_url.start_with?("https://"), "#{integration.key} needs a key source URL"
      assert integration.logo.start_with?("logos/"), "#{integration.key} needs a logo"
    end
  end

  test "essentials come first, optionals after" do
    assert_equal %w[ stripe resend ], StarterGuide.essential.map(&:key)
    assert_equal %w[ kit openrouter apify ], StarterGuide.optional.map(&:key)
  end

  test "configured? and configured_count follow the environment" do
    stripe = StarterGuide.integrations.first
    original = ENV[stripe.env_var]

    ENV.delete(stripe.env_var)
    before = StarterGuide.configured_count
    assert_not stripe.configured?

    ENV[stripe.env_var] = "sk_test_123"
    assert stripe.configured?
    assert_equal before + 1, StarterGuide.configured_count
  ensure
    original.nil? ? ENV.delete(stripe.env_var) : ENV[stripe.env_var] = original
  end
end
