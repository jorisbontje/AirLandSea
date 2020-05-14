extends Node

signal card_focussed
signal card_selected

var cards: Array

onready var PlayFaceupButton = find_node("PlayFaceupButton")
onready var PlayFacedownButton = find_node("PlayFacedownButton")

func _load_cards() -> Array:
  var file := File.new()
  file.open("res://cards.json", file.READ)
  var text = file.get_as_text()
  file.close()
  return parse_json(text)

func _ready():
  print("READY PLAYER ONE")
  randomize()

  cards = _load_cards()
  cards.shuffle()

func card_focussed(card_nr):
  emit_signal("card_focussed", card_nr)

func card_selected(card_nr):
  emit_signal("card_selected", card_nr)

  if card_nr == null:
    PlayFaceupButton.disabled = true
    PlayFacedownButton.disabled = true
  else:
    PlayFaceupButton.disabled = false
    PlayFacedownButton.disabled = false

func theater_selected(theater_type):
  pass

func _on_NewGameButton_pressed():
  print("NEW GAME")

func _on_PlayFaceupButton_pressed():
  print("PLAY FACEUP")

func _on_PlayFacedownButton_pressed():
  print("PLAY FACEDOWN")

func _on_WithdrawButton_pressed():
  print("WITHDRAW")

func _input(event):
  if Input.is_action_pressed("ui_cancel"):
    get_tree().quit()

func _on_CenterContainer_gui_input(event):
  if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
    card_selected(null)
