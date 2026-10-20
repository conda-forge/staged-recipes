#import "@preview/elembic:1.1.1" as e

#let theorem = e.element.declare(
  "theorem",
  prefix: "@preview/my-package,v1",
  display: it => [*Theorem:* #it.body],
  fields: (
    e.field("body", content, required: true),
  ),
)

#theorem[Hello]
