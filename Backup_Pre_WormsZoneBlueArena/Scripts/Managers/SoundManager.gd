extends Node

var sound_enabled: bool = true
var music_enabled: bool = true
var vibration_enabled: bool = true
var high_graphics_enabled: bool = true

var _player: AudioStreamPlayer
var _cache: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	add_child(_player)

func set_sound_enabled(v: bool) -> void:
	sound_enabled = v
	if sound_enabled:
		play_click(880.0)

func play_click(base_freq: float = 660.0) -> void:
	if not sound_enabled:
		return
	
	var stream: AudioStreamWAV = _get_or_create_chirp(base_freq)
	_player.stream = stream
	_player.play()

func _get_or_create_chirp(freq: float) -> AudioStreamWAV:
	var key := int(freq)
	if _cache.has(key):
		return _cache[key]
	
	var sample_rate: int = 22050
	var duration: float = 0.16
	var num_samples: int = int(sample_rate * duration)
	var byte_array := PackedByteArray()
	byte_array.resize(num_samples * 2)
	
	var phase: float = 0.0
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		# Exponential ramp from freq to freq * 1.6 over 0.08s
		var current_freq: float
		if t < 0.08:
			current_freq = freq * pow(1.6, t / 0.08)
		else:
			current_freq = freq * 1.6
		
		phase += current_freq * (1.0 / sample_rate)
		var frac: float = phase - floor(phase)
		# Triangle wave: 4 * abs(frac - 0.5) - 1.0
		var wave: float = 4.0 * abs(frac - 0.5) - 1.0
		
		# Exponential decay gain envelope
		var gain: float = 0.08 * exp(-t * 22.0)
		var sample_val: float = clamp(wave * gain, -1.0, 1.0)
		var sample_i16: int = int(sample_val * 32767.0)
		
		byte_array.encode_s16(i * 2, sample_i16)
	
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = byte_array
	
	_cache[key] = wav
	return wav
