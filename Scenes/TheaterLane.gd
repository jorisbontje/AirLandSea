tool
extends Container

export var theater_type = 1 setget set_theater_type

func set_theater_type(new_theater_type):
  if new_theater_type != theater_type:
    theater_type = new_theater_type
    $VBoxContainer/TheaterCard.theater_type = theater_type
