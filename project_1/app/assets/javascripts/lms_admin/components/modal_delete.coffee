@ModalDelete = React.createClass
  displayName: 'ModalDelete'
  mixins: [ShortcutsMixin]
  propTypes:
    title: React.PropTypes.string.isRequired
    modelName: React.PropTypes.string.isRequired
    isOpen: React.PropTypes.bool.isRequired
    onCancel: React.PropTypes.func.isRequired
    onConfirm: React.PropTypes.func.isRequired
  componentWillMount: ->
    ReactModal.setAppElement('body')
  render: ->
    React.createElement ReactModal,
      isOpen: @props.isOpen
      className: 'modal-delete'
      contentLabel: 'Modal'
      @div className: 'text-center modal-delete__text',
        "Are you sure you want to delete \"#{@props.title}\" #{@props.modelName}?"
      @div className: 'modal-delete__actions text-center',
        @button onClick: @props.onCancel,
          'Cancel'
        @button onClick: @props.onConfirm,
          'Confirm'
