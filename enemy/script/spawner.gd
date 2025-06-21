extends Node2D

# 敌人生成配置
@export_group("Spawn Settings")
@export var spawn_count := 3      # 每次生成的敌人数量
@export var enemy_scene: PackedScene = preload("res://enemy/enemy.tscn") # 敌人场景
var spawn_interval := 20.0 # 敌人生成间隔(秒)

# 波数控制
@export_group("Wave Settings")
@export var max_waves := 15      # 总波数
@export var progress_bar: Node2D
var current_wave := 0            # 当前波数
var round_bar

# 用于持续进度条的变量
var total_spawn_duration: float # 总的出怪时长
var elapsed_time: float = 0.0     # 从开始到现在经过的时间

# 新增：游戏状态开关
var game_has_started := false

# 节点引用
@export var grid: Node2D

var timer: Timer

func _ready():
	# 获取Round节点
	round_bar = progress_bar.get_child(0)
	
	total_spawn_duration = float(max_waves) * spawn_interval
	round_bar.max_value = total_spawn_duration
	round_bar.value = 0.0

	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_spawn_timer)



func _process(delta: float):

	if not game_has_started:
		if not get_tree().get_nodes_in_group("active_towers").is_empty():
			_start_game()
	else:
		if elapsed_time >= total_spawn_duration:
			round_bar.value = round_bar.max_value
			return
		
		elapsed_time += delta
		round_bar.value = elapsed_time


func _start_game():
	game_has_started = true 
	timer.start()          



func _on_spawn_timer():
	if current_wave >= max_waves:
		print("所有波数已生成！游戏胜利！")
		timer.stop()
		return
		
	if get_tree().get_nodes_in_group("active_towers").is_empty():
		return
	
	current_wave += 1
	
	var map_rect = grid.base_layer.get_used_rect()
	var valid_spawns = []
	var edge_cells = []
	for x in range(map_rect.position.x, map_rect.end.x):
		for y in range(map_rect.position.y, map_rect.end.y):
			var cell = Vector2i(x,y)
			if grid.base_layer.get_cell_source_id(cell) != -1:
				for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var neighbor = cell + dir
					if grid.base_layer.get_cell_source_id(neighbor) == -1:
						edge_cells.append(cell)
						break
						
	for cell in edge_cells:
		var inward_dir = Vector2i.ZERO
		for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor = cell + dir
			if grid.base_layer.get_cell_source_id(neighbor) != -1:
				inward_dir = dir
				break
		if inward_dir != Vector2i.ZERO:
			for i in range(1, 4):
				var spawn_pos = cell + inward_dir * i
				if (grid.base_layer.get_cell_source_id(spawn_pos) != -1 and not grid.astar.is_point_solid(spawn_pos)):
					valid_spawns.append(spawn_pos)
					
	valid_spawns.shuffle()
	for i in range(min(spawn_count, valid_spawns.size())):
		var enemy = enemy_scene.instantiate()
		enemy.position = grid.base_layer.map_to_local(valid_spawns[i])
		add_child(enemy)
