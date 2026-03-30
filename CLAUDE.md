# aers.mobi — Drug & Device Safety Signal Detection

## Overview
Rhino/Shiny app for Bayesian disproportionality analysis of drug and medical device adverse events using FAERS and MAUDE data. Uses the `safetysignal` R package as its statistical engine.

## Architecture
- **Framework:** Rhino (production Shiny)
- **Engine:** `safetysignal` package (2-component Gamma-Poisson)
- **Data sources:** FAERS (drugs/biologics), MAUDE (medical devices)
- **Domain:** aers.mobi

## Key Files
- `app/main.R` — App entry point
- `app/logic/signal_engine.R` — Wraps safetysignal for this app
- `app/view/signal_table.R` — Signal results table module

## Related Projects
- `safetysignal` — Shared Bayesian engine package
- `faers-mobi` — Vaccine version
- `globalpatientsafety` — Broader safety dashboard
