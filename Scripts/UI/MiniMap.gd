extends Panel

var engine
const S: float = 180.0
const WORLD: float = 3600.0

func _process(_delta: float) -> void:
	$Radar.queue_redraw()
