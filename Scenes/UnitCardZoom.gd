extends Control

var focussed_card = null
var selected_card = null

func _update_view():
  if focussed_card != null:
    $UnitCardView.card = focussed_card
    $UnitCardView.visible = true
  elif selected_card != null:
    $UnitCardView.card = selected_card
    $UnitCardView.visible = true
  else:
    $UnitCardView.visible = false
    $NoCardSelected.visible = true

func deselect():
  focussed_card = null
  selected_card = null

func _on_Game_card_focussed(card):
  focussed_card = card
  _update_view()

func _on_Game_card_selected(card):
  selected_card = card
  _update_view()
