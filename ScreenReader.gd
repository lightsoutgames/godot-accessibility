tool
extends Node

var Accessible = preload("Accessible.gd")

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
    tts.speak("%s: screen" % screen, false)
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
    tts.rate = 255
    get_tree().connect("node_added", self, "augment_tree")
