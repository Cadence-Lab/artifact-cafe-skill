# Artifact Data: shared records

Read this before you build a poll, guestbook, RSVP, form, or shared checklist
that keeps the submissions of all visitors. For a state that only one viewer
needs, use `localStorage`. The public guide is
[the data guide](https://artifact.cafe/docs/data).

Reviewers submit with no account, but the artifact must be in a workspace.
An anonymous artifact gets `403 account_required` until the claim.

## Declare the manifest and use the client

Make `.artifact/data.json` at the root of the published folder:

```json
{
  "collections": {
    "entries": {
      "fields": {
        "name": { "type": "string", "required": true, "maxLength": 80 },
        "message": { "type": "string", "required": true, "maxLength": 1000 }
      },
      "access": { "read": "public", "insert": "public", "update": "creator", "delete": "none" }
    }
  }
}
```

```html
<p id="load-error" hidden>Could not load the entries.</p>
<script src="/__ac/data.js"></script>
<script type="module">
  try {
    const { records } = await cafe.data.list("entries");
    // Show the records. In the submit handler, call cafe.data.insert("entries", { name, message }).
  } catch {
    document.getElementById("load-error").hidden = false;
  }
</script>
```

`cafe.data` has `list`, `insert`, `get`, `update`, `remove`, and `summary`.
The REST path is `/__ac/data/<collection>[/<id>]` on the artifact origin,
`https://<slug>.artifactcafe.dev`. The main origin `artifact.cafe` does not
serve it. Use relative URLs, because a browser write from a different origin
gets `403`.
Show each submitted value with `textContent`, because it is untrusted text.

## Check and confirm

`check` has no data store. It opens the page from your files, and with
`--hosted` from a copy of them. `/__ac/data.js` does not load there, so the
images show the state of the page when the data does not load, as in the
error line above. That is correct. Catch the errors of `cafe.data`: an error
that the page does not catch is a `script-error`, and it stops `publish`.

After the publish, run one command to confirm that the data store works:

```bash
npx artifact-cafe@latest data ls entries <dir> --json
```

A result with `records` means that it works. If the command fails, tell the
user its `error.code`, and stop. Do not request server paths to find the
cause.

## Fields

- Field types: `string`, `number`, `integer`, `boolean`, `datetime`, `url`,
  `email`, `array`, `object`.
- Constraints: `required`, `default`, `maxLength`, `trim`, `minimum`,
  `maximum`.
- Collection and field names match `^[a-z][a-z0-9_]*$`, with at most 64
  characters.
- `id`, `created_at`, `updated_at`, `created_by`, and `mine` are reserved.
  The server sets them, and you cannot declare them.
- A record with a field that the manifest does not declare gets `400` with
  the name of the field.
- Each record that the page reads has `mine`, which is `true` for a record
  of the same creator.

## Access

- Each of `read`, `insert`, `update`, and `delete` is `public`, `creator`,
  `owner`, or `none`. The default is `public` for `read` and `owner` for the
  others.
- `public` for `update` or `delete` also needs `"publicMutation": "open"`.
- `creator` is the account of a signed-in reviewer. For a guest, it is an id
  that the browser keeps. That id is not proof of identity.
- A person who cannot open the artifact cannot read or write its data. The
  visibility, the members, the grants, and the password all apply.

## Versions and limits

Records stay through new versions, a slug change, and a move to a different
workspace. A version with a manifest replaces the manifest. A version with no
manifest keeps the one before it. `{"collections":{}}` turns off the API and
keeps the records. When the artifact is deleted, its records are deleted.

| Limit | Value |
|---|---|
| Manifest | 64 KB |
| Collections | 10 |
| Fields in one collection | 50 |
| One record | 16 KB |
| Records in one artifact | 10,000 |
| Reads for each IP address, in one collection | 120 a minute |
| Writes for each IP address, in one collection | 10 a minute, or the `rateLimit` |
| Reads for one artifact, from all IP addresses | 10,000 an hour |
| Writes for one artifact, from all IP addresses | 1,000 an hour |

- `rateLimit` on a collection is `N/hour/ip` or `N/minute/ip`. It replaces
  only the write limit for each IP address, and never the limit for the
  artifact. Do not set it, except for a public form that gets spam. Then use
  a low value, as `10/hour/ip`.
- A rate error is `429` with `retryAfter` and `scope`, which is `ip` or
  `artifact`.

## Owner commands

```bash
npx artifact-cafe@latest data ls entries <dir> --json
npx artifact-cafe@latest data insert entries <dir> --record '{"name":"Ada","message":"hi"}' --json
npx artifact-cafe@latest data insert entries <dir> --file seed.json --json
npx artifact-cafe@latest data export <dir> --json
npx artifact-cafe@latest data clear entries <dir> --yes --json
```

- `data` has no `--artifact`. Run it from the published folder, or pass that
  folder as `<dir>`.
- It uses the account key, the publish token in the binding, or
  `ARTIFACT_CAFE_TOKEN`, in that order. An `aat_` token for the workspace
  also works.
- Owner commands pass each access level and ignore the rate limits. They
  still check the fields and the record limit.
- `--file` takes a JSON array. The CLI sends it in groups of 100 records.
  Each group is added completely or not at all. If a group fails, the error
  tells how many records went in before it.
- `data clear` deletes each record of the collection. Run it only when the
  user asks.
