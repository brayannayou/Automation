# Install

### Requirements
- Node 14

### Npm
- `npm install` inside /Automation

### Paste files at your home/yourUser
- Files must be at /home/youruser. No folders hugging it
- Ex: /home/user/.profile
- Ex: /home/user/Automation/gitlab.js

### ./Automation/config.json file
- Set your username
- Make sure to set the gitlab project ID's of the projects that your interested
- Create an API-Token and set it at "tokens.gitlab"

### ./.profile file
- Set your email
- Set your "TOKEN_JIRA" -> Get yours at https://id.atlassian.com/manage-profile/security/api-tokens
- Set your "TOKEN_GITLAB" -> Get yours at https://code.ifoodcorp.com.br/-/profile/personal_access_tokens
- Ask for permission in slack bot -> Hendry

# Features

## Gitlab MRS

### mrs: based on Automation/gitlab.js "gitlabProjectIds".
- List all mrs. ex: mrs
- -a option, list all mrs that need approve. ex: mrs -a
- -m list your mrs. ex: mrs -m

## GIT

### gichn "taskNumber"
- Finds the task number, set the type and prefix for you. ex: gichn 951 -> "feature/PAYT-951"

### gico "Commit message"
- Get the task number, type and make all the prefix for you. ex: gico "Teste" -> commit name = "PAYT-951 - feature: Teste"

### giup
- Gitlab - Push the current branch to the origin.
- Gitlab - Create new MR.
- Slack - Comment on slack asking for approval with the link of the MR.
- Jira - Comment the MR link on jira.
- Jira - Move your task to validate.

### gicou "Commit message"
- Its a merge of "gico" and "giup". Commits and make sure to open MR, comment on slack, etc.

### gipum
- Update the current branch with the "projects main branch", could be develop, main, master.
- Uses "git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@' " to get the main branch.

## JIRA

### jivalidate "TaskNumber"
- Move the task to Validate. ex: jivalidate 951.

### jidoing "TaskNumber"
- Move the task to Doing. ex: jidoing 951.

### jiready "TaskNumber"
- Move the task to Ready to Deploy. ex: jiready 951.

### jidone "TaskNumber"
- Move the task to Done. ex: jidone 951.

### jico "TaskNumber" "Comment"
- Comment on task.

# Alias

- alias c='clear'
- alias eProfile='gedit $HOME/.profile'
- alias ws='~/WebStorm/bin/webstorm.sh'
- alias ij='~/IntelliJ/bin/idea.sh'

- alias gip='git pull'
- alias gist='git status'
- alias gilo='git log --decorate --oneline --graph'
- alias gichr='git checkout -- .'
- alias gipd='git pull --rebase origin develop'
- alias gipu='git pull --rebase origin HEAD'
- alias gisa='git stash apply'


```
girs() {
  git reset --soft HEAD~${1:-1}
}

girh() {
  git reset --hard HEAD~${1:-1}
}

girc() {
  git add .
  git rebase --continue
}

po() {
  local PREFIX="backoffice-"
  local POSFIX="web-front"
  local NAME="payment-transactions"
  cd "$HOME/Documentos/code/$PREFIX${1:-$NAME}${2:-"-$POSFIX"}"
}
```
