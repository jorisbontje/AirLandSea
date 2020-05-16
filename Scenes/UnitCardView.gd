extends Control

var focussed_card_nr = null
var selected_card = null

func _update_view():
  if focussed_card_nr != null:
    $NoCardSelected.visible = false
    $"unit-cards".visible = true
    $"unit-cards".frame = focussed_card_nr
  elif selected_card != null:
    $NoCardSelected.visible = false
    $"unit-cards".visible = true
    $"unit-cards".frame = selected_card.sprite_id
  else:
    $NoCardSelected.visible = true
    $"unit-cards".visible = false

func _on_Game_card_focussed(card_nr):
  focussed_card_nr = card_nr
  _update_view()

func _on_Game_card_selected(card):
  selected_card = card
  _update_view()
