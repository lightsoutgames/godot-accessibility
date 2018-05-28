extends Object

var node

func focused():
    print("Focus entered.")

func unfocused():
    print("Unfocused")

func gui_input():
    print("GUI input.")

func _init(node):
    # print(node.get_path())
    self.node = node
    self.node.connect("focus_entered", self, "focused")
    self.node.connect("mouse_entered", self, "focused")
    self.node.connect("focus_exited", self, "unfocused")
    self.node.connect("mouse_exited", self, "unfocused")
    self.node.connect("gui_input", self, "gui_input")
    self.node.connect("tree_exiting", self, "free")
