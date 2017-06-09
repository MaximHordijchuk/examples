class LmsCore::ProgramDecorator < Draper::Decorator
  delegate_all

  def icon_url
    h.asset_url(object.icon.file_url)
  end
end
