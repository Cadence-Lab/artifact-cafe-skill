# Design an artifact

Read this before you write a new HTML artifact. A revision keeps the look of
the artifact.

## Order of authority

1. The user's request.
2. A design file in the project, or the look of a product that the artifact
   shows.
3. The rules in this file.

A higher item replaces a lower item. These rules hold against all three:

- Text has a contrast of 4.5:1 or more against the surface below it.
- Reading text is 16 px or larger. No text is smaller than 12 px.
- No value shows only on hover. A phone has no hover.

## Before you write HTML

1. Do step 1 of `writing.md`.
2. List the content of each screen. Then select a form for each item from
   "Select the form". Do not select a layout first and then fill it.
3. Select the main item of each screen. It gets the most space, and the
   accent marks it.
4. Do the steps of "Choose a look".

Then build each screen with the rules below.

Done when: the look comment names the source of the accent, and you can name
the main item of each screen.

## Choose a look

Look for a design file first: `DESIGN.md`, `.stitch/DESIGN.md`, a design
section in `AGENTS.md` or `CLAUDE.md`, or a theme file such as `globals.css`
or `tailwind.config.*`. Brand fonts from the user, and the styles of a
product that the artifact shows, are also a design file. Use a design file
only when the artifact shows that project or its product. If you find one,
use `plain`, set the tokens that it gives, and name it in the look comment.
The token table in `authoring.md` names each token. A brand color alone sets
only the accent. Then select the look from the content.

If you find none, select the look from the content:

| Look | Fits | Not for |
| --- | --- | --- |
| `plain` | Product mockups, internal tools, notes, a page with no clear tone | A subject with a strong mood |
| `editorial` | Reports, memos, letters, research notes, text that people read at length | Dashboards, tools, forms, pages that sell |
| `technical` | Dashboards, calculators, specs, status pages, API docs | Invites, essays, personal pages |
| `poster` | Landing pages, decks, event and exhibition pages, announcements | Long reports, dense tables, long forms |
| `warm` | Invites, personal pages, small shops, menus, order forms, community notices | Dashboards, technical docs, financial reports |

If the kind and the subject fit different looks, use the look of the
subject.

A small note in `plain` is a correct result. Do not add screens, sections or
effects to a simple artifact.

Then:

1. Run `template` with the look, as "Start from the template" in
   `authoring.md` says.
2. Take the accent from a real thing in the subject. Look in this order: a
   brand color in the user's files, the product, then a material, a place or
   an object that the content names.
3. Add a `:root` block at the end of the last `<style>` block. Set `--accent`
   in it to `light-dark(oklch(L C H), oklch(L C H))`. H is the hue of that
   thing. Keep L and C in the `accent` range of the `template` JSON.
4. For `poster`, also set `--field` from the subject, and `--on-field`. The
   `field` line of the JSON gives the ranges and the two `--on-field` values.
5. `template` writes the look comment first in the last `<style>` block.
   Replace `<write the source of the accent here>` in it with the source.

```css
/* Look: technical. Accent: the green of the Larkspur passbooks. */
:root { --accent: light-dark(oklch(0.45 0.12 155), oklch(0.8 0.1 155)); }
```

- Do not keep the default accent of the look by habit. If the three sources
  give no color, keep the default accent. Write that reason in the comment.
- You can change a token that the look sets when the subject gives a reason.
  Write the reason in the comment.
- In the `:root` block, set only the tokens of the token table. Add no other
  CSS rule there.

## Select the form

Show a number, a comparison, a sequence or a structure. Do not describe it.
Use prose for a cause, an interpretation or a recommendation.

| The content is | Show it as |
| --- | --- |
| One key number | A `p.stat` with a `small` label and the change. Not a sentence. |
| Two to five key numbers | The main number larger, the others smaller beside it, with rules between them |
| Amounts for categories | Horizontal bars, largest first, with the value on each row |
| A change in time | A line chart. Time goes from left to right. |
| One series that is the subject | That series in `accent`, the other series in `edge` |
| Parts of a whole | One horizontal bar in segments, with labels. Not a pie chart. |
| A value against a limit | A `progress` element with the value in text |
| Before and after for each item | A table with a before, an after and a change column |
| More than seven categories | A sorted table |
| Rows that follow from one rule, as n bags for 16 × n dollars | One sentence: "$16 for each bag" |
| Steps, a sequence or a schedule | An `ol`, a timeline with rules, or one screen for each step |
| Options with trade-offs | A table: one row for each criterion, the verdict in the first row |
| A structure or a flow | An inline SVG diagram of labeled boxes and arrows. 12 boxes max. |
| Detail that few readers need | A `details` element. The `summary` names the content. |

## Layout

- Put the result first. The main number or the conclusion is at the top of the
  first screen.
- Make one big move on a screen at most: a block of color, a `.display` line,
  or a ruled panel of numbers. Two big moves compete. A note needs none.
- Give unequal items unequal space. The main item can take a full row. Do
  not add or merge an item to fill a grid.
- At 1280 px, put a chart and its text side by side, or give the chart the
  full width.
- The sections of one screen share a left and a right edge. A block of prose
  keeps its line length. A list, a timeline or a table takes the full width,
  with `max-w-none` on each `li`, or sits beside a second block.
- A highlight on a row stays inside the edges of the row. Do not give it a
  negative margin.
- A screen has one primary action. A long screen can repeat its `.primary`
  button at the end.
- Write the content as HTML, not with a script. If the script fails, the
  reader still has the content.
- Put sources and method in one `details` element at the end.
- Do not add a section that the user's content cannot fill.
- Make the space between groups two times the space in a group or more:
  `gap-2` in a group, `gap-4` or more between groups.
- Do not set a fixed width or a fixed height on a box of text. Use
  `w-full max-w-2xl` and `min-h-*`.
- Put a code block or a diagram in a `figure`. The `figure` scrolls, and the
  page does not.

Use cards only for equal items that the reader compares or acts on, and for
the panels of a dashboard. Select the grid from the number of cards. No card
is alone on the last row.

| Cards | Classes on the grid | Result |
| --- | --- | --- |
| 2 | `grid gap-4 sm:grid-cols-2` | 2 |
| 3 | `grid gap-4 md:grid-cols-3` | 3 |
| 4 | `grid gap-4 sm:grid-cols-2 lg:grid-cols-4` | 2 × 2, then 4 |
| 6 | `grid gap-4 sm:grid-cols-2 lg:grid-cols-3` | 2 × 3, then 3 × 2 |
| 8 | `grid gap-4 sm:grid-cols-2 lg:grid-cols-4` | 2 × 4, then 4 × 2 |
| 9 | `grid gap-4 md:grid-cols-3` | 3 × 3 |
| 5, 7 | The main card on a full row, then the grid for 4 or 6. Or a table. | |

At 390 px, each grid is one column. For short number cards, add `grid-cols-2`.

## Surfaces

- Use rules in place of boxes for the second level of structure: notes,
  timelines, columns of numbers, a list of links. Write
  `border-t border-line pt-3`.
- Do not put prose or a section heading in a card. Do not put a card in a
  card, or a full screen in one card.
- The look sets the border, the shadow and the radius of a card. Do not add
  these classes to an `article`.
- Cards in one row have the same parts in the same order. A card title has
  one line. A card body has 25 words or fewer.
- Use the template `button` and `.primary` only. Do not make a new button
  style.

## Type

The look sets the faces, the sizes and the weights. Do not set a font size on
a heading or on reading text.

- Put `.display` on one item of a screen at most: the `h1` of a first screen,
  the claim of a slide, or the main number.
- Put `.lead` on one paragraph of a screen at most, below the `h1`.
- Use `text-sm` for secondary text. Use `text-xs` only for chart labels.
- Use the weights 400 and 500 only. Make a heading larger, not bolder.
- Use mono for table figures and code only. Words in mono look like an error.
- Align text to the start. Center only a heading and a block of two lines or
  fewer.

## Color

- Most of a screen is neutral: `bg`, `surface`, `text`, `muted`, `line`.
- Give the accent one job on each screen: the item that the `h1` claims.
  Links and the primary button also use it. Draw all other bars in `edge`.
- Show a selected item with `accent` or `bg-accent-soft`, not with the field.
  A deep field on a dark page does not look selected.
- Use `ok`, `warn` and `bad` for status only, and always with words. Color a
  change by its effect: a decrease in churn is `text-ok`.
- Use `text-muted` for labels, dates and captions only.
- On `bg-accent`, use `text-on-accent`. On `bg-field`, use `text-on-field`.
- Use the dark design only when the user or the design file asks for it. Do
  not put `class="dark"` on a part of a light page. A deep `bg-field` block
  is correct.

On the review page, a rail of review tools joins the right edge of the page.
The rail takes the color of `body`, so a different color at that edge shows
as a seam. Keep `html` and `body` one solid color. Keep a block of color
inside the content width.

## Tables

- Align numbers with `text-end`. Align text to the start.
- Give the table a `caption` of one line. Give each header cell a `scope`.
- Show only the columns that answer the question. Sort by the column that
  answers the question. Sort by name only in a lookup table.
- Keep a cell to a short phrase. Use one unit and one precision in a column.
- Do not make the font smaller to make a table fit.
- At 390 px, a table shows three columns or fewer, with no sideways scroll.
  Put `max-sm:hidden` on the `th` and each `td` of each other column. Show
  its value in the first cell, as `<small class="block sm:hidden">`.

## Charts

- One chart answers one question.
- Start a bar at zero. Charts that the reader compares use one scale.
- Sort bars from the largest to the smallest. Sort time from left to right.
- Name the unit of each axis in the heading, on the axis or in the labels.
- Put the value at the end of each bar. On a line, label the last point and
  the extreme points only.
- Add a legend only for two series or more. Put the name at the end of the
  line if there is space.
- Show five series at most. Add the remaining series together as "Other", in
  `edge`.
- Do not use two y axes, 3D, a pie chart, a gradient fill, dashed gridlines,
  rotated labels or a border on a bar.
- Use four gridlines at most, with `stroke-line`. Use `fill-muted text-xs` for
  labels. No two labels overlap.

Draw bars as HTML rows. The text keeps its size on a phone.

```html
<div id="bar-enterprise" class="flex items-center gap-3">
  <span class="w-24 shrink-0 sm:w-32">Enterprise</span>
  <div class="flex flex-1 items-center gap-2">
    <div class="h-3 w-63/100 rounded-sm bg-accent" aria-hidden="true"></div>
    <span class="tabular-nums">$412K</span>
  </div>
</div>
```

The widest bar is `w-4/5`, so that its value fits after it. Calculate each
other width from its value: $412K of a $520K maximum is 412 ÷ 520 × 80, so
`w-63/100`. A script can set the same class.

Draw a line chart or a diagram as inline SVG. Give the `<svg>` a `viewBox` and
`class="h-auto w-full min-w-144"`, and put it in a `figure`. Use
`fill-none stroke-accent stroke-2` for the line. If a script draws the chart
again, give each bar, point or box a `data-ac-part` (`authoring.md`, rule 4).
For series of equal weight, use `series-1` to `series-4` in their order, as
`stroke-series-2`, and label each series in text.

## States

- A loading state has the shape of the content that comes.

## Rules for each kind

### Report

- The first screen has the finding as its `h1`, two to five key numbers, the
  conclusion in three sentences or fewer, and the next step.
- Each later section has a finding as its heading, one table or chart, and two
  paragraphs at most.
- Keep the prose of a screen to about 500 words.
- Use more than one screen only for separate topics, such as "Summary" and
  "Actions".

### Dashboard

- Below the `h1`, write the period, the units, the comparison and the date of
  the data one time.
- Give the number that the `h1` names a wider panel and a larger size. Put
  two to four other numbers smaller beside it.
- One main chart follows. It has the full width. Tables with the detail come
  last.
- Controls that filter are in one row above the parts that they change. Each
  control works.
- A panel is an `article` with one number and its label, or one chart and
  its heading.
- The first screen has the main number, the main chart, and each chart that
  explains it. A reader who opens only this screen gets the full answer. Use
  a second screen only for a table of detail or for a different question.

### Mockup

- If the product exists, use its colors, font and radius.
- Fill the mockup with content that looks real. Include a long name, a zero
  and a large number.
- For options, make one screen for each option. Name it for its trade-off and
  write the trade-off in one line below the `h1`.
- A web mockup fills the page, with no device frame.
- A phone mockup shows phone screens. Put each one in a `w-full max-w-sm` box,
  with the app bar at the top and the tab bar or main action at the bottom.
  At 1280 px, put two or three steps of the flow side by side.
- Link each main control to the screen that it opens.

### Deck

- One slide is one `data-screen` section. Name its `id` for its content, such
  as `slide-churn`. Remove the `<nav>`. Write `<body data-deck>`: the arrow
  keys then change the slide, and the template sets the height and the rows
  of each slide. Add no layout class to the section.
- A slide section has one `div` with the claim and the evidence, then one
  `footer` with the Back link, the Next link and the speaker notes:

  ```html
  <section id="slide-churn" data-screen>
    <div>
      <h1>Churn fell by half after the price change</h1>
      <p class="display">2.1%</p>
      <small>Monthly churn in April 2026, from 4.2% in February</small>
    </div>
    <footer>
      <a class="button" href="#/slide-intro">Back</a>
      <a class="button primary" href="#/slide-plan">Next</a>
      <details><summary>Speaker notes</summary><p>…</p></details>
    </footer>
  </section>
  ```

- A slide has one claim as its `h1` and one piece of evidence. It has 40
  words or fewer.
- The evidence fills the slide: the main number in `.display`, or one chart
  at the full width. Do not put three small numbers at the top of a slide.
- Put `.display` on the main number, or on a claim of six words or fewer.
- A slide fits in a window of 1280 × 720 px with no scroll. If it does not
  fit, divide the slide. Do not make the text smaller.
- The first slide has the title, the presenter and the date. The last slide
  has the decision or the next steps.

### Document

- Use one column of text and one screen.
- Give each `h2` an `id`. If there are more than five, start with a list of
  links to them.
- Do not put a note in a card. Use a `blockquote`.

## Tells

A model makes the most common choice at each step. These choices together
show that a model made the page.

| Tell | Do this in its place |
| --- | --- |
| The template look and its default accent, on any subject | A look and an accent from the subject |
| A row of equal number cards at the top of a data page | One main number large, the others smaller, with rules between them |
| A grid sized before the content, as a bento grid | Size each item from its content |
| Content that fades in on scroll, a typing effect on a heading, or a hover effect on a card that is not a link | No motion |
| An icon in a tinted tile above each heading | The heading alone |
| A dot grid, a graph-paper grid, a glow or a blob behind the content | A plain surface. A pattern only from the subject, as `showpiece.md` says. |
| A pulsing or colored dot for "Live", a status or a count | The word in a `span.badge` |
| A middle dot between items: `Support · October 2026`, `6,961 · 48%` | A gap and `text-muted` on the second item, or a comma |

## Check the design

`check` measures scroll, clipped text, overlap, contrast and the right edge.
Do not look for these in the images.

Open each image, and look for these items in this order. Name the screen and
the element of each finding.

1. At 1280 px, point at the largest item of each screen. It is the main item.
   If not, make the main item larger or the other item smaller.
2. Find each use of the accent, other than links and the primary button. It
   marks one thing. Change the others to `edge` or `text`.
3. Look for an empty area of more than one third of the image. Also look for
   a hole in a grid or a row, and a short column beside a tall one. Fill it
   with the next item, or make the item next to it wider.
4. At 1280 px, find the right edge of each table, list and timeline. It is at
   the right edge of the content, or a second block is beside it. Only prose
   stops before it. A highlight on a row stays inside the row.
5. Look for a row of equal cards or columns, as features with icons, steps,
   or the events of an invite. If the items are not equal, use a list, a
   timeline or a table, or give the main item more space.
6. At 390 px, look for a heading with one word on its last line. Make the
   heading shorter.
7. At 390 px, look for a table with more than three columns, or a cell that
   the edge cuts. Hide the columns as "Tables" says.
8. At 390 px, look for more than four cards in a column. Use a list, a table,
   or two columns for short numbers.
9. Look for each tell in "Tells". Compare each screen with the rules for its
   kind, in this file, `interaction.md` or `showpiece.md`.
10. Read only the headings and the numbers. If the message is not clear, change
   the headings.

Correct all findings in one round. A showpiece then gets the second round of
`showpiece.md`. Then run the full check of step 2 of `SKILL.md` again, and
publish. After that, correct only a `check` error. If you find nothing,
publish the page with no change.
