extends Node

var mobs_spawned = 0
const MAX_MOBS_PER_WAVE = 5
var kill_streak = 0
var streak_window = 2.0

@onready var player = %PlayerCharacter
@onready var game_over_label = $GameHUD/HudContainer/GameOverLabel
@onready var score_label = $GameHUD/ScoreContainer/ScoreLabel
@onready var streak_label = $GameHUD/ScoreContainer/KillstreakLabel
@onready var dead_mob_count = 0
@onready var points = 0
@onready var kill_streak_timer = $KillStreakTimer
@export var spawn_monsters = true




func _ready() -> void:
	game_over_label.visible=false
	player.player_died.connect(on_player_died)
	dead_mob_count=0
	points = 0
	kill_streak=0

func spawn_mob():
	var spawn_position = get_valid_spawn_position()
	
	if spawn_position == Vector3.ZERO:
		print("Could not find valid spawn position, skipping this spawn")
		return
	var new_mob = preload("res://scenes/mobs/mob.tscn").instantiate()
	new_mob.global_position = spawn_position
	new_mob.mob_died.connect(_on_mob_died)
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
	
func _on_mob_died():
	dead_mob_count += 1
	kill_streak += 1
	
	kill_streak_timer.start(streak_window)
	
	var multiplier = 1
	var streak_text=""
	if kill_streak >= 5:
		multiplier = 5
		streak_text = "BABABOOEY!"
	elif kill_streak >= 4:
		multiplier = 4
		streak_text = "UBER KILL!"
	elif kill_streak >= 3:
		multiplier = 3
		streak_text = "TRIPLE KILL!"
	elif kill_streak >= 2:
		multiplier = 2
		streak_text = "DOUBLE KILL!"
	points+=10 * multiplier
	score_label.text = "Score: " + str(points)
	if streak_text != "":
		streak_label.text=streak_text
	print("Mobs defeated: ", dead_mob_count)


func _on_kill_streak_timer_timeout() -> void:
	kill_streak = 0
	streak_label.text=""
