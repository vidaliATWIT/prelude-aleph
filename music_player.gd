extends Node
@onready var SoundPlayer: AudioStreamPlayer
var song_index = 0
var main_menu = load("res://sounds/music/mainloop.wav")
var tracklist = {
	"track1": preload("res://sounds/music/Cave Music.mp3"),
}
var playlist: AudioStreamPlaylist 

func _ready():
	SoundPlayer = $AudioStreamPlayer
	playlist = AudioStreamPlaylist.new()
	playlist.set_stream_count(1)
	var i = 0
	for song in tracklist.values():
		playlist.set_list_stream(i, song)
		i += 1
	startMusic()

func startMusic():
	playlist.set_loop(true)
	playlist.shuffle = false
	SoundPlayer.stream = playlist
	SoundPlayer.play()

func stopMusic():
	if SoundPlayer:
		SoundPlayer.stop()
