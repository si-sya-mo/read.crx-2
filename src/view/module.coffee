do ->
  if frameElement
    modules = [
      "History"
      "Thread"
      "board"
      "bookmark"
      "config"
      "module"
      "Ninja"
      "read_state"
      "url"
      "util"
    ]

    for module in modules
      app[module] = parent.app[module]
  return

app.view_module = {}

app.view_module.view = ($view) ->
  #テーマ適用
  $view.addClass("theme_#{app.config.get("theme_id")}")
  app.message.add_listener "config_updated", (message) ->
    if message.key is "theme_id"
      $view.removeClass("theme_default theme_dark theme_none")
      $view.addClass("theme_#{message.val}")
    return

  #ユーザーCSS挿入
  do ->
    if $view.is(".view_index, .view_sidemenu, .view_bookmark, .view_board, .view_history, .view_inputurl, .view_thread, .view_search")
      style = document.createElement("style")
      style.textContent = app.config.get("user_css")
      document.head.appendChild(style)
    return

  #title_updatedメッセージ送出処理
  do ->
    send_title_updated = ->
      tmp =
        type: "title_updated"
        title: document.title
      parent.postMessage(JSON.stringify(tmp), location.origin)

    if document.title
      send_title_updated()
    $view
      .find("title")
        .bind("DOMSubtreeModified", send_title_updated)

  #.open_in_rcrx
  $view
    #windowsのオートスクロール対策
    .on "mousedown", ".open_in_rcrx", (e) ->
      if e.which is 2
        e.preventDefault()
      return
    .on "click", ".open_in_rcrx", (e) ->
      e.preventDefault()
      url = @href or @getAttribute("data-href")
      title = @getAttribute("data-title") or @textContent
      how_to_open = app.util.get_how_to_open(e)
      new_tab = app.config.get("always_new_tab") is "on"
      new_tab or= how_to_open.new_tab or how_to_open.new_window
      background = how_to_open.background
      app.message.send("open", {url, new_tab, background, title})
      return

  window.addEventListener "message", (e) ->
    if e.origin is location.origin
      message = JSON.parse(e.data)
      #request_reload(postMessage) -> request_reload(event) 翻訳処理
      if message.type is "request_reload"
        if message.force_update is true
          $view.trigger("request_reload", force_update: true)
        else
          $view.trigger("request_reload")
      #tab_selected(postMessage) -> tab_selected(event) 翻訳処理
      else if message.type is "tab_selected"
        $view.trigger("tab_selected")

  # キーボード操作関連
  $view
    .on "keydown", (e)->
      # F5 or Ctrl+R
      if e.which is 116 or (e.ctrlKey and e.which is 82)
        e.preventDefault()
        command = "r"

      # Esc (空白の入力欄に入力された場合)
      else if (
        e.which is 27 and
        e.target.nodeName in ["INPUT", "TEXTAREA"] and
        e.target.value is "" and
        not e.target.classList.contains("command")
      )
        $view.find(".content").focus()

      # : (基本的に入力欄では発動しないが、空白の入力欄に入力された場合のみ例外)
      else if e.which is 186
        if (
          not (e.target.nodeName in ["INPUT", "TEXTAREA"]) or
          e.target.value is ""
        )
          e.preventDefault()
          $("<input>", class: "command")
            .data("lastActiveElement", document.activeElement)
            .appendTo($view)
            .focus()

      # 入力欄内では発動しない系
      else if not (e.target.nodeName in ["INPUT", "TEXTAREA"])
        switch (e.which)
          # Enter
          when 13 then command = "enter"
          # h
          when 72
            e.preventDefault()
            if e.shiftKey
              command = "focusLeftFrame"
            else
              command = "left"
          # l
          when 76
            e.preventDefault()
            if e.shiftKey
              command = "focusRightFrame"
            else
              command = "right"
          # k
          when 75
            e.preventDefault()
            if e.shiftKey
              command = "focusUpFrame"
            else
              command = "up"
          # j
          when 74
            e.preventDefault()
            if e.shiftKey
              command = "focusDownFrame"
            else
              command = "down"
          # r
          when 82
            # Shift+r
            if e.shiftKey
              command = "r"
          # w
          when 87
            # Shift+w
            if e.shiftKey
              command = "q"
          # /
          when 191
            # ?
            if e.shiftKey
              command = "help"
            # /
            else
              e.preventDefault()
              $(".searchbox, form.search > input[type=\"text\"]").focus()

      # コマンド入力欄操作
      else if e.target.classList.contains("command")
        # Enter
        if e.which is 13
          command = e.target.value.replace(/[\s]/g, "")
          $(e.target).data("lastActiveElement")?.focus()
          $(e.target).remove()
        # Esc
        else if e.which is 27
          $(e.target).data("lastActiveElement")?.focus()
          $(e.target).remove()

      # 数値
      if command and /^\d+$/.test(command)
        if $view.is(".view_thread")
          $view.data("threadContent").scrollTo(+command)
          $view.data("threadContent").select(+command)

      switch command
        when "up"
          if $view.hasClass("view_thread")
            $view.data("threadContent").selectPrev()
          else if $view.hasClass("view_sidemenu")
            $view.data("accordion").selectPrev()
          else if $view.is(".view_bookmark, .view_board, .view_history")
            $view.data("threadList").selectPrev()
        when "down"
          if $view.hasClass("view_thread")
            $view.data("threadContent").selectNext()
          else if $view.hasClass("view_sidemenu")
            $view.data("accordion").selectNext()
          else if $view.is(".view_bookmark, .view_board, .view_history")
            $view.data("threadList").selectNext()
        when "left"
          if $view.hasClass("view_sidemenu")
            $a = $view.find("li > a.selected")
            if $a.length is 1
              $view.data("accordion").select($a.closest("ul").prev()[0])
        when "right"
          if $view.hasClass("view_sidemenu")
            $a = $view.find("h3.selected + ul a")
            if $a.length > 0
              $view.data("accordion").select($a[0])
        when "focusUpFrame", "focusDownFrame", "focusLeftFrame", "focusRightFrame"
          app.message.send("requestFocusMove", {command}, parent)
        when "r"
          $view.trigger("request_reload")
        when "q"
          parent.postMessage(
            JSON.stringify(type: "request_killme"), location.origin)
        when "enter"
          $view.find(".selected").trigger("click")
      return

  $view
    #mousedown通知
    .bind "mousedown", ->
      tmp = JSON.stringify(type: "view_mousedown")
      parent.postMessage(tmp, location.origin)

    #view_loaded翻訳処理
    .bind "view_loaded", ->
      tmp = JSON.stringify(type: "view_loaded")
      parent.postMessage(tmp, location.origin)

    #view内リロードボタンの処理
    .find(".button_reload")
      .bind "click", ->
        if not $(this).hasClass("disabled")
          $view.trigger("request_reload")
        return

  # 戻る/進むボタン管理
  parent.postMessage(JSON.stringify(type: "requestTabHistory"), location.origin)

  window.addEventListener "message", (e) ->
    if e.origin is location.origin
      message = JSON.parse(e.data)
      if message.type is "responseTabHistory"
        if message.history.current > 0
          $view.find(".button_back").removeClass("disabled")

        if message.history.current < message.history.stack.length - 1
          $view.find(".button_forward").removeClass("disabled")

        if message.history.stack.length is 1 and app.config.get("always_new_tab") is "on"
          $view.find(".button_back, .button_forward").remove()
    return

  $view.find(".button_back, .button_forward").on "click", ->
    $this = $(@)

    return if $this.is(".disabled")

    tmp = if $this.is(".button_back") then "Back" else "Forward"
    parent.postMessage(JSON.stringify(type: "requestTab#{tmp}"), location.origin)
    return

  return

app.view_module.bookmark_button = ($view) ->
  url = $view.attr("data-url")
  $button = $view.find(".button_bookmark")
  if ///^http://\w///.test(url)
    if app.bookmark.get(url)
      $button.addClass("bookmarked")
    else
      $button.removeClass("bookmarked")

    app.message.add_listener "bookmark_updated", (message) ->
      if message.bookmark.url is url
        if message.type is "added"
          $button.addClass("bookmarked")
        else if message.type is "removed"
          $button.removeClass("bookmarked")

    $button.on "click", ->
      if app.bookmark.get(url)
        app.bookmark.remove(url)
      else
        title = $view.find("title").text() or url

        if $view.hasClass("view_thread")
          resCount = $view.find(".content").children().length

        if resCount? and resCount > 0
          app.bookmark.add(url, title, resCount)
        else
          app.bookmark.add(url, title)
      return
  else
    $button.remove()

app.view_module.sort_item_selector = ($view) ->
  $table = $(".table_sort")
  $selector = $view.find(".sort_item_selector")
  $table
    .on "table_sort_updated", (e, ex) ->
      $selector
        .find("option")
          .filter(->
            String(ex.sort_attribute or ex.sort_index) is @textContent
          )
            .attr("selected", true)
      return
  $selector
    .on "change", ->
      selected = @children[@selectedIndex]
      config = {}

      config.sort_order = selected.getAttribute("data-sort_order") or "desc"

      if /^\d+$/.test(@value)
        config.sort_index = +@value
      else
        config.sort_attribute = @value

      if (tmp = selected.getAttribute("data-sort_type"))?
        config.sort_type = tmp

      $table.table_sort("update", config)
      return
  return

app.view_module.tool_menu = ($view) ->
  #メニューの表示/非表示制御
  $view.find(".button_tool").on "click", ->
    if $(@).find("ul").toggle().is(":visible")
      app.defer ->
        $view.one "click contextmenu", (e) ->
          if not $(e.target).is(".button_tool")
            $view.find(".button_tool > ul").hide()
          return
        return
    return

  $(window).on "blur", ->
    $view.find(".button_tool > ul").hide()
    return

  # Chromeで直接開く
  do ->
    url = $view.attr("data-url")

    if url is "bookmark"
      url = "chrome-extension://eemcgdkfndhakfknompkggombfjjjeno/"
      url += "main.html##{app.config.get("bookmark_id")}"
    else if /^search:/.test(url)
      return
    else
      url = app.safe_href(url)

    $view.find(".button_link > a").attr("href", url)
    return

  # タイトルをコピー
  $view.find(".button_copy_title").on "click", ->
    app.clipboardWrite(document.title)
    return

  # URLをコピー
  $view.find(".button_copy_url").on "click", ->
    app.clipboardWrite($view.attr("data-url"))
    return

  # タイトルとURLをコピー
  $view.find(".button_copy_title_and_url").on "click", ->
    app.clipboardWrite(document.title + " " + $view.attr("data-url"))
    return

  return
