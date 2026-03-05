# crispy-vault

A config-builder for OpenClaw — tools to help new users get from zero to a working bot without touching raw JSON.

## Goal

OpenClaw's current onboarding gets you one bot on one channel. This project extends that with:

1. **Multi-channel builder** — add more than one Telegram or Discord bot. OpenClaw already generates a single channel block; this adds the flow for `telegram2`, `discord2`, etc. with properly indexed tokens.

2. **Env builder** — guided setup that walks through which environment variables are required, what each one does, and generates a filled `.env.example` before the first gateway start. Reduces the "why isn't my bot connecting" troubleshooting for new users.

## Status

Early stage. Currently contains:

- `build/` — config assembler script (`build-config.js`) that reads tagged markdown blocks and outputs `dist/openclaw.json`
- `dist/` — build output (config, context files, pipelines, focus mode files)
- `test/` — build validation suite (`node test/build.test.js`)
- `package.json` — CommonJS override + npm scripts

## Build & test

```bash
node build/scripts/build-config.js          # build all dist/ artifacts
node build/scripts/build-config.js --audit  # list all block IDs found
node test/build.test.js                     # run validation (10 tests)
```

## Contributing

This is a feature branch targeting upstream OpenClaw. The two features above are the current focus — env builder and multi-channel support. Everything here is meant to eventually become a PR.
