extends Node2D

# 敌人生成配置
@export_group("Spawn Settings")
@export var spawn_interval := 4.0 # 敌人生成间隔(秒)
@export var spawn_count := 9     # 每次生成的敌人数量
@export var enemy_scene: PackedScene = preload("res://enemy/enemy.tscn") # 敌人场景

# 节点引用
@export var grid: Node2D

var timer: Timer

# 使用寻路系统
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_spawn_timer)
	timer.start(spawn_interval)
	# 初始生成一批
	_on_spawn_timer()


func _on_spawn_timer():
	if get_tree().get_nodes_in_group("active_towers").is_empty():
		return
	var map_rect = grid.base_layer.get_used_rect()
	var valid_spawns = []
	
	# 获取所有边缘图块
	var edge_cells = []
	for x in range(map_rect.position.x, map_rect.end.x):
		for y in range(map_rect.position.y, map_rect.end.y):
			var cell = Vector2i(x,y)
			if grid.base_layer.get_cell_source_id(cell) != -1:  # 检查是否有图块
				# 检查是否是边缘图块(至少一个方向无图块)
				for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var neighbor = cell + dir
					if grid.base_layer.get_cell_source_id(neighbor) == -1:
						edge_cells.append(cell)
						break
	
	# 在边缘图块向内1-3格范围内寻找可通行点
	for cell in edge_cells:
		# 获取向内方向(远离边缘的方向)
		var inward_dir = Vector2i.ZERO
		for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor = cell + dir
			if grid.base_layer.get_cell_source_id(neighbor) != -1:
				inward_dir = dir
				break
		
		if inward_dir != Vector2i.ZERO:
			# 向内1-3格
			for i in range(1, 4):
				var spawn_pos = cell + inward_dir * i
				if (grid.base_layer.get_cell_source_id(spawn_pos) != -1 and 
					not grid.astar.is_point_solid(spawn_pos)):
					valid_spawns.append(spawn_pos)
	
	# 随机选择不重复的点
	valid_spawns.shuffle()
	for i in range(min(spawn_count, valid_spawns.size())):
		var enemy = enemy_scene.instantiate()
		enemy.position = grid.base_layer.map_to_local(valid_spawns[i])
		add_child(enemy)
# wzy

# func _on_spawn_timer():
# 	if not is_instance_valid(grid) or not grid.has_method("get_used_rect"):
# 		push_warning("Spawner: Invalid grid reference")
# 		return
	
# 	var map_rect = grid.get_used_rect()
# 	var valid_spawns = []
	
# 	# 简化生成点检测 - 使用地图边界附近区域
# 	var border_size = 3
# 	for x in [map_rect.position.x, map_rect.end.x - 1]:
# 		for y in range(map_rect.position.y, map_rect.end.y):
# 			var cell = Vector2i(x, y)
# 			if grid.get_cell_source_id(cell) != -1:
# 				valid_spawns.append(cell)
	
# 	for y in [map_rect.position.y, map_rect.end.y - 1]:
# 		for x in range(map_rect.position.x, map_rect.end.x):
# 			var cell = Vector2i(x, y)
# 			if grid.get_cell_source_id(cell) != -1:
# 				valid_spawns.append(cell)
	
# 	# 过滤掉不可通行点
# 	valid_spawns = valid_spawns.filter(func(cell): 
# 		return grid.get_cell_source_id(cell) != -1)
	
# 	if valid_spawns.is_empty():
# 		push_warning("Spawner: No valid spawn points found")
# 		return
	
# 	# 随机选择不重复的点
# 	valid_spawns.shuffle()
# 	for i in range(min(spawn_count, valid_spawns.size())):
# 		var enemy = enemy_scene.instantiate()
# 		enemy.position = grid.map_to_local(valid_spawns[i])
# 		add_child(enemy)
