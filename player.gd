extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    Globals.tts.speak("Hello, world.", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("speak_coordinates"):
        Globals.tts.speak("%s, %s" % [position.x, position.y], true)
    elif Input.is_action_just_pressed("speak_heading"):
        Globals.tts.speak("%s degrees" % global_rotation_degrees, true)
    elif Input.is_action_pressed("quit"):
        get_tree().quit()
    elif Input.is_action_pressed("stop_speech"):
        Globals.tts.stop()
