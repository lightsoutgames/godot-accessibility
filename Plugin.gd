tool
extends EditorPlugin

var ScreenReader = preload("ScreenReader.gd")

var screen_reader

func _enter_tree():
    var editor_accessibility_enabled = true
    var rate = 50
    var config = ConfigFile.new()
    var     err = config.load("res://.godot-accessibility-editor-settings.ini")
    if not err:
        editor_accessibility_enabled = config.get_value("global", "editor_accessibility_enabled", true)
        rate = config.get_value("speech", "rate", 50)
    add_autoload_singleton("TTS", "res://addons/godot-tts/TTS.gd")
    if editor_accessibility_enabled:
        TTS.call_deferred("set_rate", rate)
        screen_reader = ScreenReader.new()
        get_tree().root.call_deferred("add_child", screen_reader)
        call_deferred("connect", "scene_changed", screen_reader, "set_initial_scene_focus")
        call_deferred("connect", "main_screen_changed", screen_reader, "set_initial_screen_focus")
    add_custom_type("ScreenReader", "Node", preload("ScreenReader.gd"), null)

func _exit_tree():
    remove_custom_type("ScreenReader")
