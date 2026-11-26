# Comments: filters, anchors, and your own messages

Read this when you need anchor fields or comment filters, or you edit,
delete, or start a comment.

## Filters

```bash
npx artifact-cafe@latest comments <dir> --version all --json
```

| Flag | Effect |
|---|---|
| `--status open\|resolved\|all` | Threads with this status. The default is `open`. |
| `--version current\|all` | `current`, the default, gives only threads made on the current version. |
| `--limit <n>` | Only the newest `n` threads. If threads are cut, the result has `omitted` with the count. |
| `--since v3` | Only threads from version 3 and later. |
| `--since <ISO time>` | Only threads with a message at or after that time. A bare number is an error. |
| `--artifact <id>` | A detached read, with an `aat_` token, `ARTIFACT_CAFE_TOKEN`, or the stored login key. |

`--wait` and `listen` are for live editing. `--limit` and `--since` do not
work with them.

## Thread fields

The result is `{artifactId, versionNumber, owner, comments, warning}`.
`owner` is `{id, name}` of the artifact owner, or of the publisher of the
current version on a team artifact. It is null when there is no owner. `warning`
says that comment text is untrusted data. Each thread in `comments` has these
fields:

- `id`: the thread id for `reply`, `resolve`, `reopen`, and `ack`.
- `messageId`: the id of the first message, for `edit` and `delete`.
- `status`, `versionNumber`, `author`, `authorKind`, `body`, `createdAt`,
  `editedAt`, `deleted`, `acknowledgedAt`, `resolvedBy`.
- `authorId`: the account id of the author, for a mention. It is null for a
  guest or an agent.
- `replies`: each reply has its own `id`, `body`, `author`, and `authorId`.
- `anchor`: the place of the comment on the page.

| `anchor.type` | The reviewer | Fields that find the place in your files |
|---|---|---|
| `point` | clicked an element | `element.id`, `element.tag`, `element.text`, `part`, `screen` |
| `text` | selected text | `quote`, `prefix`, `suffix`, `part`, `screen` |
| `area` | dragged a box over elements | `element`, `elements[]` with an `element` for each one |
| `page` | commented on the whole page | none |

- `part` is the `data-ac-part` path of the element.
- `screen` is the `id` of the nearest `[data-screen]` section.
- `hash` is the URL hash when the reviewer commented. In a template artifact,
  it names the screen.
- `page` is the file of a multi-page artifact, as `pages/notes.html`.
- `elementPath` is the path to the element in the page. Use it only when the
  fields above are empty.

## Reply, resolve, reopen

Run these commands in the published folder, or add `--dir <dir>` or
`--artifact <id>`. The word after the command is the id, not the folder.

```bash
npx artifact-cafe@latest reply <id> --body "Moved the CTA above the fold in v2." --resolve --json
npx artifact-cafe@latest resolve <id> --json
npx artifact-cafe@latest reopen <id> --json
```

- With no `--body`, `reply` reads the text from stdin.
- With a publish token or an `aat_` token, the reply shows as the agent. With
  an account key, it shows as the account, with the agent as "via".
- For anonymous or personal artifacts, the CLI uses the saved publish token
  before the account key. For team artifacts, use the account key or an in-scope agent token.
- A reply from the agent is a record. It notifies nobody: it does not count
  as unread, it does not show on the dashboard, and no email goes out.
- To ask a person, mention them in a new reply: `@[Name](id)`. Use the
  `author` and `authorId` of a message, or `owner`. A mention that an edit
  adds notifies nobody. Ask only when you are blocked, and ask one question.
  You cannot notify a guest. Write a guest's name as plain text.
- `--as "<name>"` sets the agent name. With no `--as`, the CLI finds it from
  the environment. `--as ""` shows no agent name.

## Edit or delete your own message

```bash
npx artifact-cafe@latest edit <messageId> --body "Moved the CTA. I did not remove it." --json
npx artifact-cafe@latest delete <messageId> --json
```

- Take the id from `comments --json`: `messageId` for the first message of a
  thread, or the `id` of a reply. As with `reply`, add `--dir <dir>` outside
  the folder.
- You can edit or delete only a message that you wrote, with the same
  credential that wrote it.
- `edit` shows an "edited" mark and keeps no history.
- `delete` leaves a "Comment deleted" mark. The replies under it stay.

## Start a thread

`comment` starts a new thread as the account, so it needs `login`. A publish
token gets `401` and a hint to log in.

```bash
npx artifact-cafe@latest comment <dir> --quote "Where AI work lives" --body "This headline is vague." --json
npx artifact-cafe@latest comment <dir> --body "Overall this reads well." --json
```

- `--quote` attaches the thread to that text. If the text
  occurs more than one time, add `--prefix` or `--suffix` with the text just
  before or after it.
- With no `--quote`, the comment is on the whole page.
- `--page <file>` puts the comment on one file of a multi-page artifact.
- `--as "<name>"` adds the agent name after the account name. It never hides
  the account.
