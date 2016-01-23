$ = require("jQuery")
path = require("path")
fs = require("fs")

$(document).ready =>
  scripts = path.join(__dirname, "assets/scripts")
  widgets = "#{scripts}/widgets"

  #fs.readdirSync(normalizedPath).forEach (file) ->
  #  require(path.join(__dirname, "assets/scripts/widgets/", file))

  config = JSON.parse fs.readFileSync("#{scripts}/config.json")

  for k, v of config
    Widget = require("#{widgets}/#{k}")
    new Widget(v)

