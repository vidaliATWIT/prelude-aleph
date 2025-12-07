extends CharacterBody3D

var player
var hp = 5
var attack_range
var player_in_range=false
var damage=2

var can_attack = true
var attack_cooldown = 1.0
var min_speed = 3.0
var speed = min_speed
var max_speed = 8.0
var max_distance = 20.0

@onready var SFXPlayer = $TickSFX

signal mob_died

func _ready():
	player = get_node("/root/main/PlayerCharacter")
	attack_range = $AttackRange
	attack_range.body_entered.connect(_on_body_entered_attack_range)
	attack_range.body_exited.connect(_on_body_exited_attack_range)

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0  # Flatten to horizontal plane
	direction = direction.normalized()  # Re-normalize after zeroing Y
	var distance = global_position.distance_to(player.global_position)
	var normalized_dist = clamp(distance / max_distance, 0.0, 1.0)
	speed = lerp(max_speed, min_speed, normalized_dist * normalized_dist)  # Square for curve
	velocity = direction * speed
	if (velocity.length()>0):
		SFXPlayer.startStepTimer()
	else:
		SFXPlayer.stopStepTimer()
		
	move_and_slide()
	attack() 

func _on_hit(damage):
	print("_ONHIT")
	hp-=damage
	if hp<=0:
		SFXPlayer.playDeath()
		mob_died.emit()
		queue_free()
	else:
		SFXPlayer.playDamage()
		

# Todo: Make sure you can't hit if behind a wall

func attack():
	if player_in_range and can_attack:
		var bodies = attack_range.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				#SFXPlayer.playDamage()
				body.take_damage(damage)
		
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _on_body_entered_attack_range(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited_attack_range(body):
	if body.is_in_group("player"):
		player_in_range = false
