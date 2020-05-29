extends Control

const Constants = preload("res://Scripts/Constants.gd")

var focussed_card = null
var selected_card = null

func _card_view(card):
  $NoCardSelected.visible = false
#  $"unit-cards".visible = true
  $"unit-cards".frame = card.sprite_id
  $Background.visible = true
  $StrengthLabel.visible = true
  if card.faceup:
    $AbilityLabel.visible = true
    $Background.color = Constants.THEATER_COLORS[card.type]
    $StrengthLabel.text = str(card.strength)
    $AbilityLabel.text = card.get("ability", "")
    $"DescriptionBox/Description".text = card.get("description", "")
    # TODO replace with icons
    if "duration" in card:
      if card.duration == "ongoing":
        $AbilityLabel.text = "∞ " + $AbilityLabel.text
        $AbilityLabel.set("custom_colors/font_color", Color.white)
      elif card.duration == "instant":
        $AbilityLabel.text = "! " + $AbilityLabel.text
        $AbilityLabel.set("custom_colors/font_color", Color.black)
    $BackLabel.visible = false
    $DescriptionBox.visible = true
  else:
    $Background.color = Constants.THEATER_COLORS[Constants.THEATERS.NONE]
    $StrengthLabel.text = "2"
    $AbilityLabel.visible = false
    $BackLabel.visible = true
    $DescriptionBox.visible = false

func _update_view():
  if focussed_card != null:
    _card_view(focussed_card)
  elif selected_card != null:
    _card_view(selected_card)
  else:
    $NoCardSelected.visible = true
    $"unit-cards".visible = false
    $Background.visible = false
    $StrengthLabel.visible = false
    $AbilityLabel.visible = false
    $BackLabel.visible = false
    $DescriptionBox.visible = false

func deselect():
  focussed_card = null
  selected_card = null
  _update_view()

func _on_Game_card_focussed(card):
  focussed_card = card
  _update_view()

func _on_Game_card_selected(card):
  selected_card = card
  _update_view()
