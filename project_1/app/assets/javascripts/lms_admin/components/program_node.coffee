@ProgramNode = React.createClass
  displayName: 'ProgramNode'
  mixins: [ShortcutsMixin, MoveNodeMixin, ScrollMixin, RoutesMixin]
  propTypes:
    connectDropTarget: React.PropTypes.func.isRequired
  storeState: ->
    program: LmsStore.currentProgram
  getInitialState: ->
    @storeState()
  componentDidMount: ->
    LmsStore.addListener('lms:changed', @programUpdated)
  componentWillUnmount: ->
    LmsStore.removeListener('lms:changed', @programUpdated)
  programUpdated: ->
    @setState(@storeState()) if LmsStore.currentProgram
  getChildModules: ->
    _.map @state.program.modules, (module) => ReactDOM.findDOMNode(@refs["module-#{module.id}"])
  isSelected: ->
    LmsStore.selectedNodeType == LmsConstants.NODE_TYPES.PROGRAM && LmsStore.selectedNode.id == @state.program.id
  selectProgram: ->
    LmsActions.selectProgram(@state.program)
    @pushStateProgram(@state.program.id)
    @scrollTop()
  render: ->
    connectDropTarget = @props.connectDropTarget
    connectDropTarget(
      @div className: 'program-node',
        @a
          href: 'javascript:void(0)'
          className: classNames('program-node__title', 'node_selected': @isSelected())
          onClick: @selectProgram
          @state.program.title
        @ul null,
          for module in @state.program.modules
            React.createElement ModuleNode, key: module.id, module: module, ref: "module-#{module.id}"
    )

programTarget =
  hover: (props, monitor, component) ->
    overNestedDropTarget = monitor.isOver(shallow: true)
    return unless overNestedDropTarget

    dragNode = monitor.getItem()
    hoverNode = component.state.program
    clientOffset = monitor.getClientOffset() # Determine mouse position
    $hoverNodeItems = component.getChildModules()

    component.moveNode
      dragNodeId: dragNode.id
      dragNodeType: LmsConstants.NODE_TYPES.MODULE
      hoverNode: hoverNode
      hoverNodeType: LmsConstants.NODE_TYPES.PROGRAM
      clientOffsetY: clientOffset.y
      $hoverNodeItems: $hoverNodeItems

  drop: (props, monitor, component) ->
    dragNode = monitor.getItem()
    component.onModuleDrop(dragNode.id)

@ProgramNode = ReactDnD.DropTarget(LmsConstants.NODE_TYPES.MODULE, programTarget, (connect) -> {
  connectDropTarget: connect.dropTarget()
})(ProgramNode)
