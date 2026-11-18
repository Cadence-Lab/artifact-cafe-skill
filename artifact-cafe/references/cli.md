# CLI: commands, secrets, agent tokens, environment, limits

Read this when you need the folder argument of a command, a `template` or
`check` detail, a secret, an `aat_` token, or the cause of a limit error.

## Commands and their folder

- These commands take the folder as an argument: `template`, `publish`,
  `check`, `pull`, `link`, `comments`, `listen`, `comment`, `edit-file`, `expiration`,
  `protect`, and `data`.
- These commands take `--dir <dir>`, or you run them in the folder: `reply`,
  `resolve`, `reopen`, `ack`, `edit`, `delete`, `review`, `share`, `unshare`,
  and `move`. A bare word after `share` is an email address, and after
  `reply` it is a thread id.
- `guide <name>` prints `references/<name>.md` of the skill.
- `install --json` copies the skill for each agent on the machine.

## `template` and `check`

- `template <dir> --look <name> --json` writes `<dir>/index.html` with the
  font link of the look. The last `<style>` block starts with the look
  comment and the `:root` block of the look. The JSON has `accent`, the
  accent range, and `field` for `poster`.
- If `<dir>/index.html` exists, `template` gives `file_exists` and writes
  nothing. An unknown look gives `unknown_look`.
- `template --looks --json` lists each look with its `fits` line.
- Each `check` finding has `rule`, `level`, `message`, and `fix`. Step 2 of
  `SKILL.md` says what to do for each level.
- `blocked-dialog`: the page calls `alert`, `confirm`, `prompt`, or `print`.
  The review frame blocks these calls, so they do nothing. Use a `<dialog>`.
- `emoji`: the text has an emoji. Use a text label or an inline SVG icon.
- A `Did not load: <url>` line in `notes` names a font, a script, or a file
  that did not load. The images show the page without it. For a font, correct
  the family name in the font link.

## Supply a secret

| Secret | Environment variable | Stdin flag |
|---|---|---|
| Account key `ack_`, or agent token `aat_` | `ARTIFACT_CAFE_API_KEY` | `--api-key-stdin` |
| Publish token `apt_` | `ARTIFACT_CAFE_TOKEN` | none |
| Password of a password gate | `ARTIFACT_CAFE_PASSWORD` | `--password-stdin` |

- Get the value from the secret manager of the user into the environment
  variable. Or pipe it from a file: `protect --password-stdin --json < <file>`.
- Stdin takes one line that is not empty. A final newline is optional.
- A stdin flag wins over the environment variable.
- One command reads one secret from stdin. Supply the other secret through its
  environment variable.
- With `--api-key-stdin`, `comment`, `reply`, and `edit` need `--body`,
  because stdin cannot also carry the text. `edit-file --edits -` does not
  work with `--api-key-stdin`.
- `protect --off` ignores `ARTIFACT_CAFE_PASSWORD`. With `--password-stdin`, it
  gives an error.
- `--api-key <value>` and `--password <value>` put the secret in argv. They
  still work, with a warning on stderr. Never use them.
- To log in with no browser, run `login --api-key-stdin --json < <file>` with
  an `ack_` key.

## Agent token (`aat_`)

A runtime can give an `aat_` token in `ARTIFACT_CAFE_API_KEY`. Use it as it
is. Never print it or save it.

- The token selects its own workspace. `--workspace` and `--folder` give an
  error, and the CLI ignores `artifact-cafe.json`.
- A first publish returns no claim URL and no publish token, and the artifact
  has no anonymous expiry. A new artifact is `unlisted`.
- `comments`, `reply`, and `resolve` work from the binding. A reply shows as
  the agent.
- Do not run account, grant, member, or workspace admin commands with it. The
  token has no account, and the API refuses each grant command for it.
- The runtime revokes the token when the run ends. A revoked or expired token
  gets `401`.

## Environment variables

| Variable | Effect |
|---|---|
| `ARTIFACT_CAFE_URL` | The API origin, for a server that is not artifact.cafe. The CLI keeps a key for each origin. |
| `ARTIFACT_CAFE_ARTIFACT_ID` | The artifact for a detached command, the same as `--artifact`. `publish` and `link` ignore it. |
| `ARTIFACT_CAFE_AGENT` | The agent name on replies and versions. It also turns off the workspace picker. |
| `ARTIFACT_CAFE_NO_SKILL_INSTALL` | The first publish does not install the skill, and does not stop with `read_skill_manual`. |
| `ARTIFACT_CAFE_NO_UPDATE_CHECK`, `NO_UPDATE_NOTIFIER` | No skill update and no update notice. |
| `CI` | No skill update, no update notice, and no `read_skill_manual` stop. The check gate records the content and does not stop for warnings. |

## Limits

| Limit | Value |
|---|---|
| One file | 100 MB |
| All files of one version | 250 MB |
| Files in one version | 1000 |
| Publishes for each account | 60 an hour |
| Publishes with an `aat_` token, for each workspace | 120 an hour, with each publish in that workspace counted |
| Publishes with no account key and no `aat_` token, for each IP address | 15 an hour, and 20 a day |
| Storage of a Personal workspace | 10 GB |
| `--title`, `--description`, `--notes` | 200, 300, and 4000 characters |

- `429 rate_limited` has `retryAfter` in seconds. If it is more than 60, tell
  the user the time and stop. Do not retry in a loop.
- `413 payload_too_large`: a file or the version is too large. Remove files,
  or make them smaller.
- `413 quota_exceeded` on `publish`: the storage of the Personal workspace is
  full. Tell the user. The user can delete an artifact.
- `403 quota_exceeded` on a data insert: the artifact has its maximum number
  of records. Tell the user. The user can export and clear the records.
- On `quota_exceeded`, do not delete an artifact or a record without the
  user's yes.
