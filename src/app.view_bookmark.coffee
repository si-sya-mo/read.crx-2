app.view_bookmark = {}

app.view_bookmark.open = ->
  $view = $("#template > .view_bookmark").clone()
  $("#tab_a").tab("add", element: $view[0], title: "ブックマーク")
  $view.attr("data-url", "bookmark")

  $loading_overlay = $view.find(".loading_overlay").hide()

  $view.find("table").table_sort()

  $view.find(".button_link").bind "click", ->
    path = "chrome-extension://eemcgdkfndhakfknompkggombfjjjeno/"
    path += "main.html##{app.config.get("bookmark_id")}"
    open(path)

  app.view_module.reload_button($view)
  app.view_module.searchbox_thread_title($view, 0)
  app.view_module.board_contextmenu($view)

  $view.bind "request_reload", ->
    $loading_overlay.show()

    board_list = []
    for bookmark in app.bookmark.get_all()
      if bookmark.type is "thread"
        board_url = app.url.thread_to_board(bookmark.url)
        if board_list.indexOf(board_url) is -1
          board_list.push(board_url)

    $prev = null
    fn = (result) ->
      if result
        if result.status is "success"
          $prev.toggleClass("loading success")
        else
          $prev.toggleClass("loading fail")

      if board_list.length > 0
        board_url = board_list[0]
        board_list.splice(0, 1)
        $prev = $("<div>", text: board_url, class: "loading")
        $prev.prependTo($loading_overlay)
        app.board.get(board_url, fn)
      else
        $view.find("tbody").empty()
        app.view_bookmark._draw($view)
        $loading_overlay.fadeOut 100, -> $(this).empty()
    fn()

  #ブックマーク更新時処理
  on_updated = (message) ->
    if message.type is "added"
      $view
        .find("tbody")
          .append(app.view_bookmark._bookmark_to_tr(message.bookmark))
        .end()
        .find("table")
          .trigger("table_sort_update")

    else if message.type is "removed"
      $view.find("tr[data-href=\"#{message.bookmark.url}\"]").remove()

  app.message.add_listener("bookmark_updated", on_updated)

  $view.bind "tab_removed", ->
    app.message.remove_listener("bookmark_updated", on_updated)

  app.view_bookmark._draw($view)

app.view_bookmark._draw = ($view) ->
  frag = document.createDocumentFragment()

  for bookmark in app.bookmark.get_all()
    if bookmark.type is "thread"
      frag.appendChild(app.view_bookmark._bookmark_to_tr(bookmark))

  $view.find("tbody").append(frag)
  $view.find("table").trigger("table_sort_update")

app.view_bookmark._bookmark_to_tr = (bookmark) ->
  tr = document.createElement("tr")
  tr.className = "open_in_rcrx"
  tr.setAttribute("data-href", bookmark.url)

  thread_created_at = +/// /(\d+)/$ ///.exec(bookmark.url)[1] * 1000

  td = document.createElement("td")
  td.textContent = bookmark.title
  tr.appendChild(td)

  td = document.createElement("td")
  td.textContent = bookmark.res_count or 0
  tr.appendChild(td)

  td = document.createElement("td")
  if (
      typeof bookmark.res_count is "number" and
      bookmark.read_state and typeof bookmark.read_state.read is "number"
  )
    td.textContent = bookmark.res_count - bookmark.read_state.read or ""
  tr.appendChild(td)

  td = document.createElement("td")
  if typeof bookmark.res_count is "number"
    td.textContent = app.util.calc_heat(Date.now(), thread_created_at, bookmark.res_count)
  tr.appendChild(td)

  td = document.createElement("td")
  td.textContent = app.util.date_to_string(new Date(thread_created_at))
  tr.appendChild(td)

  tr