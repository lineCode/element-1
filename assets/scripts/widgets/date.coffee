$ = require("jQuery")

strftime = require('strftime')

module.exports =
class BarDate

  constructor: (@config, @window) ->
    $(".bar").append @element()
    setInterval @update, @config.refresh

  update: =>
    $(".date").text @date()

  element: =>
    """
    <div class="date" style="#{@style()}"></div>
    """

  style: =>
    """
    height: #{@window.size.height}px !important;
    line-height: #{@window.size.height}px !important;
    """


  date: ->
    strftime(@config.format, new Date())

