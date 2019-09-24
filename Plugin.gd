tool
extends EditorPlugin

var ScreenReader = preload("ScreenReader.gd")

var screen_reader

func _enter_tree():
    screen_reader = ScreenReader.new()
    get_tree().root.call_deferred("add_child", screen_reader)
    call_deferred("connect", "scene_changed", screen_reader, "set_initial_scene_focus")
    call_deferred("connect", "main_screen_changed", screen_reader, "set_initial_screen_focus")
    add_custom_type("ScreenReader", "Node", preload("ScreenReader.gd"), preload("icon.png"))

func _exit_tree():
    remove_custom_type("ScreenReader")
