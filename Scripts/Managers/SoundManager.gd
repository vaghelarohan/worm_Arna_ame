extends Node

signal music_toggled(enabled: bool)
signal sound_toggled(enabled: bool)

var sound_enabled: bool = true
var music_enabled: bool = true
var vibration_enabled: bool = true
var high_graphics_enabled: bool = true

var music_volume: float = 0.8:
	set(v):
		music_volume = clamp(v, 0.0, 1.0)
		_update_volumes()

var sfx_volume: float = 0.8:
	set(v):
		sfx_volume = clamp(v, 0.0, 1.0)
		_update_volumes()

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0
var _cache: Dictionary = {}
var _current_bgm_track: String = ""

const SAMPLE_RATE: int = 22050
const AUDIO_DIR: String = "res://Assets/Audio/"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Dedicated Music Player
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)
	
	# Pool of 8 SFX Players for polyphonic sound playback
	for i in range(8):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)
	
	_update_volumes()
	_ensure_audio_files()

func _update_volumes() -> void:
	if _music_player:
		_music_player.volume_db = linear_to_db(music_volume) if (music_enabled and music_volume > 0.001) else -80.0
	for p in _sfx_players:
		if p:
			p.volume_db = linear_to_db(sfx_volume) if (sound_enabled and sfx_volume > 0.001) else -80.0

func set_sound_enabled(v: bool) -> void:
	sound_enabled = v
	_update_volumes()
	if sound_enabled:
		play_click(880.0)
	sound_toggled.emit(sound_enabled)
	if GameManager:
		GameManager.save_game()

func set_music_enabled(v: bool) -> void:
	music_enabled = v
	_update_volumes()
	if music_enabled:
		if not _current_bgm_track.is_empty():
			play_bgm(_current_bgm_track)
	else:
		if _music_player and _music_player.playing:
			_music_player.stop()
	music_toggled.emit(music_enabled)
	if GameManager:
		GameManager.save_game()

# ==========================================
# PUBLIC SOUND PLAYBACK METHODS
# ==========================================

func play_bgm(track_name: String = "gameplay") -> void:
	_current_bgm_track = track_name
	if not music_enabled:
		return
	
	var stream: AudioStreamWAV = _get_or_create_bgm(track_name)
	if _music_player.stream != stream or not _music_player.playing:
		_music_player.stream = stream
		_music_player.play()

func stop_bgm() -> void:
	if _music_player.playing:
		_music_player.stop()

func play_eat(is_treat: bool = false) -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_eat(is_treat)
	_play_sfx(stream)

func play_grow() -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_grow()
	_play_sfx(stream)

func play_boost(active: bool) -> void:
	if not sound_enabled or not active:
		return
	var stream: AudioStreamWAV = _get_or_create_boost()
	_play_sfx(stream)

func play_powerup() -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_powerup()
	_play_sfx(stream)

func play_powerup_expire() -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_powerup_expire()
	_play_sfx(stream)

func play_kill() -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_kill()
	_play_sfx(stream)

func play_coin() -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_coin()
	_play_sfx(stream)

func play_game_over() -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_game_over()
	_play_sfx(stream)

func play_click(base_freq: float = 660.0) -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_chirp(base_freq)
	_play_sfx(stream)

func play_popup_open() -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_popup(true)
	_play_sfx(stream)

func play_popup_close() -> void:
	if not sound_enabled:
		return
	var stream: AudioStreamWAV = _get_or_create_popup(false)
	_play_sfx(stream)

func play_wheel_tick() -> void:
	if not sound_enabled:
		return
	play_click(920.0)

func _play_sfx(stream: AudioStream) -> void:
	if not sound_enabled or _sfx_players.is_empty():
		return
	var p: AudioStreamPlayer = _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	p.stream = stream
	p.play()

# ==========================================
# PROCEDURAL WAV SOUND SYNTHESIS
# ==========================================

func _ensure_audio_files() -> void:
	# Pre-cache commonly used sound effects and save files
	_get_or_create_eat(false)
	_get_or_create_eat(true)
	_get_or_create_grow()
	_get_or_create_boost()
	_get_or_create_powerup()
	_get_or_create_kill()
	_get_or_create_coin()
	_get_or_create_game_over()
	_get_or_create_chirp(660.0)
	_get_or_create_bgm("menu")
	_get_or_create_bgm("gameplay")

func _get_or_create_eat(is_treat: bool) -> AudioStreamWAV:
	var key: String = "eat_treat" if is_treat else "eat"
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.12 if is_treat else 0.08
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var f0: float = 520.0 if is_treat else 420.0
	var f1: float = 980.0 if is_treat else 760.0
	var phase: float = 0.0
	
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		var freq: float = lerp(f0, f1, t / dur)
		phase += freq / float(SAMPLE_RATE)
		var frac: float = phase - floor(phase)
		var wave: float = sin(phase * TAU) + 0.3 * (4.0 * abs(frac - 0.5) - 1.0)
		var env: float = (1.0 - t / dur) * exp(-t * 28.0)
		var s: int = int(clamp(wave * env * 0.18, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	_save_wav_file(key + ".wav", bytes, false)
	return wav

func _get_or_create_grow() -> AudioStreamWAV:
	var key := "grow"
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.28
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var phase: float = 0.0
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		# Ascending triad arpeggio
		var freq: float = 330.0 + sin(t * 30.0) * 80.0 + t * 450.0
		phase += freq / float(SAMPLE_RATE)
		var wave: float = sin(phase * TAU)
		var env: float = (1.0 - t / dur) * 0.16
		var s: int = int(clamp(wave * env, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	_save_wav_file("grow.wav", bytes, false)
	return wav

func _get_or_create_boost() -> AudioStreamWAV:
	var key := "boost"
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.22
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var phase: float = 0.0
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		var freq: float = 240.0 + t * 360.0
		phase += freq / float(SAMPLE_RATE)
		# Saturated noise-tinged whoosh
		var wave: float = sin(phase * TAU) + randf_range(-0.25, 0.25)
		var env: float = sin(t / dur * PI) * 0.15
		var s: int = int(clamp(wave * env, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	_save_wav_file("boost.wav", bytes, false)
	return wav

func _get_or_create_powerup() -> AudioStreamWAV:
	var key := "powerup"
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.38
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var phase_a: float = 0.0
	var phase_b: float = 0.0
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		var step: int = int(t * 12.0)
		var notes := [523.25, 659.25, 783.99, 1046.5] # C5, E5, G5, C6
		var freq: float = notes[clamp(step, 0, 3)]
		phase_a += freq / float(SAMPLE_RATE)
		phase_b += (freq * 1.5) / float(SAMPLE_RATE)
		var wave: float = sin(phase_a * TAU) * 0.7 + sin(phase_b * TAU) * 0.3
		var env: float = (1.0 - t / dur) * 0.18
		var s: int = int(clamp(wave * env, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	_save_wav_file("powerup.wav", bytes, false)
	return wav

func _get_or_create_powerup_expire() -> AudioStreamWAV:
	var key := "powerup_expire"
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.25
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var phase: float = 0.0
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		var freq: float = 680.0 - t * 320.0
		phase += freq / float(SAMPLE_RATE)
		var wave: float = sin(phase * TAU)
		var env: float = (1.0 - t / dur) * 0.12
		var s: int = int(clamp(wave * env, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	_save_wav_file("powerup_expire.wav", bytes, false)
	return wav

func _get_or_create_kill() -> AudioStreamWAV:
	var key := "kill"
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.45
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var phase1: float = 0.0
	var phase2: float = 0.0
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		# Triumphant fanfare dual harmony
		var f1: float = 440.0 if t < 0.15 else (554.37 if t < 0.28 else 659.25)
		var f2: float = f1 * 1.5
		phase1 += f1 / float(SAMPLE_RATE)
		phase2 += f2 / float(SAMPLE_RATE)
		var wave: float = sin(phase1 * TAU) * 0.6 + sin(phase2 * TAU) * 0.4
		var env: float = (1.0 - t / dur) * 0.22
		var s: int = int(clamp(wave * env, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	_save_wav_file("kill.wav", bytes, false)
	return wav

func _get_or_create_coin() -> AudioStreamWAV:
	var key := "coin"
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.24
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var phase: float = 0.0
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		var freq: float = 987.77 if t < 0.08 else 1318.51 # B5 then E6
		phase += freq / float(SAMPLE_RATE)
		var wave: float = sin(phase * TAU)
		var env: float = exp(-t * 14.0) * 0.20
		var s: int = int(clamp(wave * env, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	_save_wav_file("coin.wav", bytes, false)
	return wav

func _get_or_create_game_over() -> AudioStreamWAV:
	var key := "game_over"
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.75
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var phase: float = 0.0
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		var notes := [440.0, 415.3, 392.0, 349.2] # A4, G#4, G4, F4
		var idx: int = clamp(int(t / 0.18), 0, 3)
		var freq: float = notes[idx]
		phase += freq / float(SAMPLE_RATE)
		var wave: float = sin(phase * TAU) + 0.25 * sin(phase * 2.0 * TAU)
		var env: float = (1.0 - t / dur) * 0.22
		var s: int = int(clamp(wave * env, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	_save_wav_file("game_over.wav", bytes, false)
	return wav

func _get_or_create_popup(is_open: bool) -> AudioStreamWAV:
	var key: String = "popup_open" if is_open else "popup_close"
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.10
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var f0: float = 300.0 if is_open else 600.0
	var f1: float = 600.0 if is_open else 300.0
	var phase: float = 0.0
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		var freq: float = lerp(f0, f1, t / dur)
		phase += freq / float(SAMPLE_RATE)
		var wave: float = sin(phase * TAU)
		var env: float = sin(t / dur * PI) * 0.12
		var s: int = int(clamp(wave * env, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	_save_wav_file(key + ".wav", bytes, false)
	return wav

func _get_or_create_chirp(freq: float) -> AudioStreamWAV:
	var key := "chirp_%d" % int(freq)
	if _cache.has(key): return _cache[key]
	
	var dur: float = 0.14
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	var phase: float = 0.0
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		var current_freq: float = freq * (pow(1.5, t / 0.07) if t < 0.07 else 1.5)
		phase += current_freq / float(SAMPLE_RATE)
		var frac: float = phase - floor(phase)
		var wave: float = 4.0 * abs(frac - 0.5) - 1.0
		var gain: float = 0.10 * exp(-t * 22.0)
		var s: int = int(clamp(wave * gain, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s)
	
	var wav := _create_wav(bytes, false)
	_cache[key] = wav
	return wav

func _get_or_create_bgm(track_name: String) -> AudioStreamWAV:
	var key := "bgm_" + track_name
	if _cache.has(key): return _cache[key]
	
	# Generate a looping 4-bar upbeat arcade background music loop (4.8 seconds @ 100 BPM)
	var dur: float = 4.8
	var num: int = int(SAMPLE_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(num * 2)
	
	# Melodic note sequence (Pentatonic Arcade Lead & Bass)
	var melody_notes: Array = [
		261.63, 293.66, 329.63, 392.0, # C4, D4, E4, G4
		440.0, 523.25, 440.0, 392.0,   # A4, C5, A4, G4
		329.63, 392.0, 440.0, 523.25,  # E4, G4, A4, C5
		587.33, 523.25, 440.0, 392.0   # D5, C5, A4, G4
	] if track_name == "gameplay" else [
		329.63, 392.0, 440.0, 392.0,
		329.63, 293.66, 261.63, 293.66,
		329.63, 392.0, 440.0, 523.25,
		440.0, 392.0, 329.63, 261.63
	]
	
	var bass_notes: Array = [
		130.81, 130.81, 164.81, 196.0, # C3, C3, E3, G3
		110.0, 110.0, 146.83, 164.81,  # A2, A2, D3, E3
		130.81, 130.81, 164.81, 196.0,
		98.0, 98.0, 130.81, 146.83     # G2, G2, C3, D3
	]
	
	var phase_lead: float = 0.0
	var phase_bass: float = 0.0
	var step_dur: float = dur / 16.0
	
	for i in range(num):
		var t: float = float(i) / float(SAMPLE_RATE)
		var step: int = clamp(int(t / step_dur), 0, 15)
		var sub_t: float = fmod(t, step_dur)
		
		# Lead Melody Synth (smooth plucky sine)
		var l_freq: float = melody_notes[step]
		phase_lead += l_freq / float(SAMPLE_RATE)
		var lead_wave: float = sin(phase_lead * TAU)
		var lead_env: float = exp(-sub_t * 9.0) * 0.08
		
		# Bass Synth (warm triangle)
		var b_freq: float = bass_notes[step]
		phase_bass += b_freq / float(SAMPLE_RATE)
		var b_frac: float = phase_bass - floor(phase_bass)
		var bass_wave: float = 4.0 * abs(b_frac - 0.5) - 1.0
		var bass_env: float = exp(-sub_t * 6.0) * 0.07
		
		# Gentle rhythmic percussion click on eighth notes
		var click_t: float = fmod(t, step_dur * 0.5)
		var perc: float = (randf_range(-1.0, 1.0) * exp(-click_t * 45.0) * 0.035) if click_t < 0.06 else 0.0
		
		var sample: float = clamp(lead_wave * lead_env + bass_wave * bass_env + perc, -1.0, 1.0)
		bytes.encode_s16(i * 2, int(sample * 32767.0))
	
	var wav := _create_wav(bytes, true)
	_cache[key] = wav
	_save_wav_file(key + ".wav", bytes, true)
	return wav

func _create_wav(bytes: PackedByteArray, loop: bool) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = bytes.size() / 2
	return wav

func _save_wav_file(filename: String, pcm_data: PackedByteArray, loop: bool) -> void:
	var path: String = AUDIO_DIR + filename
	if FileAccess.file_exists(path):
		return
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return
	
	# Write standard 44-byte canonical RIFF WAV header
	var data_size: int = pcm_data.size()
	var file_size: int = 36 + data_size
	
	file.store_string("RIFF")
	file.store_32(file_size)
	file.store_string("WAVE")
	file.store_string("fmt ")
	file.store_32(16)            # Subchunk1Size for PCM
	file.store_16(1)             # AudioFormat 1 = PCM
	file.store_16(1)             # NumChannels 1 = Mono
	file.store_32(SAMPLE_RATE)   # SampleRate
	file.store_32(SAMPLE_RATE * 2) # ByteRate
	file.store_16(2)             # BlockAlign
	file.store_16(16)            # BitsPerSample
	file.store_string("data")
	file.store_32(data_size)
	file.store_buffer(pcm_data)
	file.close()
