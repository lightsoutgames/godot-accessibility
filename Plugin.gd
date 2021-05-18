tool
extends EditorPlugin

var TTS

var TtsClass = preload("../godot-tts/TTS.gd")

var ScreenReader = preload("ScreenReader.gd")

var screen_reader


func _initialise_settings() -> void:
	_add_setting("In_Editor", TYPE_BOOL, true)
	_add_setting("Logging", TYPE_BOOL, true)
	_add_setting("Speech_Rate", TYPE_INT, 50)
	ProjectSettings.save()
	
	
func _add_setting(title: String, type: int, value, hint_type: int = -1, hint_string = "") -> void:
	title = title.insert(0, "Accessibility/")
	if ProjectSettings.has_setting(title):
		return
	ProjectSettings.set(title, value)
	var prop: Dictionary = {}
	prop["name"] = title
	prop["type"] = type
	if hint_type > -1:
		prop["hint"] = hint_type
		prop["hint_string"] = hint_string
	ProjectSettings.add_property_info(prop)


func set_initial_screen_focus(screen):
	if not screen_reader.enabled:
		return
	TTS.speak("%s: screen" % screen, false)
	var control = screen_reader.find_focusable_control(get_tree().root)
	if control.get_focus_owner() != null:
		return
	screen_reader.augment_tree(get_tree().root)
	var focus = screen_reader.find_focusable_control(get_tree().root)
	if not focus:
		return
	focus.grab_click_focus()
	focus.grab_focus()


func _enter_tree():
	_initialise_settings()
	TTS = TtsClass.new()
	var rate = ProjectSettings.get_setting("Accessibility/Speech_Rate")
	TTS.call_deferred("_set_rate", rate)
	var logging = ProjectSettings.get_setting("Accessibility/Logging")
	if ProjectSettings.get_setting("Accessibility/In_Editor"):
		screen_reader = ScreenReader.new(TTS, logging)
		screen_reader.enable_focus_mode = true
		get_tree().root.call_deferred("add_child", screen_reader)
	add_custom_type("ScreenReader", "Node", preload("ScreenReader.gd"), null)


func _exit_tree():
	remove_custom_type("ScreenReader")


var _focus_loss_interval = 0


func _process(delta):
	if not screen_reader or not screen_reader.enabled:
		return
	var focus = screen_reader.find_focusable_control(get_tree().root)
	focus = focus.get_focus_owner()
	if focus:
		_focus_loss_interval = 0
	else:
		_focus_loss_interval += delta
		if _focus_loss_interval >= 0.2:
			_focus_loss_interval = 0
			focus = screen_reader.find_focusable_control(get_tree().root)
			focus.grab_focus()
			focus.grab_click_focus()
