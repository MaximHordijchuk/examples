module LmsCore
  class Quiz < ApplicationRecord
    has_one :module_item, as: :item, dependent: :destroy, inverse_of: :item
    has_many :questions, dependent: :destroy, inverse_of: :quiz
    has_one :module, through: :module_item

    accepts_nested_attributes_for :module_item
    accepts_nested_attributes_for :questions, allow_destroy: true

    delegate :title, :next_module_item, :previous_module_item, to: :module_item

    validates :questions, presence: true

    def has_open_question?
      questions.exists?(question_type: Question.question_types[:open_question])
    end
  end
end
