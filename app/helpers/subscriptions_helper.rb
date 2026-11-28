module SubscriptionsHelper
  def wday_name(wday)
    I18n.t('date.day_names')[wday]
  end

  def wday_options
    Subscription::WDAYS.map { [wday_name(it), it] }
  end

  def subscription_status_badge(subscription)
    if subscription.active?
      tag.span '有効', class: 'badge text-bg-success'
    else
      tag.span '無効', class: 'badge text-bg-secondary'
    end
  end
end
