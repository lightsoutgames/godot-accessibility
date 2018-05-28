tool
extends EditorPlugin

var Accessible = preload("accessible.gd")

func _augment_node(node):
    if node is Control:
        node.set_focus_mode(Control.FOCUS_ALL)
        Accessible.new(node)

func _set_initial_screen_focus(screen):
    print("Screen ",screen)
    var focus
    var root = self
    while root.get_parent() != null:
        root = root.get_parent()
    if screen == "3D":
        focus = root.find_node("ToolButton", true, false)
    print("Focus ",focus)
    focus.grab_click_focus()
    focus.grab_focus()

func _set_initial_scene_focus(scene):
    print("Set focus in scene")

func _enter_tree():
    get_tree().connect("node_added", self, "_augment_node")
    connect("scene_changed", self, "_set_initial_scene_focus")
    connect("main_screen_changed", self, "_set_initial_screen_focus")

func _exit_tree():
    # Clean-up of the plugin goes here
    pass
