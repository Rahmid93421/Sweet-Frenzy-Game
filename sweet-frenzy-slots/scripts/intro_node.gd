extends Node

@onready var introTitle = $CanvasLayer/Control/IntroTitle
@onready var animPlayer = $CanvasLayer/AnimationPlayer

var deltaTimeElapsed = 0.0
var deltaTimeLimit = 0.05
var introTitleLength = 0
var currentLen = 0
var startRoll = false
var startBack = false

func _ready() -> void:
	introTitleLength = len(introTitle.text)
	introTitle.visible_characters = 0

func _process(delta: float) -> void:
	if(startRoll == true):
		if(currentLen < introTitleLength and deltaTimeElapsed >= deltaTimeLimit):
			introTitle.visible_characters += 1
			currentLen += 1
			deltaTimeElapsed = 0
		else:
			if(deltaTimeElapsed < deltaTimeLimit):
				deltaTimeElapsed += delta
			else:
				animPlayer.play("StartTextBack")
				startRoll = false
	if(startBack == true):
		if(currentLen > 0 and deltaTimeElapsed >= deltaTimeLimit):
			introTitle.visible_characters -= 1
			currentLen -= 1
			deltaTimeElapsed = 0
		else:
			if(deltaTimeElapsed < deltaTimeLimit):
				deltaTimeElapsed += delta
			else:
				startBack = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "StartTextRoll"):
		startRoll = true
	if(anim_name == "StartTextBack"):
		startBack = true
