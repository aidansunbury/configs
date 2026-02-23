function pr-comments --description "Fetch PR review comments for the current branch"
    set -l remote_url (git remote get-url origin)
    set -l OWNER (string match -r '(?:github\.com[:/])([^/]+)/' $remote_url)[2]
    set -l REPO (string match -r '(?:github\.com[:/])[^/]+/(.+?)(?:\.git)?$' $remote_url)[2]
    set -l PR (gh pr view --json number --jq .number)

    if test -z "$PR"
        echo "No PR found for the current branch"
        return 1
    end

    set -l jqfilter '[.data.repository.pullRequest.reviewThreads.nodes[] | {resolved: .isResolved, comments: [.comments.nodes[] | {user: .author.login, path: .path, line: .line, start_line: .startLine, body: (.body | gsub("<details>(.|\n)*?</details>"; "") | gsub("<sub>[^<]*</sub>"; "") | gsub("\n\n+"; "\n") | ltrimstr("\n") | rtrimstr("\n")), created_at: .createdAt}]}]'

    gh api graphql -f query="
    {
      repository(owner: \"$OWNER\", name: \"$REPO\") {
        pullRequest(number: $PR) {
          reviewThreads(first: 50) {
            nodes {
              isResolved
              comments(first: 20) {
                nodes {
                  author { login }
                  body
                  path
                  line
                  startLine
                  createdAt
                }
              }
            }
          }
        }
      }
    }" | jq "$jqfilter"
end
