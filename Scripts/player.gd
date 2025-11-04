extends CharacterBody2D

signal laser_shot(laser);

@export var acceleration : float = 10.0;
@export var max_speed : float = 350.0;
@export var rotation_speed : float = 250.0;

@onready var muzzle := $Muzzle

var laser_scene = preload("res://Scenes/laser.tscn");

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("shoot")):
		_shoot_laser();

func _physics_process(delta: float) -> void:
	var input_vector:Vector2 = Vector2(0, Input.get_axis("move_forward", "move_backward"));
	velocity += input_vector.rotated(rotation) * acceleration;
	velocity = velocity.limit_length(max_speed);

	if (Input.is_action_pressed("rotate_right")):
		rotate(deg_to_rad(rotation_speed*delta));
	if (Input.is_action_pressed("rotate_left")):
		rotate(deg_to_rad(-rotation_speed*delta));
	
	if (input_vector.y == 0):
		velocity = velocity.move_toward(Vector2.ZERO, 3);
	move_and_slide();

	var screen_size = get_viewport_rect().size;
	if global_position.y < 0:
		global_position.y = screen_size.y;
	elif global_position.y > screen_size.y:
		global_position.y = 0;
	if global_position.x < 0:
		global_position.x = screen_size.x;
	elif global_position.x > screen_size.x:
		global_position.x = 0;

func _shoot_laser() -> void:
	var l := laser_scene.instantiate();
	l.global_position = muzzle.global_position;
	l.rotation = rotation;
	emit_signal("laser_shot", l);
