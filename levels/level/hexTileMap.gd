extends Node2D

# 将BaseLayer的代码放到这里（放到这里如果有其他代码需要调用寻路系统，能更方便调用）
var astar := AStarGrid2D.new()


@export var base_layer:TileMapLayer

@export var obstruction_layer:TileMapLayer

func _ready():
	astar.region=base_layer.get_used_rect()
	astar.cell_size=base_layer.tile_set.tile_size

	astar.default_compute_heuristic=AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.default_estimate_heuristic=AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar.update()

	for x in range(astar.region.position.x,astar.region.end.x):
		for y in range(astar.region.position.y,astar.region.end.y):
			var coord=Vector2i(x,y)
			var tile_data:=obstruction_layer.get_cell_tile_data(coord)
			if tile_data and tile_data.get_custom_data("unwalkable"):
				astar.set_point_solid(coord)


func _on_empty_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		SelectionManager.deselect_all()
