extends Object

var node

func item_or_items(count):
    if count == 1:
        return "item"
    else:
        return "items"

func present_button():
    var text = "Unlabelled"
    if node.text:
        text = node.text
    print("%s: button" % text)

func present_item_list():
    var count = node.get_item_count()
    var selected = node.get_selected_items()
    print("list, %s %s" % [count, item_or_items(count)])
    print(selected)

func present_line_edit():
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

func present_tree():
    var root = node.get_root()
    var count = 0
    print("tree: %s %s" % [count, item_or_items(count)])

func focused():
    if node is Button:
        present_button()
    elif node is ItemList:
        present_item_list()
    elif node is LineEdit:
        present_line_edit()
    elif node is Tree:
        present_tree()
    else:
        print("Focus entered.", self.node)

func unfocused():
    pass

func gui_input(event):
    if self.node is LineEdit:
        check_caret_moved()

func _init(node):
    if node.is_in_group("accessible"):
        return
    node.add_to_group("accessible")
    self.node = node
    # self.node.set_focus_mode(Control.FOCUS_ALL)
    self.node.connect("focus_entered", self, "focused")
    self.node.connect("mouse_entered", self, "focused")
    self.node.connect("focus_exited", self, "unfocused")
    self.node.connect("mouse_exited", self, "unfocused")
    self.node.connect("gui_input", self, "gui_input")
    self.node.connect("tree_exiting", self, "free")
