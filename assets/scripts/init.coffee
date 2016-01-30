coffee = require('coffee-script')
coffee.register()

$ = require("jQuery")
path = require("path")
fs = require("fs")
remote = require('electron').remote

window.requireCoffee = (file) ->
  if /\.coffee/.test(file)
    f = fs.readFileSync(file).toString()
    coffee.eval(f)
  else
    require file

$(document).ready =>
  scripts = path.join(__dirname, "assets/scripts")
  window.widgets = "#{scripts}/widgets"

  config = remote.getCurrentWindow().config

  $(".bar html body").height(config.window.heght)
  console.log config.window

  for k, v of config.elements
    Widget = requireCoffee("#{widgets}/#{k}.coffee")
    new Widget(v, config.window)

