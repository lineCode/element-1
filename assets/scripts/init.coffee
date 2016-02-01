coffee = require('coffee-script')
coffee.register()

$ = require("jquery")
path = require("path")
fs = require("fs")
electron = require('electron')
remote = electron.remote

activeWidgets = []
startElement = (config) =>
  activeWidgets.pop().destroy() for w in activeWidgets
  window.config = config
  $(".bar").html("")
  $(".bar html body").height(config.window.size.height)
  for k, v of config.elements
    Widget = requireCoffee("#{widgets}/#{k}.coffee")
    activeWidgets.push new Widget(v, config.window)

window.requireCoffee = (file) ->
  file = window.root + "/" + file
  unless fs.existsSync(file)
    file = "#{window.userDir}/widgets/#{coffee.helpers.baseFileName file}"

  if /\.coffee/.test(file)
    f = fs.readFileSync(file).toString()
    coffee.eval(f)
  else
    require file

appendStylesheet = (file, classList) =>
  $("head").append "<link class='#{classList}' rel='stylesheet' type='text/less' href='#{file}'>"

removeStylesheet = (file) =>
  $("link[href='#{file}']").remove()

appendStylesheet "assets/stylesheets/main.less"

electron.ipcRenderer.on 'stylesheet', (err, file) =>
  removeStylesheet file
  appendStylesheet file, "user"

  # Sort user stylesheets alphabetically
  $("link.user").sort((a, b) =>
    if $(b).attr('href') < $(a).attr('href') then 1 else -1
  ).appendTo("head")

electron.ipcRenderer.on 'config', (err, config) =>
  startElement JSON.parse(config)

$(document).ready =>
  scripts = path.join(__dirname, "assets/scripts")
  window.widgets = "#{scripts}/widgets"
  startElement remote.getCurrentWindow().config

