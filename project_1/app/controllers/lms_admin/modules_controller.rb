module LmsAdmin
  class ModulesController < BaseController
    before_action :authenticate_user!

    def submodules
      render_json_success(lms_core_module.modules, each_serializer: SimpleModuleListSerializer)
    end

    def parent_modules_ids
      render_json_success(lms_core_module.parent_modules_ids)
    end

    def create
      @module = program.modules.new(module_params)
      if @module.save
        render_json_success(@module, serializer: ModuleListSerializer)
      else
        render_json_errors(@module.errors.full_messages, :bad_request)
      end
    end

    def update
      if lms_core_module.update(module_params)
        render_json_success(lms_core_module, serializer: ModuleListSerializer)
      else
        render_json_errors(lms_core_module.errors.full_messages, :bad_request)
      end
    end

    def destroy
      lms_core_module.destroy
      render_json_success
    end

    def move
      lms_core_module.insert_at(params[:ordinal].to_i)
      parent_module = lms_core_module.module
      if lms_core_module.update(module_params)
        parent_module.ensure_completed! if parent_module
        render_json_success(program.reload, serializer: ProgramSerializer)
      else
        render_json_errors(lms_core_module.errors.full_messages, :bad_request)
      end
    end

    private

    def program
      if current_user.admin?
        @program ||= LmsCore::Program.find(params[:program_id])
      elsif current_user.moderator?
        @program ||= current_user.company.programs.find(params[:program_id])
      else
        render_json_errors(t('errors.no_permission_access'), :forbidden)
      end
    end

    def lms_core_module
      @module ||= program.nested_modules.find(params[:id])
    end

    def module_params
      params.require(:module).permit(:title, :starts_at, :module_id, :program_id)
    end
  end
end
