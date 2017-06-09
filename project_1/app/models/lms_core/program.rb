module LmsCore
  class Program < ApplicationRecord
    include Concerns::AssetConcern

    belongs_to :company
    has_one :icon, as: :entity, class_name: 'Asset', inverse_of: :entity, dependent: :destroy
    has_many :modules, -> { where(module_id: nil) }
    has_many :nested_modules, class_name: 'LmsCore::Module', dependent: :destroy
    has_many :programs_users, dependent: :destroy
    has_many :users, through: :programs_users

    enum modules_show_order: { all_at_once: 0, one_by_one: 1, by_starts_at: 2 }

    accepts_nested_attributes_for :icon, allow_destroy: true, reject_if: :file_blank?

    default_scope { order :id }
    scope :with_completed_items, (lambda do |user_id|
      from(joins(modules: :module_item_statuses)
             .merge(ModuleItemStatus.completed(user_id)), :lms_core_programs).distinct
    end)

    validates :title, :icon, :description, :company, :modules_show_order, presence: true

    def available_modules(user_id)
      case modules_show_order
      when 'all_at_once'
        modules
      when 'one_by_one'
        one_by_one_available_modules(user_id)
      when 'by_starts_at'
        modules.started
      else
        # return nil
      end
    end

    def progress(user_id)
      all_module_items = ModuleItem.joins(:module).where(lms_core_modules: { program_id: id })
      completed_module_items = all_module_items.completed(user_id).distinct
      all_module_items.count.zero? ? 0 : (completed_module_items.count * 100.0 / all_module_items.count).to_i
    end

    private

    # finds all completed modules plus first incomplete
    def one_by_one_available_modules(user_id)
      modules_ids = []
      module_index = 0
      module_current = nil
      loop do
        if module_index < modules.size
          module_current = modules[module_index]
          modules_ids << module_current.id
        end
        module_index += 1
        break if !module_current&.completed?(user_id) || module_index >= modules.size
      end
      Module.where(id: modules_ids)
    end
  end
end
