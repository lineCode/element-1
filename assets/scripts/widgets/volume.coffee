Widget = requireCoffee("#{widgets}/widget.coffee")
$ = require("jquery")
execSync = require('child_process').execSync
dbus = require("dbus-native")

module.exports =
class Volume extends Widget

  constructor: ->
    super("volume")

    #sessionBus = dbus.sessionBus()
    #console.log sessionBus
    #sessionBus.getService('org.gtk.vfs.UDisks2VolumeMonitor')
    #          .getInterface '/org/gtk/Private/RemoveVolumeMonitor',
    #                        'org.gtk.vfs.UDisks2VolumeMonitor', (err, notifications) =>
    #                          console.log arguments

        # dbus signals are EventEmitter events
        #notifications.on('PropertiesChanged', () =>
        #    console.log('ActionInvoked', arguments)
        #})

  update: =>
    super("volume")
    percentage = @volume()
    $(".volume .value").text percentage
    $(".volume .icon").removeClass().addClass("icon fa #{@volumeIcon(percentage)}")

  element: =>
    """
    <div class="volume" style="#{@style()}">
      <span class="icon fa"></span>
      <span class="value"></span>
    </div>
    """

  style: =>
    """
    height: #{@window.size.height}px !important;
    line-height: #{@window.size.height}px !important;
    """

  volume: =>
    if @muted()
      0
    else
      execSync("amixer get Master |grep % |awk '{print $5}'|sed 's/[^0-9]//g'").toString().split("\n")[0]

  muted: =>
    execSync("amixer get Master ").toString().match(/off/g) != null

  volumeIcon: (percentage) =>
    return if percentage > 50
      "fa-volume-up"
    else if percentage > 0
      "fa-volume-down"
    else
      "fa-volume-off"

