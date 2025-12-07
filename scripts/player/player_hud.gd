extends Control
#extends Control

@onready var hp_label = $HudContainer/HPLabel
@onready var ammo_label = $HudContainer/AmmoLabel
@onready var player = %PlayerCharacter

func _ready():
	update_hud()
	# Connect to player's health changed signal if it exists
	if player.has_signal("health_changed"):
		player.health_changed.connect(update_hud)
		player.ammo_changed.connect(update_hud)

func _process(_delta):
	# Fallback: Update every frame if no signal exists
	pass

func update_hud():
	if player and "hp" in player:
		hp_label.text = "HP: " + str(player.hp) + "/" + str(player.max_hp)
	if player and "ammo" in player:
		ammo_label.text = "AMMO: " + str(player.ammo) + "/" + str(player.max_ammo)
