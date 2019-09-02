extends Node

const TTS = preload("res://godot_tts.gdns")
var tts

# Called when the node enters the scene tree for the first time.
func _ready():
    tts = TTS.new()
    tts.speak("Hello, world.", true)
