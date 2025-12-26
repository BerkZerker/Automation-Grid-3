extends Node3D

@export var view_distance: int = 4
@export var chunk_scene: PackedScene = preload("uid://cwm2g5cox1b2q")

var loaded_chunks: Dictionary = {} # Vector2i -> Chunk Node
var generator: TerrainGenerator
var player: Node3D

func _ready():
	generator = TerrainGenerator.new()
	generator.setup(12345) # Static seed for now, or sync it

func _process(_delta):
	# Find local player
	if not player:
		# In multiplayer, we look for the player that is the authority?
		# Or rather, the viewport's camera?
		# For this client, we look for the player with the name == my peer id
		var id = multiplayer.get_unique_id()
		var p_node = get_node_or_null("../Players/" + str(id))
		if p_node:
			player = p_node
	
	if player:
		_update_chunks()

func _update_chunks():
	var px = int(player.position.x / 16.0)
	var pz = int(player.position.z / 16.0)
	
	for x in range(px - view_distance, px + view_distance + 1):
		for z in range(pz - view_distance, pz + view_distance + 1):
			var key = Vector2i(x, z)
			if not loaded_chunks.has(key):
				_load_chunk(key)

func _load_chunk(key: Vector2i):
	var chunk = chunk_scene.instantiate()
	add_child(chunk)
	chunk.init(key.x, key.y, generator)
	
	# Defer generation to spread load
	chunk.generate()
	loaded_chunks[key] = chunk
