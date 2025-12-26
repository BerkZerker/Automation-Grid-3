extends Control

@onready var address_input: LineEdit = $CenterContainer/VBoxContainer/JoinAddress

func _ready() -> void:
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.connected_to_server.connect(_on_connected_to_server)

func _on_host_button_pressed() -> void:
	NetworkManager.host_game()
	_start_game()

func _on_join_button_pressed() -> void:
	NetworkManager.join_game(address_input.text)

func _on_player_connected(id: int, info: Dictionary) -> void:
	# This is called when WE connect (id 1 for host) or someone else connects
	# But for the client joining, they need 'connected_to_server'
	pass

func _on_connected_to_server() -> void:
	_start_game()

func _start_game() -> void:
	get_tree().change_scene_to_file("res://src/main/game_world.tscn")
