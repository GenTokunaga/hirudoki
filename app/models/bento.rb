class Bento < ApplicationRecord
  BENTO_TYPES = %w[japanese western chinese healthy].index_with(&:itself).freeze
  IMAGE_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  IMAGE_MAX_SIZE = 5.megabytes

  enum :bento_type, BENTO_TYPES, validate: true

  has_one_attached :image
  # NOTE: 仕様 3-7。販売をやめるときは削除ではなく非販売にする運用のため、献立から参照されていれば削除できなくしている。
  #       注文は献立を参照し、献立は注文があると削除できないので、注文のある弁当もここで削除できなくなる
  has_many :daily_menus, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 1000 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :on_sale, inclusion: { in: [true, false] }
  validates :position, presence: true, numericality: { only_integer: true }
  validate :image_must_be_acceptable

  scope :ordered, -> { order(:position, :id) }

  def self.next_position
    maximum(:position).to_i + 1
  end

  private

  def image_must_be_acceptable
    return unless image.attached?

    errors.add(:image, :invalid_content_type) unless image.blob.content_type.in?(IMAGE_CONTENT_TYPES)
    errors.add(:image, :too_large, size: '5MB') if image.blob.byte_size > IMAGE_MAX_SIZE
  end
end
