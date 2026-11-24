class OrderPrice
  attr_reader :unit_price, :discount_per_unit, :quantity, :tax_rate_percent

  def initialize(unit_price:, discount_per_unit:, quantity:, tax_rate_percent: Rails.configuration.x.hirudoki.tax_rate_percent)
    @unit_price = unit_price
    @discount_per_unit = discount_per_unit
    @quantity = quantity
    @tax_rate_percent = tax_rate_percent
  end

  def subtotal
    discounted_unit_price * quantity
  end

  # NOTE: Float の誤差を避けるため、税率をパーセントの整数で持ち、整数の割り算で 1 円未満を切り捨てている
  def tax
    subtotal * tax_rate_percent / 100
  end

  def total
    subtotal + tax
  end

  private

  def discounted_unit_price
    [unit_price - discount_per_unit, 0].max
  end
end
