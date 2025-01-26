extends CharacterBody2D
class_name Entity

#Stats custom resource
@export var stats : Stats
@export var soil : FarmField

#Animations & Sprites
@onready var animation_sprite = $AnimatedSprite2D
@onready var tool_sprite = $ToolSprite2D

#Audio
@onready var footsteps_sfx : AudioStreamPlayer = $Footsteps
@onready var hit_sfx : AudioStreamPlayer = $Hit

#Timer
@onready var timer: Timer = $Timer

#Movement Variables
const player_sprint_speed = 400.0
const player_speed = 200.0
var player_direction_x: float
var player_direction_y: float
var is_sprinting : bool = false
var debug_menu

#Action Variables
var player_action_left
var player_action_right
var player_action_up
var player_action_down
var player_is_mining : bool = false

#StateMachine Variable
var main_sm: LimboHSM

#----------Start of Ready Function----------#
func _ready():
	initiate_state_machine()
#----------End of Ready Function----------#

#----------Start of Physics Process Function----------#
func _physics_process(_delta):
	#Checking for movement and applying gravity
	#Setting player_direction variables to store if player is pressing left, right, up or down
	player_direction_x = Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
	player_direction_y = Input.get_action_strength("MoveDown") - Input.get_action_strength("MoveUp")
	
	#Setting player_action variables to store if player is using directional keys
	player_action_left = Input.is_action_pressed("ui_left")
	player_action_right = Input.is_action_pressed("ui_right")
	player_action_up = Input.is_action_pressed("ui_up")
	player_action_down = Input.is_action_pressed("ui_down")
	is_sprinting = Input.is_action_pressed("shift")
	
	#Debug menu
	debug_menu = Input.is_action_just_pressed("debug")
	if debug_menu:
		print(stats.player_stamina)
	##If player is pressing left or right, move the player. If not, velocity = 0
	# // // // Update: Moved this within walking states in state machine // // // #
	#if player_direction_x:
		#velocity.x = player_direction_x * player_speed
	#else:
		#velocity.x = 0
	
	#Same logic applies for y axis
	#if player_direction_y:
		#velocity.y = player_direction_y * player_speed
	#else:
		#velocity.y = 0
	
	#Adds movement to the player
	move_and_slide()
#----------End of Physics Process Function----------#

#----------Start of Initiate State Machine Function----------#
func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	#==Declaring new states==#
	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var walk_x_state = LimboState.new().named("walk_x").call_on_enter(walk_x_start).call_on_update(walk_x_update)
	var walk_y_state = LimboState.new().named("walk_y").call_on_enter(walk_y_start).call_on_update(walk_y_update)
	var pickaxe_state = LimboState.new().named("pickaxe").call_on_enter(pickaxe_start).call_on_update(pickaxe_update)
	
	#==Adding declared states into the state machine==#
	main_sm.add_child(idle_state)
	main_sm.add_child(walk_x_state)
	main_sm.add_child(walk_y_state)
	main_sm.add_child(pickaxe_state)
	
	#==First state player is assigned to==#
	main_sm.initial_state = idle_state
	
	#==Transitions between states==#
	main_sm.add_transition(idle_state, walk_x_state, &"to_walk_x")
	main_sm.add_transition(idle_state, walk_y_state, &"to_walk_y")
	main_sm.add_transition(idle_state, pickaxe_state, &"to_pickaxe")
	
	#Universal back to idle state
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended")
	
	#==Initialises StateMachine==#
	main_sm.initialize(self)
	main_sm.set_active(true)
#----------End of Initiate State Machine Function----------#

#----------Start of Movement State Functions----------#
func idle_start():
	print("StateMachine: idle_state")
	animation_sprite.play("idle")
func idle_update(_delta : float):
	#Checks for movement and changes state depending on player direction
	if player_direction_x:
		main_sm.dispatch(&"to_walk_x")
	if player_direction_y:
		main_sm.dispatch(&"to_walk_y")
	if !tool_sprite.is_playing() and !player_is_mining:
		if player_action_left or player_action_right or player_action_up or player_action_down:
			main_sm.dispatch(&"to_pickaxe")

func walk_x_start():
	print("StateMachine: walk_x_state")
	footsteps_sfx.play()
	animation_sprite.play("walk_horizontal")
	#Flips sprite depending on which direction player is heading on the x axis
func walk_x_update(_delta : float):
	#This is where the new movement is for x axis!
	if player_direction_x == 1:
		animation_sprite.flip_h = false
		velocity.x = player_direction_x * player_speed
		if is_sprinting:
			velocity.x = player_direction_x * player_sprint_speed
	elif player_direction_x == -1:
		animation_sprite.flip_h = true
		velocity.x = player_direction_x * player_speed
		if is_sprinting:
			velocity.x = player_direction_x * player_sprint_speed
	else:
		velocity.x = 0
	#If there is no movement, dispatch the universal 'state_ended' state transition
	if velocity.x == 0:
		footsteps_sfx.stop()
		main_sm.dispatch(&"state_ended")

func walk_y_start():
	print("StateMachine: walk_y_state")
	footsteps_sfx.play()
	#Changes animation depending on which direction player is heading in on the y axis
func walk_y_update(_delta : float):
	#This is where the new movement is for y axis!
	if player_direction_y == 1:
		animation_sprite.play("walk_down")
		velocity.y = player_direction_y * player_speed
		if is_sprinting:
			velocity.y = player_direction_y * player_sprint_speed
	elif player_direction_y == -1:
		animation_sprite.play("walk_up")
		velocity.y = player_direction_y * player_speed
		if is_sprinting:
			velocity.y = player_direction_y * player_sprint_speed
	else:
		velocity.y = 0
	#If there is no movement, dispatch the universal 'state_ended' state transition
	if velocity.y == 0:
		footsteps_sfx.stop()
		main_sm.dispatch(&"state_ended")

func pickaxe_start():
	print("StateMachine: pickaxe_state")
	velocity.x = 0
	velocity.y = 0
	timer.start()
	hit_sfx.play()
func pickaxe_update(_delta : float):
	#Stops playing moving
	velocity.x = 0
	velocity.y = 0
	#Directional Sprite Movement Based on player input
	if player_action_left and !player_is_mining:
		stats.reduce_stamina_1(1.0)
		player_is_mining = true
		tool_sprite.flip_h = true
		animation_sprite.flip_h = true
		tool_sprite.show()
		tool_sprite.play("pickaxe_horizontal")
		animation_sprite.play("mine_horizontal")
	elif player_action_right and !player_is_mining:
		stats.reduce_stamina_1(1.0)
		player_is_mining = true
		tool_sprite.flip_h = false
		animation_sprite.flip_h = false
		tool_sprite.show()
		tool_sprite.play("pickaxe_horizontal")
		animation_sprite.play("mine_horizontal")
	elif player_action_up and !player_is_mining:
		stats.reduce_stamina_1(1.0)
		player_is_mining = true
		tool_sprite.flip_h = false
		animation_sprite.flip_h = false
		tool_sprite.show()
		tool_sprite.play("pickaxe_up")
		animation_sprite.play("mine_up")
	elif player_action_down and !player_is_mining:
		stats.reduce_stamina_1(1.0)
		player_is_mining = true
		tool_sprite.flip_h = false
		animation_sprite.flip_h = false
		tool_sprite.show()
		tool_sprite.play("pickaxe_down")
		animation_sprite.play("mine_down")
	if timer.is_stopped():
		player_is_mining = false
		hit_sfx.stop()
		tool_sprite.hide()
		main_sm.dispatch(&"state_ended")
#----------End of Movement State Functions----------#

#-----Timer Timeout Function-----#
func _on_timer_timeout():
	pass
#-----Timer Timeout Function-----#
