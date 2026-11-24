module BentosHelper
  def bento_type_options
    Bento.bento_types.keys.map { [Bento.human_enum_name(:bento_type, it), it] }
  end

  def bento_image_tag(bento, size:)
    if bento.image.attached? && bento.image.persisted?
      image_tag bento.image, alt: bento.name, width: size, height: size, class: 'rounded object-fit-cover'
    else
      tag.div '画像なし', class: 'rounded bg-body-secondary text-body-secondary small d-flex align-items-center justify-content-center',
                      style: "width: #{size}px; height: #{size}px;"
    end
  end

  def bento_sale_badge(bento)
    if bento.on_sale?
      tag.span '販売中', class: 'badge text-bg-success'
    else
      tag.span '非販売', class: 'badge text-bg-secondary'
    end
  end

  def rating_stars(rating)
    tag.span(('★' * rating) + ('☆' * (5 - rating)), class: 'text-warning', aria: { label: "5段階中#{rating}" })
  end

  def average_rating_label(bento)
    average_rating = bento.average_rating
    return '評価はまだありません' if average_rating.nil?

    "平均 #{number_with_precision(average_rating, precision: 1)}（#{bento.reviews.size}件）"
  end
end
