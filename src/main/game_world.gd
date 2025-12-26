extends Node3D

@onready var players_node = $Players
@onready var buildings_node = $Buildings
@onready var spawner = $MultiplayerSpawner
@onready var building_spawner = $BuildingSpawner

const PLAYER_SCENE = preload("uid://55ag32rqaqfg")
const BUILDING_SCENE = preload("uid://dw8v8qk51lxgg")

func _ready():
	# We need to add the player scene to the spawner's list via code if not in editor
	# But typically spawner needs it in resource.
	# We will try to rely on the .tscn file having it, or add it here.
	spawner.add_spawnable_scene("uid://55ag32rqaqfg")
	building_spawner.add_spawnable_scene("uid://dw8v8qk51lxgg")

	if multiplayer.is_server():
		# Spawn existing players (host)
		for peer_id in NetworkManager.players:
			add_player(peer_id)
		
		# Listen for new ones
		NetworkManager.player_connected.connect(add_player)
		NetworkManager.player_disconnected.connect(remove_player)

@rpc("any_peer", "reliable")
func request_place_building(pos: Vector3i, _type: String):
	# Server only logic
	if not multiplayer.is_server():
		return
	
	# Validate position (basic check: is it already occupied?)
	# For MVP, we just check if a node exists at that grid coord name
	var node_name = "B_%d_%d_%d" % [pos.x, pos.y, pos.z]
	if buildings_node.has_node(node_name):
		print("Position occupied: %s" % pos)
		return

	# Spawn
	var b = BUILDING_SCENE.instantiate()
	b.name = node_name
	b.position = Vector3(pos.x, pos.y, pos.z)
	buildings_node.add_child(b, true)
	print("Placed building at %s" % pos)

func add_player(peer_id: int, _info: Dictionary = {}):
	if players_node.has_node(str(peer_id)):
		return
		
	var p = PLAYER_SCENE.instantiate()
	p.name = str(peer_id)
	players_node.add_child(p, true) # true = force readable name
	print("Spawned player %d" % peer_id)

func remove_player(peer_id: int):
	if players_node.has_node(str(peer_id)):
		players_node.get_node(str(peer_id)).queue_free()
		print("Removed player %d" % peer_id)
