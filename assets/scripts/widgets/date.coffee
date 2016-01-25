Widget = require("./widget.coffee")
$ = require("jQuery")

strftime = require('strftime')

module.exports =
class BarDate extends Widget

  constructor: ->
    super("date")
    $(".bar").append @element()
    setInterval @update, @config.refresh

  update: =>
    super("date")
    $(".date").html @date()

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

