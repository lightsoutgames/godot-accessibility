tool
extends EditorPlugin

func _focus_entered():
    print("Focus entered.")

func _gui_input():
    print("GUI input.")

func _augment_node(node):
    if node is Control:
        node.connect("focus_entered", self, "_focused")
        node.connect("mouse_entered", self, "_focused")
        node.connect("gui_input", self, "_gui_input")

func _enter_tree():
    get_tree().connect("node_added", self, "_augment_node")

func _exit_tree():
    # Clean-up of the plugin goes here
    pass
