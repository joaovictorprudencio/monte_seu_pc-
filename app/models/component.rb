class Component < ApplicationRecord
  has_many :computer_parts
  has_many :computers, through: :computer_parts
  has_one_attached :image


  scope :by_category, ->(category) { where(category: cagetory) if category.presente? }
  scope :by_brand, ->(brand) { where(brand: brand) if brand.presente? }
  scope :by_price_range, ->(min, max) do
    query = self
    query = query.where("price >= ?", min) if min.presente?
    query = query.where("price <= ?", max) if max.present?
    query
  end

  scope :cheapper_firts, -> { order(price: :asc) }
  scope :expansive_firts, -> { order(price: :desc) }
  scope :by_name, -> { order(name: :asc) }





end
