@tool
extends EditorPlugin

var is_project_initialized : bool = false

var team_suite_toolbar : Control

var git_url_input : LineEdit


var external_plugins = [
	"https://github.com/4d49/godot-console"
]

# Called when the plugin is enabled
func _enter_tree():
	team_suite_toolbar = VBoxContainer.new()
	
	download_plugins()

	if check_if_git_project():
		show_connected_project_toolbar(team_suite_toolbar)
	else: 
		show_import_project_toolbar(team_suite_toolbar)

	add_control_to_container(CONTAINER_TOOLBAR, team_suite_toolbar)

func download_plugins():
	for p in external_plugins:
		var plugin_name = get_submost_folder(p)
		var output = os_execute_stdout("ls addons")
		var is_installed = false
		for line : String in output:
			if line.contains(plugin_name):
				is_installed = true

		if !is_installed:
			os_execute("cd addons && git clone " + p, true)
			os_execute("rm -rf .git")

func _create_new_repo():
	var git_url = git_url_input.text.strip_edges()

	os_execute("git init")
	os_execute("git add -A")
	os_execute("git commit -am \"init commit\" ", true)
	os_execute("git branch -M main", true)
	os_execute("git remote add origin " + git_url, true)
	os_execute("git push -u origin main", true)

	refresh_plugin_state()

# Handle the clone button press
func _import_repo():
	var git_url = git_url_input.text.strip_edges()

	os_execute("git init")
	os_execute("git remote add origin " + git_url)
	os_execute("git fetch origin", true)
	os_execute("git reset --hard origin/main", true)
	os_execute("git clean -fd", true)
	
	reload_project_ui()

func show_connected_project_toolbar(team_suite_toolbar : VBoxContainer):
	var output = os_execute_stdout("git init")
	output = os_execute_stdout("git status")

	# Regex to extract the branch name
	var regex = RegEx.new()
	regex.compile("On branch (\\w+)")
	
	var branch_name = get_current_branch_name()
	
	var hbox = HBoxContainer.new()
	
	# Create a Label to display output messages
	var output_label = Label.new()
	output_label.text = "branch: " + branch_name
	hbox.add_child(output_label)
	
	## Create a Button to trigger the clone operation
	var push_button = Button.new()
	push_button.text = "Push"
	push_button.connect("pressed", func():
		os_execute("git pull origin main", true)
		os_execute("git add -A")
		os_execute("git commit -am 'na'")
		os_execute("git push origin main", true)
	)
	hbox.add_child(push_button)

	var pull_button = Button.new()
	pull_button.text = "Pull"
	pull_button.connect("pressed", func():
		os_execute("git pull origin main")
	)
	hbox.add_child(pull_button)
	
	team_suite_toolbar.add_child(hbox)

	
func reload_project_ui():
	#EditorInterface.get_script_editor().reload_scripts()
	print("you need to reload the current project from Project -> Reload Current Project")
	get_editor_interface().restart_editor()


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

func refresh_plugin_state():
	_exit_tree()
	_enter_tree()

func check_if_git_project():
	return os_execute("ls .git") == 0

func os_execute(cmd, print_output = false):
	var output = []
	var exit_code = OS.execute("bash", ["-c", cmd], output, true)
	if print_output:
		for i in output:
			print(i)
	return exit_code

func os_execute_stdout(cmd, print_output = false):
	var output = []
	var exit_code = OS.execute("bash", ["-c", cmd], output, true)
	if print_output:
		for i in output:
			print(i)
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
		return branch_name
	else:
		printerr("No branch name found.")
		return ""
		
func get_submost_folder(path: String) -> String:
	# Create a regular expression to match the submost folder
	var regex = RegEx.new()
	regex.compile("([^/]+)/?$")  # Match the last segment of the path

	# Search for the match
	var result = regex.search(path)
	if result:
		return result.get_string()  # Return the matched submost folder
	return ""  # Return an empty string if no match is found
