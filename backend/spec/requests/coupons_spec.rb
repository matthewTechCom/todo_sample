require "swagger_helper"
require "securerandom"

RSpec.describe "Coupons API", type: :request do
  let!(:user) do
    User.create!(
      email: "coupons-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:Authorization) do
    post "/api/v1/auth/login", params: { user: { email: user.email, password: "password123" } }, as: :json
    response.headers["Authorization"]
  end

  path "/api/v1/coupons" do
    get "List active coupons" do
      tags "Coupons"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }, required: false
      parameter name: :q, in: :query, schema: { type: :string }, required: false
      parameter name: :category, in: :query, schema: { type: :string }, required: false

      response "200", "coupons fetched" do
        let!(:food_coupon) do
          Coupon.create!(
            slug: "morning-food",
            title: "Morning Food Deal",
            brand_name: "Fresh Daily",
            category: "フード",
            discount_text: "30% OFF",
            description: "Best breakfast coupon",
            terms_and_conditions: "One per visit",
            image_url: "https://example.com/food.jpg",
            starts_at: 1.day.ago,
            ends_at: 7.days.from_now,
            display_order: 1,
            published: true
          )
        end
        let!(:drink_coupon) do
          Coupon.create!(
            slug: "coffee-drink",
            title: "Coffee Time",
            brand_name: "Konbini Roast",
            category: "ドリンク",
            discount_text: "50円引き",
            description: "Fresh brewed latte offer",
            terms_and_conditions: "Regular size only",
            image_url: "https://example.com/drink.jpg",
            starts_at: 1.day.ago,
            ends_at: 2.days.from_now,
            display_order: 2,
            published: true
          )
        end
        let!(:expired_coupon) do
          Coupon.create!(
            slug: "expired-coupon",
            title: "Old Offer",
            brand_name: "Archive",
            category: "フード",
            discount_text: "10% OFF",
            description: "Expired",
            terms_and_conditions: "Expired",
            image_url: "https://example.com/expired.jpg",
            starts_at: 5.days.ago,
            ends_at: 1.day.ago,
            display_order: 3,
            published: true
          )
        end
        let!(:scheduled_coupon) do
          Coupon.create!(
            slug: "scheduled-coupon",
            title: "Coming Soon",
            brand_name: "Next Week",
            category: "スイーツ",
            discount_text: "20% OFF",
            description: "Scheduled",
            terms_and_conditions: "Future",
            image_url: "https://example.com/future.jpg",
            starts_at: 1.day.from_now,
            ends_at: 8.days.from_now,
            display_order: 4,
            published: true
          )
        end
        let!(:unpublished_coupon) do
          Coupon.create!(
            slug: "hidden-coupon",
            title: "Hidden",
            brand_name: "Private",
            category: "スイーツ",
            discount_text: "5% OFF",
            description: "Hidden coupon",
            terms_and_conditions: "Private",
            image_url: "https://example.com/hidden.jpg",
            starts_at: 1.day.ago,
            ends_at: 10.days.from_now,
            display_order: 5,
            published: false
          )
        end
        let(:q) { nil }
        let(:category) { nil }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["coupons"].map { |coupon| coupon["slug"] }).to eq(
            [food_coupon.slug, drink_coupon.slug]
          )
          expect(body.dig("meta", "total_count")).to eq(2)
          expect(body.dig("meta", "categories")).to eq(%w[ドリンク フード])
          expect(body["coupons"].first["freshness_ratio"]).to be_between(0, 100)
          expect(body["coupons"].map { |coupon| coupon["slug"] }).not_to include(
            expired_coupon.slug, scheduled_coupon.slug, unpublished_coupon.slug
          )
        end
      end

      response "200", "category filtered" do
        let!(:food_coupon) do
          Coupon.create!(
            slug: "food-only",
            title: "Food Coupon",
            brand_name: "Fresh Daily",
            category: "フード",
            discount_text: "30% OFF",
            description: "Food offer",
            terms_and_conditions: "Food terms",
            image_url: "https://example.com/food.jpg",
            starts_at: 1.day.ago,
            ends_at: 7.days.from_now,
            display_order: 1,
            published: true
          )
        end
        let!(:drink_coupon) do
          Coupon.create!(
            slug: "drink-only",
            title: "Drink Coupon",
            brand_name: "Konbini Roast",
            category: "ドリンク",
            discount_text: "50円引き",
            description: "Drink offer",
            terms_and_conditions: "Drink terms",
            image_url: "https://example.com/drink.jpg",
            starts_at: 1.day.ago,
            ends_at: 3.days.from_now,
            display_order: 2,
            published: true
          )
        end
        let(:category) { "フード" }
        let(:q) { nil }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["coupons"].map { |coupon| coupon["slug"] }).to eq([food_coupon.slug])
          expect(body.dig("meta", "selected_category")).to eq("フード")
          expect(body["coupons"].map { |coupon| coupon["slug"] }).not_to include(drink_coupon.slug)
        end
      end

      response "200", "query filtered" do
        let!(:match_by_title) do
          Coupon.create!(
            slug: "coffee-title",
            title: "Coffee Coupon",
            brand_name: "Brand A",
            category: "ドリンク",
            discount_text: "10% OFF",
            description: "Tasty drink",
            terms_and_conditions: "Terms",
            image_url: "https://example.com/coffee.jpg",
            starts_at: 1.day.ago,
            ends_at: 4.days.from_now,
            display_order: 1,
            published: true
          )
        end
        let!(:match_by_brand) do
          Coupon.create!(
            slug: "brand-match",
            title: "Latte Deal",
            brand_name: "Coffee Select",
            category: "ドリンク",
            discount_text: "100円引き",
            description: "Smooth latte",
            terms_and_conditions: "Terms",
            image_url: "https://example.com/latte.jpg",
            starts_at: 1.day.ago,
            ends_at: 4.days.from_now,
            display_order: 2,
            published: true
          )
        end
        let!(:mismatch_coupon) do
          Coupon.create!(
            slug: "not-matching",
            title: "Rice Ball",
            brand_name: "Fresh Daily",
            category: "フード",
            discount_text: "20円引き",
            description: "Morning snack",
            terms_and_conditions: "Terms",
            image_url: "https://example.com/rice.jpg",
            starts_at: 1.day.ago,
            ends_at: 4.days.from_now,
            display_order: 3,
            published: true
          )
        end
        let(:q) { "coffee" }
        let(:category) { nil }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["coupons"].map { |coupon| coupon["slug"] }).to eq(
            [match_by_title.slug, match_by_brand.slug]
          )
          expect(body.dig("meta", "query")).to eq("coffee")
          expect(body["coupons"].map { |coupon| coupon["slug"] }).not_to include(mismatch_coupon.slug)
        end
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        let(:q) { nil }
        let(:category) { nil }

        run_test!
      end
    end
  end

  path "/api/v1/coupons/{slug}" do
    parameter name: :slug, in: :path, type: :string

    get "Show active coupon detail" do
      tags "Coupons"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }, required: false

      response "200", "coupon fetched" do
        let!(:coupon) do
          Coupon.create!(
            slug: "dessert-night",
            title: "Dessert Night",
            brand_name: "Sweet Counter",
            category: "スイーツ",
            discount_text: "15% OFF",
            description: "Night dessert offer",
            terms_and_conditions: "One item only",
            image_url: "https://example.com/dessert.jpg",
            starts_at: 1.day.ago,
            ends_at: 7.days.from_now,
            display_order: 1,
            published: true
          )
        end
        let(:slug) { coupon.slug }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.dig("coupon", "slug")).to eq(coupon.slug)
          expect(body.dig("coupon", "terms_and_conditions")).to eq("One item only")
        end
      end

      response "404", "not found for inactive coupon" do
        let!(:coupon) do
          Coupon.create!(
            slug: "expired-detail",
            title: "Expired Detail",
            brand_name: "Archive",
            category: "フード",
            discount_text: "10% OFF",
            description: "Expired detail",
            terms_and_conditions: "Expired terms",
            image_url: "https://example.com/expired-detail.jpg",
            starts_at: 5.days.ago,
            ends_at: 1.day.ago,
            display_order: 1,
            published: true
          )
        end
        let(:slug) { coupon.slug }

        run_test!
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        let(:slug) { "missing" }

        run_test!
      end
    end
  end
end
