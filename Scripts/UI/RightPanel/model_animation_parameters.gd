extends GridContainer

enum ModelAnimationType {
	MouthClosed,
	MouthOpen,
}

@export var type : ModelAnimationType

const KEY_X_FREQ_WOBBLE := "TR_X_FREQUENCY_WOBBLE"
const KEY_X_AMP_WOBBLE  := "TR_X_AMPLITUDE_WOBBLE"
const KEY_Y_FREQ_WOBBLE := "TR_Y_FREQUENCY_WOBBLE"
const KEY_Y_AMP_WOBBLE  := "TR_Y_AMPLITUDE_WOBBLE"

func _ready() -> void:
	await get_tree().current_scene.ready
	%BounceAmountSlider.get_node("%SliderValue").value_changed.connect(_on_bounce_amount_slider_value_changed)
	%GravityAmountSlider.get_node("%SliderValue").value_changed.connect(_on_gravity_amount_slider_value_changed)
	Global.update_anim.connect(set_data)
	set_data()

func set_data():
	if type == ModelAnimationType.MouthClosed:
		%BounceAmountSlider.get_node("%SliderValue").value = 800
		%GravityAmountSlider.get_node("%SliderValue").value = 3000
		%BounceAmountSlider.get_node("%SpinBoxValue").value = 800
		%GravityAmountSlider.get_node("%SpinBoxValue").value = 3000

		%XFreqWobbleSlider.value = 0.45
		%XAmpWobbleSlider.value = 5.0
		%YFreqWobbleSlider.value = 0.48
		%YAmpWobbleSlider.value = 5.04

	if type == ModelAnimationType.MouthOpen:
		%BounceAmountSlider.get_node("%SliderValue").value = 800
		%GravityAmountSlider.get_node("%SliderValue").value = 3000
		%BounceAmountSlider.get_node("%SpinBoxValue").value = 800
		%GravityAmountSlider.get_node("%SpinBoxValue").value = 3000
		%XFreqWobbleSlider.value = 0.45
		%XAmpWobbleSlider.value = 5.0
		%YFreqWobbleSlider.value = 0.48
		%YAmpWobbleSlider.value = 5.04

func _on_bounce_amount_slider_value_changed(value):
	var fixed_value = 800
	if type == ModelAnimationType.MouthClosed:
		Global.sprite_container.state_param_mc.bounce_energy = fixed_value
		%BounceAmountSlider.get_node("%SpinBoxValue").value = fixed_value
	if type == ModelAnimationType.MouthOpen:
		Global.sprite_container.state_param_mo.bounce_energy = fixed_value
		%BounceAmountSlider.get_node("%SpinBoxValue").value = fixed_value
	Global.sprite_container.save_state(Global.current_state)
	
#	%BounceAmount.text = "Bounce Amount : " + str(value)

func _on_gravity_amount_slider_value_changed(value):
	var fixed_value = 3000
	if type == ModelAnimationType.MouthClosed:
		Global.sprite_container.state_param_mc.bounce_gravity = fixed_value
		%GravityAmountSlider.get_node("%SpinBoxValue").value = fixed_value
	if type == ModelAnimationType.MouthOpen:
		Global.sprite_container.state_param_mo.bounce_gravity = fixed_value
		%GravityAmountSlider.get_node("%SpinBoxValue").value = fixed_value
	Global.sprite_container.save_state(Global.current_state)

func _on_x_freq_wobble_slider_value_changed(value):
	var fixed_value = 0.45
	if type == ModelAnimationType.MouthClosed:
		Global.sprite_container.state_param_mc.xFrq = fixed_value
	if type == ModelAnimationType.MouthOpen:
		Global.sprite_container.state_param_mo.xFrq = fixed_value

	%XFreqWobbleLabel.text = tr(KEY_X_FREQ_WOBBLE).format({ "value": fixed_value })
	Global.sprite_container.save_state(Global.current_state)

func _on_x_amp_wobble_slider_value_changed(value):
	var fixed_value = 5.0
	if type == ModelAnimationType.MouthClosed:
		Global.sprite_container.state_param_mc.xAmp = fixed_value
	if type == ModelAnimationType.MouthOpen:
		Global.sprite_container.state_param_mo.xAmp = fixed_value

	%XAmpWobbleLabel.text = tr(KEY_X_AMP_WOBBLE).format({ "value": fixed_value })
	Global.sprite_container.save_state(Global.current_state)

func _on_y_freq_wobble_slider_value_changed(value):
	var fixed_value = 0.48
	if type == ModelAnimationType.MouthClosed:
		Global.sprite_container.state_param_mc.yFrq = fixed_value
	if type == ModelAnimationType.MouthOpen:
		Global.sprite_container.state_param_mo.yFrq = fixed_value

	%YFreqWobbleLabel.text = tr(KEY_Y_FREQ_WOBBLE).format({ "value": fixed_value })
	Global.sprite_container.save_state(Global.current_state)

func _on_y_amp_wobble_slider_value_changed(value):
	var fixed_value = 5.04
	if type == ModelAnimationType.MouthClosed:
		Global.sprite_container.state_param_mc.yAmp = fixed_value
	if type == ModelAnimationType.MouthOpen:
		Global.sprite_container.state_param_mo.yAmp = fixed_value

	%YAmpWobbleLabel.text = tr(KEY_Y_AMP_WOBBLE).format({ "value": fixed_value })
	Global.sprite_container.save_state(Global.current_state)
