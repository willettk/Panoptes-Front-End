React = require 'react'
DrawingToolRoot = require './root'
DragHandle = require './drag-handle'
Draggable = require '../../lib/draggable'
DeleteButton = require './delete-button'

DEFAULT_RADIUS = 10
DEFAULT_SQUASH = 1 / 2
GUIDE_WIDTH = 1
GUIDE_DASH = [4, 4]
DEFAULT_ANGLE = 0
DELETE_BUTTON_ANGLE = 45

module.exports = React.createClass
  displayName: 'EllipseTool'

  statics:
    defaultValues: ({x, y}) ->
      x: x
      y: y
      rx: DEFAULT_RADIUS
      ry: DEFAULT_RADIUS * DEFAULT_SQUASH
      angle: DEFAULT_ANGLE

    initMove: ({x, y}, mark) ->
      distance = @getDistance mark.x, mark.y, x, y
      angle = @getAngle mark.x, mark.y, x, y
      rx: distance
      ry: distance * DEFAULT_SQUASH
      angle: angle

    getDistance: (x1, y1, x2, y2) ->
      aSquared = Math.pow x2 - x1, 2
      bSquared = Math.pow y2 - y1, 2
      Math.sqrt aSquared + bSquared

    getAngle: (x1, y1, x2, y2) ->
      deltaX = x2 - x1
      deltaY = y2 - y1
      Math.atan2(deltaY, deltaX) * (-180 / Math.PI)

  getDeletePosition: ->
    theta = (DELETE_BUTTON_ANGLE - @props.mark.angle) * (Math.PI / 180)
    x: @props.mark.rx * Math.cos theta
    y: -1 * @props.mark.ry * Math.sin theta

  render: ->
    positionAndRotate = "
      translate(#{@props.mark.x}, #{@props.mark.y})
      rotate(#{-1 * @props.mark.angle})
    "

    deletePosition = @getDeletePosition()

    <DrawingToolRoot tool={this} transform={positionAndRotate}>
      {if @props.selected
        <g>
          <line x1="0" y1="0" x2={@props.mark.rx} y2="0" strokeWidth={GUIDE_WIDTH} strokeDasharray={GUIDE_DASH} />
          <line x1="0" y1="0" x2="0" y2={-1 * @props.mark.ry} strokeWidth={GUIDE_WIDTH} strokeDasharray={GUIDE_DASH} />
        </g>}

      <Draggable onDrag={@handleMainDrag} disabled={@props.disabled}>
        <ellipse rx={@props.mark.rx} ry={@props.mark.ry} />
      </Draggable>

      {if @props.selected
        <g>
          <DeleteButton tool={this} x={deletePosition.x} y={deletePosition.y} rotate={@props.mark.angle} />
          <DragHandle onDrag={@handleRadiusHandleDrag.bind this, 'x'} x={@props.mark.rx} y={0} />
          <DragHandle onDrag={@handleRadiusHandleDrag.bind this, 'y'} x={0} y={-1 * @props.mark.ry} />
        </g>}
    </DrawingToolRoot>

  handleMainDrag: (e, d) ->
    @props.mark.x += d.x / @props.scale.horizontal
    @props.mark.y += d.y / @props.scale.vertical
    @props.classification.emit 'change'

  handleRadiusHandleDrag: (coord, e, d) ->
    {x, y} = @props.getEventOffset e
    r = @constructor.getDistance @props.mark.x, @props.mark.y , x, y
    angle = @constructor.getAngle @props.mark.x, @props.mark.y , x, y
    @props.mark["r#{coord}"] = r
    @props.mark.angle = angle
    if coord is 'y'
      @props.mark.angle -= 90
    @props.classification.emit 'change'
