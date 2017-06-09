class PortfolioItem < ApplicationRecord
  include AssetConcern
  has_many :assets, -> { where(kind: nil) }, as: :entity, inverse_of: :entity, dependent: :destroy
  has_many :portfolio_category_items, dependent: :destroy
  has_one :cover, -> { where(kind: 'cover') }, class_name: 'Asset', as: :entity,
                                               inverse_of: :entity, dependent: :destroy
  has_many :categories, through: :portfolio_category_items

  accepts_nested_attributes_for :assets, allow_destroy: true
  accepts_nested_attributes_for :cover, allow_destroy: true, reject_if: :file_blank?
  accepts_attachments_for :assets, append: true

  enum status: [:enabled, :disabled]

  scope :featured, -> { where(featured: true) }

  validates :title, :brief, :description, :categories, :cover, :status, :assets, presence: true
  validates :featured, exclusion: [nil]

  acts_as_orderable
end
