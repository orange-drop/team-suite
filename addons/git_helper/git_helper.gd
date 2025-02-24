@tool
extends EditorPlugin

# Define the buttons and their corresponding Git commands
var git_commands = {
	"Pull": "git pull",
	"Push": "git push",
	"Commit": "git commit -m 'Auto-commit from Godot'",
	"Status": "git status"
}

var toolbarRef : Control

# Called when the plugin is enabled
func _enter_tree():
	# Create a toolbar container
	var toolbar = HBoxContainer.new()

	# Add buttons for each Git command
	for command_name in git_commands:
		var button = Button.new()
		button.text = command_name
		button.connect("pressed", _on_button_pressed(git_commands[command_name]))
		toolbar.add_child(button)
		
	var vbox = VBoxContainer.new()

	var git_url_input = "hi"
	# Create a LineEdit for the Git URL
	git_url_input = LineEdit.new()
	git_url_input.placeholder_text = "Paste Git URL here ❤️"
	git_url_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(git_url_input)

	# Create a Button to trigger the clone operation
	var clone_button = Button.new()
	clone_button.text = "Clone Repository"
	#clone_button.connect("pressed", self, "_on_clone_button_pressed")
	vbox.add_child(clone_button)

	# Create a Label to display output messages
	var output_label = Label.new()
	output_label.text = "Output will appear here"
	vbox.add_child(output_label)
	
	# Add the toolbar to the editor's top bar
	#add_control_to_container(CONTAINER_TOOLBAR, toolbar)
	add_control_to_container(CONTAINER_TOOLBAR, vbox)
	toolbarRef = toolbar

# Called when the plugin is disabled
func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, toolbarRef)

# Handle button presses
func _on_button_pressed(command) -> Callable:
	return func ():
		var output = []
		var exit_code = OS.execute("bash", ["-c", command], output)
		## Display the output in the editor's output log
		if exit_code == 0:
			print("Git command succeeded: ", command)
			for line in output:
				print(line)
		else:
			print("Git command failed: ", command)
			for line in output:
				print(line)
