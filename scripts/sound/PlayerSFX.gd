extends Node
@onready var FootstepPlayer = $FootstepPlayer
@onready var GunshotPlayer = $GunshotPlayer
@onready var StepTimer = $StepTimer
@onready var HealthPlayer = $HealthPlayer
@onready var DamagePlayer = $DamagePlayer

var sound_dict = {
	"step1": preload("res://sounds/sfx/stepdirt_1.wav"),
	"step2": preload("res://sounds/sfx/stepdirt_2.wav"),
	"gunfire": preload("res://sounds/sfx/pistol_fire_pfire_01.wav"),
	"dryfire": preload("res://sounds/sfx/pistol_dryfire_pdf_01.wav"),
	"reload": preload("res://sounds/sfx/pistol_reload_01.wav"),
	"heal": preload("res://sounds/sfx/heal.ogg"),
	"dmg1": preload("res://sounds/sfx/medpain_01.ogg"),
	"dmg2": preload("res://sounds/sfx/medpain_02.ogg"),
	"dmg3": preload("res://sounds/sfx/medpain_03.ogg"),
	"death": preload("res://sounds/sfx/death_03.ogg"),
	"hit": preload("res://sounds/sfx/tick/hit_05.ogg"),
	"trapped": preload("res://sounds/sfx/dfury_sight.wav"),
}

var step_num = 0
var damage_num = 0

func playShot():
	playSound(GunshotPlayer, "gunfire")
func playDryfire():
	playSound(GunshotPlayer, "dryfire")
func playReload():
	playSound(GunshotPlayer, "reload")
	
func playHeal():
	playSound(HealthPlayer, "heal")
func playTrapped():
	playSound(HealthPlayer,"trapped")
	

# Randomize
func playDamage():
	if DamagePlayer.finished:
		playSound(DamagePlayer, "hit")
	if HealthPlayer.finished:
		var direction = randi()%2
		if direction==0:
			damage_num=(damage_num-1)%3
		else:
			damage_num=(damage_num+1)%3
		if damage_num%3==0:
			playSound(HealthPlayer, 'dmg1')
		elif damage_num%3==1:
			playSound(HealthPlayer, 'dmg2')
		else:
			playSound(HealthPlayer, 'dmg3')
			
func playDeath():
	playSound(HealthPlayer, "death")

func playSteps():
	step_num+=1
	if step_num%2==0:
		playSound(FootstepPlayer, 'step1')
	else:
		playSound(FootstepPlayer,'step2')
	
func playSound(soundPlayer: AudioStreamPlayer, soundName: String):
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
