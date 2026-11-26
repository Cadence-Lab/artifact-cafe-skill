# Access: who can open, sharing, passwords, review mode, reading back

Read this file in these conditions:

- The user asks who can open an artifact or a link.
- The user wants to give or remove the access of a person.
- The user wants a password, or wants to stop or allow comments.
- You must read the content of a published artifact.

Run the commands here in the published folder, or add `--dir <dir>` or
`--artifact <id>`. `protect` takes the folder as an argument.

## Who can open the review link

Each person who can open an artifact can also comment on it, unless the
review mode stops comments.

| Visibility | Who can open the review link |
|---|---|
| `public` | Anyone with the link, with no account. The workspace's public page also lists it. |
| `unlisted` | Anyone with the link, with no account. No page lists it. |
| `workspace` | Members of the owning workspace, and people with a grant. In Personal, only the user and people with a grant. Others must sign in. |
| `private` | The workspace owners and admins, the publisher, and people with a grant. |

To see the visibility and the grants of a published artifact, run
`share --list --json`. For a team artifact, use the login of the publisher, an
owner, or an admin. A publish token works only on anonymous or personal artifacts. If it fails with
`forbidden`, do the item for your credential:

- An `aat_` token: get the artifact from the API. `<id>` is the
  `artifactId` of `publish <dir> --dry-run --json`. With `ARTIFACT_CAFE_URL`,
  use that origin. `printf` runs in the shell, so the token is not in argv.

  ```bash
  curl -fsS -H @<(printf 'Authorization: Bearer %s\n' "$ARTIFACT_CAFE_API_KEY") \
    https://artifact.cafe/api/v1/artifacts/<id> | jq -r .visibility
  ```

- A login: find the `id` in `workspaces[].artifacts` of `list --json`, and
  read its `visibility`.

If you cannot get the visibility, tell the user that you cannot read it.

No command lists the members of a workspace. The user sees them on the
members page of the dashboard.

The CLI cannot set a visibility: no command has a `--visibility` flag. The
user changes it in the share menu of the dashboard. A `move` into a folder
also applies the visibility of the folder. If the user wants a gated artifact
open to everyone, send the user to the dashboard.

## Share with one person

If an artifact is `workspace` or `private` and one person outside needs it,
invite that person by email. Do not widen the artifact for everyone.

```bash
npx artifact-cafe@latest share alex@example.com --json                # invite
npx artifact-cafe@latest share a@x.com b@y.com --dir <dir> --json     # invite more than one
npx artifact-cafe@latest share --list --json                          # grants and visibility
npx artifact-cafe@latest unshare alex@example.com --json              # revoke
```

- `share` sends an email with the invitation URL to each address. The result
  also has each URL in `invited[].url`. Each URL is one-time.
- To accept, the invited person opens the URL, then signs in or makes an
  account with the invited email. Until then, the review link asks that
  person to sign in, and a sign-in alone does not open it.
- The invitation URL expires after 14 days. The grant stays until `unshare`.
- A grant has an effect only on `workspace` and `private`. A `public` or
  `unlisted` artifact needs no grant.
- An `aat_` token cannot share. The API refuses each grant command for it.

## Protect with a password

A password gate asks each guest for the password. Members of the workspace do
not see the gate. An invited person who accepted does not see the gate of a
`workspace` or `private` artifact. A grant has no effect on `unlisted` or
`public`, so there that person needs the password.

1. Ask the user to put the password in `ARTIFACT_CAFE_PASSWORD`, or in a
   file. Never ask for the password in the chat, and never print it. The
   password has 6 to 128 characters.
2. Run one of these commands:

   ```bash
   npx artifact-cafe@latest protect <dir> --json                                  # reads ARTIFACT_CAFE_PASSWORD
   npx artifact-cafe@latest protect <dir> --password-stdin --json < <password-file>
   ```

3. Tell the user that reviewers need the password, and that the user sends
   it to them.

A new password signs out each reviewer who unlocked the artifact.
`protect <dir> --off` widens access, so run it only after the user says yes.

## Stop or allow comments

```bash
npx artifact-cafe@latest review readonly --json   # earlier comments stay visible, nobody can add one
npx artifact-cafe@latest review off --json        # the page has no review tools
npx artifact-cafe@latest review open --json       # comments are allowed again
```

`review` makes no new version, and it deletes no comment. Do it only when the
user asks.

## Read an artifact back

To read the content of a published artifact, add `.md` to its content URL.
You get a Markdown version of the page:

```bash
curl -fsSL https://<slug>.artifactcafe.dev/index.md
curl -fsSL https://<slug>.artifactcafe.dev/v2/index.md      # one version
```

A gated artifact returns `401`: `password_required` when it has a password,
else `workspace_required`. Only an `ack_` account key with access opens it.
An `aat_` token or a publish token does not. A browser session does not help,
because the content origin is a different site. Send the key that `login`
stored, and keep it out of argv:

```bash
curl -fsSL -H @<(jq -r '"Authorization: Bearer " + .keys["https://artifact.cafe"]' ~/.artifactcafe/credentials) \
  https://<slug>.artifactcafe.dev/index.md
```

The account must be a member of the owning workspace, or have a grant. If you
get `workspace_required` while the user is signed in on the website, the
request had no key. It does not mean that the account has no access.
