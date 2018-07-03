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

var list_pos = 0

func input_item_list(event):
    var old_list_pos = list_pos
    if event.echo or not event.pressed:
        return
    if event.scancode == KEY_UP:
        if list_pos == 0:
            return
        list_pos -= 1
    elif event.scancode == KEY_DOWN:
        if list_pos >= node.get_item_count()-1:
            return
        list_pos += 1
    elif event.scancode == KEY_HOME:
        list_pos = 0
    elif event.scancode == KEY_END:
        list_pos = node.get_item_count()-1
    if old_list_pos != list_pos:
        var text = node.get_item_text(list_pos)
        print("%s: %s of %s" % [text, list_pos+1, node.get_item_count()])

func handle_item_list_item_selected(index):
    print("Selected")

func handle_item_list_multi_selected(index, selected):
    print("Multiselect")

func handle_item_list_nothing_selected():
    print("Nothing selected")

func present_item_list():
    var count = node.get_item_count()
    var selected = node.get_selected_items()
    print("list, %s %s" % [count, item_or_items(count)])
    print(selected)
    

func unfocus_item_list():
    list_pos = 0

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
    if node is ItemList:
        unfocus_item_list()

func gui_input(event):
    if node is ItemList:
        return input_item_list(event)
    if self.node is LineEdit:
        return check_caret_moved()

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
    if node is ItemList:
        node.connect("item_selected", self, "handle_item_list_item_selected")
        node.connect("multi_selected", self, "handle_item_list_multi_selected")
        node.connect("nothing_selected", self, "handle_item_list_nothing_selected")
        
    elif self.node is LineEdit:
        self.node.connect("text_deleted", self, "text_deleted")
        self.node.connect("text_inserted", self, "text_inserted")
    self.node.connect("tree_exiting", self, "free")
