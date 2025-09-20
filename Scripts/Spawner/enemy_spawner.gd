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
@export var player : CharacterBody2D 

@export var horizontal_offset: int = 200
@export var max_enemies: int = 8
@export var spawn_timer : Timer
@export var spawn_delay : float = 3.0
@export var spawn_interval: float = .5

var left_count : int = 1
var right_count : int = 1
var current_sequence_index: int = 0
var spawn_y :float
var active_enemies : int = 0


func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_timer.stop()
	
	var timer :Timer = Timer.new()
	var delay_timer: Timer = Timer.new()
	delay_timer.wait_time = spawn_delay
	delay_timer.one_shot = true
	add_child(delay_timer)
	delay_timer.start()
	await delay_timer.timeout
	spawn_timer.start()
	delay_timer.queue_free()
	spawn_y = player.global_position.y


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
	#match enemy_enum:
		#Enemy.MOB1: print("Spawning MOB1")
		#Enemy.MOB2: print("Spawning MOB2")
		#Enemy.MOB3: print("Spawning MOB3")
		#Enemy.MOB4: print("Spawning MOB4")
		#Enemy.MOB5: print("Spawning MOB5")
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
	
	if active_enemies >= max_enemies: return
	
	var screen_size : Vector2 = get_viewport_rect().size
	var half_width : float = screen_size.x / 2
	var offset :float= half_width + horizontal_offset
	var side :int = choose_side()
	
	var spawn_x :float= player.global_position.x + (side * offset)
		
	var enemy_scene : PackedScene = get_next_enemy_scene()
	
	var enemy :Mob= enemy_scene.instantiate()
	
	enemy.freeze = true # avoid the enemies bouncing away from collision
	enemy.global_position = Vector2(spawn_x, spawn_y)
	enemy.died.connect(_on_enemy_dies)
	get_parent().add_child(enemy)
	active_enemies += 1

func _on_enemy_dies() -> void:
	active_enemies -= 1
