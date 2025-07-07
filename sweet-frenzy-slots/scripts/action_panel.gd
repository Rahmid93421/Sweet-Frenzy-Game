extends Panel

@onready var parentNode = get_parent().get_parent().get_parent()
@onready var buttonMinus = $Button
@onready var buttonPlus = $Button2

var btnPressed = false
var deltaTime = 0
var pauseTimeBetweenAction = 0
var betModifier = 25
var valueChanged = false
var textValue = "none"

func _process(delta: float) -> void:
	if(btnPressed == true and parentNode.waitForMulti == false):
		if(pauseTimeBetweenAction >= 0.35):
			if(deltaTime > 0.1):
				if(textValue == '-' and parentNode.betValue - betModifier > 0):
					if(parentNode.betValue - betModifier < 0):
						parentNode.betValue = 0
					else:
						parentNode.betValue -= betModifier
				if(textValue == '+'):
					parentNode.betValue += betModifier
				parentNode._updateBetLabel()
				deltaTime = 0
			else:
				deltaTime += delta
		else:
			pauseTimeBetweenAction += delta

func _on_button_button_down() -> void:
	textValue = buttonMinus.text
	btnPressed = true

func _on_button_button_up() -> void:
	textValue = "none"
	btnPressed = false
	pauseTimeBetweenAction = 0

func _on_button2_button_down() -> void:
	textValue = buttonPlus.text
	btnPressed = true

func _on_h_slider_value_changed(value: float) -> void:
	if(value != betModifier):
		betModifier = value
		
func _on_button_pressed() -> void:
	if(parentNode.waitForMulti == false):
		if(parentNode.betValue - betModifier < 0):
			parentNode.betValue = 0
		else:
			parentNode.betValue -= betModifier
		parentNode._updateBetLabel()

func _on_button_2_pressed() -> void:
	if(parentNode.waitForMulti == false):
		parentNode.betValue += betModifier
		parentNode._updateBetLabel()
