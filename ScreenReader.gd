tool
extends Node

var Accessible = preload("Accessible.gd")

var focus_restore_timer = Timer.new()

func focused(node):
    focus_restore_timer.stop()

func click_focused(node):
    pass

func restore_focus():
    var focus = find_focusable_control(get_tree().root)
    if focus and not focus.get_focus_owner():
        print("Restoring focus.")
        focus.grab_focus()
        focus.grab_click_focus()

func unfocused(node):
    focus_restore_timer.start(0.2)

func augment_node(node):
    if node is Control:
        var accessible = Accessible.new(node)
        add_child(accessible)
        if not node.is_connected("focus_entered", self, "focused"):
            node.connect("focus_entered", self, "focused", [node])
        if not node.is_connected("mouse_entered", self, "click_focused"):
            node.connect("mouse_entered", self, "click_focused", [node])
        if not node.is_connected("focus_exited", self, "unfocused"):
            node.connect("focus_exited", self, "unfocused", [node])
        if not node.is_connected("mouse_exited", self, "unfocused"):
            node.connect("mouse_exited", self, "unfocused", [node])

func augment_tree(node):
    augment_node(node)
    for child in node.get_children():
        augment_tree(child)

func set_initial_screen_focus(screen):
    TTS.speak("%s: screen" % screen, false)
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
    self.augment_tree(get_tree().root)
    var focus = find_focusable_control(get_tree().root)
    if not focus:
        return
    focus.grab_click_focus()
    focus.grab_focus()

func _enter_tree():
    focus_restore_timer.one_shot = true
    focus_restore_timer.connect("timeout", self, "restore_focus")
    add_child(focus_restore_timer)
    get_tree().connect("node_added", self, "augment_tree")
