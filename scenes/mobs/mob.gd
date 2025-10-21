extends CharacterBody3D

var player

func _ready():
	player = get_node("/root/main/PlayerCharacter")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0  # Flatten to horizontal plane
	direction = direction.normalized()  # Re-normalize after zeroing Y
	velocity = direction * 5
	move_and_slide()
