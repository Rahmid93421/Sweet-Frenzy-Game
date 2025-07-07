extends Panel

@onready var vBoxContainer = $VBoxContainer
@onready var animationPlayer = $AnimationPlayer
@onready var symbolTextures = {
	"respinSymbol": preload("res://assets/sprites/lolli.png"),
	"valueSymbol_1": preload("res://assets/sprites/jelly.png"),
	"valueSymbol_2": preload("res://assets/sprites/peach.png"),
	"valueSymbol_3": preload("res://assets/sprites/melon.png"),
	"valueSymbol_4": preload("res://assets/sprites/bean.png"),
	"valueSymbol_5": preload("res://assets/sprites/apple.png"),
	"valueSymbol_6": preload("res://assets/sprites/banana.png")
}
var symbolName = "none"
var numberOfSymbols = 0
var minSizeY = 40.0

var items = []
var queueItems = []
var vBoxItemsUsed = 0
var lenVbox = 0
var queueOfSymbols = []
var areItemsAllUsed = false

func _ready():
	for child in vBoxContainer.get_children():
		child.custom_minimum_size = Vector2(0, 0)
		child.clip_contents = true
		items.append(child)
		
func _process(delta):
	if(!queueItems.is_empty()):
		var item = queueItems[0]
		if(vBoxItemsUsed >= 10):
			if(item.custom_minimum_size.y > 0):
				item.custom_minimum_size.y -= 150 * delta
			else:
				item.custom_minimum_size.y = 0
				vBoxContainer.move_child(item, 0)
				vBoxItemsUsed -= 1
		else:
			if(item.custom_minimum_size.y < minSizeY):
				item.custom_minimum_size.y += 150 * delta
			else:
				item.custom_minimum_size.y = minSizeY
				queueItems.pop_front()

func _getFreeItem():
	for item in items:
		if(item.custom_minimum_size.y == 0):
			return item

func _addSymbol(symbolName_a, numberOfSymbols_a):
	var currentItem = items.pop_front()
	queueItems.append(currentItem)
	currentItem.visible = true
	currentItem.get_node("TextureRect").texture = symbolTextures[symbolName_a]
	currentItem.get_node("RichTextLabel").text = "[center]X" + str(numberOfSymbols_a) + "[/center]" 

func _addSymbolToHistory(symbolName_a, numberOfSymbols_a):
	symbolName = symbolName_a
	numberOfSymbols = numberOfSymbols_a
	queueOfSymbols.append([symbolName, numberOfSymbols])
	if(areItemsAllUsed):
		var vBoxChildren = vBoxContainer.get_children()
		lenVbox = len(vBoxChildren)-1
		items.append(vBoxChildren[len(vBoxChildren)-len(queueItems)-1])
	
	var currentItem = items.pop_front()
	vBoxItemsUsed += 1
	if(vBoxItemsUsed >= 10):
		areItemsAllUsed = true
	queueItems.append(currentItem)
	currentItem.visible = true
	currentItem.get_node("TextureRect").texture = symbolTextures[symbolName]
	currentItem.get_node("RichTextLabel").text = "[center]X" + str(numberOfSymbols) + "[/center]" 
	queueOfSymbols.pop_front()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "ShowSymbolInHistory"):
		symbolName = "none"
