$ = require("jQuery")

strftime = require('strftime')

module.exports =
class Time

  constructor: (@config, @window) ->
    $(".bar").append @element()
    setInterval @update, @config.refresh

  update: =>
    $(".time").text @time()

  element: =>
    """
    <div class="time" style="#{@style()}"></div>
    """

  style: =>
    """
    height: #{@window.size.height}px !important;
    line-height: #{@window.size.height}px !important;
    """

  time: ->
    strftime(@config.format, new Date())

