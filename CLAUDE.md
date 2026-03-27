# ext-shifting — Claude Instructions

## README

Audience: mathematicians who want to use the Macaulay2 code directly (without the web app). They are comfortable with M2 but may not be software developers.

Sections to maintain:
- How to load the libraries (`load "libs.m2"`)
- How to shift a simplicial complex (with a concrete example)
- How to run the iterative analysis (step-by-step)
- Functions to know (once documented)

Do NOT add: web app instructions, Docker setup, API reference, .NET/C# internals. Those belong in the ext-shifting-app README.

Keep it brief. This README is a quick-start, not a tutorial.

## Ubiquitous Language

The canonical domain glossary lives in `UBIQUITOUS_LANGUAGE.md` at the root of this repo. It covers mathematical and algorithmic terms (simplicial complex, exterior shifting, vertex split, critical region, etc.).

App-layer terms (Docker container, job state, SSE, API endpoints) are defined in the ext-shifting-app repo's `UBIQUITOUS_LANGUAGE.md` — do not duplicate them here.

When offering to update the glossary, default to this file for any mathematical or algorithmic term. Only escalate to the app-layer file if the term is about the web application.
