# Showpiece

Read this when the artifact is a showpiece, as step 1 of `SKILL.md` says.
It adds to `design.md`. Read that file too.

## One concept, one move

Before you write HTML, select one concept from the subject and the one big
move that shows it. Write the move as the third part of the look comment:

```css
/* Look: poster. Accent: Prussian blue, the pigment of the show. Move: a field of the pigment with the title at display size. */
```

Select one move:

- A block of color from the subject, with the title on it.
- One `.display` line: the claim, the name, or the date.
- A ruled panel of real numbers at display size.
- A timeline of the real dates.
- A pattern from the subject, in inline SVG.

## In place of a hero picture

Do not draw people, objects or scenes. A drawn figure looks cheap, and a
reviewer comments on the drawing and not on the content. Use one of these:

- Real data, or real numbers at display size.
- The name, the claim or the date as type at display size.
- A photograph or a screenshot of the subject from the user.
- A geometric pattern from the world of the subject. A tile pattern fits
  Lisbon, a city of tiles. A drawing of a cup does not fit a café.

To draw a pattern:

- Use an inline `<svg>` with a `<pattern>` or repeated shapes.
- Set `fill="currentColor"` or `stroke="currentColor"`, and color the `<svg>`
  with a token class, as `text-accent` or `text-on-field`.
- Give the `<svg>` `aria-hidden="true"`.
- Keep it inside the content width, and put no text on it.

## Shape for each kind

### Landing page

- The `h1` says what it is and who it is for.
- The rest of the first screen has the main benefit with a number, the price
  or the fact that decides, and one primary action.
- The first screen also shows the thing in use, built in HTML from sample
  details: an order, a booking, an account screen.
- If the move is a block of color, it holds the title block and one piece of
  evidence, side by side at 1280 px. No half of the block is empty.
- Next come the proof, how it works, the price and the details. The proof is
  real numbers, a real screenshot or a demo. Do not show three steps in
  three equal columns.
- The page ends with the action.

### Invite or event page

- The first screen has who, what, the date, the place, and the reply action
  with its last date. The date is the largest text after the `h1`.
- Next come the schedule as a timeline with rules, the way to get there, and
  what to bring or wear. Leave out a row or a section that the user gave no
  content for. A short page is correct.
- The main event gets the field or the accent. The other events get rules,
  not equal cards.

### Announcement

- The `h1` is the news in one sentence, with the date.
- Next come what changes for the reader, the detail, and one action.

### Pitch deck

- Use the deck rules in `design.md`.
- The first slide states the claim of the whole deck, not only a title.
- Each slide has one claim and one piece of evidence.
- The last slide has the ask: the amount, the decision, or the date.

### Portfolio

- Show the work first, at a large size. One line says who and what.

Do not make the default first screen: a centered hero with a pill badge, a
slogan and two buttons. Then look for each tell in "Tells" of `design.md`
before you build.

## Words that persuade

- Start with the benefit to the reader, not with the product.
- Put the price or the date on the first screen.
- Give one action.
- At 390 px, the `h1`, the price or the date, and the action are in the first
  image.

## Second round

A showpiece gets two rounds of corrections. After the first round of
"Check the design" in `design.md`:

1. Read the `Move:` part of the look comment. If a different subject can use
   the move with no change, change it to a move from this subject. Change
   the move only.
2. Look at the changed screens again for the items of "Check the design".
   To see one screen, use `check --screen`, as step 2 of `SKILL.md` says.

Then run the full check of step 2 of `SKILL.md`, and publish. Do not start a
third round.
