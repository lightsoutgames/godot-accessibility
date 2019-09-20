extends Object

var tts

var node

var position_in_children = 0

var column_in_row = 0

func get_siblings():
    var parent = node.get_parent()
    if parent:
        return parent.get_children()
    return null

func singular_or_plural(count, singular, plural):
    if count == 1:
        return singular
    else:
        return plural

func click(item := node, button_index = BUTTON_LEFT):
    var click = InputEventMouseButton.new()
    click.button_index = button_index
    click.pressed = true
    if item is Node:
        click.position = item.rect_global_position
    else:
        click.position = node.get_tree().root.get_mouse_position()
    node.get_tree().input_event(click)
    click.pressed = false
    node.get_tree().input_event(click)

func guess_label():
    var parent = node.get_parent()
    while parent:
        if parent is EditorProperty and parent.label:
            return parent.label
        parent = parent.get_parent()

func close_key_event_dialog():
    node.get_ok().emit_signal("pressed")

var dialog_close_timer = Timer.new()

func accept_dialog_focus():
    if not dialog_close_timer.is_connected("timeout", self, "close_key_event_dialog"):
        dialog_close_timer.connect("timeout", self, "close_key_event_dialog")
    dialog_close_timer.one_shot = true
    dialog_close_timer.start(5)
    if dialog_close_timer.get_parent() == null:
        node.add_child(dialog_close_timer)

func checkbox_focus():
    var tokens = PoolStringArray([])
    if node.pressed:
        tokens.append("checked")
    else:
        tokens.append("unchecked")
    tokens.append(" checkbox")
    tts.speak(tokens.join(" "), false)

func checkbox_toggled(checked):
    if checked:
        tts.speak("checked", true)
    else:
        tts.speak("unchecked", true)

var spoke_hint_tooltip

func button_focus():
    var tokens = PoolStringArray([])
    if node.text:
        tokens.append(node.text)
    elif node.hint_tooltip:
        spoke_hint_tooltip = true
        tokens.append(node.hint_tooltip)
    tokens.append("button")
    tts.speak(tokens.join(": "), false)

func texturebutton_focus():
    tts.speak("button", false)

func item_list_focus():
    var count = node.get_item_count()
    var selected = node.get_selected_items()
    tts.speak("list, %s %s" % [count, singular_or_plural(count, "item", "items")], false)
    tts.speak(selected, false)

func item_list_item_selected(index):
    tts.speak("Selected", true)

func item_list_multi_selected(index, selected):
    tts.speak("Multiselect", false)

func item_list_nothing_selected():
    tts.speak("Nothing selected", true)

func item_list_input(event):
    var old_pos = position_in_children
    if event.is_action_pressed("ui_up"):
        node.accept_event()
        if position_in_children == 0:
            return
        position_in_children -= 1
    elif event.is_action_pressed("ui_down"):
        node.accept_event()
        if position_in_children >= node.get_item_count()-1:
            return
        position_in_children += 1
    elif event.is_action_pressed("ui_home"):
        node.accept_event()
        position_in_children = 0
    elif event.is_action_pressed("ui_end"):
        node.accept_event()
        position_in_children = node.get_item_count()-1
    if old_pos != position_in_children:
        var text = node.get_item_text(position_in_children)
        tts.speak("%s: %s of %s" % [text, position_in_children+1, node.get_item_count()], false)

func label_focus():
    var text = node.text
    if text == "":
        text = "blank"
    tts.speak(text, false)

func line_edit_focus():
    var text = "blank"
    if node.secret:
        text = "password"
    elif node.text != "":
        text = node.text
    elif node.placeholder_text != "":
        text = node.placeholder_text
    var type = "editable text"
    if not node.editable:
        type = "text"
    tts.speak("%s: %s" % [text, type], false)

func text_deleted(text):
    tts.speak("%s deleted" % text, true)

func text_inserted(text):
    tts.speak(text, true)

var old_pos

func check_caret_moved():
    var pos = node.caret_position
    if old_pos != null and old_pos != pos:
        var text = node.text
        if pos > len(text)-1:
            tts.speak("blank", true)
        else:
            tts.speak(text[pos], true)
        old_pos = pos
    elif old_pos == null:
        old_pos = pos

func menu_button_focus():
    var tokens = PoolStringArray([])
    if node.text:
        tokens.append(node.text)
    if node.hint_tooltip:
        tokens.append(node.hint_tooltip)
        spoke_hint_tooltip = true
    tokens.append("menu")
    tts.speak(tokens.join(": "), false)

func panel_focus():
    tts.speak("panel", true)

func popup_menu_focus():
    tts.speak("menu", false)

func popup_menu_item_id_focus(id):
    var tokens = PoolStringArray([])
    var index = node.get_item_index(id)
    print("id: %s, index: %s" % [id, index])
    if index == -1:
        index = id
    var item = node.get_item_text(index)
    if item:
        tokens.append(item)
    var submenu = node.get_item_submenu(index)
    if submenu:
        tokens.append(submenu)
        tokens.append("menu")
    var tooltip = node.get_item_tooltip(index)
    if tooltip:
        tokens.append(tooltip)
    var disabled = node.is_item_disabled(index)
    if disabled:
        tokens.append("disabled")
    var shortcut = node.get_item_shortcut(index)
    if shortcut:
        var name = shortcut.resource_name
        if name:
            tokens.append(name)
        var text = shortcut.get_as_text()
        if text != "None":
            tokens.append(text)
    tokens.append(str(id + 1) + " of " + str(node.get_item_count()))
    tts.speak(tokens.join(": "), true)

func tree_item_render():
    var focused_tree_item = node.get_selected()
    var tokens = PoolStringArray([])
    for i in range(node.columns):
        tokens.append(focused_tree_item.get_text(i))
    if focused_tree_item.get_children():
        if focused_tree_item.collapsed:
            tokens.append("collapsed")
        else:
            tokens.append("expanded")
    tokens.append("tree item")
    if focused_tree_item.is_selected(0):
        tokens.append("selected")
    tts.speak(tokens.join(": "), true)

var prev_selected_cell

var button_index

func tree_item_selected():
    button_index = null
    var cell = node.get_selected()
    if cell != prev_selected_cell:
        tree_item_render()
        prev_selected_cell = cell
    else:
        var tokens = PoolStringArray([])
        for i in range(node.columns):
            if cell.is_selected(i):
                var title = node.get_column_title(i)
                if title:
                    tokens.append(title)
                var column_text = cell.get_text(i)
                if column_text:
                    tokens.append(column_text)
                var button_count = cell.get_button_count(i)
                if button_count != 0:
                    button_index = 0
                    tokens.append(str(button_count) + " " + singular_or_plural(button_count, "button", "buttons"))
                    var button_tooltip = cell.get_button_tooltip(i, button_index)
                    if button_tooltip:
                        tokens.append(button_tooltip)
                        tokens.append("button")
                    if button_count > 1:
                        tokens.append("Use Home and End to switch focus.")
        tts.speak(tokens.join(": "), true)

func tree_item_multi_select(item, column, selected):
    if selected:
        tts.speak("selected", true)
    else:
        tts.speak("unselected", true)

func tree_input(event):
    var item = node.get_selected()
    var column
    if item:
        for i in range(node.columns):
            if item.is_selected(i):
                column = i
                break
    if item and event is InputEventKey and event.pressed and not event.echo:
        var area
        if column:
            area = node.get_item_area_rect(item, column)
        else:
            area = node.get_item_area_rect(item)
        var position = Vector2(node.rect_global_position.x + area.position.x, node.rect_global_position.y + area.position.y)
        node.get_tree().root.warp_mouse(position)
    if item and column and button_index != null:
        if event.is_action_pressed("ui_accept"):
            node.accept_event()
            return node.emit_signal("button_pressed", item, column, button_index + 1)
        var new_button_index = button_index
        if event.is_action_pressed("ui_home"):
            node.accept_event()
            new_button_index += 1
            if new_button_index >= item.get_button_count(column):
                new_button_index = 0
        elif event.is_action_pressed("ui_end"):
            node.accept_event()
            new_button_index -= 1
            if new_button_index < 0:
                new_button_index = item.get_button_count(column) - 1
        if new_button_index != button_index:
            button_index = new_button_index
            var tokens = PoolStringArray([])
            var tooltip = item.get_button_tooltip(column, button_index)
            if tooltip:
                tokens.append(tooltip)
            tokens.append("button")
            tts.speak(tokens.join(": "), true)

func tree_focus():
    if node.get_selected():
        tree_item_render()
    else:
        tts.speak("tree", true)

func tree_item_collapse(item):
    if node.has_focus():
        if item.collapsed:
            tts.speak("collapsed", true)
        else:
            tts.speak("expanded", true)

func tab_container_focus():
    var text = node.get_tab_title(node.current_tab)
    text += ": tab: " + str(node.current_tab + 1) + " of " + str(node.get_tab_count())
    tts.speak(text, false)

func tab_container_tab_changed(tab):
    tts.stop()
    tab_container_focus()

func tab_container_input(event):
    var new_tab = node.current_tab
    if event.is_action_pressed("ui_right"):
        node.accept_event()
        new_tab += 1
    elif event.is_action_pressed("ui_left"):
        node.accept_event()
        new_tab -= 1
    if new_tab < 0:
        new_tab = node.get_tab_count() - 1
    elif new_tab >= node.get_tab_count():
        new_tab = 0
    if node.current_tab != new_tab:
        node.current_tab = new_tab

func focus():
    print("Focus: %s" % node)
    node.get_tree().root.warp_mouse(node.rect_global_position)
    tts.stop()
    var label = guess_label()
    if label:
        tts.speak(label, false)
    if node is MenuButton:
        menu_button_focus()
    elif node is AcceptDialog:
        accept_dialog_focus()
    elif node is CheckBox:
        checkbox_focus()
    elif node is Button:
        button_focus()
    elif node.get_class() == "EditorInspectorSection":
        editor_inspector_section_focus()
    elif node is ItemList:
        item_list_focus()
    elif node is Label:
        label_focus()
    elif node is LineEdit:
        line_edit_focus()
    elif node is Panel:
        panel_focus()
    elif node is PopupMenu:
        popup_menu_focus()
    elif node is TabContainer:
        tab_container_focus()
    elif node is TextureButton:
        texturebutton_focus()
    elif node is Tree:
        tree_focus()
    else:
        tts.speak(node.get_class(), true)
        print("No handler")
    if node.hint_tooltip and not spoke_hint_tooltip:
        tts.speak(node.hint_tooltip, false)
    spoke_hint_tooltip = false

func unfocus():
    print("Unfocused")
    position_in_children = 0

func click_focus():
    if node.has_focus():
        return
    print("Grabbing focus: %s" % node)
    node.grab_focus()

func gui_input(event):
    if event is InputEventKey and event.pressed and not event.echo and event.scancode == KEY_MENU:
        return click(null, BUTTON_RIGHT)
    if node is TabContainer:
        return tab_container_input(event)
    elif node is ItemList:
        return item_list_input(event)
    elif node is LineEdit:
        return check_caret_moved()
    elif node is Tree:
        return tree_input(event)
    elif node.get_class() == "EditorInspectorSection":
        return editor_inspector_section_input(event)
    elif event.is_action_pressed("ui_left"):
        return node.accept_event()
    elif event.is_action_pressed("ui_right"):
        return node.accept_event()
    elif event.is_action_pressed("ui_up"):
        return node.accept_event()
    elif event.is_action_pressed("ui_down"):
        return node.accept_event()

func is_in_bar():
    var parent = node.get_parent()
    if parent and parent is Container:
        for child in parent.get_children():
            if child and not is_focusable(child):
                return false
        return true
    return false

func is_focusable(node):
    if node is TabContainer:
        return true
    if node.get_class() == "EditorInspectorSection":
        return true
    if node is Container or node is Separator or node is ScrollBar or node is Popup or node.get_class() == "Control":
        return false
    return true

func editor_inspector_section_focus():
    var child = node.get_children()[0]
    var expanded = child.is_visible_in_tree()
    var tokens = PoolStringArray(["editor inspector section"])
    if expanded:
        tokens.append("expanded")
    else:
        tokens.append("collapsed")
    tts.speak(tokens.join(": "), false)

func editor_inspector_section_input(event):
    if event.is_action_pressed("ui_accept"):
        click()
        var child = node.get_children()[0]
        var expanded = child.is_visible_in_tree()
        if expanded:
            tts.speak("expanded", true)
        else:
            tts.speak("collapsed", true)

func _init(tts, node):
    if node.is_in_group("accessible"):
        return
    node.add_to_group("accessible")
    self.tts = tts
    self.node = node
    if is_focusable(node):
        node.set_focus_mode(Control.FOCUS_ALL)
    node.connect("focus_entered", self, "focus")
    node.connect("mouse_entered", self, "click_focus")
    node.connect("focus_exited", self, "unfocus")
    node.connect("mouse_exited", self, "unfocus")
    node.connect("gui_input", self, "gui_input")
    if node is CheckBox:
        node.connect("toggled", self, "checkbox_toggled")
    elif node is ItemList:
        node.connect("item_selected", self, "item_list_item_selected")
        node.connect("multi_selected", self, "item_list_multi_selected")
        node.connect("nothing_selected", self, "item_list_nothing_selected")
    # elif node is LineEdit:
        # node.connect("text_deleted", self, "text_deleted")
        # node.connect("text_inserted", self, "text_inserted")
    elif node is PopupMenu:
        node.connect("id_focused", self, "popup_menu_item_id_focus")
    elif node is TabContainer:
        node.connect("tab_changed", self, "tab_container_tab_changed")
    elif node is Tree:
        node.connect("item_collapsed", self, "tree_item_collapse")
        node.connect("multi_selected", self, "tree_item_multi_select")
        if node.select_mode == Tree.SELECT_MULTI:
            node.connect("cell_selected", self, "tree_item_selected")
        else:
            node.connect("item_selected", self, "tree_item_selected")
    node.connect("tree_exiting", self, "free")
