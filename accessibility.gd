tool
extends EditorPlugin

var Accessible = preload("accessible.gd")

var TTS = preload("../godot-tts/TTS.gd")

var tts

func augment_node(node):
    if node is Control:
        Accessible.new(tts, node)

func augment_tree(node):
    augment_node(node)
    for child in node.get_children():
        augment_tree(child)

func set_initial_screen_focus(screen):
    tts.speak(screen, true)
    var control = find_focusable_control(get_tree().root)
    if control.get_focus_owner() != null:
        return
    self.augment_tree(get_tree().root)
    var focus = find_focusable_control(get_tree().root)
    if not focus:
        return
    focus.grab_click_focus()
    focus.grab_focus()

func find_focusable_control(node):
    if node is Control and node.is_visible_in_tree() and (node.focus_mode == Control.FOCUS_CLICK or node.focus_mode == Control.FOCUS_ALL):
        return node
    for child in node.get_children():
        var result = find_focusable_control(child)
        if result:
            return result
    return null

func set_initial_scene_focus(scene):
    print("Set focus in scene")
    self.augment_tree(get_tree().root)
    var focus = find_focusable_control(get_tree().root)
    if not focus:
        return
    focus.grab_click_focus()
    focus.grab_focus()

func _enter_tree():
    tts = TTS.new()
    get_tree().connect("node_added", self, "augment_tree")
    connect("scene_changed", self, "set_initial_scene_focus")
    connect("main_screen_changed", self, "set_initial_screen_focus")

func _exit_tree():
    # Clean-up of the plugin goes here
    pass

func _notification(what):
    # print("Notified: %s" % what)
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        print("User requested the project to quit")
