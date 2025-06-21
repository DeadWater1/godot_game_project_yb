extends CanvasLayer

@export var pause_panel: Panel



func pause():
	get_tree().paused = true
	pause_panel.visible = true
	
func unpause():
	get_tree().paused = false
	pause_panel.visible = false
	
func quit_game():
	get_tree().quit()
	
func _on_save_button_pressed():
	var data=SceneData.new()
	
	var towers=get_tree().get_nodes_in_group("active_towers")
	for tower in towers:
		var tower_scene=PackedScene.new()
		tower_scene.pack(tower)
		data.tower_array.append(tower_scene)
	var enemies=get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		var enemy_scene=PackedScene.new()
		enemy_scene.pack(enemy)
		data.enemy_array.append(enemy_scene)
	ResourceSaver.save(data,"res://save/load/scene_data.tres")
	print("save")
