tool
extends Node

signal swipe_left

signal swipe_right

signal swipe_up

signal swipe_down

var Accessible = preload("Accessible.gd")

export var explore_by_touch_distance = 5

var focus_restore_timer

func focused(node):
    focus_restore_timer = null

func click_focused(node):
    pass

func unfocused(node):
    focus_restore_timer = get_tree().create_timer(0.2)

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
    if node is Accessible:
        return
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
    get_tree().connect("node_added", self, "augment_tree")

var touch_index = null

var touch_position = null

var explore_by_touch = false

func _input(event):
    if event is InputEventScreenTouch:
        print(event.position)
        get_tree().set_input_as_handled()
        if touch_index and event.index != touch_index:
            return
        if event.pressed:
            touch_index = event.index
            touch_position = event.position
        else:
            touch_index = null
            var relative = event.position - touch_position
            if abs(relative.x) > abs(relative.y):
                if relative.x > 0:
                    emit_signal("swipe_right")
                else:
                    emit_signal("swipe_left")
            else:
                if relative.y > 0:
                    emit_signal("swipe_down")
                else:
                    emit_signal("swipe_up")
            touch_position = null
            explore_by_touch = false
    elif event is InputEventScreenDrag:
        if touch_index and event.index != touch_index:
            return

func _process(delta):
    if focus_restore_timer and focus_restore_timer.time_left <= 0:
        var focus = find_focusable_control(get_tree().root)
        if focus and not focus.get_focus_owner():
            print("Restoring focus.")
            focus.grab_focus()
            focus.grab_click_focus()
