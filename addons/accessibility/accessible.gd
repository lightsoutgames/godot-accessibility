extends Object

var node

var position_in_children = 0

func item_or_items(count):
    if count == 1:
        return "item"
    else:
        return "items"

func focus_button():
    var text = "Unlabelled"
    if node.text:
        text = node.text
    if text:
        print("%s: button" % text)
    else:
        print("button")

func focus_item_list():
    var count = node.get_item_count()
    var selected = node.get_selected_items()
    print("list, %s %s" % [count, item_or_items(count)])
    print(selected)
    

func handle_item_list_item_selected(index):
    print("Selected")

func handle_item_list_multi_selected(index, selected):
    print("Multiselect")

func handle_item_list_nothing_selected():
    print("Nothing selected")

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
        print("%s: %s of %s" % [text, position_in_children+1, node.get_item_count()])

func focus_label():
    print(node.text)

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
    print("%s: %s" % [text, type])

func text_deleted(text):
    print("%s deleted" % text)

func text_inserted(text):
    print(text)

var old_pos

func check_caret_moved():
    var pos = node.caret_position
    if old_pos != pos:
        var text = node.text
        if pos > len(text)-1:
            print("blank")
        else:
            print(text[pos])
        old_pos = pos

func focus_menu_button():
    print(node.text, ": menu")

func render_popup_menu_item(id):
    var item = node.get_item_text(id)
    var submenu = node.get_item_submenu(position_in_children)
    var tooltip = node.get_item_tooltip(position_in_children)
    if submenu:
        item = submenu
    if item and tooltip:
        item += ": "
        item += tooltip
    elif tooltip:
        item = tooltip
    var shortcut = node.get_item_shortcut(position_in_children)
    if shortcut:
        item += ": "+shortcut.get_as_text()
    return item

func focus_popup_menu():
    print("menu")

func focus_popup_menu_item(id):
    print(render_popup_menu_item(id))

func render_tree_item():
    var item = node.get_selected()
    var result = item.get_text(0)
    return result

func focus_tree():
    if node.get_selected():
        print(render_tree_item(), ": tree item")
    else:
        print("tree")

func select_tree():
    if node.has_focus():
        print(render_tree_item())

func focused():
    # print(node)
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
    elif node is Tree:
        focus_tree()
    else:
        print("Focus entered.", node)
    if node.hint_tooltip:
        print(node.hint_tooltip)

func unfocused():
    position_in_children = 0

func gui_input(event):
    if node is ItemList:
        return input_item_list(event)
    elif node is LineEdit:
        return check_caret_moved()

func _init(node):
    if node.is_in_group("accessible"):
        return
    node.add_to_group("accessible")
    self.node = node
    if not node is Container and not node is Panel and not node is Separator:
        node.set_focus_mode(Control.FOCUS_ALL)
    node.connect("focus_entered", self, "focused")
    node.connect("mouse_entered", self, "focused")
    node.connect("focus_exited", self, "unfocused")
    node.connect("mouse_exited", self, "unfocused")
    node.connect("gui_input", self, "gui_input")
    if node is ItemList:
        node.connect("item_selected", self, "handle_item_list_item_selected")
        node.connect("multi_selected", self, "handle_item_list_multi_selected")
        node.connect("nothing_selected", self, "handle_item_list_nothing_selected")
        
    elif node is LineEdit:
        node.connect("text_deleted", self, "text_deleted")
        node.connect("text_inserted", self, "text_inserted")
    elif node is PopupMenu:
        node.connect("id_focused", self, "focus_popup_menu_item")
    elif node is Tree:
        node.connect("item_selected", self, "select_tree")
    node.connect("tree_exiting", self, "free")
