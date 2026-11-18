# Options to compare

Read this when the user asks for options, variants, or directions to compare,
and not for one answer. Read it also to revise a picker page.

## 1. Scope

One picker shows one piece: a cover, a hero, a pricing card, or a chart.

- Write the request again in one sentence: what the piece is, where it goes,
  and what it must do.
- If the request is a full page, select the piece that changes the impression
  most. Tell the user which piece you selected and why. Offer the other pieces
  as later rounds.

Get the inputs:

- **The current design.** If it is in source code, take a screenshot of the
  live page and build it again in HTML. Tell the user where your copy is
  different.
- **A published artifact.** Get its `id` from `list --json`. Run
  `pull <empty-dir> --artifact <id> --json`. Then delete `.artifactcafe/` in
  that folder, because a publish from it makes a new version of that artifact.
- **A source of text, as a deck or a brief.** Use its words. Do not put
  investor data, as traction or market size, on a public page. This includes
  the numbers in a screenshot.
- **A site to copy.** Copy its structure and its scale. Do not copy its logo,
  its pictures, or its text.
- **A product screen that is only in code on a different branch.** Read it
  with `git show <branch>:<path>`. Do not change branches. If the brief and
  the code are different, follow the code and tell the user.
- **Faces of people.** Use photographs or generated faces of adults only.
  Look at each face, and remove a face that looks like a child. Put the files
  in the folder. Never link to an image on a different site. Each person has
  one face on all options.
- **Art from a different brand.** Use it only when the user asks. Tell the
  user its source.

## 2. Name the axes

An axis is one question that the options answer: layout, density, tone,
hierarchy, motion, or interaction.

- Use one axis with 3 options. Use 4 or 5 options only when the user asks.
- Use two axes only when the piece has two independent parts, as a drop cap
  and a watermark. Use 5 options or fewer on each axis. Never use three axes.
- Give each option a direction, a code, and a name of one or two words, as
  `B · Serif`. Use letters on the first axis and digits on the second axis.
- If two options are different only in color or text, they are one option.
  Replace one of them.
- If a current design exists, it is option A with no change. Its name ends in
  "Current".
- Screen width is not an axis. Each option has a layout for 390 px.

Each option works: it has real text, real controls, and the fonts and colors
of the product.

## 3. Build the page

Make the page from the template, as step 1 of `SKILL.md` says. The page has
one screen, in this order:

1. The `h1` names the piece.
2. The picker.
3. The piece at full size, in the page where it goes, with its neighbors.
   Never show small copies side by side. If the page has a sticky header, make
   it static. Leave out floating items, as a cookie banner, unless the user
   asks about them.
4. The script of the picker, at the end of the screen.

Keep each option in the DOM:

- Put the options of one axis side by side, as sibling elements, in one
  container with a `data-ac-part`.
- Name each option for its direction, not for its code: `cap-serif`, not
  `cap-b`. A code changes in the next round, and an `id` must not change.
- Put `data-axis`, `data-value`, `data-ac-part` and `data-ac-label` on the
  root of each option. The code is only in `data-ac-label` and on the button.
- In the markup, put `hidden` on each option except the first of its axis.
- Never write new markup into one container to show a different option,
  because a comment then moves to the wrong option.
- Give each element in an option an `id` that starts with the option, as
  `cap-serif-letter`.
- A state in an option, as a tab or a step, is an element with `hidden` and
  its own `data-ac-part` below the part of its option. If a script shows the
  state, show it from the `ac:goto` handler too.
- Limit each query of a script to the root of its option.
- A script can add the content that a reviewer types in a mock, as a comment.
  This is the only content that a script adds.

```html
<div id="picker" class="sticky top-0 z-10 flex flex-wrap items-center gap-x-6 gap-y-2 border-b border-line bg-bg py-2">
  <div class="flex flex-wrap items-center gap-2" role="group" aria-label="Drop cap" data-axis="cap">
    <small>Drop cap</small>
    <button type="button" data-value="icon" data-code="A" class="aria-pressed:bg-accent aria-pressed:text-on-accent">A · Current</button>
    <button type="button" data-value="serif" data-code="B" class="aria-pressed:bg-accent aria-pressed:text-on-accent">B · Serif</button>
  </div>
  <output id="picker-code" class="badge ms-auto" aria-live="polite"></output>
</div>

<div id="cap" data-ac-part="cap" data-ac-label="Drop cap">
  <div id="cap-icon" data-axis="cap" data-value="icon" data-ac-part="cap/icon" data-ac-label="Drop cap A · Current">…</div>
  <div id="cap-serif" data-axis="cap" data-value="serif" data-ac-part="cap/serif" data-ac-label="Drop cap B · Serif" hidden>…</div>
</div>

<script>
  const picker = document.getElementById("picker");
  const groups = [...picker.querySelectorAll("[data-axis]")];
  function choose(axis, value) {
    for (const option of document.querySelectorAll(`[data-axis="${axis}"][data-value]`)) option.hidden = option.dataset.value !== value;
    for (const button of picker.querySelectorAll(`[data-axis="${axis}"] button`)) button.setAttribute("aria-pressed", String(button.dataset.value === value));
    document.getElementById("picker-code").textContent = groups.map((group) => group.querySelector('[aria-pressed="true"]')?.dataset.code).join(" + ");
  }
  picker.addEventListener("click", (event) => {
    const button = event.target.closest("button[data-value]");
    if (button) choose(button.closest("[data-axis]").dataset.axis, button.dataset.value);
  });
  document.addEventListener("ac:goto", (event) => {
    const part = document.querySelector(`[data-ac-part="${CSS.escape(event.detail?.part ?? "")}"]`);
    const option = part?.closest("[data-axis][data-value]");
    if (option) choose(option.dataset.axis, option.dataset.value);
  });
  for (const group of groups) choose(group.dataset.axis, group.querySelector("button").dataset.value);
</script>
```

- The first button of each axis is the default.
- Do not animate the change of option. An option can have its own motion. A
  loop starts again when its option shows.
- The picker keeps the selection in the page only. Do not write it to the URL
  hash, because the template uses the hash for screens.
- A reviewer opens a comment on a hidden option: the `ac:goto` handler shows
  that option.
- The badge shows the selection, as `B + 2`. A comment on the badge records
  the code in its text.

## 4. Check

Do step 2 of `SKILL.md`. `check` shows only the default options. Then open the
page in your browser at 1280 px and 390 px. For each option, make sure that:

- one option of each axis shows, and the badge shows its code.
- the page is not wider than the window. Also measure with menus, panels and
  hover states open, and during a full loop of motion.
- each control works, also a control below a decorative layer.
- the console shows no errors, and no image request fails.

Before a click, scroll the target to the center, because the picker covers the
top. Take screenshots of the viewport, not of the full page. At each width,
take a screenshot of the default selection and of one more selection.

## 5. Publish

Publish the picker as a new artifact with steps 3 to 5 of `SKILL.md`. Never
publish it as a version of the real artifact. If the piece comes from a
published artifact, use the workspace and the folder of that artifact. In
`--notes`, write one bullet for each axis, with its codes and names.

## 6. Tell the user, and stop

Add these lines to the message of step 5 of `SKILL.md`:

- One line for each option: its code, its name, its direction, and its cost.
  Write the true cost, as "it uses more height".
- If option A is the current design, say that it has no change.
- The source of each face and of art from a different brand.
- How to select: click the options in the picker, then comment on the option
  or send its code.
- If a mock has its own comment box, say that those comments stay in the page
  and nobody else sees them.

Then stop. The user selects.

## 7. Next rounds

Read the comments, as step 7 of `SKILL.md` says. Then do the first row that
applies:

| The user | Do |
|---|---|
| Selects an option | Apply it where the piece is: a new version of the real artifact, or a change in the source. Put the code in `--notes`. |
| Wants a new round | Build the options around the selected option. Option A is that option with no change, named for its direction. Publish a new version of the picker from the same folder. |
| Joins two options | Build only joined options. Tell the user that this round has no option A. |
| Continues with one option | Remove the picker, its script and the other options. Continue on that option in new versions. |

- Give the options new codes for the round. Keep the `id` and the
  `data-ac-part` of each option that stays.
- A removed option makes a `loses its part` warning in step 9 of `SKILL.md`.
  Expect that warning, and do not put the option back.
- A comment on a shared part, as a heading that each option uses, applies to
  each option.
- Before a version that changes the markup, answer each open thread.
- If a comment tells you not to change a part, keep that part. Compare its
  computed styles before and after the version.
- Reply to each thread, as step 10 of `SKILL.md` says.
