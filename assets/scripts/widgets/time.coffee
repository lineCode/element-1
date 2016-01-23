$ = require("jQuery")

strftime = require('strftime')

module.exports =
class Time

  refresh: 1000
  height: $(".bar").height()
  timeFormat: "%l:%M"

  constructor: ->
    $(".bar").append @element()
    setInterval @update, @refresh

  update: =>
    $(".time").text @time()

  element: =>
    """
    <div class="time" style="#{@style()}"></div>
    """

  style: =>
    """
    height: #{@height}px !important;
    line-height: #{@height}px !important;
    """

  time: ->
    strftime(@timeFormat, new Date())

