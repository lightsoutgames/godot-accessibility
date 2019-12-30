tool
extends Node

signal swipe_left

signal swipe_right

signal swipe_up

signal swipe_down

var Accessible = preload("Accessible.gd")

export var min_swipe_distance = 5

export var tap_execute_interval = 125

export var explore_by_touch_interval = 200

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
    connect("swipe_right", self, "swipe_right")
    connect("swipe_left", self, "swipe_left")
    connect("swipe_up", self, "swipe_up")
    connect("swipe_down", self, "swipe_down")

func press_and_release(action):
    var event = InputEventAction.new()
    event.action = action
    event.pressed = true
    get_tree().input_event(event)
    event.pressed = false
    get_tree().input_event(event)

func swipe_right():
    press_and_release("ui_focus_next")

func swipe_left():
    press_and_release("ui_focus_prev")

func swipe_up():
    TTS.speak("Swipe up")

func swipe_down():
    TTS.speak("Swipe down")

var touch_index = null

var touch_position = null

var touch_start_time = null

var touch_stop_time = null

var explore_by_touch = false

var tap_count = 0

func _input(event):
    if event is InputEventScreenTouch:
        get_tree().set_input_as_handled()
        if touch_index and event.index != touch_index:
            return
        if event.pressed:
            touch_index = event.index
            touch_position = event.position
            touch_start_time = OS.get_ticks_msec()
            touch_stop_time = null
        else:
            touch_index = null
            var relative = event.position - touch_position
            if relative.length() < min_swipe_distance:
                tap_count += 1
            elif not explore_by_touch:
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
            touch_start_time = null
            touch_stop_time = OS.get_ticks_msec()
            explore_by_touch = false
    elif event is InputEventScreenDrag:
        if touch_index and event.index != touch_index:
            return
        if not explore_by_touch and OS.get_ticks_msec() - touch_start_time >= explore_by_touch_interval:
            explore_by_touch = true
            TTS.speak("Explore")

func _process(delta):
    if touch_stop_time and OS.get_ticks_msec() - touch_stop_time >= tap_execute_interval and tap_count != 0:
        touch_stop_time = null
        if tap_count == 2:
            press_and_release("ui_accept")
        tap_count = 0
    if focus_restore_timer and focus_restore_timer.time_left <= 0:
        var focus = find_focusable_control(get_tree().root)
        if focus and not focus.get_focus_owner():
            print("Restoring focus.")
            focus.grab_focus()
            focus.grab_click_focus()
