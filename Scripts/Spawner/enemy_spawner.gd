extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = .5
@export var player : CharacterBody2D

@export var mob1: PackedScene
@export var mob2: PackedScene
@export var mob3: PackedScene
@export var mob4: PackedScene
@export var mob5: PackedScene
enum Enemy { MOB1, MOB2, MOB3, MOB4, MOB5 }

@export var spawn_sequence_1: Array[Enemy] = [Enemy.MOB1, Enemy.MOB2, Enemy.MOB5, Enemy.MOB3]
@export var spawn_sequence_2: Array[Enemy] = [Enemy.MOB2, Enemy.MOB3, Enemy.MOB3]

func get_mob(enemy: Enemy) -> PackedScene:
	# INFO Used to map the exported variables to the enumerated mobs
	match enemy:
		Enemy.MOB1: return mob1
		Enemy.MOB2: return mob2
		Enemy.MOB3: return mob3
		Enemy.MOB4: return mob4
		Enemy.MOB5: return mob5
		_: return null


var left_count : int = 0
var right_count : int = 0

func _ready() -> void:
	var timer :Timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(spawn_enemy)
	add_child(timer)

func spawn_enemy() -> void:
	print("Spawn function started")
	if player == null: return
	
	var screen_size : Vector2 = get_viewport_rect().size
	var half_width : float = screen_size.x / 2
	
	var side :int = choose_side()
	var offset :float= half_width + 100
	print("Side: %s" % side)
	
	var spawn_x :float= player.global_position.x + (side * offset)
	var spawn_y :float= player.global_position.y + randf_range(-100, 100)
	
	var enemy :Mob= enemy_scene.instantiate()
	enemy.global_position = Vector2(spawn_x, spawn_y)
	get_parent().add_child(enemy)
	print("Enemy spawned")
	
func choose_side() -> int:
	var total : int = left_count + right_count + 1 # avoid division by zero
	var left_bias : float = float(right_count + 1) / total 
	var rand_val : float = randf()
	
	if rand_val < left_bias:
		left_count += 1
		return -1 # left
	else:
		right_count += 1
		return 1 # right
