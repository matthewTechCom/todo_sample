class Coupon < ApplicationRecord
  scope :published, -> { where(published: true) }
  scope :active, lambda {
    now = Time.current
    published.where("starts_at <= ? AND ends_at > ?", now, now)
  }
  scope :ordered, -> { order(display_order: :asc, ends_at: :asc, id: :asc) }

  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :title, :brand_name, :category, :discount_text, :description, :terms_and_conditions, :image_url,
            presence: true
  validates :display_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :ends_at_after_starts_at

  private

  def ends_at_after_starts_at
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be later than starts_at")
  end
end
