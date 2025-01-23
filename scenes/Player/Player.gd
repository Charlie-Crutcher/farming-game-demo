extends CharacterBody2D

#Animations & Sprites
@onready var animation_sprite = $AnimatedSprite2D
@onready var tool_sprite = $ToolSprite2D

#Audio
@onready var footsteps_sfx = $Footsteps
@onready var hit_sfx = $Hit

const speed = 150.0
var direction_x: float
var direction_y: float

var current_direction = PLAYER_DIRECTION.DOWN
enum PLAYER_DIRECTION {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var main_sm: LimboHSM

func _ready():
	initiate_state_machine()

func _input(event):
	direction_x = Input.get_axis("MoveLeft", "MoveRight")
	direction_y = Input.get_axis("MoveUp", "MoveDown")

func direction_result():
	match current_direction:
		PLAYER_DIRECTION.UP:
			animation_sprite.play("idle_up")

func _physics_process(delta):
	move_and_slide()

func flip_sprite(direction_x):
	if direction_x == 1:
		animation_sprite.flip_h = false
		tool_sprite.flip_h = false
	elif direction_x == -1:
		animation_sprite.flip_h = true
		tool_sprite.flip_h = true

func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	# Declare states here for the State Machine
	var idle_down_state = LimboState.new().named("idle_down").call_on_enter(idle_down_start).call_on_update(idle_down_update)
	var idle_up_state = LimboState.new().named("idle_up").call_on_enter(idle_up_start).call_on_update(idle_up_update)
	var idle_horizontal_state = LimboState.new().named("idle_horizontal").call_on_enter(idle_horizontal_start).call_on_update(idle_horizontal_update)
	var walk_horizontal_state = LimboState.new().named("walk_horizontal").call_on_enter(walk_horizontal_start).call_on_update(walk_horizontal_update)
	var walk_up_state = LimboState.new().named("walk_up").call_on_enter(walk_up_start).call_on_update(walk_up_update)
	var walk_down_state = LimboState.new().named("walk_down").call_on_enter(walk_down_start).call_on_update(walk_down_update)
	var hoe_ground_state = LimboState.new().named("hoe_ground").call_on_enter(hoe_ground_start).call_on_update(hoe_ground_update)
	var pickaxe_horizontal_state = LimboState.new().named("pickaxe_horizontal").call_on_enter(pickaxe_horizontal_start).call_on_update(pickaxe_horizontal_update)
	var pickaxe_down_state = LimboState.new().named("pickaxe_down").call_on_enter(pickaxe_down_start).call_on_update(pickaxe_down_update)
	var pickaxe_up_state = LimboState.new().named("pickaxe_up").call_on_enter(pickaxe_up_start).call_on_update(pickaxe_up_update)
	
	# Adds states into the SM
	main_sm.add_child(idle_down_state)
	main_sm.add_child(idle_up_state)
	main_sm.add_child(idle_horizontal_state)
	main_sm.add_child(walk_horizontal_state)
	main_sm.add_child(walk_up_state)
	main_sm.add_child(walk_down_state)
	main_sm.add_child(hoe_ground_state)
	main_sm.add_child(pickaxe_horizontal_state)
	main_sm.add_child(pickaxe_down_state)
	main_sm.add_child(pickaxe_up_state)
	
	# Initial State upon starting game
	main_sm.initial_state = idle_down_state
	
	# Transitions between different states
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended")
	
	# 1: Walking State Transitions
	# 1.1: State Ends
	# ! TODO - ADD WALK LEFT & WALK RIGHT STATES!
	# This will store which way the player was last facing!
	# This way we can play the appropriate idle animation (idle_left, idle_right, idle_up etc.)
	# Additionally, we can make the player actions such as pickaxe swing depending on which way they are facing!
	# GUNGA GINGA BUG BUG BUG TODO TODO TODO !!!!!!!
	main_sm.add_transtion(walk_up_state, idle_up_state, &"walk_up_to_idle_up")
	main_sm.add_transition(walk_down_state, idle_down_state, &"walk_down_to_idle_down")
	main_sm.add_transition(walk_left_state, )
	
	main_sm.add_transition(idle_down_state, walk_horizontal_state, &"idle_down_to_walk_horizontal")
	main_sm.add_transition(idle_up_state, walk_horizontal_state, &"idle_up_to_walk_horizontal")
	main_sm.add_transition(idle_horizontal_state, walk_horizontal_state, &"idle_horizontal_to_walk_horizontal")
	main_sm.add_transition(idle_down_state, walk_up_state, &"idle_down_to_walk_up")
	main_sm.add_transition(idle_up_state, walk_up_state, &"idle_up_to_walk_up")
	main_sm.add_transition(idle_horizontal_state, walk_up_state, &"idle_horizontal_to_walk_up")
	main_sm.add_transition(idle_down_state, walk_down_state, &"idle_down_to_walk_down")
	main_sm.add_transition(idle_up_state, walk_down_state, &"idle_up_to_walk_down")
	main_sm.add_transition(idle_horizontal_state, walk_down_state, &"idle_horizontal_to_walk_down")
	main_sm.add_transition(idle_state, pickaxe_horizontal_state, &"to_pickaxe_horizontal")
	main_sm.add_transition(idle_state, pickaxe_up_state, &"to_pickaxe_up")
	main_sm.add_transition(idle_state, pickaxe_down_state, &"to_pickaxe_down")
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	
	
func idle_start():
	print("State achine: idle_start")
	animation_sprite.play("idle")
	
func idle_update(delta : float):
	print("StateMachine: idle_update")
	if direction_x:
		main_sm.dispatch(&"to_walk_horizontal")
	if direction_y < 0:
		main_sm.dispatch(&"to_walk_up")
	if direction_y > 0:
		main_sm.dispatch(&"to_walk_down")
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		main_sm.dispatch(&"to_pickaxe_horizontal")
	if direction_y and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		main_sm.dispatch(&"to_pickaxe_up")



func walk_horizontal_start():
	print("StateMachine: walk_horizontal_start")
	animation_sprite.play("walk_horizontal")
	if footsteps_sfx.is_playing(): 
		pass
	else:
		footsteps_sfx.play()



func walk_horizontal_update(delta : float):
	print("StateMachine: walk_horizontal_update")
	if direction_x:
		velocity.x = direction_x * speed
	else:
		velocity.x = 0
	flip_sprite(direction_x)
	if velocity.x == 0:
		footsteps_sfx.stop()
		main_sm.dispatch(&"state_ended")



func walk_up_start():
	print("StateMachine: walk_up_start")
	animation_sprite.play("walk_up")
	if footsteps_sfx.is_playing(): 
		pass
	else:
		footsteps_sfx.play()



func walk_up_update(delta : float):
	print("StateMachine: walk_up_update")
	if direction_y < 0:
		velocity.y = direction_y * speed
	else:
		velocity.y = 0
	if velocity.y == 0:
		footsteps_sfx.stop()
		main_sm.dispatch(&"state_ended")



func walk_down_start():
	print("StateMachine: walk_down_start")
	animation_sprite.play("walk_down")
	if footsteps_sfx.is_playing(): 
		pass
	else:
		footsteps_sfx.play()



func walk_down_update(delta : float):
	print("StateMachine: walk_down_update")
	if direction_y > 0:
		velocity.y = direction_y * speed
	else:
		velocity.y = 0
	if velocity.y == 0:
		footsteps_sfx.stop()
		main_sm.dispatch(&"state_ended")



func hoe_ground_start():
	pass
func hoe_ground_update(delta : float):
	pass


# =----- Pickaxe States -----= #
func pickaxe_horizontal_start():
	print("StateMachine: pickaxe_horizontal_start")
	flip_sprite(direction_x)
	tool_sprite.show()
	tool_sprite.play("pickaxe_horizontal")
	animation_sprite.play("mine_horizontal")
	hit_sfx.play()
	
func pickaxe_horizontal_update(delta : float):
	print("StateMachine: pickaxe_horizontal_update")
	await tool_sprite.animation_finished
	tool_sprite.hide()
	main_sm.dispatch(&"state_ended")
	
func pickaxe_up_start():
	pass

func pickaxe_up_update(delta : float):
	pass

func pickaxe_down_start():
	pass

func pickaxe_down_update(delta : float):
	pass
