extends State
class_name AttackState

@export_category("Parameters")
## NOTE: the range is calculated from the center of the parent. Take the parent [param size] into acount.
@export var attack_range: float = 100.0
@export var cast_time: float = 1.0
@export var damage: int = 1
@export var is_one_shot: bool = false
## NOTE: [member cooldown_time] can be ignored if [member is_one_shot] is [code]true[/code].
@export var cooldown_time: float = 1.0
@export var is_range_attack: bool = false
## NOTE: [member range_projectile] can be ignored if [member is_range_attack] is [code]false[/code].
## [member range_projectile] has its own [param damage] value and doesn't use [member damage].
@export var range_projectile: PackedScene
@export_category("Essentials")
@export var cast_timer: Timer
@export var cooldown_timer: Timer

var attackCount: int = 0

func _ready() -> void:
	cast_timer.timeout.connect(_attack)
	cooldown_timer.timeout.connect(_on_cast_attack_begin)


func _on_enter() -> void:
	_on_cast_attack_begin()


func _on_cast_attack_begin() -> void:
	cast_timer.start(cast_time)
	# TODO Change visual asset to cast sprite


func _attack() -> void:
	if is_range_attack:
		# TODO Spawn range_projectile in front of the enemy.
		pass
	else:
		# TODO inflict damage to target
		# TBD Should I use EventBus to convey the hit? Or can the Raycast share the player node with this state?
		pass
	attackCount += 1
	if is_one_shot:
		# WARNING The enemy never quits the Attack state on its own - but doesn't attack anymore due to one-shot.
		return
	_on_cooldown_begin()


func _on_cooldown_begin() -> void:
	cooldown_timer.start(cooldown_time)


func _on_exit() -> void:
	cast_timer.stop()
	cooldown_timer.stop()
