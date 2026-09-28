class_name StartMenu extends Control

const GAME_SCENE := "res://scenes/split_screen/static_split_screen.tscn"

@export var pause_menu := false

var player_options: Dictionary = {}
var player_rows: Dictionary = {}
var player_count_option: OptionButton
var status_label: Label


func _ready() -> void:
  var background := ColorRect.new()
  background.color = Color(0.025, 0.035, 0.065, 1.0)
  background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  background.mouse_filter = Control.MOUSE_FILTER_IGNORE
  add_child(background)

  var center := CenterContainer.new()
  center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  add_child(center)

  var layout := VBoxContainer.new()
  layout.add_theme_constant_override("separation", 14)
  layout.custom_minimum_size.x = 440
  center.add_child(layout)

  var title := Label.new()
  title.text = "METAL WARRIORS"
  title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  title.add_theme_font_size_override("font_size", 32)
  layout.add_child(title)

  var subtitle := Label.new()
  subtitle.text = "CONTROLES"
  subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  layout.add_child(subtitle)

  if not pause_menu:
    var count_row := HBoxContainer.new()
    layout.add_child(count_row)

    var count_label := Label.new()
    count_label.text = "Jogadores"
    count_label.custom_minimum_size.x = 110
    count_row.add_child(count_label)

    player_count_option = OptionButton.new()
    player_count_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    for player_count in GameInput.PLAYER_COUNTS:
      player_count_option.add_item("%d jogadores" % player_count, player_count)
    player_count_option.select(player_count_option.get_item_index(GameInput.active_player_count))
    player_count_option.item_selected.connect(_on_player_count_selected)
    count_row.add_child(player_count_option)

  var player_rows_container := VBoxContainer.new()
  layout.add_child(player_rows_container)

  for player_slot in GameInput.PLAYER_SLOTS:
    var row := HBoxContainer.new()
    row.visible = player_slot <= GameInput.active_player_count
    player_rows_container.add_child(row)
    player_rows[player_slot] = row

    var label := Label.new()
    label.text = "Jogador %d" % player_slot
    label.custom_minimum_size.x = 110
    row.add_child(label)

    var option := OptionButton.new()
    option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    option.item_selected.connect(_on_player_option_selected.bind(player_slot, option))
    row.add_child(option)
    player_options[player_slot] = option

  status_label = Label.new()
  status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  layout.add_child(status_label)

  var start_button := Button.new()
  start_button.text = "Retomar" if pause_menu else "Iniciar"
  if pause_menu:
    start_button.pressed.connect(_resume_game)
  else:
    start_button.pressed.connect(_start_game)
  layout.add_child(start_button)
  start_button.grab_focus()

  GameInput.devices_changed.connect(_refresh_options)
  _refresh_options()


func _refresh_options() -> void:
  for player_slot in GameInput.PLAYER_SLOTS:
    var option: OptionButton = player_options[player_slot]
    var row: HBoxContainer = player_rows[player_slot]
    row.visible = player_slot <= GameInput.active_player_count
    option.clear()
    option.add_item("Automático", GameInput.AUTO_DEVICE)
    option.add_item("Teclado", GameInput.KEYBOARD_DEVICE)
    for device_id in Input.get_connected_joypads():
      var name := Input.get_joy_name(device_id)
      option.add_item("Controle %d - %s" % [device_id + 1, name], device_id)

    var selected_id := GameInput.AUTO_DEVICE
    if not GameInput.is_auto_assigned(player_slot):
      selected_id = GameInput.get_player_device(player_slot)
    var selected_index := option.get_item_index(selected_id)
    if selected_index >= 0:
      option.select(selected_index)

  var connected_count := Input.get_connected_joypads().size()
  status_label.text = "%d controle(s) detectado(s)" % connected_count


func _on_player_count_selected(_index: int) -> void:
  GameInput.set_active_player_count(player_count_option.get_selected_id())
  _refresh_options()


func _on_player_option_selected(_index: int, player_slot: int, option: OptionButton) -> void:
  GameInput.set_player_device(player_slot, option.get_selected_id())


func _start_game() -> void:
  var error := get_tree().change_scene_to_file(GAME_SCENE)
  if error != OK:
    push_error("Could not open game scene: %s" % GAME_SCENE)


func _resume_game() -> void:
  GameInput.resume_game()
