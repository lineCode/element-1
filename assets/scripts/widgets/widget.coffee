remote = require('electron').remote

module.exports =
class Widget
  constructor: (widget) ->
    @getConfig(widget)
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
    console.log "destroy"
    clearInterval @updateInterval
    #@ = null

