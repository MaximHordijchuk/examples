@ModuleNode = React.createClass
  displayName: 'ModuleNode'
  mixins: [ShortcutsMixin, MoveNodeMixin, ScrollMixin, RoutesMixin]
  propTypes:
    module: React.PropTypes.object.isRequired
    connectDragSource: React.PropTypes.func.isRequired
    connectDropTarget: React.PropTypes.func.isRequired
    dragNode: React.PropTypes.object
  getChildModules: ->
    _.map @props.module.modules, (module) => ReactDOM.findDOMNode(@refs["module-#{module.id}"])
  getChildModuleItems: ->
    _.map @props.module.module_items, (moduleItem) => ReactDOM.findDOMNode(@refs["module-item-#{moduleItem.id}"])
  isSelected: ->
    LmsStore.selectedNode == @props.module
  selectModule: ->
    LmsActions.selectModule(@props.module)
    @pushStateModule(@props.module.program_id, @props.module.id)
    @scrollTop()
  render: ->
    connectDragSource = @props.connectDragSource
    connectDropTarget = @props.connectDropTarget
    isDragging = @props.dragNode && @props.dragNode.id == @props.module.id && @props.dragNode.type == LmsConstants.NODE_TYPES.MODULE

    connectDragSource(connectDropTarget(
      @li className: classNames('module-node', 'module-node_dragging': isDragging),
        @a
          href: 'javascript:void(0)'
          className: classNames('module-node__title', 'node_selected': @isSelected())
          onClick: @selectModule
          @props.module.title
          components = []
        @ul null,
          for module in @props.module.modules
            React.createElement ModuleNode, key: module.id, module: module, ref: "module-#{module.id}"
          for moduleItem in @props.module.module_items
            React.createElement ModuleItemNode, key: moduleItem.id, moduleItem: moduleItem, ref: "module-item-#{moduleItem.id}"
    ))

moduleSource =
  beginDrag: (props) ->
    id: props.module.id
    type: LmsConstants.NODE_TYPES.MODULE

moduleTarget =
  hover: (props, monitor, component) ->
    overNestedDropTarget = monitor.isOver(shallow: true)
    return unless overNestedDropTarget

    dragNode = monitor.getItem()
    hoverNode = props.module
    clientOffset = monitor.getClientOffset() # Determine mouse position
    if dragNode.type == LmsConstants.NODE_TYPES.MODULE
      $hoverNodeItems = component.getChildModules()
    else
      $hoverNodeItems = component.getChildModuleItems()

    component.moveNode
      dragNodeId: dragNode.id
      dragNodeType: dragNode.type
      hoverNode: hoverNode
      hoverNodeType: LmsConstants.NODE_TYPES.MODULE
      clientOffsetY: clientOffset.y
      $hoverNodeItems: $hoverNodeItems

  drop: (props, monitor, component) ->
    dragNode = monitor.getItem()
    if dragNode.type == LmsConstants.NODE_TYPES.MODULE
      component.onModuleDrop(dragNode.id)
    else
      component.onModuleItemDrop(dragNode.id, dragNode.module_id)

@ModuleNode = ReactDnD.DropTarget([LmsConstants.NODE_TYPES.MODULE, LmsConstants.NODE_TYPES.MODULE_ITEM], moduleTarget, (connect) -> {
  connectDropTarget: connect.dropTarget()
})(ModuleNode)

@ModuleNode = ReactDnD.DragSource(LmsConstants.NODE_TYPES.MODULE, moduleSource, (connect, monitor) -> {
  connectDragSource: connect.dragSource()
  dragNode: monitor.getItem()
})(ModuleNode)
