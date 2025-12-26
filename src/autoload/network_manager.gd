extends Node

signal player_connected(peer_id: int, player_info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

# Player info structure: { "name": "PlayerName" }
var players: Dictionary = {}
var player_info: Dictionary = {"name": "Player"}

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connection_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error != OK:
		push_error("Failed to create server: %s" % error)
		return
	
	multiplayer.multiplayer_peer = peer
	players[1] = player_info # Register host as player 1
	player_connected.emit(1, player_info)
	print("Server started on port %d" % PORT)

func join_game(address: String = "") -> void:
	if address.is_empty():
		address = DEFAULT_SERVER_IP
		
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error != OK:
		push_error("Failed to create client: %s" % error)
		return
		
	multiplayer.multiplayer_peer = peer
	print("Joining server at %s:%d..." % [address, PORT])

func _on_peer_connected(id: int) -> void:
	print("Peer connected: %d" % id)
	# Send our info to the new player
	_register_player.rpc_id(id, player_info)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: %d" % id)
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok() -> void:
	print("Successfully connected to server")
	# Register ourselves with the server (and by extension other clients if server relays)
	_register_player.rpc_id(1, player_info)

func _on_connection_fail() -> void:
	push_error("Connection failed")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected() -> void:
	print("Server disconnected")
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

@rpc("any_peer", "reliable")
func _register_player(info: Dictionary) -> void:
	var id = multiplayer.get_remote_sender_id()
	players[id] = info
	player_connected.emit(id, info)
	print("Registered player %d: %s" % [id, info])
