tool
extends Button

onready var _window_dialog = $WindowDialog
var settings : EditorSettings

const adb_setting = "export/android/adb"
onready var adb_command = settings.get(adb_setting)

const settings_category = "ADBHelper"
const devices_setting = settings_category + "/devices"
const devices_property_info = {
			"name": devices_setting,
			"type": TYPE_DICTIONARY,
			"hint": "Established Devices",
			"hint_string": "{'device_name': 'ip'}",
		}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Do we have the adb?
	if not adb_setting:
		#We have a problem
		print("No ADB found under ", adb_setting)
		print("Please set it up in the Editor Settings!")
	
	#Make sure we have devices
	if not settings.has_setting(devices_setting):
		settings.set(devices_setting, 0)
		settings.add_property_1info(devices_property_info)
	
	#Get all of the devices
	var devices = settings.get(devices_setting)
	for device_name in devices:
		var device_ip = devices[device_name]
		_add_device(device_name, device_ip)

func _on_adb_helper_pressed():
	
	#Show the dialog
	if _window_dialog.visible:
		_window_dialog.hide()
	else:
		#Move the dialog
		_window_dialog.popup_centered()

func _add_device(device_name, device_ip):
	
	#Need to make three elements
	var device_container = HBoxContainer.new()
	
	#A label for the device
	var device_label = Label.new()
	device_label.text = device_name
	device_container.add_child(device_label)
	
	#An input field for the IP
	var device_text_edit = TextEdit.new()
	device_text_edit.text = device_ip
	device_text_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	device_container.add_child(device_text_edit)
	
	#And a connect button
	var device_button = Button.new()
	device_button.text = "Connect..."
	device_button.connect("pressed", self, "_on_device_connect_pressed", [device_name, device_ip])
	device_container.add_child(device_button)
	
	#Add it to the dialog
	$WindowDialog/DialogContainer/DeviceContainer.add_child(device_container)
	
	#Also add it to the settings
	
func _on_device_connect_pressed(device_name, device_ip):
	
	#Attempt to make the connection
	
	print("CONNECT", device_name, device_ip)
	print("adb: ", settings.get_setting(adb_setting))


func _on_AddButton_pressed():
	
	#Add the device
	var device_name = $WindowDialog/DialogContainer/AddDeviceContainer/DeviceTextEdit.text
	var device_ip = $WindowDialog/DialogContainer/AddDeviceContainer/IPTextEdit.text
	
	#Validate the input
	#TODO
	
	#Add it to the settings
	var device_property = {
		"name": device_name,
		"ip": device_ip
	}
	
	#Get the current devices
	var devices = settings.get_setting(devices_setting)
	devices.append(device_property)
	settings.set_setting(devices_setting, devices)