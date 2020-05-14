tool
extends Container

export var theater_type = 1 setget set_theater_type

onready var OpponentStack = find_node("OpponentStack")
onready var PlayerStack = find_node("PlayerStack")

func set_theater_type(new_theater_type):
  if new_theater_type != theater_type:
    theater_type = new_theater_type
    $VBoxContainer/TheaterCard.theater_type = theater_type

func clear():
  for c in OpponentStack.get_children():
    c.queue_free()
  for c in PlayerStack.get_children():
    c.queue_free()
