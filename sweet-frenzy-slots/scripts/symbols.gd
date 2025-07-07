extends GridContainer

@onready var symbolTextures = [
	preload("res://assets/sprites/lolli.png"),
	 preload("res://assets/sprites/jelly.png"),
	preload("res://assets/sprites/peach.png"),
	preload("res://assets/sprites/melon.png"),
	preload("res://assets/sprites/bean.png"),
	preload("res://assets/sprites/apple.png"),
	preload("res://assets/sprites/banana.png")
]

var spinTime = 1.5
var gridColumns = []

func _ready() -> void:
	for vbox in self.get_children():
		if(vbox is VBoxContainer):
			gridColumns.append(vbox)
			
func _startSpin():
	for i in range(gridColumns.size()):
		spinColumn(gridColumns[i], i * 0.2)
		
func spinColumn(vbox, delay):
	await get_tree().create_timer(delay).timeout
	var spin_speed = 0.05  # Initial fast swapping speed
	var elapsed_time = 0.0  # Track how long this column has been spinning
	while(elapsed_time < spinTime):
		for child in vbox.get_children():
			child.texture = symbolTextures.pick_random()
	await get_tree().create_timer(spin_speed).timeout  # Wait before next swap
	elapsed_time += spin_speed
	
	spin_speed = lerp(spin_speed, 0.3, 0.1)
