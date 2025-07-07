extends Button

@onready var parentNode = get_parent().get_parent().get_parent().get_parent()

var btnPressed = false
var deltaTime = 0
var betModifier = 0
var valueChanged = false

func _on_pressed() -> void:
	pass
func _process(delta: float) -> void:
	if(btnPressed == true):
		if(deltaTime > 0.05):
			var textValue = self.text
			if(textValue == '-'):
				parentNode.betValue -= betModifier
			if(textValue == '+'):
				parentNode.betValue += betModifier
			parentNode._updateBetLabel()
			deltaTime = 0
		else:
			deltaTime += delta

func _on_button_down() -> void:
	btnPressed = true

func _on_button_up() -> void:
	btnPressed = false

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	valueChanged = value_changed
