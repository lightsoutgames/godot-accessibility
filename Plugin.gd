tool
extends EditorPlugin

var ScreenReader = preload("ScreenReader.gd")

var screen_reader

var TTS

var editor_settings

const settings_path = "interface/accessibility/"


func _initialise_settings() -> void:
	editor_settings = get_editor_interface().get_editor_settings()
	_add_setting("In_Editor", TYPE_BOOL, false)
	_add_setting("Logging", TYPE_BOOL, false)
	_add_setting("Speech_Rate", TYPE_INT, 50)
	
	
func _add_setting(title: String, type: int, value, hint_type: int = -1, hint_string = "") -> void:
	title = title.insert(0, settings_path)
	if editor_settings.has_setting(title):
		return
	editor_settings.set(title, value)
	var prop: Dictionary = {}
	prop["name"] = title
	prop["type"] = type
	if hint_type > -1:
		prop["hint"] = hint_type
		prop["hint_string"] = hint_string
	editor_settings.add_property_info(prop)


func set_initial_screen_focus(screen):
	if not screen_reader or not screen_reader.enabled:
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
	var rate = editor_settings.get_setting(settings_path + "Speech_Rate")
	var logging = editor_settings.get_setting(settings_path + "Logging")
	if editor_settings.get_setting(settings_path + "In_Editor"):
		screen_reader = ScreenReader.new()
		screen_reader.enable_focus_mode = true
		screen_reader.logging = logging
		TTS = screen_reader.TTS
		TTS.call_deferred("_set_rate", rate)
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
