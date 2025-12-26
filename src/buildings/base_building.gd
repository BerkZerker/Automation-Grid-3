extends Node3D

@export var data: Resource # BuildingData
var inventory: Inventory
var timer: Timer

@onready var label = $Label3D

func _ready():
	inventory = Inventory.new()
	add_child(inventory)
	
	if multiplayer.is_server():
		timer = Timer.new()
		timer.wait_time = 1.0
		timer.autostart = true
		timer.timeout.connect(_on_tick)
		add_child(timer)

func _on_tick():
	if not multiplayer.is_server():
		return
		
	inventory.add_item("iron_ore", 1)
	_update_label()

@rpc("authority", "call_local", "reliable")
func _update_label_rpc(total: int):
	label.text = str(total)

func _update_label():
	var total = 0
	for slot in inventory.slots:
		total += slot.count
	_update_label_rpc.rpc(total)
