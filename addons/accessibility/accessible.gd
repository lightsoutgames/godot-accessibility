extends Object

var node

func _focused():
    print("Focus entered.")

func _gui_input():
    print("GUI input.")

func _init(node):
    print(node.get_path())
    self.node = node
    self.node.connect("focus_entered", self, "_focused")
    self.node.connect("mouse_entered", self, "_focused")
    self.node.connect("gui_input", self, "_gui_input")
    self.node.connect("tree_exiting", self, "free")
