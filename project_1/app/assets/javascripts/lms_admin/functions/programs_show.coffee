jQuery ->
  $('.js-company-input').initialize ->
    $(@).programsShow()

$.fn.programsShow = ->
  $(@).change ->
    $list = $('.js-program-wrapper').find('.choices-group')
    $list.empty()
    company_id = $(@).find('option:selected').val()
    if company_id > 0
      $.get Routes.lms_admin_programs_path(company_id: company_id), (programs) =>
        _.each programs, (program) =>
          input_id = "user_program_ids_#{program.id}"
          $li = $('<li>', class: 'choice')
          $label = $('<label>', for: input_id)
          $input = $('<input>', type: 'checkbox', name: 'user[prorgam_ids][]', id: input_id, value: program.id)
          $li.append($label)
          $label.append($input)
          $label.append(program.title)
          $list.append($li)
