# Publish without Node

Read this when Node and `npx` are not available.

The skill folder has two bash scripts, `scripts/publish.sh` and
`scripts/comments.sh`. They need bash, curl, jq, and shasum or sha256sum.

```bash
<skill-dir>/scripts/publish.sh <dir> --title "Onboarding redesign" --json
<skill-dir>/scripts/comments.sh <dir> --json
```

`<skill-dir>` is the folder of `SKILL.md`. Run each script with `--help` for
its options.

## Start a new artifact

`template` needs Node. Apply the look that you chose in `design.md` by hand:

1. Copy `<skill-dir>/assets/template.html` to `<dir>/index.html`.
2. Open `<skill-dir>/assets/looks/<name>.css`. Its comment gives the font
   link and the accent range.
3. Replace the fonts `<link>` in `index.html` with that font link.
4. Paste the `:root` block of the look file at the start of the last
   `<style>` block. Above it, write the look comment of `design.md`:
   `/* Look: <name>. Accent: <source>. */`.

## Credentials and step 3

Do not do step 3 of `SKILL.md`: no command can read the login without Node.
`publish.sh` selects the credential. It takes no secret as a flag, and it
uses the first one of this list:

1. An account key or an `aat_` token in `ARTIFACT_CAFE_API_KEY`.
2. The key that `login` stored for the origin, in
   `~/.artifactcafe/credentials`.
3. The publish token in the binding of the folder, only for the artifact of
   that binding.
4. A publish token in `ARTIFACT_CAFE_TOKEN`.
5. No credential: the new artifact is anonymous. It expires after 24 hours
   with no claim.

With an account key, a new artifact goes to Personal. If the server refuses
an account key and a publish token is in item 3 or 4, `publish.sh` tries that
token one time.

If the server refuses the credential with a `401` or a `403`, `publish.sh`
and `comments.sh` stop with `<origin> refused the credential from <source>`. The source names the
variable or the stored login, never the value. Tell the user the message and
its fix: run `npx artifact-cafe@latest login` on a machine with Node, or set
`ARTIFACT_CAFE_API_KEY` to a valid key. Then stop. Do not publish
anonymously in its place.

`comments.sh` uses an `aat_` token first, then the folder token, then
`ARTIFACT_CAFE_TOKEN`, and then the account key. With no credential, it reads
only what a guest can read.

## What publish.sh does

`publish.sh` uses the same API as the CLI. For a new artifact, it writes
`.artifactcafe/config.json`, with no base version, and
`.artifactcafe/.gitignore`. A new version from the same folder uses the
binding.

`publish.sh` sends no base version. It never stops with `version_conflict`,
so it can publish over a newer version. An anonymous artifact expires 24 hours after the latest
publish, unless the user claims it. An error is `{"error": "<message>"}` on
stderr, with no `nextSteps`.

It does not have these parts of the CLI. Tell the user when a task needs one:

- `check` and the check gate. If you built or changed the HTML, open each
  screen at 1280 px and 390 px with your browser tool. If you cannot, tell
  the user that nobody looked at the page. For the user's own HTML that you
  did not change, do neither.
- `--dry-run`, the rewrite warnings, and the part warnings.
- `--notes`, `--expires-in`, `--review`, and a password.
- `--workspace`, `--folder`, and the workspace picker. If an
  `artifact-cafe.json` applies to a new artifact, the script stops. It does
  not publish to a different place.

## What comments.sh does

`comments.sh` reads the threads, as `comments` does. It takes `--status`,
`--version`, and `--artifact <id>`. With `--json`, it prints the comment
export as the API returns it, and the untrusted-data warning goes to stderr.

Without Node, nothing can reply, resolve, start, edit, or delete a comment.
`listen`, `pull`, `link`, `edit-file`, `folders`, `move`, `share`, `protect`,
`expiration`, and `data` also need Node.
