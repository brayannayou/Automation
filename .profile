TOKEN_SLACK="Authorization: Bearer xoxb-3379626902-2395411428309-6Xl2hFNLyotW7Oj2YZKTh6rk"

#CONFIGURE-YOUR-TOKENS
MY_EMAIL="your-email@email.com"
TOKEN_JIRA="xxxxxx"
TOKEN_GITLAB="xxxxxx"
#CONFIGURE-YOUR-TOKENS

URL_SLACK="https://slack.com/api"
URL_JIRA="https://rwondemand.atlassian.net/rest/api"

SLACK_MERGE_CHANNEL="squad-payin-tooling-devs-only"

CHECK="\e[32m✔\033[0m"
ERROR="\e[31m✘\033[0m"

# my alias

alias c='clear'
alias eProfile='gedit $HOME/.profile'
alias ws='~/WebStorm/bin/webstorm.sh'
alias ij='~/IntelliJ/bin/idea.sh'

alias gip='git pull'
alias gist='git status'
alias gilo='git log --decorate --oneline --graph'
alias gichr='git checkout -- .'
alias gipd='git pull --rebase origin develop'
alias gipu='git pull --rebase origin HEAD'
alias gisa='git stash apply'

function gich() {
  git fetch
  if [[ ${1} =~ ^[0-9]*$ ]]; then
    ISSUE_TYPE=$(curl --request GET -sS \
    --url "$URL_JIRA/3/issue/PAYT-${1}" \
    --user "$MY_EMAIL:$TOKEN_JIRA" \
    --header 'Accept: application/json' 2>/dev/null | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin').toString()).fields.issuetype.name === 'Bug' ? 'fix' : 'feature'")
    git checkout "$ISSUE_TYPE/PAYT-$1" 2> /dev/null
    echo "$CHECK To branch - $ISSUE_TYPE/PAYT-$1"
  else
    git checkout $1
    echo "$CHECK To branch $1"
  fi
}

function po() {
  local PREFIX="backoffice-"
  local POSFIX="-web-front"
  local NAME="payment-transactions"
  cd "$HOME/Documentos/code/$PREFIX${1:-$NAME}${2:-"-$POSFIX"}"
}

mrs() {
  if [ $1 = "-m" ]; then
    node -e "require('$HOME/Automation/gitlab.js').getMyMergeRequests()"
  elif [ $1 = "-a" ]; then
    node -e "require('$HOME/Automation/gitlab.js').getToApproveMergeRequests()"
  else
    node -e "require('$HOME/Automation/gitlab.js').getAllMergeRequests()"
  fi
}

gipum() {
  local MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@' 2> /dev/null);
  git pull --rebase origin $MAIN_BRANCH
}

sProfile() {
  echo "$CHECK Profile saved"
  source $HOME/.profile
}

jitransit() {
  local JIRA_RETURN=$(curl --request POST -sS \
  --url https://rwondemand.atlassian.net/rest/api/2/issue/PAYT-$1/transitions \
  --header 'Accept: application/json' \
  --user "$MY_EMAIL:$TOKEN_JIRA" \
  --header 'Content-Type: application/json' \
  --data '{"transition":{"id":"'$2'"}}' 2> /dev/null)
}

jivalidate() {
  local JIRA_RETURN=$(jitransit "$1" "41" 2> /dev/null)
  echo "$CHECK Jira $1 to Validate"
}

jidoing() {
  local JIRA_RETURN=$(jitransit "$1" "21" 2> /dev/null)
  echo "$CHECK Jira $1 to Doing"
}

jiready() {
  local JIRA_RETURN=$(jitransit "$1" "51" 2> /dev/null)
  echo "$CHECK Jira $1 to Ready 4 Deploy"
}

jidone() {
  local JIRA_RETURN=$(jitransit "$1" "31" 2> /dev/null)
  echo "$CHECK Jira $1 to Doing"
}

jico() {
  local JIRA_RETURN=$(curl --request POST -sS \
  --url https://rwondemand.atlassian.net/rest/api/3/issue/PAYT-$1/comment \
  --header 'Accept: application/json' \
  --user "$MY_EMAIL:$TOKEN_JIRA" \
  --header 'Content-Type: application/json' \
  --data '{ "body": { "type": "doc", "version": 1, "content": [ { "type": "paragraph", "content": [ { "text": "'$2'", "type": "text" } ] } ] } }' 2> /dev/null)
  echo "$CHECK Jira Comment"
}

slco() {
  local SLACK_RETURN=$(curl --request POST -sS \
  --url https://slack.com/api/chat.postMessage \
  --header "$TOKEN_SLACK" \
  --header 'Content-Type: application/json' \
  --data '{ "channel": "'$SLACK_MERGE_CHANNEL'", "text": "'$1'" }' 2> /dev/null)
  echo "$CHECK Slack Comment"
}

giup() {
  local BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
  echo "$CHECK Branch Name: $BRANCH_NAME"
  local TASK_NUMBER=$(echo $BRANCH_NAME | tr -dc '0-9' 2> /dev/null)
  echo "$CHECK Task Number: $TASK_NUMBER"
  local TASK_TYPE=$(echo $BRANCH_NAME | node -pe "require('fs').readFileSync('/dev/stdin').toString().split('/')[0].toLowerCase()" 2> /dev/null)
  echo "$CHECK Task Type: $TASK_TYPE"
  local PUSH_OUTPUT=$(git push -o merge_request.create -o merge_request.title="PAYT-$TASK_NUMBER" origin HEAD -f 2>&1)
  local MERGE_LINK=$(echo "$PUSH_OUTPUT" | node -pe "require('fs').readFileSync('/dev/stdin').toString().match(/https:\/\/[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)?/ig)[0]" 2> /dev/null)

  if [ $1 =~ "-s" ];then
    echo "$CHECK Silent push"
  elif [ $MERGE_LINK =~ ^http ]; then
    echo "$CHECK Git Push"
    echo "$CHECK MR created: $MERGE_LINK"

    slco "Da uma olhada no meu MR :heart: :\\n$MERGE_LINK\\n<!subteam^S0274JH89B5>"
    jico "$TASK_NUMBER" "$MERGE_LINK"
    jivalidate "$TASK_NUMBER"
  else
    echo "$ERROR $MERGE_LINK"
    echo "$ERROR $PUSH_OUTPUT"
  fi
}

giupf() {
  local MERGE_LINK=$(git push -o merge_request.create origin HEAD -f 2>/dev/null)
  echo "$CHECK Git Push force"
  echo "$CHECK MR created"
}

gichn() {
  if [[ ${1} =~ ^[0-9]*$ ]]; then
    ISSUE_TYPE=$(curl --request GET -sS \
    --url "$URL_JIRA/3/issue/PAYT-${1}" \
    --user "$MY_EMAIL:$TOKEN_JIRA" \
    --header 'Accept: application/json' 2>/dev/null | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin').toString()).fields.issuetype.name === 'Bug' ? 'fix' : 'feature'")
    git checkout -b "$ISSUE_TYPE/PAYT-$1" 2> /dev/null
    echo "$CHECK Branch created - $ISSUE_TYPE/PAYT-$1"
    jidoing $1
  else
    echo "$ERROR Tell only the number of the task"
  fi
}

gico() {
  git add . 2> /dev/null
  
  local BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
  local TASK_NUMBER=$(echo $BRANCH_NAME | tr -dc '0-9' 2> /dev/null)
  local TASK_TYPE=$(echo $BRANCH_NAME | node -pe "require('fs').readFileSync('/dev/stdin').toString().split('/')[0].toLowerCase()" 2> /dev/null)
  
  git commit -m "PAYT-${TASK_NUMBER} - $TASK_TYPE: $1" --no-verify 2> /dev/null
  echo "$CHECK Commit created - PAYT-${TASK_NUMBER} - $TASK_TYPE: $1"
}

gicou() {
  gico $1
  giup $2
}

gichncou() {
  gichn $1
  gicou $2
}

gicouf() {
  gico $1
  giupf
}

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

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
