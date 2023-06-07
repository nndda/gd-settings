extends Control

@export_subgroup("Display")
@export var resolutions_available : PackedVector2Array = [
    Vector2i( 1920, 1080 ),
    Vector2i( 1280, 720 ),
    Vector2i( 800, 600 ), ]
@export var target_fps_available : PackedInt32Array = [
    30, 60, 120 ]
#   Adjustments modify WorldEnvironment's Environment, which require Mobile or Forward+ rendering method
@export_file("*.tres","*.res") var world_environment


@export_subgroup("Controls")
#   by default, it will get all action set in input map in project settings, excluding all the defaults.
#   assign a value to action_string or action_string_excludes to override this
@export var actions_override : Array[StringName] = []
@export var actions_override_exclude : Array[StringName] = []
var action_map : Array[StringName] = []




@onready var display_items : Control = $TabContainer/Display/Items

@onready var controls_keybinds : Control = $TabContainer/Controls/Items
@onready var controls_item_template : Control = $TabContainer/Controls/Items/Template


func build_display() -> void:
    var resolution : OptionButton = display_items.get_node("Resolution/HBoxContainer/OptionButton") as OptionButton
    resolution.clear()
    for res in resolutions_available.size():
        resolution.add_item(
            str(resolutions_available[res].x) + " x " +
            str(resolutions_available[res].y) , res )
            
    var target_fps : OptionButton = display_items.get_node("Target FPS/HBoxContainer/OptionButton") as OptionButton

    target_fps.clear()
    target_fps.add_item( "VSync", -1 )
    for fps in target_fps_available.size():
        target_fps.add_item( str(target_fps_available[fps]), fps )
    target_fps.add_item( "Unlimited", target_fps_available.size() + 1 )





func build_controls() -> void:
    var defaults : Array[StringName] = [
        &"ui_accept", &"ui_select", &"ui_cancel", &"ui_focus_next", &"ui_focus_prev", &"ui_left", &"ui_right", &"ui_up", &"ui_down", &"ui_page_up", &"ui_page_down", &"ui_home", &"ui_end", &"ui_cut", &"ui_copy", &"ui_paste", &"ui_undo", &"ui_redo", &"ui_text_completion_query", &"ui_text_completion_accept", &"ui_text_completion_replace", &"ui_text_newline", &"ui_text_newline_blank", &"ui_text_newline_above", &"ui_text_indent", &"ui_text_dedent", &"ui_text_backspace", &"ui_text_backspace_word", &"ui_text_backspace_word.macos", &"ui_text_backspace_all_to_left", &"ui_text_backspace_all_to_left.macos", &"ui_text_delete", &"ui_text_delete_word", &"ui_text_delete_word.macos", &"ui_text_delete_all_to_right", &"ui_text_delete_all_to_right.macos", &"ui_text_caret_left", &"ui_text_caret_word_left", &"ui_text_caret_word_left.macos", &"ui_text_caret_right", &"ui_text_caret_word_right", &"ui_text_caret_word_right.macos", &"ui_text_caret_up", &"ui_text_caret_down", &"ui_text_caret_line_start", &"ui_text_caret_line_start.macos", &"ui_text_caret_line_end", &"ui_text_caret_line_end.macos", &"ui_text_caret_page_up", &"ui_text_caret_page_down", &"ui_text_caret_document_start", &"ui_text_caret_document_start.macos", &"ui_text_caret_document_end", &"ui_text_caret_document_end.macos", &"ui_text_caret_add_below", &"ui_text_caret_add_below.macos", &"ui_text_caret_add_above", &"ui_text_caret_add_above.macos", &"ui_text_scroll_up", &"ui_text_scroll_up.macos", &"ui_text_scroll_down", &"ui_text_scroll_down.macos", &"ui_text_select_all", &"ui_text_select_word_under_caret", &"ui_text_select_word_under_caret.macos", &"ui_text_add_selection_for_next_occurrence", &"ui_text_clear_carets_and_selection", &"ui_text_toggle_insert_mode", &"ui_menu", &"ui_text_submit", &"ui_graph_duplicate", &"ui_graph_delete", &"ui_filedialog_up_one_level", &"ui_filedialog_refresh", &"ui_filedialog_show_hidden", &"ui_swap_input_direction"]
    var actions : Array[StringName] = []
    
    for action in InputMap.get_actions():
        if !defaults.has(action):
            actions.append(action)

    for i in actions_override:
        if InputMap.has_action(i):
            actions.append(i)
        else: push_error( i + " in actions_override is not assigned in Input Map. go to Project Setting > Input Map > Add New Action" )

    for e in actions_override_exclude:
        if InputMap.has_action(e):
            actions.erase(e)
        else: push_error( e + " in actions_override_exclude is not assigned in Input Map. go to Project Setting > Input Map > Add New Action" )

    for ctrl in actions:
        var ctrl_item       : Control = controls_item_template.duplicate()
        var ctrl_btn        : Control = ctrl_item.get_node("HBoxContainer/Button")
        var ctrl_evemts     : Array[InputEvent] = InputMap.action_get_events(ctrl)
        
        for event in ctrl_evemts:
            var event_btn : Control = ctrl_btn.duplicate()
            event_btn.text = event.as_text()
            ctrl_item.get_node("HBoxContainer").add_child(event_btn)

        ctrl_item.get_node("Label").text = str(ctrl)
        controls_keybinds.add_child(ctrl_item)
        ctrl_btn.queue_free()
    
    controls_item_template.queue_free()

func _ready():
    build_display()
    build_controls()


func _on_set_resolution(index):
    pass

func _on_set_display_mode(index):
    match index:
        0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    print( "Display set to " + $TabContainer/Display/Items/Mode/HBoxContainer/OptionButton.get_item_text(index) )

func _on_set_fps(index):
    DisplayServer.window_set_vsync_mode( DisplayServer.VSYNC_DISABLED )
    if index == -1:
        Engine.max_fps = 0
        DisplayServer.window_set_vsync_mode( DisplayServer.VSYNC_ENABLED )
        print("VSync enabled")
    elif index == target_fps_available.size() + 1:
        Engine.max_fps = 0
        print("Target fps set to unlimited")
    else:
        Engine.max_fps = target_fps_available[index]
        print("Target fps set to " + str(target_fps_available[index]))

