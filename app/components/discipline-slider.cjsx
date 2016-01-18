React = require 'react'
StepThrough = require './step-through'
MediaCard = require './media-card'
{DISCIPLINES} = require './disciplines'
Filmstrip = require './filmstrip'

module.exports = React.createClass
  displayName: 'DisciplineSlider'

  propTypes:
    selectedDiscipline: React.PropTypes.string
    filterDiscipline: React.PropTypes.func.isRequired

  getDefaultProps: ->
    filterCards: DISCIPLINES

  render: ->
    <Filmstrip increment={350} filterOption={@props.filterDiscipline}/>