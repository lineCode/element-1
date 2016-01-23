$ = require("jQuery")

strftime = require('strftime')

module.exports =
class BarDate

  refresh: 1000
  height: $(".bar").height()
  dateFormat: "%a %b %d"

  constructor: ->
    $(".bar").append @element()
    setInterval @update, @refresh

  update: =>
    $(".date").text @date()

  element: =>
    """
    <div class="date" style="#{@style()}"></div>
    """

  style: =>
    """
    height: #{@height}px !important;
    line-height: #{@height}px !important;
    """


  date: ->
    strftime(@dateFormat, new Date())

