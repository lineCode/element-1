$ = require("jQuery")
Widget = require('./widget.coffee')
exec = require("child_process").exec
i3 = require('i3').createClient()

module.exports =
class Workspaces extends Widget

  constructor: ->
    super("i3-workspaces")
    @connectToI3()
    $(".bar").append @element()

  connectToI3: =>
    # Collect existing workspaces
    i3.workspaces (err, ws) =>
      @addWorkspaces ws

    # Handle workspace events
    i3.on "workspace", (w) =>
      switch w.change
        when "focus" then @focusWorkspace(w)
        when "init" then @createWorkspace(w)
        when "empty" then @removeWorkspace(w)

  addWorkspaces: (ws) =>
    @createWorkspace(w) for w in ws

  focusWorkspace: (w) =>
    switch @config.style
      when "name"
        $(".workspace").removeClass("active")
        $(".workspace.#{w.current.num}").addClass("active")
      when "bullet"
        $(".workspace").removeClass("fa-circle fa-circle-thin").addClass("fa-circle-thin")
        $(".workspace.#{w.current.num}").removeClass("fa-circle-thin").addClass("fa-circle")

  createWorkspace: (w) =>
    $(".workspaces").append switch @config.style
      when "name"
        active = if w.focused then "active" else ""
        $("<span class='workspace #{active} #{w.num || w.current.num}'>#{w.name || w.current.name}</span>")
      when "bullet"
        bullet = if w.focused then "fa-circle" else "fa-circle-thin"
        $("<span class='workspace #{w.num || w.current.num} fa #{bullet}'></span>")

  removeWorkspace: (w) =>
    $(".workspace.#{w.current.num}").remove()

  element: =>
    """
    <style>#{@style()}</style>
    <div class="workspaces"></div>
    """

  style: =>
    """
    .workspaces {
      color: #999;
      padding-left: 5px;
      height: #{@window.size.height}px !important;
      line-height: #{@window.size.height}px !important;
    }
    .workspace {
      margin-right: 5px;
    }
    .workspace.fa {
      font-size: 10px;
    }
    .active { color: #fff; }
    """

