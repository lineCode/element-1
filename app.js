'use strict';
require('app-module-path').addPath(__dirname + "/node_modules");

var production = process.argv.indexOf("production") != -1
var devTools   = process.argv.indexOf('dev') != -1
var fs = require('fs'),
    coffee = require('coffee-script'),
    electron = require('electron');

coffee.register();

if(!production){
  require('electron-reload')(__dirname);
}

coffee.eval(fs.readFileSync(__dirname + "/browser/window-manager.coffee").toString())
coffee.eval(fs.readFileSync(__dirname + "/browser/config.coffee").toString())


///////////////////////////////////////////////
// App Events
///////////////////////////////////////////////

// Module to control application life.
const app = electron.app;

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
app.on('ready', function(){
  // Keep a global reference of the window object, if you don't, the window will
  // be closed automatically when ;the JavaScript object is garbage collected.
  let wm = new WindowManager({ production: production, tools: devTools }, __dirname)
});

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
  //if (mainWindow === null) {
  //  createWindow();
  //}
});
