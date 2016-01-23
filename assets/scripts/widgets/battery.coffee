
$ = require("jQuery")
exec = require("child_process").exec

# Capacity
# upower -i /org/freedesktop/UPower/devices/battery_BAT0 | perl -wnE'say for /capacity:\s*(\d*\.\d*)/g'
#
# Percentage
# upower -i /org/freedesktop/UPower/devices/battery_BAT0 | perl -wnE'say for /percentage:\s*(\d*)/g'
module.exports =
class Battery

  refresh: 1000
  height: $(".bar").height()
  capacityCommand: "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | perl -wnE'say for /capacity:(.*)%/g'"
  percentageCommand: "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | perl -wnE'say for /percentage:(.*)%/g'"

  # upower -i /org/freedesktop/UPower/devices/battery_BAT0
  constructor: ->
    $(".bar").append @element()
    exec @capacityCommand, (err, stdout, stderr) =>
      @capacity = parseInt(stdout.replace(/\ /g, ""))

    setTimeout @update, @refresh


  update: =>
    exec @percentageCommand, (err, stdout, stderr) =>
      bat = parseInt(stdout.replace(/\ /g, ""))
      console.log(bat, @capacity)
      percentage = Math.min(Math.floor(100 * (bat / @capacity)), 100)
      $(".battery").html """
        <style>#{@style()}</style>
        <span class='fa #{@iconClass(percentage)}'></span>
        <span>#{percentage}%</span>
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
    .battery{ margin-right: 10px; }
    .fa { margin-right: 3px; }
    """
