extends Panel

@onready var titleLabel = $Title
@onready var contentLabel = $Content
@onready var animationPlayer = $AnimationPlayer

@onready var mayTheForceSound = preload("res://assets/sounds/maytheforce.wav")
@onready var audioStreamPlayer = $"../../AudioStreamPlayer"
@onready var mainAnimPlayer = $"../../AnimationPlayer"
@onready var buttonYes = $Close2
@onready var buttonNo = $Close3
@onready var parentNode = $"../../.."

var respinsWon = false
var respinsWon_bkp = false
var showContent = false
var contentToShow = ""
var delayTime = 0.05
var countTime = 0
var numberOfCharactersShown = 0
var spinsFinished = false
var moreSpins = false
var stopAnim = false

func _ready():
	buttonNo.hide()
	buttonYes.hide()

func _process(delta: float) -> void:
	if(showContent):
		if(respinsWon == true):
			respinsWon = false
		
		if(numberOfCharactersShown > len(contentToShow)):
			if(stopAnim == false):
				audioStreamPlayer.stream = mayTheForceSound
				audioStreamPlayer.play()
			showContent = false
			stopAnim = false
		else:
			if(countTime >= delayTime):
				numberOfCharactersShown += 1
				contentLabel.visible_characters += 1
				countTime = 0
			else:
				countTime += delta * 100

func _setTitle(title):
	titleLabel.text = "[center]" + str(title) + "[/center]"
	
func _setContent(content):
	contentLabel.text = "[center]" + str(content) + "[/center]" 
	contentToShow = content
	
func _askBuyRespins():
	buttonYes.visible = true
	buttonNo.visible = true
	
func _wonMoreSpins():
	moreSpins = true

func _finishSpins():
	spinsFinished = true

func _showInfoPanel():
	animationPlayer.play("ShowInfoPanel")
	
func _closeInfoPanel():
	stopAnim = true
	animationPlayer.play("CloseInfoPanel")

func _on_close_pressed() -> void:
	_closeInfoPanel()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "ShowInfoPanel"):
		stopAnim = false
		numberOfCharactersShown = 0
		showContent = true
	if(anim_name == "CloseInfoPanel"):
		if(moreSpins == false):
			if(respinsWon_bkp == true):
				respinsWon_bkp = false
				mainAnimPlayer.play("PrepareFeatureSpins")
			else:
				buttonNo.hide()
				buttonYes.hide()
		else:
			parentNode.buttonPressedPlay = false
			parentNode._featureSpins()
			moreSpins = false
			
		if(spinsFinished == true):
			mainAnimPlayer.play("RevertFeatureSpins")
			spinsFinished = false
	
func _setRespins():
	respinsWon = true
	respinsWon_bkp = true

func _on_buy_pressed() -> void:
	stopAnim = true
	animationPlayer.play("CloseInfoPanel")
	mainAnimPlayer.play("PrepareFeatureSpins")
