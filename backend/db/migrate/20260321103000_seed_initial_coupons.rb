# frozen_string_literal: true

class SeedInitialCoupons < ActiveRecord::Migration[7.1]
  class MigrationCoupon < ApplicationRecord
    self.table_name = "coupons"
  end

  COUPONS = [
    {
      slug: "morning-onigiri-30off",
      title: "手巻おにぎり 朝のまとめ買い",
      brand_name: "Fresh Daily",
      category: "フード",
      discount_text: "30% OFF",
      description: "対象のおにぎりを2点以上購入で使える朝限定クーポンです。出勤前の軽食やまとめ買いに合わせた定番ディールとして表示します。",
      terms_and_conditions: "毎日 06:00-10:59 に利用可能です。対象商品は店頭表示に準じます。他クーポンとの併用はできません。",
      image_url: "https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?auto=format&fit=crop&w=1200&q=80",
      starts_at: Time.utc(2026, 3, 1, 0, 0, 0),
      ends_at: Time.utc(2026, 12, 31, 23, 59, 59),
      display_order: 10,
      published: true
    },
    {
      slug: "coffee-latte-set-50off",
      title: "淹れたてコーヒーとラテセット",
      brand_name: "Konbini Roast",
      category: "ドリンク",
      discount_text: "50円引き",
      description: "ホットコーヒーとカフェラテを一緒に購入すると適用される、午後の回遊を想定したセットクーポンです。",
      terms_and_conditions: "1会計につき1回利用可能です。アイス商品も対象です。対象サイズはレギュラーのみです。",
      image_url: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1200&q=80",
      starts_at: Time.utc(2026, 3, 1, 0, 0, 0),
      ends_at: Time.utc(2026, 10, 31, 23, 59, 59),
      display_order: 20,
      published: true
    },
    {
      slug: "fried-food-weekend-deal",
      title: "揚げ物ウィークエンドセール",
      brand_name: "Hot Snack Select",
      category: "ホットスナック",
      discount_text: "2個で80円引き",
      description: "週末の来店強化向けに、からあげやコロッケなどのホットスナックをまとめ買いしやすくする訴求です。",
      terms_and_conditions: "金曜 15:00 から日曜 23:59 まで有効です。対象商品は在庫状況により異なります。",
      image_url: "https://images.unsplash.com/photo-1513639776629-7b61b0ac49cb?auto=format&fit=crop&w=1200&q=80",
      starts_at: Time.utc(2026, 3, 15, 0, 0, 0),
      ends_at: Time.utc(2026, 9, 30, 23, 59, 59),
      display_order: 30,
      published: true
    },
    {
      slug: "dessert-night-special",
      title: "ごほうびスイーツ ナイトクーポン",
      brand_name: "Sweet Counter",
      category: "スイーツ",
      discount_text: "15% OFF",
      description: "夜帯の立ち寄り需要を狙ったデザート向けクーポンです。詳細画面では余白を広く取り、訴求コピーを大きく扱います。",
      terms_and_conditions: "毎日 18:00-23:59 に利用可能です。酒類との同時購入では利用できません。",
      image_url: "https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=1200&q=80",
      starts_at: Time.utc(2026, 3, 10, 0, 0, 0),
      ends_at: Time.utc(2026, 11, 30, 23, 59, 59),
      display_order: 40,
      published: true
    }
  ].freeze

  def up
    timestamp = Time.current

    MigrationCoupon.upsert_all(
      COUPONS.map { |coupon| coupon.merge(created_at: timestamp, updated_at: timestamp) },
      unique_by: :index_coupons_on_slug
    )
  end

  def down
    MigrationCoupon.where(slug: COUPONS.map { |coupon| coupon[:slug] }).delete_all
  end
end
