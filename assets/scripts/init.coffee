$ = require("jQuery")
path = require("path")
fs = require("fs")
remote = require('electron').remote

$(document).ready =>
  scripts = path.join(__dirname, "assets/scripts")
  widgets = "#{scripts}/widgets"

  config = remote.getCurrentWindow().config

  $(".bar html body").height(config.window.heght)
  console.log config.window

  for k, v of config.elements
    Widget = require("#{widgets}/#{k}")
    new Widget(v, config.window)

