extends State
class_name AttackState

@export_category("Parameters")
## WARNING: Range should be smaller than the player's left/right hitbox. 
## If not, the player cannot attack them from his static position.
@export var attack_range: float = 100.0
@export var cast_time: float = 1.0
@export var damage: int = 1
@export var cooldown_time: float = 1.0
@export_category("Essentials")
@export var cast_timer: Timer
@export var cooldown_timer: Timer
@export var collision: CollisionShape2D
@export_category("Animations")
@export var cast_texture: Texture2D
@export var attack_texture: Texture2D
@export var attack_duration: float = 0.1
@export var cooldown_texture: Texture2D

var attack_count: int = 0
var range_size: float

func _ready() -> void:
	cast_timer.timeout.connect(_attack)
	cooldown_timer.timeout.connect(_on_cast_attack_begin)
	range_size = (collision.shape.get_rect().size.x /2) + attack_range


func _on_enter() -> void:
	_on_cast_attack_begin()


func _on_cast_attack_begin() -> void:
	_change_texture(cast_texture)
	cast_timer.start(cast_time)
	# TODO Change visual asset to cast sprite


func _attack() -> void:
	_change_texture(attack_texture)
	# NOTE Using EventBus because using the raycast collider creates a new dependency.
	EventBus.enemy.attack_hit_player.emit(damage)
	attack_count += 1
	
	await get_tree().create_timer(attack_duration).timeout
	_on_cooldown_begin()


func _on_cooldown_begin() -> void:
	_change_texture(cooldown_texture)
	cooldown_timer.start(cooldown_time)


func _on_exit() -> void:
	cast_timer.stop()
	cooldown_timer.stop()


func _change_texture(new_texture: Texture2D) ->void:
	if sprite.texture is not CanvasTexture:
		push_error("Mob's Sprite2D is not of type CanvasTexture.")
	var texture: CanvasTexture = sprite.texture as CanvasTexture
	texture.diffuse_texture = new_texture
