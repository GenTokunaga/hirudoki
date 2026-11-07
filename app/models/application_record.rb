class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.human_enum_name(enum_name, value)
    I18n.t("enums.#{model_name.i18n_key}.#{enum_name}.#{value}")
  end
end
