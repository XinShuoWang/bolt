#!/usr/bin/env bash
set -exuo pipefail

###
# Bolt Rebase Script (CI)
#
# This script is used by CI to rebase Bolt. If the rebase succeeds, CI pushes the result to origin;
# if it fails, CI sends a notification to the bot.
#
# Manual recovery (when CI rebase fails):
# 1. Ensure your local main is up to date and matches origin/main.
# 2. Run `./codebase/pipelines/scripts/rebase.sh`.
#    - If the rebase fails, Git will leave an in-progress rebase in your Bolt working directory.
# 3. Resolve conflicts, then run `git rebase --continue` to complete the rebase.
# 4. Push the updated branch with `git push --force-with-lease origin main`.
###

## fetch from upstream and merge into local branch, then push to origin
BRANCH_NAME="${1:-main}"

UPSTREAM_URL="https://github.com/bytedance/bolt.git"
UPSTREAM_REMOTE="upstream"
ORIGIN_REMOTE="origin"

BOT_URL="https://open.larkoffice.com/open-apis/bot/v2/hook/8034ab53-6b8a-4794-aaf7-b194d6706774"
TEMPLATE_ID="AAqvdoOm73Z30"
TEMPLATE_VERSION="1.0.1"

function send_message() {
  local title="$1"
  local msg_body="$2"
  local color="${3}"

  payload="$(jq -n \
    --arg template_id "$TEMPLATE_ID" \
    --arg template_version "$TEMPLATE_VERSION" \
    --arg title "$title" \
    --arg msg_body "$msg_body" \
    --arg color "$color" \
    '{
      msg_type: "interactive",
      card: {
        type: "template",
        data: {
          template_id: $template_id,
          template_version_name: $template_version,
          template_variable: {
            title: $title,
            msg_body: $msg_body,
            color: $color
          }
        }
      }
    }'
  )"

  curl -X POST -H "Content-Type: application/json" -d "$payload" "$BOT_URL"

  echo "Message sent: $title"
}


LOCAL_BRANCH_NAME="${BRANCH_NAME}"

git rev-parse --is-inside-work-tree >/dev/null

if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
  git remote add "${UPSTREAM_REMOTE}" "${UPSTREAM_URL}"
fi

git fetch "${UPSTREAM_REMOTE}" --prune

if ! git show-ref --verify --quiet "refs/heads/${LOCAL_BRANCH_NAME}"; then
  git checkout --track ${ORIGIN_REMOTE}/${LOCAL_BRANCH_NAME}
elif [[ "$(git rev-parse ${LOCAL_BRANCH_NAME})" == "$(git rev-parse ${ORIGIN_REMOTE}/${LOCAL_BRANCH_NAME})" ]]; then
  git checkout ${LOCAL_BRANCH_NAME}
else
  echo -e "\033[31m[ERROR]\033[0m Local branch ${LOCAL_BRANCH_NAME} does not match with remote branch ${ORIGIN_REMOTE}/${LOCAL_BRANCH_NAME}"
  exit 1
fi

BASE_BEFORE="$(git merge-base "${LOCAL_BRANCH_NAME}" "${UPSTREAM_REMOTE}/${BRANCH_NAME}")"

rebase_result=""
if rebase_result="$(git rebase "${UPSTREAM_REMOTE}/${BRANCH_NAME}" 2>&1)"; then
  echo "git rebase succeeded"
else
  rc=$?
  printf '%s\n' "$rebase_result"
  body="$(printf 'Failure information:\n```shell\n%s\n```' "${rebase_result}")"
  send_message "Rebase failed, please handle manually" "$body" "red"
  exit "$rc"
fi

BASE_AFTER="$(git merge-base "${LOCAL_BRANCH_NAME}" "${UPSTREAM_REMOTE}/${BRANCH_NAME}")"

make submodules
INTERNAL_BEFORE="$(git -C bytedance_internal rev-parse --short HEAD)"
git -C bytedance_internal fetch origin --prune
git -C bytedance_internal checkout origin/master
INTERNAL_AFTER="$(git -C bytedance_internal rev-parse --short HEAD)"

if [ "${INTERNAL_BEFORE}" != "${INTERNAL_AFTER}" ]; then
  echo "Internal changes detected: ${INTERNAL_BEFORE} -> ${INTERNAL_AFTER}"
  git add bytedance_internal
  OLD_MSG="$(git log -1 --pretty=%B)"
  git commit --amend -m "$(cat <<EOF
${OLD_MSG}

update bytedance_internal from ${INTERNAL_BEFORE} to ${INTERNAL_AFTER}
EOF
)"
fi

git push --force-with-lease "${ORIGIN_REMOTE}" "${LOCAL_BRANCH_NAME}"

echo
echo "========================================"
echo "Upstream commits introduced by this rebase:"
echo

if [ "${BASE_BEFORE}" = "${BASE_AFTER}" ]; then
  echo "  (No new upstream commits introduced)"
else
  GIT_LOG=$(git log --pretty=format:'- [`%h`](https://github.com/bytedance/bolt/commit/%H) %s' "${BASE_BEFORE}..${BASE_AFTER}")
  commit_count=$(git rev-list --count "${BASE_BEFORE}..${BASE_AFTER}")
  body="$(printf 'commit list:\n%s' "$GIT_LOG")"
  send_message "Successfully rebased $commit_count commits" "$body" "green"
fi

if [ "${INTERNAL_BEFORE}" != "${INTERNAL_AFTER}" ]; then
    GIT_LOG=$(git -C bytedance_internal log --pretty=format:'- [`%h`](https://code.byted.org/dp/bolt-internal/commit/%H) %s' "${INTERNAL_BEFORE}..${INTERNAL_AFTER}")
    commit_count=$(git -C bytedance_internal rev-list --count "${INTERNAL_BEFORE}..${INTERNAL_AFTER}")
    body="$(printf 'commit list:\n%s' "$GIT_LOG")"
    send_message "Successfully update bytedance-internal $commit_count commits" "$body" "green"
fi

echo "========================================"
