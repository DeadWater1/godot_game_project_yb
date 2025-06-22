# card.gd
extends Node2D

var card_being_dragged
var screen_size
var drag_offset = Vector2.ZERO
var is_hovered_on_card



func _ready() -> void:
	screen_size = get_viewport_rect().size
	

func _process(delta: float) -> void:
	if card_being_dragged:

		var mouse_pos = get_global_mouse_position()
		var target_pos = mouse_pos + drag_offset # 计算目标全局位置

		# 对目标全局位置进行边界限制
		target_pos.x = clamp(target_pos.x, 0, screen_size.x)
		target_pos.y = clamp(target_pos.y, 0, screen_size.y)
		
		card_being_dragged.global_position = target_pos
		
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				start_dragged(card)
		else:
			if card_being_dragged:
				finish_dragged()

func start_dragged(card):
	card_being_dragged = card
	drag_offset = card_being_dragged.global_position - get_global_mouse_position()
	card.scale = Vector2(1, 1)

func finish_dragged():
	card_being_dragged.scale = Vector2(1.05, 1.05)
	card_being_dragged = null
			
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_hovered_over_card(card):
	if not is_hovered_on_card:
		is_hovered_on_card = true
		highlight_card(card, true)


func on_hovered_off_card(card):
	if not card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovered_on_card = false
	

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
	
	
	
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters)
	
	if result.size() > 0:
		return get_card_with_hightest_z_index(result)
	
	return null


func get_card_with_hightest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_index = current_card.z_index
			highest_z_card = current_card
			
	return highest_z_card
	
