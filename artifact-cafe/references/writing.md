# Write the text of an artifact

Read this before you write the text of an artifact, in HTML or in Markdown.
A reviewer opens the link between two other tasks. They read the headings and
the numbers, decide, and comment. Each word before the point costs them time.

1. Write one sentence for yourself: who reads this, and what must they decide
   or do after 10 seconds.
2. Write the headings and the numbers first. Then write only the sentences
   that the headings and the numbers cannot carry.
3. Before you check or publish, do "Last pass" at the end of this file.

## Facts

A reader takes each fact on the page as true. The reader cannot see which
facts a model added.

- Never invent evidence: a testimonial, a quote, a logo, a statistic, a
  number of users, or an award. If the user gives none, leave out the
  section.
- The page can need a detail that the user owns: a price, a date, a name, an
  address, or a URL. If the user did not give it, write a sample value. Do
  not stop to ask for it.
- Add a fact about the world, as a place, a history, or a public date, only
  when you are sure of it.
- In your message to the user, list each value and each fact on the page that
  the user did not give. The user can then correct it. Do not put this list,
  or a note about a draft or sample content, on the page.
- A mockup, or a view of the product in use, shows sample data. In your
  message, say that it is sample data. Do not list each value of it.
- If an action has no URL from the user, link it to a screen of the artifact
  that says what occurs next.
- Keep the text that the user gives, word for word. If it breaks a rule of
  this file, keep it and tell the user.
- Calculate each percentage and each total again from its source numbers.
  Mark an estimate with "about". Write what the data does not show.

## Say the point first

- The first sentence of the page and of each section is its point. The
  reason and the detail come after it, because a reviewer often reads only
  that sentence.
- Write a summary in this order: the finding, the cause, what is not known,
  and the next step.

For each sentence, do the first row that applies.

| The sentence | Do this |
| --- | --- |
| Has two numbers or more | Move the numbers to a table or a list. In an HTML artifact, use the form that "Select the form" in `design.md` gives. |
| Repeats a heading, a chart, a table or a sentence before it | Remove it |
| Describes the page or its design, as `This section shows` or `The pattern on this page` | Remove it |
| Fits a different artifact with no change | Write a fact of this subject in its place, or remove it |
| Is the third paragraph in sequence | Change it to a list, a table or a chart |

## Headings

Select the heading from what the reader does with the section.

| The reader | The heading |
| --- | --- |
| Learns a result or a claim: a report section, a chart, a slide, a pitch | The point as a sentence, with its number: "Signups doubled in March", not `Signups` |
| Looks for a thing: hours, tickets, questions, the nav | A name of four words or fewer: "Opening hours" |
| Sees a product screen in a mockup | The title that the product uses: "Settings" |

If a different artifact can use a claim heading with no change, write a new
one. Use sentence case and two lines at most. Put no small label above a
heading. Number sections only for a sequence.

## Labels, numbers and messages

| Text | Write | Example |
| --- | --- | --- |
| Number label | The measure and the period | "Revenue, Q3 2026", not `Total Revenue` |
| Change | The sign, the base and the period | "Up 4.4% from September", not `+4.4%` |
| Large number | A thousands separator and the unit. K or M above 10,000. Only the precision that the decision needs. | "1,240 kg", "12.9K", "$4.2M" |
| Date | The month as a word, in a `<time>` element in HTML. Never a relative date, because the page stays online. | "12 Nov 2026", not `next week` |
| Time, range, quote | The zone for readers in two zones. An en dash in a range. Curly quotes in text. | "9:00 PT", "Mon–Fri", “ ”, ’ |
| Table header | The noun, with the unit in parentheses | "Revenue ($K)" |
| Chart caption | What the heading does not say: the unit, the source, a baseline, a mark | "The axis starts at $1.0M. The shaded band is Q3." |
| Button | A verb and its object. A submit button names the result. | "Export report", "Send RSVP", not `Submit` or `OK` |
| Link | The place that it opens | "Read the billing docs", not `Learn more` |
| Error | What occurred, and how to correct it | "Enter the date as DD/MM/YYYY", not `Oops, something went wrong` |
| Empty state | Why it is empty, and one action | "No invoices yet. Each paid order adds one." Then "Create invoice" |

## Tells

A model writes the most likely phrase. Readers know these phrases, and they
stop trusting the page.

| Tell | Write in its place |
| --- | --- |
| A claim with no fact: `Faster closes`, `Data you can trust` | The claim with its number: "Close the books in 2 days instead of 6" |
| A stock phrase: `unlock the full potential`, `seamless integration`, `world-class`, `successfully` | The fact or the number. If there is none, remove the sentence. |
| A contrast with nobody: `not just X, but Y`, `isn't X, it's Y` | Y only |
| Three items from habit: `quality, convenience, and value` | The real items. Two items stay two. |
| A tail that adds weight: `, highlighting the importance of` | Remove it. Give a real effect its own sentence and its evidence. |
| Inflation: `a testament to`, `plays a crucial role` | What occurred, with the date or the number |
| A line that sounds deep: `Some conversations only start across a table.` | A fact that the reader can use: a time, a place, a price |
| The reader as a type: `Whether you're a beginner or a pro` | The person it is for, named one time |
| Chat words: `Here's an overview`, `Let's dive in`, `In summary` | Nothing. Start with the point, and stop after the last fact. |
| A dash between two clauses: `—` | A period or a comma |
| Many names or values for one thing: tickets, cases, requests | One name and one value in the whole artifact |

The examples, sentence case, and the formats of dashes, quotes, dates and
numbers are for English. In a different language, use its conventions. Find
the tells by their shape: a contrast with nobody, three items from habit, a
slogan.

## Last pass

Read only the headings and the first sentence of each section. Correct each
one that breaks a rule of this file.

Done when:

- Each heading matches its row of "Headings".
- No heading and no first sentence fits a different artifact with no change.
- For HTML: in step 2 of `SKILL.md`, `check` gives no `stock-phrase` or
  `filler` warning in text that you wrote.
- You have the list of "Facts" for your message to the user.
