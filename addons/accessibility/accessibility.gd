tool
extends EditorPlugin

var Accessible = preload("accessible.gd")

func _augment_node(node):
    if node is Control:
        Accessible.new(node)

func _enter_tree():
    get_tree().connect("node_added", self, "_augment_node")

func _exit_tree():
    # Clean-up of the plugin goes here
    pass
