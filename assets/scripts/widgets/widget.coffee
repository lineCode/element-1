remote = require('electron').remote
$ = require("jquery")

module.exports =
class Widget
  constructor: (widget) ->
    @homePath = process.env['HOME']
    @configPath = "#{@homePath}/.config/element"
    @getConfig(widget)
    $(".bar").append @element()
    setTimeout @update, 0
    if @config?.refresh > 0
      @updateInterval = setInterval(@update, @config.refresh)

  update: (widget) =>
    @getConfig(widget)

  getConfig: (widget) =>
    config = window.config
    @config = config.elements[widget]
    @window = config.window

  destroy: =>
    clearInterval @updateInterval

