require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with email and password" do
      user = described_class.new(
        email: "model-spec@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user).to be_valid
    end

    it "is invalid without email" do
      user = described_class.new(
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe "jwt revocation" do
    it "assigns jti on create" do
      user = described_class.create!(
        email: "jti-spec@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user.jti).to be_present
    end
  end
end
