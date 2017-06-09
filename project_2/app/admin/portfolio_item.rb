ActiveAdmin.register PortfolioItem do
  menu priority: 105, parent: I18n.t('admin.menu.portfolio')

  permit_params :title, :brief, :description, :status, :featured,
                category_ids: [], assets_files: [], assets_attributes: [:id, :_destroy, :ordinal],
                cover_attributes: [:id, :file]

  actions :all, except: [:destroy]

  config.sort_order = 'ordinal_asc'
  config.per_page = 100

  orderable

  action_item :view_on_site, only: :show do
    link_to 'View on site', portfolio_item_path(params[:id])
  end

  index do
    orderable_handle_column
    selectable_column
    id_column
    column :cover do |portfolio_item|
      image_tag attachment_url(portfolio_item.cover, :file, :fill, 100, 100)
    end
    column :title
    column :brief
    column :status
    column :featured
    actions do |portfolio_item|
      link_to 'View on site', portfolio_item_path(portfolio_item)
    end
  end

  filter :status, as: :select, collection: PortfolioItem.statuses
  filter :featured
  filter :categories, as: :check_boxes

  form partial: 'form'

  show do |portfolio_item|
    attributes_table do
      row :id
      row 'Cover' do
        image_tag attachment_url(portfolio_item.cover, :file, :fill, 150, 150)
      end
      row 'Attachments' do
        safe_join(portfolio_item.assets.map do |asset|
          content_tag(:span, (image_tag attachment_url(asset, :file, :fill, 150, 150)))
        end, ' ')
      end
      row :title
      row :brief
      row :description
      row :status
      row :featured
      row 'Categories' do
        safe_join(portfolio_item.categories.map do |category|
          link_to category.title, admin_category_path(category)
        end, ', ')
      end
      row :created_at
      row :updated_at
    end
  end
end
