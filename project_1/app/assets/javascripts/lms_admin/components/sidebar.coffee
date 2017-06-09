@Sidebar = React.createClass
  displayName: 'Sidebar'
  mixins: [ShortcutsMixin]
  isShowAddItemActions: ->
    LmsStore.currentProgram && !LmsStore.currentProgram.is_new
  render: ->
    @div className: 'sidebar',
      if LmsStore.currentProgram
        React.createElement ProgramNode
      React.createElement AddItemActions if @isShowAddItemActions()

@Sidebar = ReactDnD.DragDropContext(ReactDnDHTML5Backend)(Sidebar)
