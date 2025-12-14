extends StaticBody3D

# type
@export var pickup_type: String
@export var min: int
@export var max: int

func _ready():
	pass

func _on_interact_area_body_entered(body: Node3D) -> void:
		if body.is_in_group("player"):
			var rand_val = randi()%max + min
			if pickup_type=="HEALTH":
				print("Picked up heal: ", rand_val)
				body.heal(rand_val)
			elif pickup_type=="AMMO":
				print("Picked up ammo: ", 12)
				body.increase_ammo(12)
			elif pickup_type=="TRAP":
				print("Trapped: ", 12)
				body.stop_movement(rand_val)
			queue_free()


func _on_interact_area_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
