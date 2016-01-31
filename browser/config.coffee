
fs = require 'fs'
jsyaml = require('js-yaml')

module.exports=
class ConfigManager
  constructor: ->
    @path = process.env['HOME'] + "/.config/element"
    @config = @getConfig()

  # watchStylesheets watches for updates in the user's stylesheets path.
  # on change, it notifies the client so the stylesheet can be reloaded.
  watchStylesheets: (window) =>
    w = fs.watch "#{@path}/stylesheets/"
    w.on 'change', (e, file) =>
      if e is "change" and file.indexOf(".") > 0
        afterTimeout =>
          window.webContents.send "stylesheet", "#{@path}/stylesheets/#{file}"
          @styleTimeout = @resetWatcher(@styleTimeout, w, @watchStylesheets, window)


  # watchWidgets watches for widgets in the user's widgets path. on change, it
  # notifies the client that a user has added/changed a widget
  watchWidgets: (window) =>
    w = fs.watch "#{@path}/widgets/"
    w.on 'change', (e, file) =>
      if e is "change" and file.indexOf('.') > 0
        afterTimeout =>
          @reloadConfig(window, w, @watchWidgets)


  # afterTimeout calls the passed method after a quarter second. fs.watch can
  # sometimes send multiple events when a file is updated with vim/emacs. This
  # method keeps the client from being updated too many times
  afterTimeout: (callback) =>
    clearTimeout @to
    @to = setTimeout(callback, 250)


  # getConfig reads the user's configuration yaml file
  getConfig: () =>
    jsyaml.safeLoad fs.readFileSync(@configPath())


  # configPath returns the path to the configuration file that should be loaded
  configPath: () =>
    "#{if @userHasConfig() then @path else __dirname}/config.yml"


  # userHasConfig checks to see if the user has a configuration file in their
  # config directory.
  userHasConfig: () =>
    fs.existsSync("#{@path}/config.yml")


  # watchConfig watches the user's configuration file for changes. Upon change, it
  # notifies the client with the new configuration
  watchConfig: (window) =>
    w = fs.watch "#{@path}/config.yml"
    w.on 'change', (e) =>
      @reloadConfig(window, w, @watchConfig) if e is "change"


  # reloadConfig is called from watching methods. It's the method that actually
  # gets the config and sends the it to the client.
  reloadConfig: (window, w, callback) =>
    @config = @getConfig()
    window.webContents.send("config", JSON.stringify(@config))
    @configTimeout = @resetWatcher(@configTimeout, w, callback, window)


  # resetWatcher resets a file watcher after it has been used. Vim/emacs can
  # delete/recreate files when backup files are in use. This method ensures
  # watching doesn't break when that happens
  resetWatcher: (timeout, watcher, callback, window) =>
    # Restart watcher (vim/emacs can kill the watcher)
    clearTimeout timeout
    setTimeout () =>
      watcher.close()
      callback(window)
    , 1000
