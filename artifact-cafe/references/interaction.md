# Interaction and motion

Read this when the artifact has a form, an input, a dialog, a script that
changes what the page shows, or motion. The template already gives 44 px
controls, 16 px fields, focus rings, press feedback, and the reduced-motion
rule. This file has what the template cannot do for you.

## The review frame

The review page runs the artifact in a sandbox.

- `alert`, `confirm`, `prompt` and `print` do nothing in the sandbox. `check`
  warns with `blocked-dialog`. Use a `<dialog>`.
- Do not use `autofocus`. On a phone, it opens the keyboard before the reader
  sees the page.

## Forms and inputs

- Do not put `text-sm` or `text-xs` on an `input`, `select` or `textarea`.
  Below 16 px, iOS zooms the page when the field gets focus.
- Put fields that the reader submits in a `<form>`, so that Enter submits.
  Give each other button in the form `type="button"`, because a plain
  `<button>` submits.
- Give a field the `type` and `autocomplete` of its data:
  `type="email" autocomplete="email"`, `type="tel"`, `autocomplete="name"`.
- Validate a field when it loses focus or when the form submits. After the
  first error, validate it at each change. Put the error text below the field.
- While a submit waits: disable the button, and change its label to what
  occurs, as "Sending…". Enable it again in a `finally` block, so that an
  error does not leave a dead button.
- Show the result on the page, in a `<p role="status">` near the form. Do not
  show it only in a dialog.
- Confirm a delete in a `<dialog>`. Close it with
  `<form method="dialog"><button>Cancel</button></form>`.

## Touch

- A control that you make is 44 × 44 px or larger: `min-h-11 min-w-11`.
- Hover adds to a control. It never shows a value or an action that a tap and
  the keyboard cannot reach.
- Put `touch-action: none` only on a surface that the reader drags or draws on.

## Motion

Answer the questions in order. The first answer that applies decides.

| Question | Motion |
|---|---|
| Does the change come from a load, a scroll or a timer? | None |
| Does a key or a repeated action start it, as deck keys, filters or tabs? | None |
| Is it a hover, a press or a color change? | `transition-colors`. It takes `--duration` (150 ms) and `--ease`. |
| Does an item come in or go out, as a panel or a note? | Opacity, and a scale of 0.97 or 8 to 16 px of travel. 200 ms in, 150 ms out, `--ease`. |
| Does an item on the screen move or change size, as a bar after a filter? | `transform` only, as `scale-x`. 200 to 300 ms, `ease-in-out`. |
| Does it show that work waits, as a spinner? | None. Change the label, as "Forms and inputs" says. |

- Animate `transform` and `opacity` only. Width, height and margin make the
  page lay out again on each frame.
- Keep each motion under 300 ms. All content is visible with no motion.
- The template stops CSS motion for a reader who asks for reduced motion. A
  script does not stop. Before `element.animate()` or a smooth scroll, read
  `matchMedia("(prefers-reduced-motion: reduce)").matches`, and skip the
  motion if it is true.

## Rules for each kind

### Tool

- Load the tool with a filled, real example. The `check` images and a new
  reviewer then see a result, not an empty tool.
- Put the input and its result in view together at 1280 px. At 390 px, the
  result comes directly after the input.
- Each control works. Remove a control that does nothing.

### Calculator

- Fill the inputs with a real, typical case. Name the case in the `h1`.
- Calculate the result at each `input` event. Use no `<form>` and no submit
  button.
- Show the result with its unit in `<output class="stat block">`. It is the
  largest item of the screen. For one main result, use `display` in place of
  `stat`.
- Put the formula and each assumption in a `details` element below the
  result.
- Draw a comparison as bar rows, as "Charts" in `design.md` says. The script
  sets the width class.

### Form

- Ask only for what the owner needs. Write "(optional)" after the label of
  an optional field.
- After a submit, replace the form with what the person sent and what occurs
  next.
- If the page keeps what visitors submit, read `references/data.md`.
