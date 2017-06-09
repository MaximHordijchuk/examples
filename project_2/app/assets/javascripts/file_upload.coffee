Dropzone.autoDiscover = false

jQuery ->
  $('.file-inputs').bootstrapFileInput()
  $dz = $('.js-dropzone')

  dzSelector = ($dz, selector) ->
    _.map(selector.split(','), (part) -> "##{$dz.closest('form').attr('id')} #{part.trim()}").join(', ')

  $dz.dropzone(
    uploadMultiple: false
    clickable: dzSelector($dz, '.dropzone, .dm-clickable-zone')
    url: '/attachments/cache'
    acceptedFiles: if $dz.is('.dz-images-upload') then 'image/*' else null
    addRemoveLinks: true
    createImageThumbnails: true
    previewsContainer: dzSelector($dz, '.dropzone-previews')
    init: ->
      $input = $(@element).find("input[type='hidden'][data-reference='#{$(@element).find('.dz-form-value').data('reference')}']")

      # Set file attribute value. Works with persisted and not persisted files
      setAttribute = (file, attribute, value) =>
        file[attribute] = value
        if file.persisted
          $("#asset-#{file.assetId} .js-ordinal").val(value)
        else
          fieldValues = JSON.parse($input.val())
          fileObject = _.find fieldValues, (f) => f.id == file.id
          fileObject[attribute] = value
          $input.val(JSON.stringify(fieldValues))

      filesToAdd = []

      # Add images when form is not saved
      $input.val('[]') if $input.val() == '{}'
      if JSON.parse($input.val()).length
        _.each JSON.parse($input.val()), (file) =>
          dzFile =
            id: file.id
            name: file.filename
            size: file.size
            content_type: file.type
            status: Dropzone.SUCCESS
            ordinal: file.ordinal
            fileUrl: file.file_url
          filesToAdd.push(dzFile)

      # Add already uploaded images
      _.each $('.js-image-asset'), (asset, index) =>
        $img = $(asset).find('img')
        return if $(asset).find('input[type="checkbox"]').is(':checked') # if image is not persisted (not uploaded) or checked to remove
        imageUrl = $img.attr('src')
        mockFile =
          assetId: $(asset).data('id')
          name: _.first(imageUrl.split('/').reverse())
          size: $(asset).data('size')
          status: Dropzone.SUCCESS
          ordinal: parseInt($(asset).find('.js-ordinal').val())
          fileUrl: imageUrl
          persisted: true
        filesToAdd.push(mockFile)

      # Order and add files to dropzone
      filesToAdd = _.sortBy filesToAdd, 'ordinal'
      _.each filesToAdd, (file, index) =>
        setAttribute(file, 'ordinal', index) if file.ordinal != index
        @emit("addedfile", file)
        $(file.previewTemplate).find('.dz-success-mark').text('')
        @createThumbnailFromUrl(file, file.fileUrl)
        @emit("complete", file)
        @emit("success", file)
        @files.push(file)

      @on 'success', (file, response) ->
        file.ordinal = $(file.previewTemplate).index()
        file.id = response.id
        value = JSON.parse($input.val())
        value.push({id: response.id, filename: file.name, size: file.size, content_type: file.type, ordinal: file.ordinal})
        $input.val(JSON.stringify(value))

      @on 'error', (file, response) ->
        $('.js-upload-errors').append("<p class='inline-errors'>#{file.name}: #{response}</p>")
        @removeFile(file)

      @on 'removedfile', (file) ->
        _.each @files, (f) -> setAttribute(f, 'ordinal', f.ordinal - 1) if f.ordinal > file.ordinal
        return $("#asset-#{file.assetId}").find('input[type="checkbox"]').attr('checked', true) if file.assetId
        if file.id
          value = _.reject(JSON.parse($input.val()), (obj) -> obj.id == file.id)
          $input.val(JSON.stringify(value))

      Sortable.create @previewsContainer,
        animation: 150
        draggable: '.dz-preview.dz-success'
        onEnd: (event) =>
          if event.oldIndex < event.newIndex # from left to right
            _.each @files, (file) =>
              if file.ordinal > event.oldIndex && file.ordinal <= event.newIndex
                setAttribute(file, 'ordinal', file.ordinal - 1)
              else if file.ordinal == event.oldIndex
                setAttribute(file, 'ordinal', event.newIndex)
          else if event.oldIndex > event.newIndex # from right to left
            _.each @files, (file) =>
              if file.ordinal >= event.newIndex && file.ordinal < event.oldIndex
                setAttribute(file, 'ordinal', file.ordinal + 1)
              else if file.ordinal == event.oldIndex
                setAttribute(file, 'ordinal', event.newIndex)
        onStart: (event) => $(event.item).find('.dz-success-mark').text('')
  )
