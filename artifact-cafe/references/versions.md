# Versions: binding, pull, link, edit-file, and conflicts

Read this when you work on an artifact from a folder with no binding,
`publish` stops with `version_conflict`, or you use `pull`, `link`, or
`edit-file`.

Each publish makes a new version. A version never changes, and each comment
stays on the version that it was made on.

## The binding

The binding is `.artifactcafe/config.json` in the published folder. It names
the artifact and the base version. After a first publish, it also holds the
publish token, unless an `aat_` token published it. Each command that you run
with the folder uses the binding.

A detached command has no binding. Pass `--artifact <id>` and supply one of
these credentials:

- an `aat_` token for the workspace of the artifact
- the publish token in `ARTIFACT_CAFE_TOKEN`
- the account key that `login` stored

The commands other than `publish` and `link` also read the id from
`ARTIFACT_CAFE_ARTIFACT_ID`. `publish` and `link` ignore it, so always pass
`--artifact <id>` to them.

- For `publish`, a team workspace refuses a publish token alone: the user
  must log in as a member. The comment commands accept the token.
- An anonymous artifact refuses an account key: use its publish token.

## Work on an artifact from a folder with no binding

Do these steps by default:

1. Run `pull <empty-dir> --artifact <id> --json` with one of the credentials
   above. `pull` writes the binding with the base version that it downloaded.
2. Make your edits in that folder.
3. Publish from that folder with no `--artifact`.

Use `link` only when the local files hold the current version. Never run
`publish --artifact <id>` from a folder with no binding: it sends no base
version, so it can publish over a newer version with no `version_conflict`.
If you did, its warning says that the folder is not bound. Before you edit
again, run the `pull <dir> --artifact <id> --force` command in the warning.

If the user has no login and no `aat_` token, ask the user to put the publish
token in `ARTIFACT_CAFE_TOKEN`. Keep it set for each later command, because
`pull` does not write the token into the binding.

## pull

```bash
npx artifact-cafe@latest pull <dir> --artifact <id> --json
npx artifact-cafe@latest pull <dir> --artifact <id> --version 3 --json
```

- `pull` downloads each file of the current version, or of `--version N`. It
  checks the hash and the size of each file.
- The folder must be empty. With `--force`, `pull` writes each file over the
  local file with the same path. Other local files stay, and `extraFiles` in
  the result lists them.
- `pull` refuses a folder that is linked to a different artifact, also with
  `--force`. Use a different folder.
- `pull` never writes a publish token. In the folder of the first publish, it
  keeps the token that is there.
- After `pull --version N` of an older version, a publish from the folder
  stops with `version_conflict`.

## link

```bash
npx artifact-cafe@latest link <dir> --json                   # list the artifacts that you can publish to
npx artifact-cafe@latest link <dir> --artifact <id> --json   # or --slug <slug>
```

`link` needs `login`. It sets the base version to the current version, so a
publish of older files replaces the newer changes with no `version_conflict`.
It writes a binding with no publish token, so each command from the folder
uses the account. It downloads no files. `link` replaces the binding, so a
publish token in it is lost. Never run `link` in the folder of an anonymous
artifact.

## edit-file

`edit-file` replaces text in a file of the current version and publishes a
new version. It needs no local copy.

```bash
npx artifact-cafe@latest edit-file --artifact <id> --path index.html \
  --old "Sign up" --new "Start free trial" --json
npx artifact-cafe@latest edit-file <dir> --edits edits.json --json
```

- `--old` must occur one time in the file. To replace each occurrence, add
  `--replace-all`.
- For more than one change in one version, put
  `[{"path": "…", "old": "…", "new": "…", "replaceAll": false}]` in a file
  and pass `--edits <file>`, or `--edits -` for stdin.
- For template content, `edit-file` runs `check` and stops with
  `check_failed` on an error. Nothing uploads.
- `edit-file` has no `--notes`.
- `edit-file` does not change the local files or the binding. If the folder
  is bound to the same artifact, `nextSteps` says that a publish of it stops
  with `version_conflict`. With a binding from an older CLI or from
  `publish.sh`, the publish removes the edit, because the binding has no
  base version. Copy your local changes, then run
  `pull <dir> --force --json`, as in step 1 and step 2 of `version_conflict`.

## version_conflict

`publish` stops with `version_conflict` when a different session published a
version after your base version. The error has `currentVersion`. Never add
`--force` on your own: the other author's changes are then not in the new
version.

After `edit-file`, run the same `edit-file` command again. It reads the
latest version each time.

After `publish`, do these steps. `<dir>` is the published folder.

1. Run `mktemp -d`. In this step and the next steps, `<mine>` is the path
   that it prints. Copy your files to `<mine>`. Do not copy `.artifactcafe/`,
   because it holds the publish token.

   ```bash
   tar -C <dir> --exclude=.artifactcafe -cf - . | tar -C <mine> -xf -
   ```

2. Get the latest version into `<dir>`, not into `<mine>`. `pull --force`
   writes each file over your file with the same path, and moves the base
   version to the latest version.

   ```bash
   npx artifact-cafe@latest pull <dir> --force --json
   diff -ru <mine> <dir> --exclude=.artifactcafe
   ```

3. Make your edits again on the files in `<dir>`, from the copy in `<mine>`.
   Keep the changes of the other author. If you cannot tell which change is
   yours, stop and ask the user.
4. Read `extraFiles` in the result of `pull`. Each of these files publishes
   again. Remove a file that the other author deleted, unless your edit
   needs it.
5. For template content, run `check <dir> --json`. Then publish with the same
   flags, with no `--force`. If `publish` stops with `version_conflict`
   again, run `rm -rf <mine>`, and start at step 1.
6. Run `rm -rf <mine>`.
