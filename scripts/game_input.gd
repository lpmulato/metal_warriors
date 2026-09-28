extends Node

signal devices_changed

const KEYBOARD_DEVICE := -100
const AUTO_DEVICE := -101
const PLAYER_SLOTS := [1, 2, 3, 4]
const PLAYER_COUNTS := [2, 3, 4]
const ACTIONS := [
  "left",
  "right",
  "up",
  "down",
  "button_north",
  "button_east",
  "button_south",
  "button_west",
  "shoulder_left",
  "shoulder_right",
  "button_select",
]

const JOY_BUTTONS := {
  "button_south": JOY_BUTTON_A,
  "button_east": JOY_BUTTON_B,
  "button_west": JOY_BUTTON_X,
  "button_north": JOY_BUTTON_Y,
  "shoulder_left": JOY_BUTTON_LEFT_SHOULDER,
  "shoulder_right": JOY_BUTTON_RIGHT_SHOULDER,
  "button_select": JOY_BUTTON_BACK,
  "left": JOY_BUTTON_DPAD_LEFT,
  "right": JOY_BUTTON_DPAD_RIGHT,
  "up": JOY_BUTTON_DPAD_UP,
  "down": JOY_BUTTON_DPAD_DOWN,
}

const JOY_AXES := {
  "left": [JOY_AXIS_LEFT_X, -1.0],
  "right": [JOY_AXIS_LEFT_X, 1.0],
  "up": [JOY_AXIS_LEFT_Y, -1.0],
  "down": [JOY_AXIS_LEFT_Y, 1.0],
}
const GAME_SCENE := "res://scenes/split_screen/static_split_screen.tscn"
const START_MENU_SCENE: PackedScene = preload("res://scenes/ui/start_menu.tscn")

var active_player_count := 2
var _player_devices := {
  1: KEYBOARD_DEVICE,
  2: KEYBOARD_DEVICE,
  3: KEYBOARD_DEVICE,
  4: KEYBOARD_DEVICE,
}
var _auto_assign := {1: true, 2: true, 3: true, 4: true}
var _pause_menu_layer: CanvasLayer


func _ready() -> void:
  Input.joy_connection_changed.connect(_on_joy_connection_changed)
  _refresh_auto_assignments()


func _input(event: InputEvent) -> void:
  if not event is InputEventKey or not event.pressed or event.echo:
    return
  if get_tree().current_scene == null or get_tree().current_scene.scene_file_path != GAME_SCENE:
    return

  if event.keycode == KEY_ESCAPE:
    if get_tree().paused:
      _close_pause_menu()
    else:
      _open_pause_menu()
    get_viewport().set_input_as_handled()
  elif event.keycode in [KEY_ENTER, KEY_KP_ENTER] and not get_tree().paused:
    _open_pause_menu()
    get_viewport().set_input_as_handled()


func _open_pause_menu() -> void:
  if _pause_menu_layer != null:
    return

  get_tree().paused = true
  _pause_menu_layer = CanvasLayer.new()
  _pause_menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
  get_tree().current_scene.add_child(_pause_menu_layer)

  var menu := START_MENU_SCENE.instantiate() as StartMenu
  menu.pause_menu = true
  menu.process_mode = Node.PROCESS_MODE_ALWAYS
  _pause_menu_layer.add_child(menu)


func _close_pause_menu() -> void:
  if _pause_menu_layer == null:
    return

  get_tree().paused = false
  _pause_menu_layer.queue_free()
  _pause_menu_layer = null


func resume_game() -> void:
  _close_pause_menu()


func set_active_player_count(player_count: int) -> void:
  if player_count not in PLAYER_COUNTS:
    push_error("Invalid player count: %d" % player_count)
    return
  active_player_count = player_count


func get_action_name(player_slot: int, action: String) -> StringName:
  return StringName("p%d_%s" % [player_slot, action])


func get_player_device(player_slot: int) -> int:
  return _player_devices.get(player_slot, KEYBOARD_DEVICE)


func is_auto_assigned(player_slot: int) -> bool:
  return _auto_assign.get(player_slot, true)


func set_player_device(player_slot: int, device_id: int) -> void:
  if player_slot not in PLAYER_SLOTS:
    push_error("Invalid player slot: %d" % player_slot)
    return
  if device_id == AUTO_DEVICE:
    _auto_assign[player_slot] = true
    _refresh_auto_assignments()
    return

  _auto_assign[player_slot] = false
  _player_devices[player_slot] = device_id
  _configure_player_actions(player_slot, device_id)
  devices_changed.emit()


func set_player_auto(player_slot: int) -> void:
  set_player_device(player_slot, AUTO_DEVICE)


func _on_joy_connection_changed(_device_id: int, _connected: bool) -> void:
  _refresh_auto_assignments()


func _refresh_auto_assignments() -> void:
  var connected_devices := Input.get_connected_joypads()
  connected_devices.sort()

  for slot in PLAYER_SLOTS:
    if not _auto_assign[slot]:
      continue
    var device_id := KEYBOARD_DEVICE
    if connected_devices.size() >= slot:
      device_id = connected_devices[slot - 1]
    _player_devices[slot] = device_id
    _configure_player_actions(slot, device_id)

  devices_changed.emit()


func _configure_player_actions(player_slot: int, device_id: int) -> void:
  for action in ACTIONS:
    var player_action := get_action_name(player_slot, action)
    if InputMap.has_action(player_action):
      InputMap.action_erase_events(player_action)
    else:
      InputMap.add_action(player_action, 0.5)

    if device_id == KEYBOARD_DEVICE:
      _copy_keyboard_events(action, player_action)
    elif device_id >= 0:
      _add_joypad_events(action, player_action, device_id)


func _copy_keyboard_events(source_action: String, target_action: StringName) -> void:
  if not InputMap.has_action(source_action):
    push_error("Missing input action: %s" % source_action)
    return
  for event in InputMap.action_get_events(source_action):
    if event is InputEventKey:
      InputMap.action_add_event(target_action, event.duplicate())


func _add_joypad_events(action: String, target_action: StringName, device_id: int) -> void:
  var button_event := InputEventJoypadButton.new()
  button_event.device = device_id
  button_event.button_index = JOY_BUTTONS[action]
  InputMap.action_add_event(target_action, button_event)

  if JOY_AXES.has(action):
    var axis_event := InputEventJoypadMotion.new()
    axis_event.device = device_id
    axis_event.axis = JOY_AXES[action][0]
    axis_event.axis_value = JOY_AXES[action][1]
    InputMap.action_add_event(target_action, axis_event)
