jQuery ->
  $('.js-quiz').initialize ->
    $(@).properAnswerOptions()

$.fn.properAnswerOptions = ->
  do properAnswerOptions = =>
    $(@).find('.questions > fieldset').each ->
      $question = $(@)
      $questionType = $question.find('.js-question_type')
      if $questionType.val() == 'open_question'
        $answer_options = $question.find('.answer_options')
        $answer_options.hide()
        $answer_options.find('fieldset').remove()
      else
        $question.find('.answer_options').show()

  $(@).on 'change', ->
    properAnswerOptions()
