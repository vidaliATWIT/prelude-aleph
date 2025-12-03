extends Node
@onready var WalkPlayer = $WalkPlayer
@onready var AttackPlayer = $AttackPlayer
@onready var StepTimer = $StepTimer
@onready var HealthPlayer = $HealthPlayer
@onready var Tick = get_parent()

var sound_dict = {
	"step1": preload("res://sounds/sfx/tick/walk1.ogg"),
	"step2": preload("res://sounds/sfx/tick/walk2.ogg"),
	"step3": preload("res://sounds/sfx/tick/walk3.ogg"),
	"step4": preload("res://sounds/sfx/tick/walk4.ogg"),
	"step5":preload("res://sounds/sfx/tick/walk5.ogg"),
	"dmg1": preload("res://sounds/sfx/tick/pain1.ogg"),
	"dmg2": preload("res://sounds/sfx/tick/pain2.ogg"),
	"dmg3": preload("res://sounds/sfx/tick/pain3.ogg"),
	"death1": preload("res://sounds/sfx/tick/death1.ogg"),
	"death2": preload("res://sounds/sfx/tick/death2.ogg"),
	"death3": preload("res://sounds/sfx/tick/death3.ogg"),
}

var step_num = 0
var damage_num = 0
var death_num = 0


# Randomize
func playDamage():
	if AttackPlayer.finished:
		var direction = randi()%2
		if direction==0:
			damage_num=(damage_num-1)%3
		else:
			damage_num=(damage_num+1)%3
		if damage_num%3==0:
			playSound(AttackPlayer, 'dmg1')
		elif damage_num%3==1:
			playSound(AttackPlayer, 'dmg2')
		else:
			playSound(AttackPlayer, 'dmg3')
			
func playDeath():
	damage_num = randi() % 3
	if damage_num==0:
		playSound(HealthPlayer, 'death1')
	elif damage_num==1:
		playSound(HealthPlayer, 'death2')
	else:
		playSound(HealthPlayer, 'death3')

func playSteps():
	step_num+=1
	if step_num%1==0:
		playSound(WalkPlayer, 'step1')
	else:
		playSound(WalkPlayer,'step2')
	
func playSound(soundPlayer: AudioStreamPlayer3D, soundName: String):
	soundPlayer.volume_db = 0.0
	if sound_dict.has(soundName):
		soundPlayer.stream = sound_dict[soundName]
		soundPlayer.play()
		
func startStepTimer():
	if StepTimer.is_stopped():
		StepTimer.start()
	
func stopStepTimer():
	if not StepTimer.is_stopped():
		StepTimer.stop()

func _on_step_timer_timeout() -> void:
	playSteps()
	var step_speed = Tick.speed
	StepTimer.wait_time=(.75)/step_speed
