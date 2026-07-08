extends Node
@onready var SFXPlayer = $AudioStreamPlayer

var sound_dict = {
	"click1": preload("res://sounds/sfx/gui_sfx/click.wav")
}

func playClick1():
	playSound(SFXPlayer, "click1")
	
func playSound(soundPlayer: AudioStreamPlayer, soundName: String):
	soundPlayer.volume_db = 0.0
	if sound_dict.has(soundName):
		soundPlayer.stream = sound_dict[soundName]
		soundPlayer.play()
		
