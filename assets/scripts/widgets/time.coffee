Widget = requireCoffee("#{widgets}/widget.coffee")
$ = require("jquery")

strftime = require('strftime')

module.exports =
class Time extends Widget

  constructor: ->
    super("time")

  update: =>
    super("time")
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

