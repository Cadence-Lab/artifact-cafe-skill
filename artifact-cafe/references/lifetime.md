# Lifetime: temporary links, deadlines, and the claim

Read this when the user asks for a temporary link, a new deadline, or to keep
an artifact.

## The two deadlines

An artifact can have two deadlines. The earlier one is the effective expiry.

| Deadline | Field | Set by | Removed by |
|---|---|---|---|
| Explicit deadline | `autoDeleteAt` | `publish --expires-in`, `expiration --in` | `expiration --keep` |
| Anonymous retention | none | each anonymous publish, 24 hours after the latest publish | the claim |

`expiresAt` in each result is the effective expiry. `null` means that no
deadline remains. At the effective expiry, the server deletes all versions,
comments, files, and data. No credential opens the artifact after that time.
Nobody can restore it or extend it.

## Choose a deadline

Step 4 of `SKILL.md` says when to pass `publish --expires-in`. It works for
an anonymous publish too: then `expiresAt` is the earlier of the two
deadlines. On an artifact that exists, run `expiration` only when the user
asks for it.

A duration is a positive whole number and `m`, `h`, or `d`: `30m`, `1h`,
`7d`. The clock starts when the publish finishes. Give `expiresAt` and
`autoDeleteAt` as the date and time in the result, with the timezone. Never
round them to "today" or "tomorrow". Never calculate them from your own clock.

A later publish with no `--expires-in` keeps the explicit deadline.

## Change a deadline

```bash
npx artifact-cafe@latest expiration <dir> --in 7d --json    # a new deadline, 7 days from now
npx artifact-cafe@latest expiration <dir> --keep --json     # remove the explicit deadline
```

- Pass exactly one of `--in` and `--keep`. Neither makes a new version.
- Pass the published folder, or `--artifact <id>` with a credential that
  controls the artifact.
- "Keep permanently" in the review page is the same as `expiration --keep`.
- Report `expiresAt` from the result.

## Anonymous artifacts and the claim

- With no claim, the server deletes an anonymous artifact 24 hours after its
  latest publish.
- The claim URL expires 24 hours after the first publish. A later publish does
  not extend it.
- The claim moves the artifact into the Personal workspace of the user, and
  removes the anonymous retention. It does not change who can open the link.
- The claim keeps an explicit deadline. Only `expiration --keep` removes it.
- `expiration --keep` on an anonymous artifact removes only the explicit
  deadline. The 24-hour retention stays until the claim. Never say that
  `--keep` makes an anonymous artifact permanent.
