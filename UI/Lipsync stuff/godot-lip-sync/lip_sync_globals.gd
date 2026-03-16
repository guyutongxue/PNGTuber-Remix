extends Node



signal file_state_changed()


signal file_data_changed(cause)



var file_name: = ""


var file_modified: = false


var file_data: LipSyncTraining = LipSyncTraining.new()


var speech_bus: int


var speech_spectrum: AudioEffectSpectrumAnalyzerInstance

func _ready() -> void :
    speech_spectrum = AudioServer.get_bus_effect_instance(2, 1)


func set_modified(cause):

    emit_signal("file_data_changed", cause)


    if not file_modified:
        file_modified = true
        emit_signal("file_state_changed")



func new_file():

    file_name = ""
    file_data = LipSyncTraining.new()
    file_modified = false


    emit_signal("file_state_changed")
    emit_signal("file_data_changed", "new")



func load_file(path: String):

    file_name = path
    Settings.theme_settings.lipsync_file_path = file_name
    file_data = ResourceLoader.load(file_name)
    file_modified = false

    emit_signal("file_state_changed")
    emit_signal("file_data_changed", "load")



func save_file():

    ResourceSaver.save(file_data.duplicate(true), file_name)
    Settings.theme_settings.lipsync_file_path = file_name
    file_modified = false


    emit_signal("file_state_changed")



func save_file_as(path: String):

    file_name = path
    save_file()



func file_display_name() -> String:

    var display_name: = "unnamed" if file_name == "" else file_name


    if file_modified:
        display_name = "*" + display_name


    return display_name
