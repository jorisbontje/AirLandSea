tool
extends Container

export var theater_type = 1 setget set_theater_type
export var opponent_strength = 1 setget set_opponent_strength
export var player_strength = 1 setget set_player_strength

onready var OpponentStack = find_node("OpponentStack")
onready var PlayerStack = find_node("PlayerStack")
onready var OpponentStrength = find_node("OpponentStrength")
onready var PlayerStrength = find_node("PlayerStrength")
onready var UnitCard = preload("res://Scenes/UnitCard.tscn")
onready var TheaterCard = find_node("TheaterCard")

func _ready():
  TheaterCard.theater_type = theater_type
  OpponentStrength.text = str(opponent_strength)
  PlayerStrength.text = str(player_strength)

func set_theater_type(new_theater_type):
  if new_theater_type != theater_type:
    theater_type = new_theater_type
    if TheaterCard:
      TheaterCard.theater_type = theater_type

func set_opponent_strength(new_opponent_strength):
  opponent_strength = new_opponent_strength
  if OpponentStrength:
    OpponentStrength.text = str(opponent_strength)

func set_player_strength(new_player_strength):
  player_strength = new_player_strength
  if PlayerStrength:
    PlayerStrength.text = str(player_strength)

func clear():
  for c in OpponentStack.get_children():
    c.queue_free()
  for c in PlayerStack.get_children():
    c.queue_free()
  set_opponent_strength(0)
  set_player_strength(0)

func select():
  TheaterCard._on_TheaterCard_pressed()

func deselect():
  TheaterCard.selected = false

func play_card(side, card):
  var c = UnitCard.instance()
  c.card = card
  var strength = card.strength
  if not card.faceup:
    strength = Globals.FACEDOWN_STRENGTH
  if side == Globals.SIDES.OPPONENT:
    OpponentStack.add_child(c)
    set_opponent_strength(opponent_strength + strength)
  elif side == Globals.SIDES.PLAYER:
    PlayerStack.add_child(c)
    set_player_strength(player_strength + strength)
