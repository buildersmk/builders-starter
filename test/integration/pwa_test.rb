require "test_helper"

class PwaTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  test "manifest renders installable JSON" do
    get manifest_path
    assert_response :success
    manifest = JSON.parse(response.body)
    assert_equal "standalone", manifest["display"]
    assert manifest["icons"].any?, "has icons"
    assert_equal "/", manifest["scope"]
  end

  test "service worker renders as javascript, uncached" do
    get pwa_service_worker_path
    assert_response :success
    assert_equal "text/javascript", response.media_type
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_match "addEventListener", response.body
  end

  test "offline fallback renders standalone" do
    get offline_path
    assert_response :success
    assert_match(/offline/i, response.body)
  end

  test "saving a push subscription requires signing in" do
    post push_subscription_path, as: :json,
         params: { endpoint: "https://example.com/x", keys: { p256dh: "a", auth: "b" } }
    assert_response :redirect
    assert_equal 0, PushSubscription.count
  end

  test "a signed-in person can save a push subscription tied to their identity" do
    identity = identities(:owner)
    perform_enqueued_jobs { post session_code_path, params: { email_address: identity.email_address } }
    code = ActionMailer::Base.deliveries.last.subject[/\d{6}/]
    post session_path, params: { code: code }

    assert_difference -> { PushSubscription.count }, 1 do
      post push_subscription_path, as: :json,
           params: { endpoint: "https://example.com/abc", keys: { p256dh: "pub", auth: "sec" } }
    end
    assert_response :created
    assert_equal identity.id, PushSubscription.last.identity_id
  end
end
