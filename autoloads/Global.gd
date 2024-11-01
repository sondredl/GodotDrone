extends Node


signal game_mode_changed


enum GameMode {FREE, RACE}
enum RaceState {START, RACE, END}


var packed_popup := preload("res://GUI/ConfirmationPopup.tscn")

var log_path := "user://output.log"

var startup := true

var highscore_path := "user://highscores.sav"

var config_dir_old := "user://config"
var config_dir := "user://config_G3"
var replay_dir_old := "user://replays"
var replay_dir := "user://replays_G3"

var game_mode: int = GameMode.FREE: set = set_game_mode
var active_track: Track = null


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("race_mode"):
        if game_mode == GameMode.FREE:
            self.game_mode = GameMode.RACE
        elif game_mode == GameMode.RACE:
            self.game_mode = GameMode.FREE


func initialize() -> void:
    var dir = DirAccess.new.call()
    if not dir.dir_exists(config_dir):
        if dir.dir_exists(config_dir_old):
            var _discard = dir.rename(config_dir_old, config_dir)
        else:
            var _discard = dir.make_dir(config_dir)
    if not dir.dir_exists(replay_dir):
        if dir.dir_exists(replay_dir_old):
            var _discard = dir.rename(replay_dir_old, replay_dir)
        else:
            var _discard = dir.make_dir(replay_dir)
    if not dir.file_exists(highscore_path):
        var file = FileAccess.new.call()
        var _discard = file.open(highscore_path, FileAccess.WRITE)
        file.close()

    startup = false


func get_formatted_date_time() -> String:
    var date_time := Time.get_datetime_dict_from_system()
    var time := "[%04d-%02d-%02d %02d:%02d:%02d]" % [date_time["year"], date_time["month"],
                                                     date_time["day"], date_time["hour"], date_time["minute"], date_time["second"]]
    return time


func show_error_popup(control: Control, error: String) -> void:
    var controller_dialog := packed_popup.instantiate()
    control.add_child(controller_dialog)
    controller_dialog.set_text(error)
    controller_dialog.set_buttons("OK")
    controller_dialog.show_modal(true)
    var _dialog = await controller_dialog.validated


func log_error(err_code: int, message: String="") -> void:
    var file = FileAccess.new.call()
    var _discard = file.open(log_path, FileAccess.WRITE_READ)
    file.store_line("%s ERROR %d: %s" %
                    [get_formatted_date_time(), err_code, message])
    file.close()


func set_game_mode(mode: int) -> void:
    if mode < GameMode.size():
        if mode == game_mode:
            return
        game_mode = mode
        emit_signal("game_mode_changed", game_mode)
