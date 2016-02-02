$ = require("jquery")
Widget = requireCoffee("#{widgets}/widget.coffee")
exec = require("child_process").exec
i3 = require('i3').createClient()

module.exports =
class Workspaces extends Widget

  constructor: ->
    super("i3-workspaces")
    @connectToI3()

  update: =>

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
        @$currentWorkspace(w).addClass("active")
      when "bullet"
        $(".workspace").removeClass("fa-circle fa-circle-tin").addClass("fa-circle-thin")
        @$currentWorkspace(w).removeClass("fa-circle-thin").addClass("fa-circle")

  createWorkspace: (w) =>
    $el = switch @config.style
      when "name" then @createNameWorkspace(w)
      when "bullet" then @createBulletWorkspace(w)

    # Go to a workspace on click
    $el.on 'click', @selectWorkspace

    # Add to workspaces
    $(".workspaces").append $el

    # Ensure elements are always sorted by workspace number
    @sortElements()

  sortElements: =>
    # Sort workspaces by workspace number
    $sort = $(".workspace").sort (a, b) =>
      $(a).data('num') - $(b).data('num')

    $(".workspaces").append($e) for $e in $sort

  createNameWorkspace: (w) =>
    active = if w.focused then "active" else ""
    $("<span class='workspace #{active}' data-num='#{w.num || w.current.num}'>#{w.name || w.current.name}</span>")

  createBulletWorkspace: (w) =>
    num = w.num || w.current.num
    bullet = if w.focused then "fa-circle" else "fa-circle-thin"
    $("<span class='workspace fa #{bullet}' data-num='#{num}'></span>")

  removeWorkspace: (w) =>
    @$currentWorkspace(w).remove()

  $currentWorkspace: (w) =>
    $(".workspaces").find("[data-num='#{w.num || w.current.num}']")

  selectWorkspace: (e) =>
    i3.command "workspace #{$(e.target).data('num')}"

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
      height: 100%;
      padding: 0 4px;
    }
    .workspace.fa {
      padding: 0 2px;
      font-size: 10px;
    }
    .active { color: #fff; }
    """

