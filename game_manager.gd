extends Node

var mobs_spawned = 0
const MAX_MOBS_PER_WAVE = 5
@onready var player = %PlayerCharacter
@onready var game_over_label = $GameHUD/HudContainer/GameOverLabel
@export var spawn_monsters = true

func _ready() -> void:
	game_over_label.visible=false
	player.player_died.connect(on_player_died)

func spawn_mob():
	var spawn_position = get_valid_spawn_position()
	
	if spawn_position == Vector3.ZERO:
		print("Could not find valid spawn position, skipping this spawn")
		return
	var new_mob = preload("res://scenes/mobs/mob.tscn").instantiate()
	new_mob.global_position = spawn_position
	add_child(new_mob)
	mobs_spawned += 1
	
	# Stop short timer if we've spawned enough mobs
	if mobs_spawned >= MAX_MOBS_PER_WAVE:
		%ShortTimer.stop()
		

func get_valid_spawn_position(max_attempts: int = 10) -> Vector3:
	var space_state = get_viewport().get_world_3d().direct_space_state
	
	for attempt in max_attempts:
		%FollowPath.progress_ratio = randf()
		var test_position = %FollowPath.global_position
		
		var query = PhysicsShapeQueryParameters3D.new()
		var shape = SphereShape3D.new()
		shape.radius = 0.5
		query.shape = shape
		query.transform.origin = test_position
		query.collision_mask = 0xFFFFFFFF
		
		var result = space_state.intersect_shape(query, 32)
		
		if not result.is_empty():
			for collision in result:
				print("  - Hit: ", collision.collider.name)
		
		if result.is_empty():
			return test_position
	
	return Vector3.ZERO
func _on_short_timer_timeout() -> void:
	if spawn_monsters:
		print("Spawned mob")
		spawn_mob()


func _on_long_timer_timeout() -> void:
	# Reset the counter and start spawning
	if spawn_monsters:
		print("NEW WAVE")
		mobs_spawned = 0
		%ShortTimer.start()

func on_player_died():
	get_tree().paused = true
	game_over_label.visible=true
	await get_tree().create_timer(1.5).timeout
	get_tree().paused = false  # Unpause before changing scene
	get_tree().reload_current_scene()	
