tool
extends Container

# TODO globals?
enum SIDES {OPPONENT, PLAYER}

export var theater_type = 1 setget set_theater_type

onready var OpponentStack = find_node("OpponentStack")
onready var PlayerStack = find_node("PlayerStack")
onready var UnitCard = preload("res://Scenes/UnitCard.tscn")
onready var TheaterCard = find_node("TheaterCard")

func _ready():
  TheaterCard.theater_type = theater_type

func set_theater_type(new_theater_type):
  if new_theater_type != theater_type:
    theater_type = new_theater_type
    if TheaterCard:
      TheaterCard.theater_type = theater_type

func clear():
  for c in OpponentStack.get_children():
    c.queue_free()
  for c in PlayerStack.get_children():
    c.queue_free()

func deselect():
  TheaterCard.selected = false

func play_card(side, card):
  var c = UnitCard.instance()
  c.card = card
  if side == SIDES.OPPONENT:
    OpponentStack.add_child(c)
  elif side == SIDES.PLAYER:
    PlayerStack.add_child(c)
