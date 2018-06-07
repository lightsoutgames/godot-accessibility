tool
extends EditorPlugin

var Accessible = preload("accessible.gd")

func augment_node(node):
    if node is Control:
        node.set_focus_mode(Control.FOCUS_ALL)
        Accessible.new(node)

func set_initial_screen_focus(screen):
    print("Screen ",screen)
    var focus
    var root = get_tree().root
    if screen == "3D":
        focus = root.find_node("ToolButton", true, false)
    print("Focus ",focus)
    focus.grab_click_focus()
    focus.grab_focus()

func set_initial_scene_focus(scene):
    print("Set focus in scene")

func _enter_tree():
    get_tree().connect("node_added", self, "augment_node")
    connect("scene_changed", self, "set_initial_scene_focus")
    connect("main_screen_changed", self, "set_initial_screen_focus")

func _exit_tree():
    # Clean-up of the plugin goes here
    pass
