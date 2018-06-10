extends Object

var node

func focused():
    if node is Button:
        var text = "Unlabelled"
        if node.text:
            text = node.text
        print("%s: button" % text)
    else:
        print("Focus entered.", self.node)

func unfocused():
    pass

func gui_input(event):
    pass

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
