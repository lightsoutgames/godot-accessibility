extends Object

var tts

var node

var position_in_children = 0

func item_or_items(count):
    if count == 1:
        return "item"
    else:
        return "items"

func focus_button():
    var text
    if node.text:
        text = node.text
    if text:
        tts.speak("%s: button" % text, false)
    else:
        tts.speak("button", false)

func focus_item_list():
    var count = node.get_item_count()
    var selected = node.get_selected_items()
    tts.speak("list, %s %s" % [count, item_or_items(count)], false)
    tts.speak(selected, false)

func item_list_item_selected(index):
    tts.speak("Selected", false)

func item_list_multi_selected(index, selected):
    tts.speak("Multiselect", false)

func item_list_nothing_selected():
    tts.speak("Nothing selected", false)

func input_item_list(event):
    var old_pos = position_in_children
    if event.echo or not event.pressed:
        return
    if event.scancode == KEY_UP:
        node.get_tree().set_input_as_handled()
        if position_in_children == 0:
            return
        position_in_children -= 1
    elif event.scancode == KEY_DOWN:
        node.get_tree().set_input_as_handled()
        if position_in_children >= node.get_item_count()-1:
            return
        position_in_children += 1
    elif event.scancode == KEY_HOME:
        position_in_children = 0
    elif event.scancode == KEY_END:
        position_in_children = node.get_item_count()-1
    if old_pos != position_in_children:
        var text = node.get_item_text(position_in_children)
        tts.speak("%s: %s of %s" % [text, position_in_children+1, node.get_item_count()], false)

func focus_label():
    var text = node.text
    if text == "":
        text = "blank"
    tts.speak(text, false)

func focus_line_edit():
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

func focus_menu_button():
    tts.speak(node.text + ": menu", false)

func focus_popup_menu():
    tts.speak("menu", false)

func focus_popup_menu_item(id):
    print("id: %s" % id)
    print("count: %s" % node.get_item_count())
    var item = node.get_item_text(id)
    var submenu = node.get_item_submenu(id)
    var tooltip = node.get_item_tooltip(position_in_children)
    print("Tooltip: %s" % tooltip)
    var disabled = node.is_item_disabled(id)
    if item and tooltip:
        print("Got item and tooltip")
        item += ": "
        item += tooltip
    elif tooltip:
        print("Got tooltip only")
        item = tooltip
    var shortcut = node.get_item_shortcut(position_in_children)
    if shortcut != null and shortcut.get_as_text() != "None":
        print("Got shortcut: %s" % shortcut.get_as_text())
        item += ": "+shortcut.get_as_text()
    if item == "":
        item = "Unlabelled"
    if submenu:
        item += ": menu"
    if disabled:
        item += ": disabled"
    item += ": " + str(id + 1) + " of " + str(node.get_item_count())
    tts.speak(item, true)

func render_tree_item():
    var item = node.get_selected()
    var result = item.get_text(0)
    return result

func focus_tab_container():
    var text = node.get_tab_title(node.current_tab)
    text += ": tab: " + str(node.current_tab + 1) + " of " + str(node.get_tab_count())
    tts.speak(text, false)

func input_tab_container(event):
    tts.stop()
    var new_tab = node.current_tab
    if event.echo or not event.pressed:
        return
    if event.scancode == KEY_RIGHT:
        new_tab += 1
    elif event.scancode == KEY_LEFT:
        new_tab -= 1
    if new_tab < 0:
        new_tab = node.get_tab_count() - 1
    elif new_tab >= node.get_tab_count():
        new_tab = 0
    node.current_tab = new_tab
    focus_tab_container()

func focus_tree():
    if node.get_selected():
        tts.speak(render_tree_item(), true)
    else:
        tts.speak("tree", true)

func select_tree():
    if node.has_focus():
        tts.speak(render_tree_item(), true)

func focused():
    print("Focus: %s" % node)
    tts.stop()
    var parent = node.get_parent()
    if parent is EditorProperty and parent.label:
        tts.speak(parent.label, false)
    if node is MenuButton:
        focus_menu_button()
    elif node is Button:
        focus_button()
    elif node is ItemList:
        focus_item_list()
    elif node is Label:
        focus_label()
    elif node is LineEdit:
        focus_line_edit()
    elif node is PopupMenu:
        focus_popup_menu()
    elif node is TabContainer:
        focus_tab_container()
    elif node is Tree:
        focus_tree()
    else:
        print("No handler")
    if node.hint_tooltip:
        tts.speak(node.hint_tooltip, false)

func unfocused():
    position_in_children = 0

func gui_input(event):
    if node is TabContainer:
        return input_tab_container(event)
    if node is ItemList:
        return input_item_list(event)
    elif node is LineEdit:
        return check_caret_moved()

func _init(tts, node):
    if node.is_in_group("accessible"):
        return
    node.add_to_group("accessible")
    self.tts = tts
    self.node = node
    if not node is Container and not node is Panel and not node is Separator and not node is ScrollBar and not node is Popup and node.get_class() != "Control":
        node.set_focus_mode(Control.FOCUS_ALL)
    elif node is TabContainer:
        node.set_focus_mode(Control.FOCUS_ALL)
    node.connect("focus_entered", self, "focused")
    node.connect("mouse_entered", self, "focused")
    node.connect("focus_exited", self, "unfocused")
    node.connect("mouse_exited", self, "unfocused")
    node.connect("gui_input", self, "gui_input")
    if node is ItemList:
        node.connect("item_selected", self, "item_list_item_selected")
        node.connect("multi_selected", self, "item_list_multi_selected")
        node.connect("nothing_selected", self, "item_list_nothing_selected")
    # elif node is LineEdit:
        # node.connect("text_deleted", self, "text_deleted")
        # node.connect("text_inserted", self, "text_inserted")
    elif node is PopupMenu:
        node.connect("id_focused", self, "focus_popup_menu_item")
    elif node is Tree:
        node.connect("item_selected", self, "select_tree")
    node.connect("tree_exiting", self, "free")
