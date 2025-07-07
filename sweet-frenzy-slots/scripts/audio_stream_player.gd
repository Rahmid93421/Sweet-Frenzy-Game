extends AudioStreamPlayer

@onready var sounds = {
	"unstoppable": preload("res://assets/sounds/f_unstoppable.wav"),
	"godlike": preload("res://assets/sounds/f_godlike.wav"),
	"dominating": preload("res://assets/sounds/f_dominating.wav"),
	"holyshit": preload("res://assets/sounds/f_holyshit.wav"),
	"wickedsick": preload("res://assets/sounds/f_wickedsick.wav")
}

func _playUnstoppable():
	self.stream = sounds["unstoppable"]
	self.play()
	
func _playDominating():
	self.stream = sounds["dominating"]
	self.play()
	
func _playHolyshit():
	self.stream = sounds["holyshit"]
	self.play()
	
func _playWickedsick():
	self.stream = sounds["wickedsick"]
	self.play()

func _playGodlike():
	self.stream = sounds["godlike"]
	self.play()
