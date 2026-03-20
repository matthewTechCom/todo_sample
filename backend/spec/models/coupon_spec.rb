require "rails_helper"

RSpec.describe Coupon, type: :model do
  it "is invalid when ends_at is not later than starts_at" do
    timestamp = Time.current

    coupon = described_class.new(
      slug: "invalid-window",
      title: "Invalid Window",
      brand_name: "Fresh Daily",
      category: "フード",
      discount_text: "10% OFF",
      description: "Window is invalid",
      terms_and_conditions: "Terms",
      image_url: "https://example.com/coupon.jpg",
      starts_at: timestamp,
      ends_at: timestamp,
      display_order: 0,
      published: true
    )

    expect(coupon).not_to be_valid
    expect(coupon.errors[:ends_at]).to include("must be later than starts_at")
  end
end
