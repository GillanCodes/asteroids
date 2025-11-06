class_name Player extends CharacterBody2D

signal laser_shot(laser);
signal died;

@export var acceleration : float = 10.0;
@export var max_speed : float = 350.0;
@export var rotation_speed : float = 250.0;
@export var shoot_cd_time: float = 0.5;


@onready var muzzle := $Muzzle;
@onready var sprite := $Sprite2D;

var laser_scene = preload("res://Scenes/laser.tscn");
var shoot_cd : bool = false

var alive: bool = true;

func _process(_delta: float) -> void:
	if(Input.is_action_pressed("shoot")):
		if shoot_cd:
			return;
		shoot_cd = true;
		_shoot_laser();
		await get_tree().create_timer(shoot_cd_time).timeout
		shoot_cd = false;

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

func die():
	if alive == true:
		alive = false;
		emit_signal("died");
		sprite.visible = false;
		process_mode = Node.PROCESS_MODE_DISABLED

func respawn(pos):
	if alive == false:
		alive = true;
		global_position = pos;
		velocity = Vector2.ZERO;
		sprite.visible = true;
		process_mode = Node.PROCESS_MODE_INHERIT
