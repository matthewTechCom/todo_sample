# frozen_string_literal: true

class ReplaceTodosWithCoupons < ActiveRecord::Migration[7.1]
  def change
    drop_table :todos do |t|
      t.bigint :user_id, null: false
      t.string :title, null: false
      t.boolean :completed, null: false, default: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    create_table :coupons do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :brand_name, null: false
      t.string :category, null: false
      t.string :discount_text, null: false
      t.text :description, null: false
      t.text :terms_and_conditions, null: false
      t.string :image_url, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :display_order, null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
    end

    add_index :coupons, :slug, unique: true
    add_index :coupons, :published
    add_index :coupons, :category
    add_index :coupons, :display_order
    add_index :coupons, :ends_at
  end
end
