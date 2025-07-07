extends Node

@onready var itemToDuplicate = $Interface_Layout/Control/Control/SlotPanel/DummyItem8
@onready var multiplierLabel = $Interface_Layout/Control/Control/Multiplier/RichTextLabel
@onready var betLabel = $Interface_Layout/Control/Panel/RichTextLabel2
@onready var moneyLabel = $Interface_Layout/Control/Panel/RichTextLabel
@onready var winningsLabel = $Interface_Layout/Control/Control/Winnings
@onready var gridContainer = $Interface_Layout/Control/Control/SlotPanel/Symbols
@onready var animationPlayer = $Interface_Layout/AnimationPlayer
@onready var audioStreamPlayer = $Interface_Layout/AudioStreamPlayer
@onready var infoPanel = $Interface_Layout/Control/InfoPanel
@onready var scriptToAttach = preload("res://scripts/dummy_item.gd")
@onready var statsBar = $Interface_Layout/Control/Control/StatsBar
@onready var winFreeSpins = preload("res://assets/sounds/playful-casino-slot-machine-jackpot-3-183921.mp3")
@onready var featureSpinsButton = $Interface_Layout/Control/Panel/FeatureSpinButton
@onready var spinsLabel = $Interface_Layout/Control/Panel/RichTextLabel4
@onready var symbolTextures = {
	"respinSymbol": preload("res://assets/sprites/lolli.png"),
	"valueSymbol_1": preload("res://assets/sprites/jelly.png"),
	"valueSymbol_2": preload("res://assets/sprites/peach.png"),
	"valueSymbol_3": preload("res://assets/sprites/melon.png"),
	"valueSymbol_4": preload("res://assets/sprites/bean.png"),
	"valueSymbol_5": preload("res://assets/sprites/apple.png"),
	"valueSymbol_6": preload("res://assets/sprites/banana.png")
}
var symbolValue = {
	"respinSymbol": 3,
	"valueSymbol_1": 0.02,
	"valueSymbol_2": 0.008,
	"valueSymbol_3": 0.005,
	"valueSymbol_4": 0.003,
	"valueSymbol_5": 0.002,
	"valueSymbol_6": 0.001
}
var popSound = {
	"valueSymbol_1": preload("res://assets/sounds/pop1.ogg"),
	"valueSymbol_2": preload("res://assets/sounds/pop2.ogg"),
	"valueSymbol_3": preload("res://assets/sounds/pop3.ogg"),
	"valueSymbol_4": preload("res://assets/sounds/pop4.ogg"),
	"valueSymbol_5": preload("res://assets/sounds/pop5.ogg"),
	"valueSymbol_6": preload("res://assets/sounds/pop6.ogg")
}
var symbolChance = {
	"respinSymbol": [37, 38],
	"valueSymbol_1": [44, 46],
	"valueSymbol_2": [25, 28],
	"valueSymbol_3": [70, 77],
	"valueSymbol_4": [50, 60],
	"valueSymbol_5": [0, 24],
	"valueSymbol_6": [78, 90]
}
var symbolsNames = [
	#"valueSymbol_6", "valueSymbol_5", "valueSymbol_4",
	#"valueSymbol_3", "valueSymbol_2", "valueSymbol_1", "respinSymbol"
	"respinSymbol",
	"valueSymbol_6", "valueSymbol_5", "valueSymbol_4", "valueSymbol_3", "valueSymbol_2", "valueSymbol_1",
]

var symbolsAppearances = {
	"respinSymbol": 0,
	"valueSymbol_1": 0,
	"valueSymbol_2": 0,
	"valueSymbol_3": 0,
	"valueSymbol_4": 0,
	"valueSymbol_5": 0,
	"valueSymbol_6": 0
}

var symbolsAppearances_Ex = {
	"respinSymbol": 0,
	"valueSymbol_1": 0,
	"valueSymbol_2": 0,
	"valueSymbol_3": 0,
	"valueSymbol_4": 0,
	"valueSymbol_5": 0,
	"valueSymbol_6": 0
}

var positionsColsX = [0, 89, 178, 267, 356, 445]
var workPositionsColsX = []

@export var symbolSize = 1.0
@export var symbolRota = 0.0
@export var dummyMinSize = 85.0
@export var popRotation = 0.0
@export var columnsPosition = Vector2(0, 0)
@export var columnVisible = true

var numberOfSymbols = 0
var matrixX = 6
var matrixY = 5
var respinSymbolsCount = 0
var maxRespinSymbols = 3
var gridContainer_children
var minSymbolsNum = 8
var minRespingSymbols = 3
var currentItem = null
var symbolsRefs = []
var newSymbolsAdded = []
var deadSpin = false
var stopWinning = -1
var unPop = false
var winnings = 0
var betValue = 1500
var startingMoney = 50000
var multiplierValue = 1
var waitForMulti = false
var deadSpinThres = 80
var stopWinThres = 80
var freeSpins = false
var respinSymbols = []
var audioStreamFinished = false
var rotateThePop = false
var waitForPop = false
var breakTheProcess = false
var buttonPressedPlay = false
var featureSpinsValue = 0
var numberOfSpins = 6
var featureSpinsActivated = false
var currentSpins = 1
var spinsFinished = false

var rngObj = RandomNumberGenerator.new()
var degreesRot = 0
var shuffleSymbolsAnim = false

var symbolWeights = {
	"respinSymbol": 80,    # Rare special symbol
	"valueSymbol_1": 5,  # Highest value (rarest regular symbol)
	"valueSymbol_2": 9,
	"valueSymbol_3": 15,
	"valueSymbol_4": 35,
	"valueSymbol_5": 45,
	"valueSymbol_6": 55   # Most common symbol
}

# Variables to control game balance
var baseWinChance = 0.35       # Base chance of creating a winning spin (35%)
var respinSymbolChance = 0.04  # Base chance of getting respin symbols (4%)
var minRespinSpacing = 10      # Minimum spins between respin features
var spinsSinceLastRespin = 0   # Track spins since last respin feature
var targetRTP = 0.96           # Return to player percentage (94%)
var winStreakFactor = 0.80     # Reduce win chance after wins (by 20%)
var lossStreakFactor = 1.20    # Increase win chance after losses (by 20%)
var consecutiveWins = 0        # Track consecutive wins
var consecutiveLosses = 0      # Track consecutive losses
var totalSpins = 0             # Track total spins
var totalBetAmount = 0         # Track total bet amount
var totalPayoutAmount = 0      # Track total payout amount
var currentRTP = 0.0           # Current calculated RTP

func _getSymbol_Ex():
	# Adjust win chance based on RTP, win/loss streaks
	var winChance = baseWinChance
	
	# Adjust for RTP (reduce win chance if RTP too high, increase if too low)
	if totalSpins > 50:  # Only start adjusting after enough data
		currentRTP = totalPayoutAmount / totalBetAmount if totalBetAmount > 0 else 0.0
		if currentRTP > targetRTP:
			winChance *= 0.75  # Reduce win chance
		elif currentRTP < targetRTP * 0.90:  # RTP too low
			winChance *= 1.10  # Increase win chance
	
	# Adjust for win/loss streaks
	if consecutiveWins > 0:
		winChance *= pow(winStreakFactor, min(consecutiveWins, 3))
	elif consecutiveLosses > 0:
		winChance *= pow(lossStreakFactor, min(consecutiveLosses, 3))
	
	# Determine if this will be a winning spin
	var willBeWinning = rngObj.randf() < winChance
	
	# Determine if we should include respin symbols
	var includeRespinSymbol = false
	if spinsSinceLastRespin >= minRespinSpacing:
		includeRespinSymbol = rngObj.randf() < respinSymbolChance
	
	# Create weighted list of potential symbols
	var availableSymbols = []
	var totalWeight = 0
	
	for symbolName in symbolsNames:
		# Skip respin symbol if we're not including it
		if symbolName == "respinSymbol" and not includeRespinSymbol:
			continue
			
		# If we're making a dead spin (non-winning), avoid symbols that already have enough
		# appearances to trigger a win
		if not willBeWinning and symbolsAppearances_Ex[symbolName] >= minSymbolsNum - 1:
			continue
			
		# For respin symbols, limit to max allowed
		if symbolName == "respinSymbol" and respinSymbolsCount >= maxRespinSymbols:
			continue
		
		# Add the symbol to our weighted pool
		availableSymbols.append(symbolName)
		totalWeight += symbolWeights[symbolName]
	
	# If no symbols were available, use a random regular symbol
	if availableSymbols.size() == 0:
		return symbolsNames[rngObj.randi_range(1, symbolsNames.size() - 1)]
	
	# Select a symbol based on weights
	var selection = rngObj.randi_range(1, totalWeight)
	var cumulativeWeight = 0
	
	for symbolName in availableSymbols:
		cumulativeWeight += symbolWeights[symbolName]
		if selection <= cumulativeWeight:
			# If it's a respin symbol, increment the counter
			if symbolName == "respinSymbol":
				respinSymbolsCount += 1
				spinsSinceLastRespin = 0
			
			# Update symbol appearances
			symbolsAppearances_Ex[symbolName] += 1
			return symbolName
	
	# Fallback (shouldn't reach here)
	return symbolsNames[1]

func _startSpin():
	totalSpins += 1
	spinsSinceLastRespin += 1
	totalBetAmount += betValue
	
	# Reset symbol appearances for this spin
	for symbolName in symbolsNames:
		symbolsAppearances_Ex[symbolName] = 0
		symbolsAppearances[symbolName] = 0
	
	respinSymbolsCount = 0

# Call this at the end of a spin after determining wins
func _updateStatistics(spinWinAmount):
	totalPayoutAmount += spinWinAmount
	
	if spinWinAmount > 0:
		consecutiveWins += 1
		consecutiveLosses = 0
	else:
		consecutiveLosses += 1
		consecutiveWins = 0
	
	if totalBetAmount > 0:
		currentRTP = totalPayoutAmount / totalBetAmount
		
	# Optional debug information
	print("Spin: ", totalSpins, " Win: ", spinWinAmount > 0, " RTP: ", currentRTP)

func _shuffleSymbols():
	_startSpin()
	
	for child in gridContainer_children:
		child.alignment = 2
		var VBoxContainer_children = child.get_children()
		for vboxChild in VBoxContainer_children:
			var symbolName = _getSymbol_Ex()
			vboxChild.get_node("Symbol").texture = symbolTextures[symbolName]
			vboxChild.symbolName = symbolName
			symbolsAppearances[symbolName] += 1
			
func _shuffleNewSymbols():
	_randomizeRng()
	
	if(!newSymbolsAdded.is_empty()):
		for item in newSymbolsAdded:
			var symbolName = _getSymbol_Ex()
			item.get_node("Symbol").texture = symbolTextures[symbolName]
			item.symbolName = symbolName

func _fillEmptySpots():
	for child in gridContainer_children:
		child.alignment = 2
		var childrenNum = child.get_child_count()
		if(childrenNum < matrixY):
			for i in range(0, matrixY - childrenNum):
				var newItem = itemToDuplicate.duplicate()
				newItem.set_script(scriptToAttach)
				newItem.set_process(true)
				child.add_child(newItem)
				child.move_child(newItem, 0)
				newItem.get_node("Symbol").scale = Vector2(0, 0)
				newItem.visible = true
				newSymbolsAdded.append(newItem)
	_shuffleNewSymbols()
	unPop = true
	animationPlayer.play("UnPop")

func _checkSymbols():
	symbolSize = 1.0
	symbolRota = 0.0
	dummyMinSize = 85.0
	var anyItemPopped = false
	for symbolName in symbolsNames:
		if(symbolsAppearances[symbolName]):
			if(symbolName == "respinSymbol" and symbolsAppearances[symbolName] >= minRespingSymbols):
				freeSpins = true
			else:
				if(symbolsAppearances[symbolName] >= minSymbolsNum):
					var symbolWinnings = (((betValue * symbolValue[symbolName]) * symbolsAppearances[symbolName]))
					statsBar._addSymbolToHistory(symbolName, symbolsAppearances[symbolName])
					
					if(featureSpinsActivated == true):
						symbolWinnings *= multiplierValue
					winnings += symbolWinnings 
					_getAllRefs(symbolName)
					currentItem = symbolName
					audioStreamPlayer.stream = popSound[symbolName]
					
					animationPlayer.play("PopAnimation")
					anyItemPopped = true
					
	if(anyItemPopped == false):
		if(freeSpins == false):
			buttonPressedPlay = false
			if(featureSpinsActivated == false):
				winnings *= multiplierValue
			if(winnings > betValue * 5):
				audioStreamPlayer._playDominating()
			if(winnings > betValue * 10):
				audioStreamPlayer._playUnstoppable()
			if(winnings > betValue * 25):
				audioStreamPlayer._playHolyshit()
			if(winnings > betValue * 40):
				audioStreamPlayer._playGodlike()
			if(featureSpinsActivated == false):
				startingMoney += winnings
				_updateMoneyLabel()
			if(winnings > 0 and featureSpinsActivated == false):
				animationPlayer.play("MultiTheWinnings")
			else:
				waitForMulti = false
				if(featureSpinsActivated == false):
					animationPlayer.play("RevertMultiLabel")
			if(featureSpinsActivated == true and currentSpins >= numberOfSpins):
				featureSpinsActivated = false
			if(featureSpinsActivated == false and currentSpins >= numberOfSpins and spinsFinished == false):
				startingMoney += winnings
				_updateMoneyLabel()
				infoPanel._setTitle("[center]Congrats[/center]")
				infoPanel._setContent("[center]The GODS bestowed upon you " + str("%.2f" % winnings) + "$!\nBe grateful for this gift received from the GODS![/center]")
				infoPanel._finishSpins()
				infoPanel._showInfoPanel()
				spinsFinished = true
		else:
			_getRespinSymbols()
			audioStreamFinished = true
			animationPlayer.play("RollThePop")
			rotateThePop = true
			audioStreamPlayer.stream = winFreeSpins
			audioStreamPlayer.play()
			freeSpins = false
		if(featureSpinsActivated == true):
			currentSpins += 1
			_updateSpinsLabel()

func _getRespinSymbols():
	for child in gridContainer_children:
		var VBoxContainer_children = child.get_children()
		for vboxChild in VBoxContainer_children:
			if(vboxChild.symbolName == "respinSymbol"):
				respinSymbols.append(vboxChild)

func _getAllRefs(symbolName):
	for child in gridContainer_children:
		var VBoxContainer_children = child.get_children()
		for vboxChild in VBoxContainer_children:
			if(vboxChild.symbolName == symbolName):
				symbolsRefs.append(vboxChild)

func _updateMultiplierLabel():
	multiplierLabel.text = "[center]X" + str(multiplierValue) + "[/center]" 
	
func _updateMoneyLabel():
	moneyLabel.text = "[center] MONEY: " + str("%.2f" % startingMoney) + "$[/center]" 

func _updateBetLabel():
	betLabel.text = "[center] BET: " + str(betValue) + "$[/center]"
	featureSpinsValue = (betValue * numberOfSpins) * 1.50
	featureSpinsButton.text = str(featureSpinsValue) + "$"

func _updateWinninsLabel():
	winningsLabel.text = "[center] YOU WON " + str("%.2f" % winnings) + "$[/center]"

func _randomizeRng():
	rngObj.randomize()

func _ready():
	if(symbolTextures.is_empty()):
		infoPanel._setTitle("Error")
		infoPanel._setContent("The app seems to have run into a problem, there are no symbols to be loaded or no symbols defined. If you are the dev, please check if the symbols are defined in the app generator. If those are defined, please contact the support.")
		infoPanel._showInfoPanel()
		breakTheProcess = true
	
	if(breakTheProcess == false):		
		_updateBetLabel()
		_updateMoneyLabel()
		_updateMultiplierLabel()
		_randomizeRng()
		
		gridContainer_children = gridContainer.get_children()
		_shuffleSymbols()

var shuffleOnce = false

func _process(_delta):
	if(currentItem != null):
		for symbol in symbolsRefs:
			symbol.get_node("Symbol").scale = (Vector2(symbolSize, symbolSize))
			symbol.get_node("Symbol").rotation_degrees = symbolRota
			symbol.custom_minimum_size.y = dummyMinSize
	if(unPop == true and !newSymbolsAdded.is_empty()):
		for symbol in newSymbolsAdded:
			symbol.get_node("Symbol").scale = (Vector2(symbolSize, symbolSize))
			
	if(rotateThePop == true):
		for symbol in respinSymbols:
			symbol.pivot_offset = Vector2(43, 43)
			symbol.rotation_degrees = popRotation
			
	if(buttonPressedPlay == true):
		if(shuffleOnce == false):
			if(featureSpinsActivated == true):
				_spinTheSymbolsOnFeature()
			else:
				_spinTheSymbolsOnButton()
			shuffleOnce = true
			
	if(numberOfSpins >= currentSpins and featureSpinsActivated == true):
		_featureSpins()

func _spinTheSymbolsOnButton():
	if(0):
		pass
	else:
		if(waitForMulti == false):
			waitForMulti = true
			_randomizeRng()
			var multiplierRng = rngObj.randi_range(0, 100)
			if(multiplierRng <= 75):
				multiplierValue = 2
			else:
				if(multiplierRng <= 96):
					multiplierValue = randi_range(3, 12)
				else:
					multiplierValue = 30
			_updateMultiplierLabel()
			startingMoney -= betValue
			moneyLabel.text = "[center] MONEY: " + str("%.2f" % startingMoney) + "$[/center]" 
			deadSpin = 0
			winnings = 0
			stopWinning = -1
			symbolSize = 1.0
			symbolRota = 0.0
			dummyMinSize = 85.0
			for symbol in symbolsAppearances:
				symbol = 0
			_updateWinninsLabel()
			_shuffleSymbols()

func _spinTheSymbolsOnFeature():
	if(0):
		pass
	else:
		if(1):
			_randomizeRng()
			var multiplierRng = rngObj.randi_range(0, 100)
			if(multiplierRng <= 90):
				multiplierValue = 2
			else:
				if(multiplierRng <= 98):
					multiplierValue = randi_range(3, 12)
				else:
					multiplierValue = 30
			_updateMultiplierLabel()
			deadSpin = 0
			stopWinning = -1
			symbolSize = 1.0
			symbolRota = 0.0
			dummyMinSize = 85.0
			for symbol in symbolsAppearances:
				symbol = 0
			_updateWinninsLabel()
			_shuffleSymbols()

func _featureSpins():
	if(buttonPressedPlay == false):
		workPositionsColsX = positionsColsX
		buttonPressedPlay = true
		shuffleOnce = false
		animationPlayer.play("RollAnimation")

func _on_spin_button_pressed():
	if(breakTheProcess == false and buttonPressedPlay == false):
		if(startingMoney - betValue < 0):
			infoPanel._setTitle("ERROR")
			infoPanel._setContent("Looks like you ran out of funds and cannot afford the bet. \nTry to lower the bet value and try again!")
			infoPanel._showInfoPanel()
		else:
			workPositionsColsX = positionsColsX
			buttonPressedPlay = true
			shuffleOnce = false
			animationPlayer.play("RollAnimation")
	
func _on_animation_player_animation_finished(anim_name: StringName):
	if(anim_name == "PopAnimation"):
		var fillAndGo = false
		if(!symbolsRefs.is_empty()):
			fillAndGo = true
		for symbol in symbolsRefs:
			symbol.free()
		currentItem = "null"
		symbolsRefs.clear()
		if(fillAndGo == true):
			_fillEmptySpots()
		_updateWinninsLabel()
		
	if(anim_name == "UnPop"):
		newSymbolsAdded.clear()
		unPop = false
		for symbolName in symbolsNames:
			symbolsAppearances[symbolName] = 0
		for child in gridContainer_children:
			child.alignment = 2
			var VBoxContainer_children = child.get_children()
			for vboxChild in VBoxContainer_children:
				symbolsAppearances[vboxChild.symbolName] += 1
		_checkSymbols()
		
	if(anim_name == "MultiTheWinnings"):
		_updateWinninsLabel()
		waitForMulti = false
	
	if(anim_name == "RollThePop"):
		rotateThePop = false
		
	if(anim_name == "RollAnimation"):
		_checkSymbols()
		
	if(anim_name == "PrepareFeatureSpins"):
		featureSpinsActivated = true
		currentSpins = 1
		numberOfSpins = 6
		buttonPressedPlay = false
		spinsFinished = false
		winnings = 0
		targetRTP = 0.1
		baseWinChance = 0.45
		_updateWinninsLabel()
		_updateSpinsLabel()
		if(freeSpins == false):
			startingMoney -= featureSpinsValue
			moneyLabel.text = "[center] MONEY: " + str("%.2f" % startingMoney) + "$[/center]" 
		_featureSpins()
	
	if(anim_name == "RevertFeatureSpins"):
		winnings = 0
		targetRTP = 0.96
		baseWinChance = 0.35
		_updateWinninsLabel()
		
func _updateSpinsLabel():
	spinsLabel.text = "[center]SPINS\n" + str(currentSpins) + "/" + str(numberOfSpins) + "[/center]"

func _on_audio_stream_player_finished() -> void:
	if(audioStreamFinished == true and len(respinSymbols) > 0):
		if(featureSpinsActivated == false):
			infoPanel._setTitle("Congrats")
			infoPanel._setContent("The GODS of Sweet Frenzy bestowed upon you 6 free spins!\nAs a philosopher said:\n 'Now it is time to spray and pray'\nWish you the biggest x1000 win!")
			infoPanel._setRespins()
			infoPanel._showInfoPanel()
			audioStreamFinished = false
		else:
			infoPanel._setTitle("Congrats")
			infoPanel._setContent("The GODS of Sweet Frenzy bestowed upon you 3 more free spins!\nYour luck is one of the biggest!")
			infoPanel._wonMoreSpins()
			infoPanel._showInfoPanel()
			numberOfSpins+=3
			_updateSpinsLabel()
			audioStreamFinished = false
		respinSymbols.clear()

func _on_feature_spin_button_pressed() -> void:
	infoPanel._setTitle("Feature Spins Buy")
	infoPanel._setContent("You are going to make an offering to the Sweet Frenzy GODS for 6 feature spins. That will cost you " + str(featureSpinsValue) + "$ \nDo you wish to proceed?")
	infoPanel._askBuyRespins()
	infoPanel._showInfoPanel()
