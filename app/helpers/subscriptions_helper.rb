module SubscriptionsHelper
  def wday_name(wday)
    I18n.t('date.day_names')[wday]
  end

  def wday_options
    Subscription::WDAYS.map { [wday_name(it), it] }
  end

  # NOTE: 管理者があとからエリアを無効にした設定も、エリアを選び直さずに他の項目を編集できるよう、
  #       保存済みの無効なエリアだけは選択肢に残している（モデルもエリアを変えたときだけ有効かを確認する）
  def subscription_delivery_area_options(subscription)
    saved_area = subscription.persisted? ? DeliveryArea.find_by(id: subscription.delivery_area_id_in_database) : nil
    return delivery_area_options if saved_area.nil? || saved_area.active?

    [["#{saved_area.name}（#{formatted_postal_code(saved_area.postal_code)}）※無効", saved_area.id], *delivery_area_options]
  end

  def subscription_status_badge(subscription)
    if subscription.active?
      tag.span '有効', class: 'badge text-bg-success'
    else
      tag.span '無効', class: 'badge text-bg-secondary'
    end
  end
end
