'use strict';

var CoffeeScript = require('coffee-script');
CoffeeScript.register();

const electron = require('electron');
// Module to control application life.
const app = electron.app;
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow;

require('electron-reload')(__dirname);

var ensureConfig = function(path){
  if(!fs.existsSync(path + "config.yml")){
    fs.writeFileSync(path + "config.yml", fs.readFileSync("./config/config.sample.yml"))
  }
};

var symlinkWidgets = function(path){
  var widgetsDir = "./assets/scripts/widgets/";
  var userWidgetsDir = "./assets/scripts/widgets/user/widgets";
  try{
    fs.unlinkSync(userWidgetsDir);
  } catch(e) { }
  fs.symlinkSync(path + "widgets/", userWidgetsDir);
};

var symlinkStylesheets = function(path){
  if(!fs.existsSync(path + "stylesheets/main.less")){
    fs.writeFileSync(path + "stylesheets/main.less", fs.readFileSync("./assets/stylesheets/main.sample.less"))
  }
  var stylesheetsDir = "./assets/stylesheets/";
  try{
    fs.unlinkSync(stylesheetsDir + "main.less");
  } catch(e) { }
  fs.symlinkSync(path + "stylesheets/main.less", stylesheetsDir + "main.less");
};

var jsyaml = require('js-yaml');
var fs = require('fs');
var production = process.argv[2] == "production";
var configPath = process.env['HOME']+"/.config/element/"
ensureConfig(configPath);
symlinkWidgets(configPath);
symlinkStylesheets(configPath);
var config = jsyaml.safeLoad(fs.readFileSync(configPath + "config.yml"));

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when ;the JavaScript object is garbage collected.
let mainWindow;

var symlinkWidgets = function(){
};

var createWindows = function() {
  var screen = require("screen")
  var displays = screen.getAllDisplays();
  //for(var i in displays){
  //  createBar(displays[0], options)
  //}
  createBar(displays[0], { padding: config.window })

};

var createBar = function(display, options){
  console.log(display);
  createWindow(display, options.padding);
};


var createWindow = function(display, win) {
  var padding = win.padding
  var windowOptions = {
    width: getWidth(display.bounds.width, win.size.width, padding),
    height: getHeight(display.bounds.height, win.size.height),
    type: win.type,
    frame: false,
    autoHideMenuBar: true,
    alwaysOnTop: true,
    resizable: false,
    movable: false,
    title: ""
  }

  // Create the browser window.
  mainWindow = new BrowserWindow(windowOptions)

  // Share config with client side
  mainWindow.config = config;
  watchConfig();

  // Set position outside of options to avoid centering issue
  mainWindow.setPosition(
      getXPos(display.bounds.width, display.bounds.x, padding),
      getYPos(display.bounds.height, display.bounds.y, padding)
  )

  // Make it visible on all workspaces
  mainWindow.setVisibleOnAllWorkspaces(true);

  // and load the index.html of the app.
  mainWindow.loadURL('file://' + __dirname + '/index.html');

  if(!production){
    // Open the DevTools.
    mainWindow.webContents.openDevTools({ detach: true });
  }

  // Emitted when the window is closed.
  mainWindow.on('closed', function() {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null;
  });
};

var resetWatcherTimeout;
var watchConfig = function(){
  var w = fs.watch(configPath + "config.yml");
  w.on('change', function(e){
    if(e == "change") {
      // Reset configuration
      config = jsyaml.safeLoad(fs.readFileSync(configPath + "config.yml"))
      mainWindow.config = config;
      mainWindow.reload();

      // Restart watcher (vim/emacs can kill the watcher)
      clearTimeout(resetWatcherTimeout);
      resetWatcherTimeout = setTimeout(function(){
        w.close();
        watchConfig();
      }, 1000);
    }
  });
};

var getXPos = function(displayWidth, displayX, padding){
  if(typeof(padding.left) == "string") {
    return displayX + percentToInt(displayWidth, padding.left);
  }
  return displayX + padding.left
};

var getYPos = function(displayHeight, displayY, padding){
  if(typeof(padding.top) == "string"){
    return displayY + percentToInt(displayHeight, padding.top)
  }
  return displayY + padding.top
};

var getHeight = function(displayHeight, configHeight){
  if(typeof(configHeight) == "string"){
    return percentToInt(displayHeight, configHeight);
  }
  return configHeight;
};

var getWidth = function(displayWidth, configWidth, padding){
  if(configWidth == "auto"){
    return displayWidth - padding.left - padding.right
  } else if(typeof(configWidth) == "string") {
    return percentToInt(displayWidth, configWidth);
  }
  return configWidth;
};

var percentToInt = function(max, percent){
  return Math.floor(max * (parseInt(percent.replace("%", "")) / 100));
};


///////////////////////////////////////////////
// App Events
///////////////////////////////////////////////

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
app.on('ready', createWindows);

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', function () {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow();
  }
});
