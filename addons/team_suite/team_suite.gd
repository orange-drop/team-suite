@tool
extends EditorPlugin

var is_project_initialized : bool = false

var team_suite_toolbar : Control

var git_url_input : LineEdit

# Called when the plugin is enabled
func _enter_tree():
	team_suite_toolbar = VBoxContainer.new()

	if check_if_git_project():
		show_connected_project_toolbar(team_suite_toolbar)
	else: 
		show_import_project_toolbar(team_suite_toolbar)

	add_control_to_container(CONTAINER_TOOLBAR, team_suite_toolbar)
	

func _create_new_repo():
	var git_url = git_url_input.text.strip_edges()

	os_execute("git init")
	os_execute("git add -A")
	os_execute("git commit -am \"init commit\" ")
	os_execute("git branch -M main")
	os_execute("git remote add origin " + git_url)
	os_execute("git push -u origin main")
	_exit_tree()
	_enter_tree()

# Handle the clone button press
func _import_repo():
	var git_url = git_url_input.text.strip_edges()

	#if git_url.empty():
		#output_label.text = "Error: Please paste a Git URL."
		#return
	print("clone button pressed", git_url)

	## Construct the Git clone command
	#var command = "git clone " + git_url
	#var output = []
	#var exit_code = OS.execute("bash", ["-c", command], true, output)
	#
	## Display the output
	#if exit_code == 0:
		#output_label.text = "Repository cloned successfully!\n" + "\n".join(output)
	#else:
		#output_label.text = "Error cloning repository:\n" + "\n".join(output)
	

func show_connected_project_toolbar(team_suite_toolbar : VBoxContainer):
	var output = os_execute_stdout("git init")
	output = os_execute_stdout("git status")

	# Regex to extract the branch name
	var regex = RegEx.new()
	regex.compile("On branch (\\w+)")
	
	var branch_name = get_current_branch_name()
	print("branch name from conncted")


func show_import_project_toolbar(team_suite_toolbar : VBoxContainer):
	git_url_input = LineEdit.new()
	git_url_input.placeholder_text = "Paste Git URL here"
	git_url_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	team_suite_toolbar.add_child(git_url_input)
	
	var hbox = HBoxContainer.new()

	## Create a Button to trigger the clone operation
	var clone_button = Button.new()
	clone_button.text = "Import Project"
	clone_button.connect("pressed", _import_repo)
	
	var new_button = Button.new()
	new_button.text = "New Project"
	new_button.connect("pressed", _create_new_repo)

	hbox.add_child(clone_button)
	hbox.add_child(new_button)
	
	team_suite_toolbar.add_child(hbox)


func check_if_git_project():
	return os_execute("ls .git") == 0

func os_execute(cmd):
	return OS.execute("bash", ["-c", cmd])

func os_execute_stdout(cmd):
	var output = []
	var exit_code = OS.execute("bash", ["-c", cmd], output)
	return output

# Called when the plugin is disabled
func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, team_suite_toolbar)

func get_current_branch_name():
	var output = os_execute_stdout("git status")

	# Regex to extract the branch name
	var regex = RegEx.new()
	regex.compile("On branch (\\w+)")

	# Search for the branch name
	var result = regex.search(output[0])

	# Check if a match was found
	if result:
		var branch_name = result.get_string(1)
		# Create a Label to display output messages
		var output_label = Label.new()
		output_label.text = branch_name
		team_suite_toolbar.add_child(output_label)
		return branch_name
	else:
		print("No branch name found.")
		return ""
