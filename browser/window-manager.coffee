
# Module to create native browser window.
BrowserWindow = require('electron').BrowserWindow

fs = require('fs')
coffee = require('coffee-script')
coffee.register()

coffee.eval(fs.readFileSync(__dirname + "/browser/config.coffee").toString())

module.exports =
class WindowManager
  constructor: (@production, @root) ->
    @windows = []
    @cm = new ConfigManager()

    @createWindows()

    w.webContents.on('did-finish-load', => @onload(w)) for w in @windows

  # onload initializes communication from browser to client for various
  # situations
  onload: (window) ->
    @cm.watchConfig window
    @cm.watchStylesheets window
    @cm.watchWidgets window
    @loadStylesheets window


  # loadStylesheets reads each of the stylesheets in the user's configuration
  # folder and sends them to the client
  loadStylesheets: (window) ->
    for file in fs.readdirSync("#{@cm.path}/stylesheets/")
      window.webContents.send("stylesheet", "#{@cm.path}/stylesheets/#{file}")


  # createWindows creates a window for each display
  # TODO: support multiple displays
  createWindows: () ->
    screen = require("screen")
    displays = screen.getAllDisplays()
    #for var i in displays
    #  createBar(displays[0], options)
    @windows.push @createWindow(displays[0], @cm.config.window)


  # createWindow builds a window using the user's configuration file
  createWindow: (display, win) =>
    # Create the browser window.
    window = new BrowserWindow(@windowOptions(display, win))
    window.config = @cm.config

    # Set position outside of options to avoid centering issue
    xpos = @getXPos(display.bounds.width, display.bounds.x, win.padding)
    ypos = @getYPos(display.bounds.height, display.bounds.y, win.padding)
    window.setPosition(xpos, ypos)

    # Make it visible on all workspaces
    window.setVisibleOnAllWorkspaces true

    # and load the index.html of the app.
    window.loadURL "file://#{@root}/index.html"

    # Open the DevTools.
    window.webContents.openDevTools({ detach: true }) unless @production

    return window


  # windowOptions formats an object for the BrowserWindow to create a
  # window out of
  windowOptions: (display, win) =>
    width: @getWidth(display.bounds.width, win.size.width, win.padding)
    height: @getHeight(display.bounds.height, win.size.height)
    type: win.type
    frame: false
    autoHideMenuBar: true
    alwaysOnTop: true
    resizable: false
    movable: false
    title: ""


  # Might be useful for os x. Leaving out for now
  #
  #windowEvents: (window) =>
  #  # Emitted when the window is closed.
  #  @window.on 'closed', () =>
  #    # Dereference the window object, usually you would store windows
  #    # in an array if your app supports multi windows, this is the time
  #    # when you should delete the corresponding element.
  #    @window = null

  #  return @window


  getXPos: (displayWidth, displayX, padding) =>
    if typeof(padding.left) is "string"
      return displayX + @percentToInt(displayWidth, padding.left)
    return displayX + padding.left

  getYPos: (displayHeight, displayY, padding) ->
    if typeof(padding.top) is "string"
      return displayY + @percentToInt(displayHeight, padding.top)
    return displayY + padding.top

  getHeight: (displayHeight, configHeight) ->
    if typeof(configHeight) is "string"
      return @percentToInt(displayHeight, configHeight)
    return configHeight

  getWidth: (displayWidth, configWidth, padding) =>
    if configWidth is "auto"
      return displayWidth - padding.left - padding.right
    else if typeof(configWidth) is "string"
      return @percentToInt(displayWidth, configWidth)
    return configWidth

  percentToInt: (max, percent) ->
    Math.floor(max * (parseInt(percent.replace("%", "")) / 100))
