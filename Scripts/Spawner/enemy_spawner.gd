extends Node2D

@export var mob1: PackedScene
@export var mob2: PackedScene
@export var mob3: PackedScene
@export var mob4: PackedScene
@export var mob5: PackedScene
enum Enemy { MOB1, MOB2, MOB3, MOB4, MOB5 }

@export var spawn_sequence_1: Array[Enemy] = [Enemy.MOB1, Enemy.MOB1, Enemy.MOB1, Enemy.MOB1]
@export var spawn_sequence_2: Array[Enemy] = [Enemy.MOB1, Enemy.MOB2, Enemy.MOB3]
@export var spawn_sequence_3: Array[Enemy] = [Enemy.MOB3, Enemy.MOB3, Enemy.MOB3]

@export var spawn_interval: float = .5
@export var horizontal_offset: int = 200
@export var player : CharacterBody2D

var left_count : int = 1
var right_count : int = 1
var current_sequence_index: int = 0

func _ready() -> void:
	var timer :Timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(spawn_enemy)
	add_child(timer)

func get_current_sequence() -> Array:
	if player.scale.x >= 2:
		return spawn_sequence_3
	elif player.scale.x >= 1:
		return spawn_sequence_2
	else:
		return spawn_sequence_1

func get_next_enemy_scene() -> PackedScene:
	# INFO Chooses spawn sequence based off player's scale size, and returns
	# enemy scene. Will repeat sequence once the end of sequence is reached.
	var sequence : Array = get_current_sequence()
	var enemy_enum : Enemy = sequence[current_sequence_index]
	current_sequence_index = (current_sequence_index + 1) % sequence.size()
	
	#region DEBUG
	match enemy_enum:
		Enemy.MOB1: print("Spawning MOB1")
		Enemy.MOB2: print("Spawning MOB2")
		Enemy.MOB3: print("Spawning MOB3")
		Enemy.MOB4: print("Spawning MOB4")
		Enemy.MOB5: print("Spawning MOB5")
	#endregion
	
	match enemy_enum:	
		Enemy.MOB1: return mob1
		Enemy.MOB2: return mob2
		Enemy.MOB3: return mob3
		Enemy.MOB4: return mob4
		Enemy.MOB5: return mob5
		_: return null
	
func choose_side() -> int:
	# INFO Chooses which side the enemy spawns in. Biases either side
	# if one side receives more spawns than the other
	
	var left_bias : float = float(right_count) / (left_count + right_count) 
	var rand_val : float = randf()
	
	if rand_val < left_bias:
		left_count += 1
		return -1 # left
	else:
		right_count += 1
		return 1 # right

func spawn_enemy() -> void:
	# INFO Spawns enemy outside the viewport on either side of the player.
	# Do note if horizontal offset is greater than the boundary, enemies will
	# spawn and drop outside of the level
	if player == null: return
	
	var screen_size : Vector2 = get_viewport_rect().size
	var half_width : float = screen_size.x / 2
	var offset :float= half_width + horizontal_offset
	var side :int = choose_side()
	
	var spawn_x :float= player.global_position.x + (side * offset)
	var spawn_y :float= player.global_position.y + randf_range(-100, 100)
		
	var enemy_scene : PackedScene = get_next_enemy_scene()
	
	var enemy :Mob= enemy_scene.instantiate()
	enemy.global_position = Vector2(spawn_x, spawn_y)
	get_parent().add_child(enemy)
