extends Node2D

@export var stats : Stats
@onready var energy_sprite = $AnimatedSprite2D

func _physics_process(delta):
	if stats.player_stamina >= 52.0:
		energy_sprite.play("max_stamina")
	elif stats.player_stamina == 51.0:
		energy_sprite.play("stamina_51")
	elif stats.player_stamina == 50.0:
		energy_sprite.play("stamina_50")
	elif stats.player_stamina == 49.0:
		energy_sprite.play("stamina_49")
	elif stats.player_stamina == 48.0:
		energy_sprite.play("stamina_48")
	elif stats.player_stamina == 47.0:
		energy_sprite.play("stamina_47")
	elif stats.player_stamina == 47.0:
		energy_sprite.play("stamina_46")
	elif stats.player_stamina == 46.0:
		energy_sprite.play("stamina_46")
	elif stats.player_stamina == 45.0:
		energy_sprite.play("stamina_45")
	elif stats.player_stamina == 44.0:
		energy_sprite.play("stamina_44")
	elif stats.player_stamina == 43.0:
		energy_sprite.play("stamina_43")
