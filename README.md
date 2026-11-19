# artifact.cafe skill

The agent skill for [artifact.cafe](https://artifact.cafe). An agent publishes
static artifacts to a review link. People open the link with no login and
comment on the artifact. The agent then publishes a new immutable version.

```
publish a folder → review URL → guest comments (no login) → publish v2
```

## Install

**With npm:**

```bash
npx artifact-cafe@latest install
```

In a terminal, `install` asks for the scope and the agents. To install for one
project only, run it in the project folder and answer `p`. A newer CLI updates
each copy that `install` wrote for all projects.

**Without npm:**

```bash
curl -fsSL https://artifact.cafe/install.sh | bash
```

The script installs the skill into `~/.agents/skills/artifact-cafe/`. For each
agent in the table that does not read that folder, it adds a symbolic link.
To update, run the script again.

**With the skills CLI:**

```bash
npx skills add Cadence-Lab/artifact-cafe-skill --skill artifact-cafe -g
```

The CLI does not update a copy from another installer or a project copy. It
shows a notice when that copy is older.

## Where the skill goes

| Agent | Folder (all projects) | Folder (one project) |
|---|---|---|
| Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode, Amp, and most other agents | `~/.agents/skills/artifact-cafe/`, always | `.agents/skills/artifact-cafe/` |
| Claude Code | `~/.claude/skills/artifact-cafe/`, if `~/.claude/` exists | `.claude/skills/artifact-cafe/` |
| Antigravity | `~/.gemini/config/skills/artifact-cafe/`, if `~/.gemini/config/`, `~/.gemini/antigravity/`, or `~/.gemini/antigravity-cli/` exists | none |
| Kiro | `~/.kiro/skills/artifact-cafe/`, if `~/.kiro/` exists | `.kiro/skills/artifact-cafe/`, if the project has `.kiro/` |
| Claude.ai (web and desktop) | Upload a ZIP file. Refer to the next section. | none |

The installers write no copy into an agent folder when that agent also reads
`~/.agents/skills/`. A second copy can make the agent show the skill two times.

## Claude.ai

Claude.ai does not read skills from your disk. Upload the skill as a ZIP file:

1. Make a ZIP file whose root is the `artifact-cafe` folder:

   ```bash
   cd ~/.agents/skills && zip -r ~/artifact-cafe.zip artifact-cafe -x '*/.*'
   ```

2. In Claude.ai, turn on code execution.
3. Open **Customize > Skills** and upload `artifact-cafe.zip`.

The skill must reach these hosts from the code sandbox: `artifact.cafe`,
`*.artifactcafe.dev`, `registry.npmjs.org`, and the storage host that an
upload error names. If your organization limits the network, an owner must
allow these hosts.

## Agents with no skill support

Add these lines to the `AGENTS.md` file of the project:

```md
## artifact.cafe
To publish work for review or read review comments, first read ~/.agents/skills/artifact-cafe/SKILL.md and follow it.
```

## What's here

| Path | What it is |
|---|---|
| `artifact-cafe/SKILL.md` | The skill: how an agent publishes, reads review comments, and publishes a new version |
| `artifact-cafe/references/` | Instructions that the agent reads only when a task needs them |
| `artifact-cafe/assets/template.html` | The starting page for a new artifact |
| `artifact-cafe/assets/looks/` | Token values and a font link for each look of the template |
| `artifact-cafe/scripts/publish.sh` | Publish helper with no Node (bash, curl, jq) |
| `artifact-cafe/scripts/comments.sh` | Comment helper with no Node (bash, curl, jq) |

The preferred path is the `artifact-cafe` npm CLI:
`npx artifact-cafe@latest publish <folder>`. The scripts are the fallback when
Node is not available. Run each script with `--help` for its options and
credentials.

## Canonical source

This repo is a copy of the artifact.cafe skill. The artifact.cafe team changes the skill upstream and then updates this copy.

## License

The skill is proprietary. `artifact-cafe/LICENSE.txt` has the terms.
