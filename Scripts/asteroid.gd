extends Area2D

var movement_vector: Vector2 = Vector2(0, -1);

enum AsteroidSize{LARGE, MEDIUM, SMALL};
@export var size:= AsteroidSize.LARGE;

var speed:float = 50.0;

@onready var sprite = $Sprite2D;
@onready var cshape = $CollisionShape;

func _ready() -> void:
	rotation = randf_range(0, 2*PI);
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50, 100);
			sprite.texture = preload("res://Assets/Items/meteorGrey_big1.png");
			cshape.shape = preload("res://Ressources/asteroid_cshape_large.tres");
		AsteroidSize.MEDIUM:
			speed = randf_range(100, 150);
			sprite.texture = preload("res://Assets/Items/meteorGrey_med1.png");
			cshape.shape = preload("res://Ressources/asteroid_cshape_medium.tres");
		AsteroidSize.SMALL:
			speed = randf_range(100, 200);
			sprite.texture = preload("res://Assets/Items/meteorGrey_small1.png");
			cshape.shape = preload("res://Ressources/asteroid_cshape_small.tres");

func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta;
	
	var radius = cshape.shape.radius;
	var screen_size = get_viewport_rect().size;
	if (global_position.y + radius) < 0:
		global_position.y = (screen_size.y + radius);
	elif (global_position.y - radius) > screen_size.y:
		global_position.y = -radius;
	if (global_position.x + radius) < 0:
		global_position.x = (screen_size.x + radius);
	elif global_position.x - radius > screen_size.x:
		global_position.x = -radius;
