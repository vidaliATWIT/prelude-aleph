extends Node
@onready var SoundPlayer: AudioStreamPlayer
var song_index = 0
var main_menu = load("res://sounds/music/mainloop.wav")
var tracklist = {

}
var playlist: AudioStreamPlaylist 

func _ready():
	SoundPlayer = $AudioStreamPlayer
	playlist = AudioStreamPlaylist.new()
	playlist.set_stream_count(5)
	var i = 0
	for song in tracklist.values():
		playlist.set_list_stream(i, song)
		i += 1

func startMusic():
	playlist.set_loop(true)
	playlist.shuffle = true
	SoundPlayer.stream = playlist
	SoundPlayer.play()

func startMainMenuLoop():
	if main_menu:
		# Enable looping for the main menu track before setting it
		if main_menu is AudioStreamWAV:
			var sample_count = main_menu.get_length() * main_menu.mix_rate
			main_menu.loop_end = sample_count
			main_menu.loop_mode = AudioStreamWAV.LOOP_FORWARD
		
		SoundPlayer.stream = main_menu
		SoundPlayer.play()

func stopMusic():
	if SoundPlayer:
		SoundPlayer.stop()
