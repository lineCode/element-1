remote = require('electron').remote

module.exports =
class Widget
  constructor: (widget) ->
    @update(widget)

  update: (widget) =>
    console.log(widget)
    config = remote.getCurrentWindow().config
    @config = config.elements[widget]
    @window = config.window
