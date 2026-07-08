extends Node2D

@export var game_scene_path: String = "res://main.tscn"

@onready var start_button: TextureButton = $MainMenuUI/VBoxContainer/StartButton
@onready var quit_button: TextureButton = $MainMenuUI/VBoxContainer/QuitButton
@onready var sfx_player: Node = $SFXPlayer
@onready var loading_icon: TextureRect = $loadingIcon

func _ready():
	# Connect button signals
	# music_player.startMainMenuLoop()
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
	loading_icon.visible=true
	sfx_player.playClick1()
	print("Starting game...")
	await get_tree().create_timer(0.1).timeout
	# Change to game scene
	get_tree().change_scene_to_file(game_scene_path)

func _on_quit_button_pressed():
	sfx_player.playClick1()
	print("Quitting game...")
	get_tree().quit()

# Optional: Function to set a different game scene path
func set_game_scene(scene_path: String):
	game_scene_path = scene_path
