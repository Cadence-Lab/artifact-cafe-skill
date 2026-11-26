# Organize: folders and move

Read this when the user asks you to organize, file, or move artifacts. Each
command here needs Node and `login`. A publish token cannot file an artifact.

Each workspace, Personal too, has one flat list of folders. `--folder`, on
`publish` and `move`, takes the exact folder name, with the same case, or the
folder id. If two folders have the same name, pass the id.

## Folder visibility changes artifact visibility

A folder is `workspace` or `public`. When an artifact goes into a folder, it
gets the visibility of the folder. This occurs on a first publish into the
folder, and on a `move` by the publisher of the artifact or by an admin. It
also occurs on a publish with `--workspace` and `--folder` that moves a
Personal artifact into a team workspace. Nothing asks for a confirmation.

- Before you put an artifact into a `public` folder, get a yes from the user.
  A public artifact shows on the public page of the workspace.
- After each `move`, compare `previousVisibility` and `visibility` in the
  result. Tell the user about each change.

## Make a folder

```bash
npx artifact-cafe@latest folders --workspace <handle> --json
npx artifact-cafe@latest folders create "Design specs" --workspace <handle> --visibility workspace --json
```

- `--visibility` is `workspace`, the default, or `public`.
- Use `--icon <name>` to choose a gray Phosphor icon for the folder. The default is `folder`.
- Use a folder that exists before you make a new one. `folders create`
  refuses a name that is already in the workspace, with a different case
  too. Then use that folder.
- Make a folder only for a group: this artifact and two or more others with
  the same subject, or a project that the user names. Never make a folder for
  one artifact.
- Give a folder a short name, as "Design specs" or "Q3 planning". Use the
  name style of the folders that exist.
- Any member can make a workspace-only folder. Only owners and admins can
  make a public folder. Tell the user about each folder that you make.

## Move an artifact

`move` changes only the folder. It makes no new version, and the comments
stay.

```bash
npx artifact-cafe@latest move --dir <dir> --folder "Design specs" --json   # the artifact of a published folder
npx artifact-cafe@latest move --artifact <id> --folder "Design specs" --json
npx artifact-cafe@latest move --artifact <id> --unfiled --json             # out of its folder
```

Pass exactly one of `--folder` and `--unfiled`. With no `--dir` and no
`--artifact`, `move` uses the binding of the current folder.

## Organize a workspace

1. Run `workspaces --json`. If it is not clear which workspace to organize,
   ask the user.
2. Run `list --workspace <handle> --json`. The result has each artifact,
   with its `folderId`, and the list of folders.
3. Show the user a plan before you change anything: the folders to make, the
   folder for each artifact, and each change of visibility. Group by subject.
   Leave an artifact that fits no group out of all folders. Do not make a
   "Misc" folder.
4. When the user agrees, make the folders and move each artifact. Then show
   the folders with their artifacts, and each change of visibility.

The CLI cannot rename or delete a folder. Tell the user to do it in the
dashboard.
