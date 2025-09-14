extends Camera2D

const TIME_IN_SECONDS: int = 2
const ZOOM_OUT_VALUE: float = 0.2

# TODO The camera must be centered on the PlayerCharacter. Probably as a child.

func _ready() -> void:
	# TODO Set the Camera.limit_* using reference to the Background.size.
	
	#region DEBUG Creates a timer to trigger _zoom_out() every x scd.
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = TIME_IN_SECONDS
	timer.timeout.connect(_zoom_out)
	timer.start()
	#endregion

func _zoom_out() -> void:
	var vector2: Vector2 = Vector2(ZOOM_OUT_VALUE, ZOOM_OUT_VALUE)
	var target_zoom: Vector2 = self.zoom - vector2
	# WARNING This condition doesn't work if vector2.x & .y are not equal.
	if target_zoom.is_zero_approx():
		return
	var tween: Tween = create_tween()
	tween.tween_property(self, "zoom", target_zoom, 1)
	# NOTE Camera zoom value is relative to the size of limit_*. 
	# Zoom 0.1 for Limit 5000 will have a different value than Zoom 0.1 for Limit 1500.
