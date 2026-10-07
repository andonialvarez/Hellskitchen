extends Node
## Sonido (autoload "Audio"). Efectos sintetizados en assets/sfx/.

var muted := false
var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _sfx := {}
var _hit_cd := 0.0
var _ambient: AudioStreamPlayer
var _ambient_stream: AudioStream


func _ready() -> void:
	for n in ["sizzle", "soul", "arrive", "gong", "pact", "relic", "hit", "dispatch", "open", "nom"]:
		var p := "res://assets/sfx/%s.wav" % n
		if ResourceLoader.exists(p):
			_sfx[n] = load(p)
	var lasthit_path := "res://assets/sfx/lasthit.mp3"
	if ResourceLoader.exists(lasthit_path):
		_sfx["lasthit"] = load(lasthit_path)
	for i in 12:
		var pl := AudioStreamPlayer.new()
		add_child(pl)
		_players.append(pl)

	_ambient = AudioStreamPlayer.new()
	add_child(_ambient)
	var amb_path := "res://assets/sfx/ambient_fire.wav"
	if ResourceLoader.exists(amb_path):
		_ambient_stream = load(amb_path)
		_ambient.stream = _ambient_stream
		_ambient.volume_db = -15.0
		_ambient.finished.connect(func() -> void:
			if not muted:
				_ambient.play())

	if has_node("/root/Game"):
		var g := get_node("/root/Game")
		g.demon_served.connect(func(_d):
			play("soul", 0.16)
			play("nom", 0.18))
		g.demon_dispatched.connect(func(_d): play("dispatch", 0.1))
		g.damaged.connect(func(_a, _t):
			if g.hp <= 0.0:
				play("lasthit")
			else:
				play("hit", 0.2))
		g.shift_started.connect(func(): play("arrive"))
		g.shift_ended.connect(func(r, _s, _n):
			if r != "muerte":
				play("gong"))
		g.pact_signed.connect(func(_g): play("pact"))
		g.reward_opened.connect(func(_i, loot):
			play("open", 0.05)
			if not loot.get("items", []).is_empty():
				play("relic"))
	_load_settings()
	_update_ambient()


func _update_ambient() -> void:
	if _ambient_stream == null:
		return
	if muted:
		_ambient.stop()
	elif not _ambient.playing:
		_ambient.play()


func _process(delta: float) -> void:
	if _hit_cd > 0.0:
		_hit_cd -= delta


func play(id: String, pitch_var := 0.0) -> void:
	if muted or not _sfx.has(id):
		return
	if id == "hit":
		if _hit_cd > 0.0:
			return
		_hit_cd = 0.18
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _sfx[id]
	p.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
	p.play()


func set_muted(v: bool) -> void:
	muted = v
	_update_ambient()
	var f := FileAccess.open("user://settings.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"muted": muted}))
		f.close()


func _load_settings() -> void:
	if not FileAccess.file_exists("user://settings.json"):
		return
	var f := FileAccess.open("user://settings.json", FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(d) == TYPE_DICTIONARY:
		muted = bool(d.get("muted", false))
