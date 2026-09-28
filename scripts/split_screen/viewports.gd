extends GridContainer

const PILOT_SCENE: PackedScene = preload("res://scenes/pilot.tscn")
const PLAYER_VISUAL_IDS := {3: 1, 4: 4}
const ADDITIONAL_PLAYER_POSITIONS := {
  3: Vector2(365, 473),
  4: Vector2(872, 473),
}

@onready var viewport1: SubViewport = $ViewportContainer1/Viewport1
@onready var stage: Node2D = $ViewportContainer1/Viewport1/Stage


func _ready():
  var player_count := GameInput.active_player_count
  columns = 1 if player_count == 2 else 2

  for slot in range(1, 5):
    var container := get_node("ViewportContainer%d" % slot) as SubViewportContainer
    var viewport := container.get_node("Viewport%d" % slot) as SubViewport
    container.visible = slot <= player_count
    if slot > 1:
      viewport.world_2d = viewport1.world_2d

  _create_additional_players(player_count)
  stage.get_node("Players/Player1/Camera2D").enabled = false
  for slot in range(1, player_count + 1):
    var camera_path := "ViewportContainer%d/Viewport%d/Camera2D" % [slot, slot]
    var camera := get_node(camera_path) as Camera2D
    camera.target = stage.get_node("Players/Player%d" % slot)

  get_viewport().size_changed.connect(on_size_changed)
  on_size_changed()


func _create_additional_players(player_count: int) -> void:
  var players := stage.get_node("Players")
  for slot in range(3, player_count + 1):
    var player := PILOT_SCENE.instantiate() as Pilot
    player.name = "Player%d" % slot
    player.id = PLAYER_VISUAL_IDS[slot]
    player.input_slot = slot
    player.position = ADDITIONAL_PLAYER_POSITIONS[slot]
    players.add_child(player)



### CALLBACKS ###

func on_size_changed():
  var screen_size = get_viewport().get_visible_rect().size
  size = screen_size
