#!/bin/bash
# autogit4unimoose.sh
# source ./debug_on.sh
# debug_on
./a.sh # deletas all for a restart
declare -g owner_slash_repo_global_var_set_onload_kigit github_pages_repo_url
declare -gA global_conf

# Fun and colorful output with emojis
# Set up colors and formatting
fun_echo() {
  echo -e "\e[1;${3:-32}m$2 $1 \e[0m"
}

# Function to initialize a new Git repository in the current directory
init_git_repo_local() {

[[ -d .git ]] || { 
    git init -b main; 
    echo "Initialized a new Git repository!"; 
    git add .
git commit -m "Initial commit"
}
if [[ ! -f .gitignore ]]; then
touch .gitignore
echo "Created .gitignore!"
git add .
git commit -m "Git ignore added"
fi

}

# Function to change to an existing branch or create a new one
change_or_create_new_branch() {
local branch=${1:-main}
if ! git rev-parse --verify "$branch" &>/dev/null; then
git checkout -b "$branch"
echo "Created and switched to new branch: $branch"
else
git checkout "$branch"
echo "Switched to existing branch: $branch"
fi
}

# Function to create a new GitHub repository
create_repo() {
    local repo_name=$1
    local owner=$2
    local visibility=${3:-private}
    local branch=${4:-main}

    if gh repo view "$owner_slash_repo_global_var_set_onload_kigit" &>/dev/null; then
        echo "Repository $repo_name already exists. Updating..."
        update_repo "$owner_slash_repo_global_var_set_onload_kigit"
    else
        echo "Creating new repository: $repo_name"
        if [[ "$visibility" == "public" ]]; then
            visibility_flag="--public"
        else
            visibility_flag="--private"
        fi
       # if gh repo create "${owner_slash_repo_global_var_set_onload_kigit}" $visibility_flag --default-branch "$branch"; then
    if gh repo create "${owner_slash_repo_global_var_set_onload_kigit}" $visibility_flag; then
    echo "Created GitHub repository: $repo_name"
    # Set default branch after creation
    gh repo edit "${owner_slash_repo_global_var_set_onload_kigit}" --default-branch "$branch"
    echo "Default branch set to $branch"

    git remote add origin "https://github.com/${owner_slash_repo_global_var_set_onload_kigit}.git"
    update_repo "$owner_slash_repo_global_var_set_onload_kigit"
else
    echo "Failed to create repository. Please check your permissions and try again."
    exit 1
fi
    fi
}
update_repo_homepage() {
  local owner_slash_repo_global_var_set_onload_kigit=$1

  local owner="${GITHUB_USER:-$(git config user.name)}"
  local description=${global_conf[set303f]}
  local homepage=${global_conf[set303g]}

  # Update repository description
  gh repo edit --description "$description"

  # Update repository homepage
  gh repo edit --homepage "$homepage"

  fun_echo "Updated repository homepage and description!" "📚" 33
}
update_repo_topics() {
  local owner_slash_repo_global_var_set_onload_kigit=$1
  local topics=${global_conf[set303e]}

  # Remove existing topics
  #gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --remove-all-topics

  # Add new topics
  IFS=',' read -ra topic_array <<< "$topics"
  for topic in "${topic_array[@]}"; do
    sanitized_topic=$(echo "$topic" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    if [[ $sanitized_topic =~ ^[a-z0-9][a-z0-9-]{0,49}$ ]]; then
      gh repo edit --add-topic "$sanitized_topic"
    else
      fun_echo "Invalid topic: $topic. Topics must start with a lowercase letter or number, consist of 50 characters or less, and can include hyphens." "❌" 31
    fi
  done

  fun_echo "Updated repository topics!" "🏷️" 33
}
# Function to update a GitHub repository
update_repo() {
    local owner_slash_repo_global_var_set_onload_kigit=$1
    local branch=${global_conf[set303j]:-main}


git add .
git commit -m "committi pitti"
git push -u origin main
#git push -u origin main --force

    fun_echo "Updating GitHub repository: $owner_slash_repo_global_var_set_onload_kigit" "🔄" 33

    # Check if the branch exists on the remote repository
    if ! git ls-remote --heads "https://github.com/$owner_slash_repo_global_var_set_onload_kigit.git" | grep -q "refs/heads/$branch"; then
        echo "trying this....";
        # Create the branch on the remote repository if it doesn't exist
        git push --set-upstream origin ":refs/heads/$branch"
    fi

    # Push changes to the remote branch
    git push origin "$branch" --force
    if [[ $? -ne 0 ]]; then
        fun_echo "Failed to push the latest changes to the remote branch. Please check the branch and try again." "⚠️" 33
        exit 1
    fi
    fun_echo "Changes synced with GitHub!" "🌍" 32
    return 0
}
# Function to create kigit.txt if it doesn't exist
create_config_f_kigit() {
local config_file=kigit.txt
if [[ ! -f "$config_file" ]]; then
local template_file=$(dirname "$0")/templates/a_1_template_kigit4.txt
local repo_name=$(basename "$PWD")
local owner="${GITHUB_USER:-$(git config user.name)}"
github_pages_repo_url="https://$owner.github.io/$repo_name"

mkdir -p $(dirname "$template_file")
cat > "$template_file" <<EOL
# This is a config file for the auto_git_unicorn_moose_feather ..
# File: kigit.txt

# Update()
set303a=y

# Verbose, output for each terminal run, y for yes and n for no
set303i=y

# git-reponame (empty for current folder name, 'random' for a random name)
set303b=$repo_name

# public git (private for private, public for public)
set303c=private

# auto generate HTML page, y for yes and n for no
set303d=y

# tags, separated by commas
set303e=Git, Bash, Automation, Automagic, un-PEP8-perhaps

# description
set303f=A work in progress with automation testing for Git leveraging python, bash etc

# website URL
set303g=$github_pages_repo_url

# GithubPartywebpageLink
set303h=index.html

# Branch to commit to, 'main' or a new branch name
set303j=main

# Default commit message (use ~date and ~data for auto-generated content)
set303k=Automated ~date ~data

# Change ownership of all files to current user
set303l=y

# DONT EDIT OUT THIS LAST LINE
EOL

sed -e "s|set303b=\$.*|set303b=$repo_name|" \
-e "s|set303g=\$.*|set303g=$github_pages_repo_url|" \
"$template_file" > "$config_file"

echo "Created default kigit.txt from template with replaced values."
echo "Update them and re-run the script! :)"
exit 0
else
echo "kigit.txt exists"
fi
}

# Function to load kigit.txt
load_config_f_kigit() {
local config_file=kigit.txt
while IFS='=' read -r key value; do
[[ -z "$key" || "$key" =~ ^#.*$ ]] && continue
key=$(echo "$key" | tr -d '[:space:]')
value=$(echo "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

# Parse and normalize values but do not sanitize them in the file
case "$value" in
[yY]*|[fF]orce:[yY]*) value="y" ;;
[nN]*|[fF]orce:[nN]*) value="n" ;;
esac

global_conf["$key"]="${value:-}"
echo "Read config: $key=$value"
done < "$config_file"

local owner="${GITHUB_USER:-$(git config user.name)}"
local repo_name=$(basename "$PWD")
owner_slash_repo_global_var_set_onload_kigit="$owner/$repo_name"
github_pages_repo_url="https://$owner.github.io/$repo_name"

echo "**************";
echo $github_pages_repo_url
echo "**************";
}

# Function to push changes to the remote repository
push_sync_git_repository() {
local commit_msg=$1
local owner_slash_repo_global_var_set_onload_kigit=$2
local branch=${3:-main}

git add . && git commit -m "$commit_msg" || true
if ! git remote | grep -q '^origin$'; then
git remote add origin "https://github.com/$owner_slash_repo_global_var_set_onload_kigit.git"
fi

# Create the main branch if it doesn't exist
if ! git rev-parse --quiet --verify "$branch"; then
git branch -m "$branch"
fi

git push -u origin "$branch"
echo "Changes synced with GitHub!"
}

# Function to check if a repository exists
repo_exists() {
local owner_slash_repo_global_var_set_onload_kigit=$1
gh repo view "$owner_slash_repo_global_var_set_onload_kigit" &>/dev/null
return $?
}

# Function to fetch GitHub token
fetch_github_api_token() {
local token_file=~/.git_token_secret
if [[ -f "$token_file" ]]; then
github_api_token=$(<"$token_file")
echo "GitHub token found!"
else
echo "Let's set up your GitHub token!"
read -sp "Enter GitHub token: " token
echo "$token" > "$token_file" && chmod 600 "$token_file"
github_api_token="$token"
echo "GitHub token saved securely!"
fi
}

# Function to change ownership of files
chown_local_f() {
if [[ ${global_conf[set303l]} =~ ^[Nn]$ ]]
then
return 0
elif [[ ${global_conf[set303l]} =~ ^[Yy]$ ]]
then
sudo chown -R $(whoami) .
echo "Changed ownership to $(whoami)!"
fi
}

# Function to create README.md and index.html
create_readmemd() {
local template_dir=$(dirname "$0")/templates
mkdir -p "$template_dir"
cat > "$template_dir/a_1_template_README.md" <<EOL
# ${global_conf[set303b]}
<!-- ![Image](github_repo_image.webp) -->

## Description
${global_conf[set303f]}

Tags: ${global_conf[set303e]}

## Features
- Automagic ...

## License
This project is licensed under a license not written here yet..
EOL
cat > "$template_dir/a_1_template_index.html" <<EOL
<html>
<head>
<title>${global_conf[set303b]}</title>
</head>
<body>
<h1>${global_conf[set303b]}</h1>
<p>${global_conf[set303f]}</p>
</body>
</html>
EOL
cp "$template_dir/a_1_template_README.md" README.md
cp "$template_dir/a_1_template_index.html" index.html
echo "Created README.md and index.html from templates."
}

# Function to update kigit.txt with current settings
update_config_file_kigit() {
local config_file=kigit.txt
local temp_file=$(mktemp)
while IFS= read -r line; do
if [[ $line =~ ^[[:space:]]*set303[a-z]= ]]; then
key=$(echo "$line" | cut -d'=' -f1 | tr -d '[:space:]')
if [[ ${global_conf[$key]} != force:* ]]; then
echo "$key=${global_conf[$key]:-}" >> "$temp_file"
else
echo "$line" >> "$temp_file"
fi
else
echo "$line" >> "$temp_file"
fi
done < "$config_file"
mv "$temp_file" "$config_file"
echo "Updated kigit.txt with current settings"
}

# Function to create install_ish.py
create_first_run_py() {
if [[ "$developer_mode" == "y" || -f "$main_script_f" ]]; then
cat > install_ish.py <<EOL
import os
import subprocess

script_name = "autogit4unimoose.sh"

# Make the script executable
os.chmod(script_name, 0o755)

# Run the script
try:
subprocess.run(["./"+script_name], check=True)
except subprocess.CalledProcessError:
print("Error occurred while running the script.")
print("Trying with sudo...")
try:
subprocess.run(["sudo", "./"+script_name], check=True)
except subprocess.CalledProcessError:
print("Error occurred even with sudo. Please check the script and try again.")
EOL
echo "Created install_ish.py"
fi
}

# Function to create HTML page
create_html_page() {
  local repo_name=${global_conf[set303b]}
  local owner="${GITHUB_USER:-$(git config user.name)}"
  local owner_slash_repo_global_var_set_onload_kigit="$owner/$repo_name"
  local token_file=~/.git_very_secret_and_ignored_file_token
  local github_api_token

  if [[ -f $token_file ]]; then
    github_api_token=$(<$token_file)
  else
    echo "GitHub token not found. Please set it in your environment variables or save it in the specified file."
    return 1
  fi

  python3 -c "
import os
import markdown
import requests
import sys

def create_html_page(repo_name):
  if os.path.exists('README.md'):
    with open('README.md', 'r') as readme_file:
      readme_content = readme_file.read()
    html = markdown.markdown(readme_content)
    full_html = f\"\"\"<html><head><title>{repo_name}</title></head><body>{html}</body></html>\"\"\"
    with open('index.html', 'w') as html_file:
      html_file.write(full_html)
    print('index.html created successfully.')
  else:
    print('README.md not found.')

def check_github_pages(repo_name, token):
  headers = {'Authorization': f'token {token}', 'Accept': 'application/vnd.github.v3+json'}
  response = requests.get(f'https://api.github.com/repos/{repo_name}/pages', headers=headers)
  if response.status_code == 404:
    init_git_repo_localhub_pages(repo_name, token)

def init_git_repo_localhub_pages(repo_name, token):
  headers = {'Authorization': f'token {token}', 'Accept': 'application/vnd.github.v3+json'}
  data = {'source': {'branch': 'main', 'path': '/'}}
  response = requests.post(f'https://api.github.com/repos/{repo_name}/pages', headers=headers, json=data)
  if response.status_code == 201:
    print('GitHub Pages has been set up.')
  else:
    print('Failed to set up GitHub Pages.')

create_html_page('${owner_slash_repo_global_var_set_onload_kigit}')
check_github_pages('${owner_slash_repo_global_var_set_onload_kigit}', '${github_api_token}')
"

  echo "HTML page created from README.md!"
}

# Define API-like functions
update_git() {
  update_repo "$1"
}

fetch_git() {
  create_repo "$" "$2" "$3"
}

# Main script execution
fun_echo "Welcome 🦄🦌💨" "🎉" 35
fun_echo "Running: $(basename "$0")" "📂" 36

# Ensure we're in a Git repo or create one if not
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  fun_echo "No Git repository detected. Initializing a new Git repo..." "🌟" 33
  init_git_repo_local
fi

fetch_github_api_token
create_config_f_kigit
load_config_f_kigit

echo "Config Variables:"
for key in "${!global_conf[@]}"; do
  echo "$key = ${global_conf[$key]}"
done

chown_local_f
init_git_repo_local
git push -u origin main
git branch -m main
git push origin HEAD:main

create_repo "${global_conf[set303b]}" "${GITHUB_USER:-$(git config user.name)}" "${global_conf[set303c]:-private}" "${global_conf[set303j]:-main}"
git branch -m main
git push origin HEAD:main

echo "git status:" && git status
echo "git branch -a:" && git branch -a
echo "git remote show origin:" && git remote show origin
echo "config --get remote.origin.head:" && git config --get remote.origin.head

change_or_create_new_branch "${global_conf[set303j]:-main}"

[ ! -f "README.md" ] && (create_readmemd; create_html_page)

push_sync_git_repository "${global_conf[set303k]//\~date/$(date '+%Y%m%d-%H')}" "${global_conf[set303b]}" "${global_conf[set303j]:-main}"
update_repo_homepage "${global_conf[set303b]}" "${GITHUB_USER:-$(git config user.name)}"
update_repo_topics "${global_conf[set303b]}" "${GITHUB_USER:-$(git config user.name)}"
update_config_file_kigit
create_first_run_py

unset global_conf owner_slash_repo_global_var_set_onload_kigit github_pages_repo_url

fun_echo "Script executed successfully! Have a magical day! 🌈✨" "🎉" 36