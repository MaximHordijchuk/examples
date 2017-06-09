class LmsCore::MaterialDecorator < Draper::Decorator
  delegate_all

  def content
    object.content.html_safe
  end
end
