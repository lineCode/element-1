remote = require('electron').remote

module.exports =
class Widget
  constructor: (widget) ->
    @getConfig(widget)
    setTimeout =>
      @update(widget)
    , 0

  update: (widget) =>
    @getConfig(widget)

  getConfig: (widget) =>
    config = remote.getCurrentWindow().config
    @config = config.elements[widget]
    @window = config.window
