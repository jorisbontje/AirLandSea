extends Node

signal card_focussed
signal card_selected

enum {TH_AIR = 1, TH_LAND, TH_SEA}

var theaters = [TH_AIR, TH_LAND, TH_SEA]
var deck: Array
var default_deck: Array
var theater_lanes = []

onready var OpponentHand = find_node("OpponentHand")
onready var PlayerHand = find_node("PlayerHand")

onready var TheaterLane1 = find_node("TheaterLane1")
onready var TheaterLane2 = find_node("TheaterLane2")
onready var TheaterLane3 = find_node("TheaterLane3")

onready var PlayFaceupButton = find_node("PlayFaceupButton")
onready var PlayFacedownButton = find_node("PlayFacedownButton")

func _load_cards() -> Array:
  var file := File.new()
  file.open("res://cards.json", file.READ)
  var text = file.get_as_text()
  file.close()
  return parse_json(text)

func _new_game():
  deck = default_deck.duplicate()
  deck.shuffle()

  theaters.shuffle()
  for lane_nr in range(3):
    theater_lanes[lane_nr].theater_type = theaters[lane_nr]
    theater_lanes[lane_nr].clear()

  OpponentHand.clear()
  PlayerHand.clear()

  for i in range(6):
    OpponentHand.deal_card(deck.pop_back())
    PlayerHand.deal_card(deck.pop_back())

func _ready():
  print("READY PLAYER ONE")
  randomize()

  theater_lanes = [TheaterLane1, TheaterLane2, TheaterLane3]
  default_deck = _load_cards()
  _new_game()

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
  _new_game()

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
