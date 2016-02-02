Widget = requireCoffee("#{widgets}/widget.coffee")
$ = require("jquery")
exec = require("child_process").exec

# Capacity
# upower -i /org/freedesktop/UPower/devices/battery_BAT0 | perl -wnE'say for /capacity:\s*(\d*\.\d*)/g'
#
# Percentage
# upower -i /org/freedesktop/UPower/devices/battery_BAT0 | perl -wnE'say for /percentage:\s*(\d*)/g'
module.exports =
class Battery extends Widget

  capacityCommand: "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | perl -wnE'say for /capacity:(.*)%/g'"
  percentageCommand: "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | perl -wnE'say for /percentage:(.*)%/g'"

  # upower -i /org/freedesktop/UPower/devices/battery_BAT0
  constructor:  ->
    super('battery')
    exec @capacityCommand, (err, stdout, stderr) =>
      @capacity = parseInt(stdout.replace(/\ /g, ""))

  update: =>
    super('battery')
    exec @percentageCommand, (err, stdout, stderr) =>
      bat = parseInt(stdout.replace(/\ /g, ""))
      percentage = Math.min(Math.floor(100 * (bat / @capacity)), 100)
      percentageText = if @config.capacity is "last_charge" then percentage else bat
      $(".battery").html """
        <style>#{@style()}</style>
        <span class='fa #{@iconClass(percentage)}'></span>
        <span>#{percentageText}%</span>
      """

  iconClass: (percentage) =>
    return if percentage > 90
      "fa-battery-full"
    else if percentage > 70
      "fa-battery-three-quarters"
    else if percentage > 40
      "fa-battery-half"
    else if percentage > 20
      "fa-battery-quarter"
    else
      "fa-battery-empty"


  element: =>
    """
    <div class="battery" style="#{@style()}"></div>
    """

  style: =>
    """
    .battery{ margin-right: 10px; height: #{@window.size.height}px; line-height: #{@window.size.height}px;}
    .fa { margin-right: 3px; }
    """
