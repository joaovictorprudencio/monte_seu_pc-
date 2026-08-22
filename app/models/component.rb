class Component < ApplicationRecord
  has_many :computer_parts
  has_many :computers, through: :computer_parts
  has_one_attached :image

  def display_image
      image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true) : default_image
  end


 def default_image
    filename = "#{category}_placeholder.png"
    images_dir = Rails.root.join("app/assets/images")
    match = Dir.glob(File.join(images_dir, "*_placeholder.png")).find { |f| File.basename(f).casecmp(filename).zero? }
    if match
      Rails.application.routes.url_for(match)
    else
      Rails.application.routes.url_for(
        Rails.root.join("app/assets/images/placeholder.png")
      )
    end
  rescue
    "placeholder.png"
  end


  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_brand, ->(brand) { where(brand: brand) if brand.present? }
  scope :by_price_range, ->(min, max) do
    query = self
    query = query.where("price >= ?", min) if min.present?
    query = query.where("price <= ?", max) if max.present?
    query
  end

  scope :cheapper_firts, -> { order(price: :asc) }
  scope :expansive_firts, -> { order(price: :desc) }
  scope :by_name, -> { order(name: :asc) }
end
