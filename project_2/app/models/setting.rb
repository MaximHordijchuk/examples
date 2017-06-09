class Setting < ApplicationRecord
  validates :key, presence: true
  validate :allowed_key

  class << self
    def method_missing(name, *args, &block)
      super
    rescue NoMethodError
      setting = Setting.find_by(key: name)
      return setting.value if setting
    end

    def respond_to_missing?(method_name, include_private = false)
      super || (method_name.match(/^(?!define_method).*$/) && where(key: method_name).present?)
    end
end

  private

  def allowed_key
    errors.add(:key, :not_allowed) if key && Setting.methods.include?(key.to_sym)
  end
end
