extends Node2D

@export var mob1: PackedScene
@export var mob2: PackedScene
@export var mob3: PackedScene
@export var mob4: PackedScene
@export var mob5: PackedScene
enum Enemy { MOB1, MOB2, MOB3, MOB4, MOB5 }

@export var spawn_sequence_1: Array[Enemy] = [Enemy.MOB1, Enemy.MOB2, Enemy.MOB5, Enemy.MOB3]
@export var spawn_sequence_2: Array[Enemy] = [Enemy.MOB2, Enemy.MOB3, Enemy.MOB3]

# left_spawn_position
# right_spawn_position

var left_count : int = 0
var right_count : int = 0

func get_mob(enemy: Enemy) -> PackedScene:
	# INFO Used to map the exported variables to the enumerated mobs
	match enemy:
		Enemy.MOB1: return mob1
		Enemy.MOB2: return mob2
		Enemy.MOB3: return mob3
		Enemy.MOB4: return mob4
		Enemy.MOB5: return mob5
		_: return null
		
func spawn_next(player: Node2D, spawn_sequence: Array[Enemy]) -> void:
	var sequence_index : int = 0
	var enemy : Enemy = spawn_sequence[sequence_index]
	sequence_index = (sequence_index + 1) % spawn_sequence.size()

	var mob_scene : PackedScene = get_mob(enemy)
	if mob_scene == null:
		return

	var total : int = left_count + right_count + 1 # avoid divide by zero
	var left_bias : float = float(right_count + 1) / total
	var spawn_left : bool = randf() < left_bias

	var mob :Mob= mob_scene.instantiate()
	add_child(mob)

	var spawn_offset : Vector2 = Vector2(400, 0)
	if spawn_left:
		mob.global_position = player.global_position + Vector2(-spawn_offset.x, spawn_offset.y)
		left_count += 1
	else:
		mob.global_position = player.global_position + Vector2(spawn_offset.x, spawn_offset.y)
		right_count += 1
