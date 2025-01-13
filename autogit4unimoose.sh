#!/bin/bash
declare -g owner_slash_repo_global_var_set_onload_kigit github_pages_repo_url
declare -gA global_conf
fun_echo() {
  echo -e "\e[1;${3:-32}m$2 $1 \e[0m"
}
init_git_repo_local() {
  [[ -d .git ]] || { git init -b main; echo "Initialized a new Git repository!"; git add .; git commit -m "Initial commit"; }
  [[ ! -f .gitignore ]] && { touch .gitignore; echo "Created .gitignore!"; git add .; git commit -m "Git ignore added"; }
}
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
    local visibility_flag=${visibility:-private}
    if [[ "$visibility" == "public" ]]; then visibility_flag="--public"; fi
    if gh repo create "$owner_slash_repo_global_var_set_onload_kigit" $visibility_flag; then
      echo "Created GitHub repository: $repo_name"
      gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --default-branch "$branch"
      echo "Default branch set to $branch"
      git remote add origin "https://github.com/$owner_slash_repo_global_var_set_onload_kigit.git"
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
  gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --description "${global_conf[set303f]}"
  gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --homepage "${global_conf[set303g]}"
  fun_echo "Updated repository homepage and description!" "📚" 33
}
update_repo_topics() {
  local owner_slash_repo_global_var_set_onload_kigit=$1
  IFS=',' read -ra topic_array <<< "${global_conf[set303e]}"
  for topic in "${topic_array[@]}"; do
    sanitized_topic=$(echo "$topic" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    if [[ $sanitized_topic =~ ^[a-z0-9][a-z0-9-]{0,49}$ ]]; then
      gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --add-topic "$sanitized_topic"
    fi
  done
  fun_echo "Updated repository topics!" "🏷️" 33
}
update_repo() {
  local owner_slash_repo_global_var_set_onload_kigit=$1
  local branch=${global_conf[set303j]:-main}
  git add .
  git commit -m "Partial auto-commit"
  git push -u origin main
  fun_echo "Updating GitHub repository: $owner_slash_repo_global_var_set_onload_kigit" "🔄" 33
  if ! git ls-remote --heads "https://github.com/$owner_slash_repo_global_var_set_onload_kigit.git" | grep -q "refs/heads/$branch"; then
    git push --set-upstream origin ":refs/heads/$branch"
  fi
  git push origin "$branch" --force
  if [[ $? -ne 0 ]]; then
    fun_echo "Failed to push the latest changes to the remote branch. Please check the branch and try again." "⚠️" 33
    exit 1
  fi
  fun_echo "Changes synced with GitHub!" "🌍" 32
  return 0
}
create_config_f_kigit() {
  local config_file=kigit.txt
  if [[ ! -f "$config_file" ]]; then
    local template_file=$(dirname "$0")/templates/a_1_template_kigit4.txt
    local repo_name=$(basename "$PWD")
    local owner="${GITHUB_USER:-$(git config user.name)}"
    github_pages_repo_url="https://$owner.github.io/$repo_name"
    mkdir -p "$(dirname "$template_file")"
    cat > "$template_file" <<EOL
set303a=y
set303i=y
set303b=$repo_name
set303c=private
set303d=y
set303e=Git, Bash, Automation, Automagic, un-PEP8-perhaps
set303f=A work in progress with automation testing for Git leveraging python, bash etc
set303g=$github_pages_repo_url
set303h=index.html
set303j=main
set303k=Automated ~date ~data
set303l=y
set303m=n
set303n=n
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
load_config_f_kigit() {
  local config_file=kigit.txt
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" =~ ^#.*$ ]] && continue
    key=$(echo "$key" | tr -d '[:space:]')
    value=$(echo "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    case "$value" in
      [yY]* | [fF]orce:[yY]*) value="y" ;;
      [nN]* | [fF]orce:[nN]*) value="n" ;;
    esac
    global_conf["$key"]="${value:-}"
  done < "$config_file"
  local owner="${GITHUB_USER:-$(git config user.name)}"
  local repo_name=$(basename "$PWD")
  owner_slash_repo_global_var_set_onload_kigit="$owner/$repo_name"
  github_pages_repo_url="https://$owner.github.io/$repo_name/"
}
push_sync_git_repository() {
  local commit_msg=$1
  local owner_slash_repo_global_var_set_onload_kigit=$2
  local branch=${3:-main}
  git add . && git commit -m "$commit_msg" || true
  if ! git remote | grep -q '^origin$'; then
    git remote add origin "https://github.com/$owner_slash_repo_global_var_set_onload_kigit.git"
  fi
  if ! git rev-parse --quiet --verify "$branch"; then
    git branch -m "$branch"
  fi
  git push -u origin "$branch"
  echo "Changes synced with GitHub!"
}
repo_exists() {
  local owner_slash_repo_global_var_set_onload_kigit=$1
  gh repo view "$owner_slash_repo_global_var_set_onload_kigit" &>/dev/null
  return $?
}
fetch_github_api_token() {
  local token_file=~/.git_token_secret
  if [[ -f "$token_file" ]]; then
    github_api_token=$(<"$token_file")
    echo "GitHub token found!"
  else
    echo "GitHub token not found. Using gh credentials."
  fi
}
chown_local_f() {
  local needs_chown=0
  if [[ ${global_conf[set303l]} =~ ^[Nn]$ ]]; then
    return 0
  elif [[ ${global_conf[set303l]} =~ ^[Yy]$ ]]; then
    for file in *; do
      local current_owner=$(stat -c "%U" "$file")
      if [ "$current_owner" != "$(whoami)" ]; then
        needs_chown=1
        break
      fi
    done
    if [ $needs_chown -eq 1 ]; then
      sudo chown -R "$(whoami)" .
      echo "Changed ownership to $(whoami)!"
    else
      echo "Ownership is already set to $(whoami) for all files, no change needed."
    fi
  fi
}
update_repo_from_kigit() {
  local owner_slash_repo_global_var_set_onload_kigit=$1
  local owner="${GITHUB_USER:-$(git config user.name)}"
  local current_repo_name=$(basename "$PWD")
  if [[ "${global_conf[set303b]}" != "$current_repo_name" ]]; then
    gh repo rename "${global_conf[set303b]}" --repo "$owner_slash_repo_global_var_set_onload_kigit"
    owner_slash_repo_global_var_set_onload_kigit="$owner/${global_conf[set303b]}"
    fun_echo "Repository renamed to ${global_conf[set303b]}" "🏷️" 32
  fi
  local current_visibility=$(gh repo view "$owner_slash_repo_global_var_set_onload_kigit" --json isPrivate --jq '.isPrivate')
  if [[ "$current_visibility" == "true" && "${global_conf[set303c]}" == "public" ]]; then
    gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --visibility public
    fun_echo "Repository visibility changed to public" "🌍" 32
  elif [[ "$current_visibility" == "false" && "${global_conf[set303c]}" == "private" ]]; then
    gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --visibility private
    fun_echo "Repository visibility changed to private" "🔒" 32
  fi
  gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --description "${global_conf[set303f]}"
  gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --homepage "${global_conf[set303g]}"
  IFS=',' read -ra topic_array <<< "${global_conf[set303e]}"
  for topic in "${topic_array[@]}"; do
    sanitized_topic=$(echo "$topic" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    if [[ $sanitized_topic =~ ^[a-z0-9][a-z0-9-]{0,49}$ ]]; then
      gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --add-topic "$sanitized_topic"
    fi
  done
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ "${global_conf[set303j]}" != "$current_branch" ]]; then
    git checkout -b "${global_conf[set303j]}" || git checkout "${global_conf[set303j]}"
    git push -u origin "${global_conf[set303j]}"
    gh repo edit "$owner_slash_repo_global_var_set_onload_kigit" --default-branch "${global_conf[set303j]}"
    fun_echo "Branch updated to ${global_conf[set303j]}" "🌿" 32
  fi
  if [[ "${global_conf[set303d]}" == "y" ]]; then
    [ ! -f "$(pwd)/README.md" ] && (create_readmemd)
    [ ! -f "$(pwd)/index.html" ] && (create_html_page)
    fun_echo "README.md and index.html updated if previous files were deleted!" "📄" 32
  fi
  git add .
  git commit -m "${global_conf[set303k]//\~date/$(date '+%Y%m%d-%H')}" || true
  git push origin "${global_conf[set303j]}"
  fun_echo "Repository updated based on kigit.txt changes" "✅" 32
}
create_readmemd() {
  local template_dir=$(dirname "$0")/templates
  mkdir -p "$template_dir"
  cat > "$template_dir/a_1_template_README.md" <<EOL
# ${global_conf[set303b]}
## Description
${global_conf[set303f]}
Tags: ${global_conf[set303e]}
## Features
- Automagic ...
## License
This project is licensed under a license not written here yet..
EOL
  cat > "$template_dir/a_1_template_index.html" <<EOL
<!DOCTYPE html>
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
create_first_run_py() {
  if [[ "$developer_mode" == "y" || -f "$main_script_f" ]]; then
    cat > install_ish.py <<EOL
import os
import subprocess
script_name = "autogit4unimoose.sh"
os.chmod(script_name, 0o755)
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
create_html_page() {
  local repo_name=${global_conf[set303b]}
  local owner="${GITHUB_USER:-$(git config user.name)}"
  local owner_slash_repo_global_var_set_onload_kigit="$owner/$repo_name"
  if [[ ! -f index.html ]]; then
    python3 -c """
import os
import markdown
import requests
import sys
def create_html_page(repo_name):
  if os.path.exists('README.md'):
    with open('README.md', 'r') as readme_file:
      readme_content = readme_file.read()
    html = markdown.markdown(readme_content)
    full_html = f\"\"\"<!DOCTYPE html>
<html lang='EN'>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width' width=device-width value='viewport' description='viewport' viewport='viewport: wow, could it be html??' />
  <head>
    <title>{repo_name}</title><link rel='stylesheet' href='https://essingen123.github.io/cssGuden/html_auto_style_factor_parameter_cool_party_2_of_30.css'>
  </head>
  <body>{html}
  </body>
</html>\"\"\"
    with open('index.html', 'w') as html_file:
      html_file.write(full_html)
    print('index.html created successfully from README.md.')
  else:
    print('README.md not found.')
def check_github_pages(repo_name, token):
  headers = {'Authorization': f'token {token}', 'Accept': 'application/vnd.github.v3+json'}
  response = requests.get(f'https://api.github.com/repos/{repo_name}/pages', headers=headers)
  if response.status_code == 404:
    init_github_pages(repo_name, token)
  elif response.status_code == 200:
      print("GitHub Pages is already enabled for this repository.")
  else:
      print(f"Error checking GitHub Pages: Status code {response.status_code}")
def init_github_pages(repo_name, token):
  headers = {'Authorization': f'token {token}', 'Accept': 'application/vnd.github.v3+json'}
  data = {'source': {'branch': 'main', 'path': '/'}}
  response = requests.post(f'https://api.github.com/repos/{repo_name}/pages', headers=headers, json=data)
  if response.status_code == 201:
    print('GitHub Pages has been set up.')
    update_repo_homepage(repo_name, token)
  else:
    print(f'Failed to set up GitHub Pages. Status code: {response.status_code}, Response: {response.text}')
def update_repo_homepage(repo_name, token):
    repo_owner, repo_short_name = repo_name.split('/')
    homepage_url = f"https://{repo_owner}.github.io/{repo_short_name}/"
    headers = {'Authorization': f'token {token}', 'Accept': 'application/vnd.github.v3+json'}
    data = {'homepage': homepage_url}
    response = requests.patch(f'https://api.github.com/repos/{repo_name}', headers=headers, json=data)
    if response.status_code == 200:
        print(f"Successfully updated homepage URL to {homepage_url}")
    else:
        print(f"Failed to update homepage URL. Status code: {response.status_code}, Response: {response.text}")
if not os.path.exists('index.html'):
  create_html_page('${owner_slash_repo_global_var_set_onload_kigit}')
else:
  print("index.html already exists. Skipping creation.")
check_github_pages('${owner_slash_repo_global_var_set_onload_kigit}', '${github_api_token}')
"""
  else
    echo "index.html already exists. Skipping automatic creation."
  fi
  echo "GitHub Pages setup checked/initiated!"
}
force_refresh_github_pages() {
  local repo_name=${global_conf[set303b]}
  local owner="${GITHUB_USER:-$(git config user.name)}"
  local owner_slash_repo_global_var_set_onload_kigit="$owner/$repo_name"
  sed -i -e "\$a<!---- Last Update: $(date) -->" README.md || true
  git add README.md
  git commit -m "Force GitHub Pages refresh [$(date +'%Y-%m-%d %H:%M:%S')]"
  git push origin "${global_conf[set303j]}"
  echo "GitHub Pages refresh forced."
}
delete_old_master_branch() {
  local repo_name=${global_conf[set303b]}
  local owner="${GITHUB_USER:-$(git config user.name)}"
  local owner_slash_repo_global_var_set_onload_kigit="$owner/$repo_name"
  if git ls-remote --heads origin master | grep -q 'refs/heads/master'; then
    echo "Deleting remote 'master' branch..."
    git push origin --delete master
    if [[ $? -eq 0 ]]; then
      echo "Remote 'master' branch deleted successfully."
    else:
      echo "Error deleting remote 'master' branch."
    fi
  else:
    echo "Remote 'master' branch does not exist."
  fi
}
update_git() {
  update_repo "$1"
}
fetch_git() {
  create_repo "$" "$2" "$3"
}
fun_echo "Welcome 🦄🦌💨" "🎉" 35
fun_echo "Running: $(basename "$0")" "📂" 36
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  fun_echo "No Git repository detected. Initializing a new Git repo..." "🌟" 33
  init_git_repo_local
fi
fetch_github_api_token
create_config_f_kigit
load_config_f_kigit
chown_local_f
init_git_repo_local
git push -u origin main
git branch -m main
git push origin HEAD:main
create_repo "${global_conf[set303b]}" "${GITHUB_USER:-$(git config user.name)}" "${global_conf[set303c]:-private}" "${global_conf[set303j]:-main}"
git branch -m main
git push origin HEAD:main
change_or_create_new_branch "${global_conf[set303j]:-main}"
create_html_page
[ ! -f "$(pwd)/README.md" ] && (create_readmemd)
[ ! -f "$(pwd)/index.html" ] && (create_html_page)
push_sync_git_repository "${global_conf[set303k]//\~date/$(date '+%Y%m%d-%H')}" "${global_conf[set303b]}" "${global_conf[set303j]:-main}"
update_repo_homepage "${global_conf[set303b]}" "${GITHUB_USER:-$(git config user.name)}"
update_repo_topics "${global_conf[set303b]}" "${GITHUB_USER:-$(git config user.name)}"
update_repo_from_kigit "$owner_slash_repo_global_var_set_onload_kigit"
force_refresh_github_pages
if [[ "${global_conf[set303m]}" == "y" ]]; then
  delete_old_master_branch
fi
if [[ "${global_conf[set303n]}" == "y" ]]; then
  echo "REFRESH"
fi
update_config_file_kigit
create_first_run_py
unset global_conf owner_slash_repo_global_var_set_onload_kigit github_pages_repo_url
fun_echo "Script executed successfully! Have a magical day! 🌈✨" "🎉" 36