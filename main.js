'use strict';

const electron = require('electron');
// Module to control application life.
const app = electron.app;
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow;

require('electron-reload')(__dirname);

const config = require('js-yaml').safeLoad(require('fs').readFileSync("./config.yml"))


// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

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
    x: getXPos(display.bounds.width, display.bounds.x, win.position.x, padding),
    y: getYPos(display.bounds.height, display.bounds.y, win.position.y, padding),
    center: false,
    frame: false,
    autoHideMenuBar: true
  }
  // Create the browser window.
  mainWindow = new BrowserWindow(windowOptions)

  // Make it visible on all workspaces
  mainWindow.setVisibleOnAllWorkspaces(true);

  // and load the index.html of the app.
  mainWindow.loadURL('file://' + __dirname + '/index.html');

  // Open the DevTools.
  mainWindow.webContents.openDevTools({ detach: true });

  // Emitted when the window is closed.
  mainWindow.on('closed', function() {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null;
  });
};

var getXPos = function(displayWidth, displayX, configX, padding){
  if(typeof(configX) == "string"){
    if(configX == "auto"){
      return displayX + padding.left;
    }
    return displayX + displayWidth * (parseInt(configX.replace("%", "")) / 100);
  }
  return displayX + configX;
};

var getYPos = function(displayHeight, displayY, configY, padding){
  if(typeof(configY) == "string"){
    if(configY == "auto"){
      return displayY - padding.top;
    }
    return displayY + displayHeight * (parseInt(configY.replace("%", "")) / 100);
  }
  return displayY + configY;
};

var getHeight = function(displayHeight, configHeight){
  if(typeof(configHeight) == "string") {
    return displayHeight * (parseInt(configHeight.replace("%", "")) / 100);
  } else {
    return configHeight;
  }
};

var getWidth = function(displayWidth, configWidth, padding){
  if(typeof(configWidth) == "string"){
    if(configWidth == "auto"){
      return displayWidth - padding.left - padding.right;
    }
    return displayWidth * (parseInt(configWidth.replace("%", "")) / 100);
  }
  return configWidth;
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
