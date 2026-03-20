require "test_helper"
require "securerandom"

class CouponFlowTest < ActionDispatch::IntegrationTest
  test "user can list active coupons and view detail" do
    password = "password123"
    user = User.create!(
      email: "coupon-flow-#{SecureRandom.hex(4)}@example.com",
      password: password,
      password_confirmation: password
    )

    coupon = Coupon.create!(
      slug: "flow-coupon",
      title: "Flow Coupon",
      brand_name: "Fresh Daily",
      category: "フード",
      discount_text: "30% OFF",
      description: "Active coupon",
      terms_and_conditions: "Terms",
      image_url: "https://example.com/coupon.jpg",
      starts_at: 1.day.ago,
      ends_at: 2.days.from_now,
      display_order: 1,
      published: true
    )

    post "/api/v1/auth/login", params: { user: { email: user.email, password: password } }, as: :json
    auth_header = response.headers["Authorization"]

    get "/api/v1/coupons", headers: { "Authorization" => auth_header }, as: :json
    assert_response :success
    assert_equal [coupon.slug], response.parsed_body["coupons"].map { |item| item["slug"] }

    get "/api/v1/coupons/#{coupon.slug}", headers: { "Authorization" => auth_header }, as: :json
    assert_response :success
    assert_equal coupon.slug, response.parsed_body.dig("coupon", "slug")
  end
end
