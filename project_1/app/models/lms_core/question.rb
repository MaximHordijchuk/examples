module LmsCore
  class Question < ApplicationRecord
    belongs_to :quiz, inverse_of: :questions
    has_many :user_question_answers, dependent: :destroy
    has_many :answer_options, dependent: :destroy, inverse_of: :question
    accepts_nested_attributes_for :answer_options, allow_destroy: true

    enum question_type: { checkbox_question: 0, multiple_choice: 1, open_question: 2 }

    default_scope { order :id }

    validates :quiz, :question_text, :question_type, presence: true
    validate :validate_answer_options_presence

    private

    def validate_answer_options_presence
      if open_question? && answer_options.present?
        errors.add(:answer_options, :should_not_be_present)
      elsif !(open_question? || answer_options.present?)
        errors.add(:answer_options, :must_be_present)
      end
    end
  end
end
