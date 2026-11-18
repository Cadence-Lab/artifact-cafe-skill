# Build an artifact

Read this before you write a new HTML artifact. It says how the template
works.

## Start from the template

Choose the look first, as "Choose a look" in `design.md` says. Then run this
command. It writes `<dir>/index.html` with the look applied, and it never
writes over an existing `index.html`:

```bash
npx artifact-cafe@latest template <dir> --look <name> --json
```

Without Node, read `references/no-node.md`.

The template is one file. It has Tailwind CSS 4, the font link of the look,
and base styles for plain elements. It also has light and dark colors, the
screen router, and the accessibility base. Do not write a base of your own.

The JSON has `editFrom`, the line where the part that you edit starts. Read
`index.html` from that line to the end. Do not read the lines before it:
they hold the locked base, and "Tokens" below lists what the base gives.
Then edit the file:

1. Set the title in `<title>Artifact title</title>`, which is on line 6, and
   in the header `<span>`.
2. Write one `<section id="…" data-screen>` for each screen, with your own
   `id` values. Link to a screen with `<a href="#/its-id">`, from the nav or
   from any other place. The nav does not have to list each screen. An
   artifact with one screen has one section and no `<nav>`.
3. Fill each screen with plain HTML. Start each screen with an `<h1>`.
4. Style with Tailwind classes. Read "Style with Tailwind" below.

Do not edit the first `<style>` block, the Tailwind `<script>` tag or the
router script. `check` compares each of them with the template and gives a
`template-block` error for a change. The first block also holds the marker
`artifact.cafe base N`. Without the marker, `check` and `publish` do not
know the file as template content, and the check gate turns off.

## Rules for every artifact

These hold with or without the template.

1. **One file.** Inline the JavaScript. No build step. The template loads
   Tailwind and the fonts from a CDN. Add no other CDN for anything the page
   needs to work. A CDN file is not in the version, so it can change or go
   away after you publish. Images sit next to `index.html`.
2. **Each screen has a URL hash.** A screen is any state a reviewer can comment
   on: a page, a tab, a wizard step, an error state, an empty state. Show it
   with a link to `#/its-id`, never with a JavaScript variable alone. A comment
   stores the screen, and the review page takes the reviewer back to that screen.
   Each nav link shows its screen and changes the URL hash.
   To move between steps of a flow, use `<a class="button primary" href="#/next-id">`.
   It needs no script. If a `<form>` has a submit button, its handler must call
   `preventDefault()`, or the page reloads.
3. **Each part has an `id`.** Give an `id` to each card, section, form field,
   main button, table row and chart bar. Use lowercase letters, digits and
   hyphens. Each `id` is unique in the file, across all screens. Keep the same `id` in
   the next version. A comment carries the `id` of its element, so you can
   find the element in your source. Name a part for what it is, not for its
   position: `row-order-1042` and `stat-revenue`, not `row-3` and `card-2`.
   A position changes when you add a row, and the comment then points to a
   different part.
4. **Name the parts of a page that redraws.** Some pages draw again from
   their state: an app, a map, a diagram, a chart with a filter. Then a
   different element can take the position of a part. Give each part that a reviewer can talk about
   a `data-ac-part` path, and the comment stays on the part:

   ```html
   <svg data-ac-part="map" aria-label="Store map">
     <g data-ac-part="map/store-12" data-ac-label="Store 12">…</g>
   </svg>
   ```

   - Join the segments with `/`: the path says which part is in which part.
     If a part is not drawn, its comment shows on the nearest drawn part
     above it. Name each view and each container too.
   - Name a part for what it is, with an id from your data, never its
     position. Use letters, digits and `. _ : ~ @ + = -`, up to 16 segments and 400 characters.
   - `data-ac-label`, else `aria-label`, is the name that the reader sees.
   - Set the attributes where you make the element, in the markup or in the
     script that draws it.
   - When a reviewer opens a comment on a part that is not drawn, the page
     gets an `ac:goto` event. The template shows the screen of the part. If
     your page has other states, show the part:
     `document.addEventListener("ac:goto", (e) => showPart(e.detail.part))`.

   A document with screens and an `id` on each part does not need this.
5. **No server.** The host returns files only. A form cannot POST, and a
   library that needs HTML from a server (htmx) does not work. For data that
   visitors share, use Artifact Data, as step 1 of `SKILL.md` says.
6. **Microphone.** The review page blocks the microphone. If the page needs
   it, add `<meta name="artifact-cafe:permissions" content="microphone">` to
   the `<head>`. The review page then asks the reader, and after Allow,
   `getUserMedia` works. Allow loads the page again, so keep no state that
   the reader needs before that. Start the microphone from a click in the page.

## Style with Tailwind

Tailwind CSS 4.3.5 runs in the page. Each Tailwind class works, with variants
(`md:`, `hover:`) and fractions (`w-62/100`). A class that a script adds also
works. There is no build step.

- Use Tailwind classes only. Do not write CSS rules or `style` attributes.
  The one exception is the last `<style>` block: it is for the look, token
  values and `@font-face`.
- The template styles plain elements already. Add a class only to change
  something.

| You write                                        | You get                                |
| ------------------------------------------------ | -------------------------------------- |
| `h1`–`h4`, `p`, `ul`, `ol`, `blockquote`, `hr`    | spaced, readable text                  |
| `class="display"` on an `h1` or a `p`            | the largest type of the look           |
| `p.lead`                                         | a larger first paragraph               |
| `table` with `caption`, `thead`, `th scope`      | a data table                           |
| `figure` around a wide chart or code block       | sideways scroll on small screens       |
| `article`                                        | a card in the style of the look        |
| `p.stat`                                         | a large number for a metric            |
| `span.badge`, with `text-ok`, `text-warn` or `text-bad` for a status | a neutral pill, or a colored status pill |
| `small`                                          | secondary text                         |
| `button`, `a.button`, with `.primary` for one    | a neutral button, or a filled main action |
| `label` + `input`, `select`, `textarea`          | a labeled field. Fields in a row stack |
| `small` after a field, with `text-bad` for an error | help text, or error text             |
| `fieldset` + `legend`, `label` around a checkbox | a group of choices                     |
| `details` + `summary`                            | a disclosure                           |
| `dialog` (open with `showModal()`)               | a modal with a backdrop                |
| `code`, `kbd`, `pre`                             | inline code, keys, a code block        |
| `progress`                                       | a bar in the accent color              |

For a table, use [Tables](design.md#tables).

`stat`, `badge`, `button`, `primary`, `display` and `lead` are the only
classes that are not Tailwind. For all other styling, use Tailwind:

- A line of buttons or badges: `<div class="flex flex-wrap items-center gap-3">`.
- A number column: `<td class="text-end">`. It takes `--font-figures`. Put
  `font-sans` on a `text-end` cell that holds words.
- A child of a `flex` or `grid` box has no margin. Use `gap`.
- A `div` has no margin. Put `mt-6` on it, or `space-y-6` on its parent.
- A block of color: `bg-field text-on-field`. A selected row: `bg-accent-soft`.
- A label in the heading face or a heading in the UI face: `font-heading`,
  `font-ui`.

Key numbers, the main one larger, with a rule between them:

```html
<div class="flex flex-wrap gap-8"><div id="stat-revenue"><small>Revenue, Q3 2026</small><p class="display">$1.24M</p></div><div id="stat-orders" class="border-s border-line ps-8"><small>Orders, Q3 2026</small><p class="stat">8,410</p></div></div>
```

## Tokens

This table is the list of the tokens. Set a token in a `:root` block in the
last `<style>` block. Each color token is also a Tailwind color without the
`--`: `bg-surface`, `text-muted`, `border-line`, `fill-accent`.

| Token | Role |
|---|---|
| `--bg` | Page background |
| `--surface` | Panels and code |
| `--card` | Background of an `article` |
| `--text` | Reading text |
| `--muted` | Labels, dates, and captions |
| `--line` | Dividers |
| `--edge` | Control borders and neutral bars |
| `--accent` | Links, the primary button, and the one series or number that is the subject |
| `--on-accent` | Text on `accent` |
| `--field` | A large block of color. If a look or you do not set it, it is `--accent` in light mode and the accent hue at lightness 0.4 in dark mode. Set `--on-field` with it. |
| `--on-field` | Text on `field` |
| `--font` | Reading text |
| `--font-heading` | Headings, `.display`, and `.stat` |
| `--font-ui` | Labels, controls, tables, and the nav |
| `--font-figures` | Numbers in `td.text-end` |
| `--mono` | Code |
| `--heading-weight` | 400 or 500 |
| `--heading-variation` | Variable-font axes of headings, as `"wdth" 68` |
| `--tracking` | Letter spacing of `h1` and `.display` |
| `--size-display`, `--size-h1`, `--size-h2`, `--size-h3`, `--size-lead`, `--size-text` | Type sizes |
| `--leading` | Line height of reading text |
| `--radius` | Corners |
| `--card-pad`, `--card-border`, `--card-shadow` | Padding, border, and shadow of an `article` |
| `--header-rule`, `--table-rule` | The line below the header, and the line below a table head |
| `--header-title` | Font of the title in the header |
| `--width` | Content width |

- Only the template sets `--accent-soft`, `--ok`, `--warn`, `--bad`,
  `--series-1` to `--series-4`, `--measure`, `--ease`, and `--duration`. Do
  not set them. It makes `--accent-soft` from `--accent`, and the colors pass
  contrast in each look.
- A color token takes one color, or `light-dark(<light>, <dark>)` for the
  two modes. Write a new color as `oklch(L C H)`.
- The page is light. For a dark design, write `<html lang="en" class="dark">`.
  The tokens change. The `dark:` variant follows the same class.

## Fonts

The look gives the font link. Keep it, unless the subject gives a reason for
a different face, as a brand font.

- A Google font: change the family in the fonts `<link>`, then set the font
  tokens: `:root { --font-heading: "Family Name", Georgia, serif; }`. Load the
  weights 400 and 500 only. If the font does not load, `check` gives a
  `Did not load` note.
- A font file from the user: put the `.woff2` file next to `index.html`, add
  `@font-face { font-family: "Brand"; src: url("brand.woff2") format("woff2"); font-display: swap; }`
  to the last `<style>` block, and set the font tokens. Remove the fonts
  `<link>` if no text uses it.

## Accessibility you still own

The template gives the language attribute, landmarks, a skip link, focus
rings, focus on screen change, target sizes, reduced motion and print. You
supply the content, so you own these:

- Change `lang` if the text is not English.
- Each `<img>` has `alt`. A decorative image has `alt=""`.
- Each field has a `<label for>`. Each field has an `id`.
- Each button and link has text. An icon-only button has `aria-label`.
- Use `<button>` for an action and `<a href>` for navigation.
- Headings go in order: one `<h1>` per screen, then `<h2>`, then `<h3>`.
- A field error has text, `aria-invalid="true"` on the field, and
  `aria-describedby` that points to the text.
- Help text below a field has an `id`. The field has `aria-describedby` that
  points to it.
- An SVG chart has `role="img"`, an `aria-label`, and a text summary or a
  table of the data. Its geometry attributes (`x`, `width`, `rx`) are not
  styles.
- A `figure` that scrolls sideways has `tabindex="0"` and an `aria-label`.
- Do not remove the focus outline. Do not use a positive `tabindex`.
- The Tab key reaches each control, in order.

## The share card

A link to the artifact in a chat app or a social site shows a card. By
default, the card is a generated artifact.cafe card about review. If the
artifact is for reading, as an article, a report, a guide, or a comparison,
put these tags in the `<head>` of the entry file:

```html
<meta name="description" content="One line on what this is.">
<meta property="og:image" content="cover.png">
<meta name="author" content="Ada Lovelace">
```

The API reads the tags when you publish, from the CLI, the bash script, or the
API. It also accepts `og:description` and `article:author`.

The image has rules. If the image breaks a rule, the API uses the generated
card and gives no error, so check each rule yourself:

- The image is a file in the folder that you publish: `cover.png`,
  `./cover.png`, or `/assets/cover.png`. The API refuses a remote URL, a
  protocol-relative URL, and a `data:` URL.
- It is PNG, JPEG, WebP, or GIF, at most 5 MB. SVG is not accepted. Use
  1200 x 630 px.

`publish --description "<one line>"` replaces the description of the entry
file. A gated artifact always shows a locked card, so its tags have no
effect.
