module Api
  module V1
    class CouponsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_coupon, only: :show

      def index
        coupons = filtered_coupons

        render json: {
          coupons: coupons.map { |coupon| coupon_list_payload(coupon) },
          meta: {
            total_count: coupons.size,
            categories: active_categories,
            query: params[:q].to_s.strip,
            selected_category: selected_category
          }
        }, status: :ok
      end

      def show
        render json: { coupon: coupon_detail_payload(@coupon) }, status: :ok
      end

      private

      def set_coupon
        @coupon = Coupon.active.find_by!(slug: params[:slug])
      end

      def filtered_coupons
        scope = Coupon.active
        scope = scope.where(category: selected_category) if selected_category.present?

        if search_query.present?
          pattern = "%#{ActiveRecord::Base.sanitize_sql_like(search_query)}%"
          scope = scope.where(
            "title ILIKE :pattern OR brand_name ILIKE :pattern OR description ILIKE :pattern",
            pattern: pattern
          )
        end

        scope.ordered
      end

      def active_categories
        Coupon.active.distinct.order(:category).pluck(:category)
      end

      def selected_category
        @selected_category ||= params[:category].to_s.strip.presence
      end

      def search_query
        @search_query ||= params[:q].to_s.strip.presence
      end

      def coupon_list_payload(coupon)
        {
          id: coupon.id,
          slug: coupon.slug,
          title: coupon.title,
          brand_name: coupon.brand_name,
          category: coupon.category,
          discount_text: coupon.discount_text,
          description: coupon.description,
          image_url: coupon.image_url,
          starts_at: coupon.starts_at.iso8601,
          ends_at: coupon.ends_at.iso8601,
          freshness_ratio: freshness_ratio(coupon)
        }
      end

      def coupon_detail_payload(coupon)
        coupon_list_payload(coupon).merge(
          terms_and_conditions: coupon.terms_and_conditions
        )
      end

      def freshness_ratio(coupon)
        total_window = coupon.ends_at.to_f - coupon.starts_at.to_f
        return 100 if total_window <= 0

        remaining = coupon.ends_at.to_f - Time.current.to_f
        ((remaining / total_window) * 100).clamp(0, 100).round
      end
    end
  end
end
