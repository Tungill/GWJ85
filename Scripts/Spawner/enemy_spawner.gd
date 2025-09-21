extends Node2D

@export var rat: PackedScene
@export var frog: PackedScene
@export var peasant: PackedScene
@export var soldier: PackedScene
@export var lion: PackedScene
@export var dolphin: PackedScene
@export var wyvern: PackedScene
@export var dog: PackedScene
@export var angel: PackedScene

enum Enemy {rat, frog, peasant, soldier, lion, dolphin, wyvern, dog, angel}
@export var spawn_sequence_1: Array[Enemy] = [Enemy.rat, Enemy.frog, Enemy.rat, Enemy.frog]
@export var spawn_sequence_2: Array[Enemy] = [Enemy.dog, Enemy.dog, Enemy.dog]
@export var spawn_sequence_3: Array[Enemy] = [Enemy.wyvern, Enemy.wyvern, Enemy.wyvern]
@export var player : CharacterBody2D 
@export var camera: Camera2D

@export_category("Parameters")
@export var horizontal_offset: int = 200
@export var max_enemies: int = 8
@export var spawn_timer : Timer
@export var spawn_delay : float = 3.0
@export var spawn_interval: float = .5
@export var second_sequence_threshold : int = 20
@export var third_sequence_threshold : int = 40

var left_count : int = 1
var right_count : int = 1
var current_sequence_index: int = 0
var spawn_y :float
var active_enemies : Array = []


func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_timer.stop()
	
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
	if player.enemies_killed >= third_sequence_threshold:
		return spawn_sequence_3
	elif player.enemies_killed >= second_sequence_threshold:
		return spawn_sequence_2
	else:
		return spawn_sequence_1

func get_next_enemy_scene() -> PackedScene:
	# INFO Chooses spawn sequence based off player's scale size, and returns
	# enemy scene. Will repeat sequence once the end of sequence is reached.
	var sequence : Array = get_current_sequence()
	var enemy_enum : Enemy = sequence[current_sequence_index]
	current_sequence_index = (current_sequence_index + 1) % sequence.size()
	
	match enemy_enum:
		Enemy.rat: return rat
		Enemy.frog: return frog
		Enemy.peasant: return peasant
		Enemy.soldier: return soldier
		Enemy.lion: return lion
		Enemy.dolphin: return dolphin
		Enemy.wyvern: return wyvern
		Enemy.dog: return dog
		Enemy.angel: return angel	
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

func get_camera_visible_rect() -> Rect2:
	if camera == null:
		return get_viewport_rect() # fallback

	var screen_size :Vector2= get_viewport_rect().size
	var top_left :Vector2= camera.get_screen_center_position() - screen_size / 2
	return Rect2(top_left, screen_size)

func spawn_enemy() -> void:
	# INFO Spawns enemy outside the viewport on either side of the player.
	# Do note if horizontal offset is greater than the boundary, enemies will
	# spawn and drop outside of the level
	if player == null: return
	
	if active_enemies.size() >= max_enemies: return
	
	var visible_rect : Rect2 = get_camera_visible_rect()
	var side : int = choose_side()
	var spawn_x : float
	if side == -1:
		spawn_x = visible_rect.position.x - horizontal_offset
	else:
		spawn_x = visible_rect.position.x + visible_rect.size.x + horizontal_offset
	var enemy_scene : PackedScene = get_next_enemy_scene()
	
	var enemy :Mob= enemy_scene.instantiate()
	
	enemy.freeze = true # avoid the enemies bouncing away from collision
	enemy.global_position = Vector2(spawn_x, spawn_y)
	enemy.died.connect(_on_enemy_dies.bind(enemy))
	enemy.died.connect(player._on_enemy_killed)
	get_parent().add_child(enemy)
	active_enemies.append(enemy)

func _on_enemy_dies(enemy:Mob) -> void:
	active_enemies.erase(enemy)

func clear_enemies() -> void:
	for enemy:Mob in active_enemies:
		if enemy and enemy.is_inside_tree():
			enemy.queue_free()
	active_enemies.clear()
