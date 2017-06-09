class TeamMember < ApplicationRecord
  include AssetConcern
  has_one :asset, as: :entity, inverse_of: :entity, dependent: :destroy
  accepts_nested_attributes_for :asset, allow_destroy: true, reject_if: :file_blank?

  enum status: [:enabled, :disabled]

  validates :first_name, :last_name, :description, :status, :asset, presence: true

  def display_name
    "#{first_name} #{last_name}"
  end
end
