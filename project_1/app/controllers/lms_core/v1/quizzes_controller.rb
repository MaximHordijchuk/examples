module LmsCore
  class V1::QuizzesController < V1::BaseController
    def show
      render_json_success(quiz, serializer: LmsCore::V1::QuizSerializer)
    end

    def update
      module_item_status = quiz.module_item.module_item_statuses.build(user_id: current_user.id)
      attributes = ModuleItemStatus.build_attributes(question_answers_params[:question_answers],
                                                     @quiz.questions)
      if module_item_status.update(attributes)
        render_json_success(quiz, serializer: LmsCore::V1::QuizSerializer)
      else
        render_json_errors(module_item_status.errors.full_messages, :bad_request)
      end
    end

    private

    def program
      @program ||= current_user.programs.find(params[:program_id])
    end

    def lms_core_module
      @module ||= program.nested_modules.find(params[:module_id])
    end

    def quiz
      @quiz ||= lms_core_module.module_items.quiz_items.find(params[:id]).item
    end

    def question_answers_params
      params.permit(question_answers: [:question_id, :answer_text, answer_options_ids: []])
    end
  end
end
