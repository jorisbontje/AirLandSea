tool
extends Container

export var stack_height = 24 setget set_stack_height

func _notification(what):

  if (what==NOTIFICATION_SORT_CHILDREN):
    # Must re-sort the children
    var count = 0
    for c in get_children():
#      fit_child_in_rect( c, Rect2( Vector2(), rect_size ) )
#      fit_child_in_rect( c, Rect2( Vector2(8, stack_height), rect_size ) )
      c.rect_position = count * Vector2(0, stack_height)
      count += 1
#    self.rect_size = get_child(0).rect_size + (count-1)* Vector2(8, stack_height)

func set_stack_height(new_stack_height):
  if stack_height != new_stack_height:
    stack_height = new_stack_height
  # Some setting changed, ask for children re-sort
  queue_sort()
