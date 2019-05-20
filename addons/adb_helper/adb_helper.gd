tool
extends Button

onready var _window_dialog = $WindowDialog
var settings : EditorSettings

#ADB command values
const adb_setting = "export/android/adb"
onready var adb_command = settings.get(adb_setting)
const port_setting = "5555"
onready var adb_port = settings

#Settings values
const settings_category = "ADBHelper"
const devices_setting = settings_category + "/devices"
const devices_property_info = {
			"name": devices_setting,
			"type": TYPE_DICTIONARY,
			"hint": "Established Devices",
			"hint_string": "{'device_name': 'ip'}",
		}

#Validation
const ip_regex = "^[012]?\\d?\\d\\.[012]?\\d?\\d\\.[012]?\\d?\\d\\.[012]?\\d?\\d$"
onready var regex = RegEx.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Compile regex
	regex.compile(ip_regex)

	#Do we have the adb?
	if not adb_setting:
		#We have a problem
		print("No ADB found under ", adb_setting)
		print("Please set it up in the Editor Settings!")
	
	#Show the port
	$WindowDialog/DialogContainer/ExtraContainer/PortLabel.text = "Port: " + port_setting + " (added to IP)"
	
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
	
	#Delete button
	var delete_button = Button.new()
	delete_button.text = "X"
	delete_button.connect("pressed", self, "_on_delete_button_pressed", [device_container])
	device_container.add_child(delete_button)
	
	#Add it to the dialog
	$WindowDialog/DialogContainer/DeviceContainer.add_child(device_container)
	

func _on_device_connect_pressed(device_name, device_ip):
	
	#Attempt to make the connection
	var full_ip = device_ip + ":" + port_setting
	print("Attempting to connect to ", device_name, " ", full_ip)
	
	#Validate the input
	if not regex.search(device_ip):
		#Fake!
		print("Invalid IP!")
		return

	#TODO: Error handling!!
	OS.execute(adb_setting, ['tcpip', port_setting], true)
	OS.execute(adb_setting, ['connect', full_ip], true)

func _on_delete_button_pressed(container):
	
	#Get the device name
	var device_name = container.get_child(0).text
	
	#Kill it
	var devices = settings.get_setting(devices_setting)
	devices.erase(device_name)
	settings.set_setting(devices_setting, devices)
	
	container.queue_free()
	

func _on_AddButton_pressed():
	
	#Add the device
	var device_name = $WindowDialog/DialogContainer/AddDeviceContainer/DeviceTextEdit.text
	var device_ip = $WindowDialog/DialogContainer/AddDeviceContainer/IPTextEdit.text
	
	#Validate the input
	if not regex.search(device_ip):
		#Fake!
		print("Invalid IP!")
		return
	
	#Get the current devices
	var devices = settings.get_setting(devices_setting)
	devices[device_name] = device_ip
	settings.set_setting(devices_setting, devices)
	
	#Show new device
	_add_device(device_name, device_ip)

func _on_HelpButton_pressed():
	
	#Bring up the page
	OS.shell_open("https://github.com/DevinPentecost/godot-adb-helper/blob/master/addons/adb_helper/README.md")
