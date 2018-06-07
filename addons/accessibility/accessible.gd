extends Object

var node

func focused():
    print("Focus entered.")

func unfocused():
    print("Unfocused")

func gui_input():
    print("GUI input.")

func _init(node):
    if node.is_in_group("accessible"):
        return
    node.add_to_group("accessible")
    # print(node.get_path())
    self.node = node
    self.node.connect("focus_entered", self, "focused")
    self.node.connect("mouse_entered", self, "focused")
    self.node.connect("focus_exited", self, "unfocused")
    self.node.connect("mouse_exited", self, "unfocused")
    self.node.connect("gui_input", self, "gui_input")
    self.node.connect("tree_exiting", self, "free")
