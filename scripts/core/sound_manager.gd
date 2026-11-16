extends Node

# Procedural Sound Manager for Echoes of Astra
# Synthesizes sound effects directly using AudioStreamGenerator

var sample_rate: float = 22050.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _play_synth(generator_callable: Callable, duration: float, volume_db: float = 0.0) -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.volume_db = volume_db
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = duration + 0.1
	player.stream = generator
	player.play()
	
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	var frames_to_fill = int(duration * sample_rate)
	generator_callable.call(playback, frames_to_fill)
	
	# Clean up after playback
	get_tree().create_timer(duration + 0.2).timeout.connect(func():
		player.stop()
		player.queue_free()
	)

func play_bell() -> void:
	# Resonant bell sound with harmonics
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		var freq1 = 880.0
		var freq2 = 1320.0
		var freq3 = 1760.0
		for i in range(frames):
			var t = float(i) / sample_rate
			var env = exp(-t * 2.8) # Exponential decay
			var wave = (sin(TAU * freq1 * t) * 0.5 + sin(TAU * freq2 * t) * 0.3 + sin(TAU * freq3 * t) * 0.2) * env
			playback.push_frame(Vector2(wave, wave) * 0.35)
	, 1.8, -2.0)

func play_crystal() -> void:
	# High-pitched celestial chime
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		var freq = 1200.0
		for i in range(frames):
			var t = float(i) / sample_rate
			var env = exp(-t * 4.0)
			var wave = (sin(TAU * freq * t) * 0.7 + sin(TAU * (freq * 1.5) * t) * 0.3) * env
			playback.push_frame(Vector2(wave, wave) * 0.25)
	, 1.0, -4.0)

func play_dialogue_blip() -> void:
	# Subtle short typewriter blip
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		for i in range(frames):
			var t = float(i) / sample_rate
			var env = 1.0 - (float(i) / float(frames))
			var wave = sin(TAU * 480.0 * t) * env
			playback.push_frame(Vector2(wave, wave) * 0.12)
	, 0.04, -8.0)

func play_memory() -> void:
	# Ethereal sweeping chord for memory flashback
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		var f1 = 440.0
		var f2 = 554.37 # C#
		var f3 = 659.25 # E
		for i in range(frames):
			var t = float(i) / sample_rate
			var env = sin(PI * (t / 2.5)) # smooth swell and fade
			var wave = (sin(TAU * f1 * t) + sin(TAU * f2 * t) + sin(TAU * f3 * t)) * 0.33 * env
			playback.push_frame(Vector2(wave, wave) * 0.3)
	, 2.5, -2.0)

func play_select() -> void:
	# UI click sound
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		for i in range(frames):
			var t = float(i) / sample_rate
			var wave = sin(TAU * (600.0 + t * 400.0) * t) * (1.0 - t / 0.08)
			playback.push_frame(Vector2(wave, wave) * 0.2)
	, 0.08, -5.0)

func play_puzzle_success() -> void:
	# Success jingle
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		for i in range(frames):
			var t = float(i) / sample_rate
			var freq = 523.25 # C5
			if t > 0.15: freq = 659.25 # E5
			if t > 0.30: freq = 783.99 # G5
			if t > 0.45: freq = 1046.50 # C6
			var env = exp(-(t - int(t / 0.15) * 0.15) * 4.0)
			var wave = sin(TAU * freq * t) * env
			playback.push_frame(Vector2(wave, wave) * 0.25)
	, 0.8, -3.0)

func play_sword_slash() -> void:
	# Swoosh / slash sound effect
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		for i in range(frames):
			var t = float(i) / sample_rate
			var freq = 600.0 - (t * 2400.0)
			if freq < 120.0: freq = 120.0
			var env = (1.0 - (float(i) / float(frames))) * sin(PI * (t / 0.16))
			var noise = (randf() * 2.0 - 1.0) * 0.4
			var wave = (sin(TAU * freq * t) * 0.6 + noise) * env
			playback.push_frame(Vector2(wave, wave) * 0.3)
	, 0.16, -4.0)

func play_jump() -> void:
	# Leaping chirp sound
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		for i in range(frames):
			var t = float(i) / sample_rate
			var freq = 320.0 + (t * 600.0)
			var env = 1.0 - (float(i) / float(frames))
			var wave = sin(TAU * freq * t) * env
			playback.push_frame(Vector2(wave, wave) * 0.22)
	, 0.18, -6.0)

func play_hit() -> void:
	# Impact crunch
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		for i in range(frames):
			var t = float(i) / sample_rate
			var env = exp(-t * 25.0)
			var noise = (randf() * 2.0 - 1.0) * 0.5
			var wave = (sin(TAU * 160.0 * t) * 0.5 + noise) * env
			playback.push_frame(Vector2(wave, wave) * 0.35)
	, 0.15, -3.0)

func play_player_hurt() -> void:
	# Low dull hurt thud
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		for i in range(frames):
			var t = float(i) / sample_rate
			var env = exp(-t * 12.0)
			var wave = sin(TAU * 120.0 * t) * env
			playback.push_frame(Vector2(wave, wave) * 0.4)
	, 0.25, -2.0)

func play_step_puzzle() -> void:
	# Heavy stone switch click
	_play_synth(func(playback: AudioStreamGeneratorPlayback, frames: int):
		for i in range(frames):
			var t = float(i) / sample_rate
			var env = exp(-t * 18.0)
			var wave = sin(TAU * 260.0 * t) * env
			playback.push_frame(Vector2(wave, wave) * 0.3)
	, 0.2, -4.0)


