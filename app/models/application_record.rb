class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # enum の値を画面表示用の名前にする（config/locales/ja.yml の enums）。
  #   Bento.human_enum_name(:bento_type, :healthy) # => "ヘルシー"
  def self.human_enum_name(enum_name, value)
    I18n.t("enums.#{model_name.i18n_key}.#{enum_name}.#{value}")
  end
end
