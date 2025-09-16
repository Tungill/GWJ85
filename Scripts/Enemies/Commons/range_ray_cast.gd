extends RayCast2D
class_name RangeRayCast

#signal entered(new_collider: Object) # Not used?
#signal exited(old_collider: Object) # Not used?
signal collision_begin(new_collider: Object, emitter: RangeRayCast)
signal collision_stop(old_collider: Object, emitter: RangeRayCast)
#signal collision_change(old_collider: Object, new_collider: Object)  # Not used?

var old_collider: Object


func _physics_process(_delta: float) -> void:
	var new_collider: Object = null
	if is_colliding():
		new_collider = get_collider()
	
	if new_collider == old_collider:
		return
	
	if old_collider == null:
		collision_begin.emit(new_collider, self)
		#entered.emit(new_collider)
	elif new_collider == null:
		collision_stop.emit(old_collider, self)
		#exited.emit(old_collider)
	#else:
		#collision_change.emit(old_collider, new_collider)
		#exited.emit(old_collider)
		#entered.emit(new_collider)
	
	old_collider = new_collider
