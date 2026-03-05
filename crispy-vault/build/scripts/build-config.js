#!/usr/bin/env node

/**
 * Crispy Kitsune Vault Builder
 *
 * Reads Obsidian vault markdown files and extracts tagged code blocks
 * to assemble deployable config files.
 *
 * Block ID conventions:
 *   Config:   ^config-gateway, ^config-agents, ^config-channels, etc.
 *   Context:  ^ctx-soul-*, ^ctx-identity-*, ^ctx-agents-*, ^ctx-tools-*,
 *             ^ctx-user-*, ^ctx-memory-*, ^ctx-boot-*, ^ctx-heartbeat-*,
 *             ^ctx-bootstrap-*, ^ctx-status-*
 *   Env:      ^env-gateway-token, ^env-openrouter, ^env-template, etc.
 *   Pipeline: ^pipeline-brief, ^pipeline-email, ^pipeline-git, etc.
 *   Focus:    ^mode-{slug}, ^tree-{slug}, ^triggers-{slug}, ^filter-{slug},
 *             ^compaction-{slug}, ^speed-{slug}
 *   Guard:    ^guardrail-input, ^guardrail-output, etc.
 *
 * Usage:
 *   node build-config.js                    # build all
 *   node build-config.js --dry-run          # show what would be built
 *   node build-config.js --only config      # just openclaw.json
 *   node build-config.js --only context     # just context files
 *   node build-config.js --only pipelines   # just .lobster files
 *   node build-config.js --only focus       # just focus mode files
 *   node build-config.js --only env         # just .env
 *   node build-config.js --version-tag v0.001+INIT  # embed version tag in headers
 *   node build-config.js --audit            # list all block IDs found
 *   node build-config.js --channels discord:3 telegram:2  # generate indexed channel entries
 *   node build-config.js --agents discord-bot:5           # generate indexed agent entries
 *
 * Output: ./dist/ directory with all deployable files
 *         - openclaw.json5 (JSON5 with comments)
 *         - openclaw.json (valid pure JSON)
 *         - .env.example (template with placeholder values)
 *         - LAYERS-MANIFEST.json (block → layer mapping)
 */

const fs = require('fs');
const path = require('path');

// ─── Configuration ───────────────────────────────────────────
const VAULT_ROOT = path.resolve(__dirname, '../..');
const DIST_DIR = path.join(VAULT_ROOT, 'dist');

const args = process.argv.slice(2);
const DRY_RUN = args.includes('--dry-run');
const AUDIT = args.includes('--audit');
const ONLY = args.includes('--only') ? args[args.indexOf('--only') + 1] : null;
const VERSION_TAG = args.includes('--version-tag') ? args[args.indexOf('--version-tag') + 1] : null;

// Multi-bot CLI args: --channels discord:3 telegram:2 → generate indexed channel entries
// --agents discord-bot:5 → generate indexed agent entries
function parseMultiArg(flag) {
  const idx = args.indexOf(flag);
  if (idx === -1) return {};
  const result = {};
  for (let i = idx + 1; i < args.length; i++) {
    if (args[i].startsWith('--')) break;
    const [type, countStr] = args[i].split(':');
    if (type && countStr) result[type] = parseInt(countStr, 10);
  }
  return result;
}
const CHANNELS_GEN = parseMultiArg('--channels');
const AGENTS_GEN = parseMultiArg('--agents');

// ─── Block ID → Context File Mapping ─────────────────────────
// Maps block ID prefixes to their target context files.
// Vault uses ^ctx-soul-*, ^ctx-agents-* pattern.
// getContextPrefix() strips the leading 'ctx-' to match these keys.
const CONTEXT_PREFIX_MAP = {
  'soul':      'SOUL.md',
  'identity':  'IDENTITY.md',
  'agents':    'AGENTS.md',
  'tools':     'TOOLS.md',
  'user':      'USER.md',
  'memory':    'MEMORY.md',
  'boot':      'BOOT.md',
  'heartbeat': 'HEARTBEAT.md',
  'bootstrap': 'BOOTSTRAP.md',
  'status':    'STATUS.md',
};

// ─── Focus Mode Block → Deploy Mapping ───────────────────────
// Maps focus block type prefixes to their deploy filenames and formats.
// Blocks use ^mode-{slug}, ^tree-{slug}, etc.
const FOCUS_BLOCK_MAP = {
  'mode':       { file: 'mode.md',       format: 'markdown' },
  'tree':       { file: 'tree.json',     format: 'json' },
  'triggers':   { file: 'triggers.json', format: 'json' },
  'filter':     { file: 'filter.json',   format: 'json' },
  'compaction': { file: 'compaction.md', format: 'markdown' },
  'speed':      { file: 'speed.json',    format: 'json' },
};

// Prefixes that are NOT context blocks (avoid false matches)
const NON_CONTEXT_PREFIXES = [
  'config',    // openclaw.json sections
  'env',       // .env variables
  'pipeline',  // .lobster pipelines
  'guardrail', // guardrail code blocks
  'telegram',  // telegram-specific patterns
  'block',     // generic block references in comments
  'mode',      // focus mode context → focus build
  'tree',      // focus trees → focus build
  'triggers',  // focus triggers → focus build
  'filter',    // focus filters → focus build
  'compaction',// focus compaction → focus build
  'speed',     // focus speed baselines → focus build
];

/**
 * Resolve a context block prefix.
 * Handles ^ctx-soul-* → 'soul', ^ctx-agents-* → 'agents', etc.
 * Returns null if not a context block.
 */
function getContextPrefix(id) {
  if (!id.startsWith('ctx-')) return null;
  // Strip 'ctx-' and get next segment
  const rest = id.slice(4); // e.g., 'soul-identity', 'agents-loop'
  const dash = rest.indexOf('-');
  return dash === -1 ? rest : rest.slice(0, dash);
}

/**
 * Parse a focus block ID into {type, slug}.
 * e.g., ^mode-cooking → {type: 'mode', slug: 'cooking'}
 *       ^speed-pet-care → {type: 'speed', slug: 'pet-care'}
 */
function parseFocusBlockId(id) {
  for (const prefix of Object.keys(FOCUS_BLOCK_MAP)) {
    if (id.startsWith(prefix + '-')) {
      return { type: prefix, slug: id.slice(prefix.length + 1) };
    }
  }
  return null;
}

// ─── Block ID extraction ─────────────────────────────────────

/**
 * Extract all blocks with ^block-id tags from a markdown file.
 *
 * Handles three patterns:
 *   1. Code fence with ID on same line:  ```json5 ^config-models
 *   2. Code fence with ID on next line:  ```yaml\n^pipeline-brief
 *   3. Text line ending with ID:         Some text ^soul-nature
 *   4. Standalone ID on its own line:    ^agents-loop
 *      (captures the NEXT non-empty paragraph as content)
 */
function extractBlocks(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const blocks = [];
  const seenIds = new Set();

  // Pattern 4: Code fence FOLLOWED BY standalone ^block-id on the next non-empty line
  // This is the COMMENT→BLOCK→ID pattern used by all config-reference.md files:
  //   ```json
  //   "gateway": { ... }
  //   ```
  //   ^config-gateway
  //
  // MUST run FIRST — before Pattern 2 — because Pattern 2 would otherwise false-match
  // the closing ``` of a Pattern 4 block as an "opening fence" (``` with no language
  // matches \w*), consuming the block ID and any following text until the next ```.
  // By running Pattern 4 first, block IDs are registered in seenIds before Pattern 2
  // can produce a false match.
  const fenceP4 = /```(\w*)\n([\s\S]*?)```\n\n?\^([\w-]+)/g;
  let match;
  while ((match = fenceP4.exec(content)) !== null) {
    const id = match[3];
    if (!seenIds.has(id)) {
      seenIds.add(id);
      blocks.push({
        id: id,
        type: 'code',
        language: match[1] || 'text',
        content: match[2].trim(),
        source: filePath,
      });
    }
  }

  // Pattern 1: Block ID on the fence line
  // ```json5 ^config-models
  // content
  // ```
  const fenceP1 = /```(\w*)[ \t]+\^([\w-]+)\n([\s\S]*?)```/g;
  while ((match = fenceP1.exec(content)) !== null) {
    if (!seenIds.has(match[2])) {
      seenIds.add(match[2]);
      blocks.push({
        id: match[2],
        type: 'code',
        language: match[1] || 'text',
        content: match[3].trim(),
        source: filePath,
      });
    }
  }

  // Pattern 2: Block ID on separate line inside fence
  // ```yaml
  // ^config-models
  // content
  // ```
  const fenceP2 = /```(\w*)\n\^([\w-]+)\n([\s\S]*?)```/g;
  while ((match = fenceP2.exec(content)) !== null) {
    if (!seenIds.has(match[2])) {
      seenIds.add(match[2]);
      blocks.push({
        id: match[2],
        type: 'code',
        language: match[1] || 'text',
        content: match[3].trim(),
        source: filePath,
      });
    }
  }

  // Pattern 3: Text ending with ^block-id (inline block)
  // Crispy is a **zenko**... ^soul-nature
  const textP3 = /^(.+?)\s+\^([\w-]+)\s*$/gm;
  while ((match = textP3.exec(content)) !== null) {
    if (!seenIds.has(match[2])) {
      // Skip if this looks like it's inside a code fence or HTML comment
      const line = match[0];
      if (line.trim().startsWith('```') || line.trim().startsWith('<!--')) continue;
      seenIds.add(match[2]);
      blocks.push({
        id: match[2],
        type: 'text',
        language: 'markdown',
        content: match[1].trim(),
        source: filePath,
      });
    }
  }

  // Pattern 5: Standalone ^block-id on its own line
  // Captures the next non-empty lines until a blank line or heading
  // Runs AFTER Pattern 4 so code-fence blocks take priority.
  const standaloneP5 = /^\^([\w-]+)\s*$/gm;
  while ((match = standaloneP5.exec(content)) !== null) {
    const id = match[1];
    if (!seenIds.has(id)) {
      // Look for content after the block ID
      const afterId = content.slice(match.index + match[0].length);
      const nextContent = afterId.split(/\n\n|\n#/)[0].trim();
      if (nextContent) {
        seenIds.add(id);
        blocks.push({
          id: id,
          type: 'text',
          language: 'markdown',
          content: nextContent,
          source: filePath,
        });
      }
    }
  }

  return blocks;
}

/**
 * Recursively find all .md files in a directory
 */
function findMarkdownFiles(dir) {
  const results = [];
  if (!fs.existsSync(dir)) return results;

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.name.startsWith('.')) continue;
    if (['node_modules', 'dist', 'archive', 'releases'].includes(entry.name)) continue;

    if (entry.isDirectory()) {
      results.push(...findMarkdownFiles(fullPath));
    } else if (entry.name.endsWith('.md')) {
      results.push(fullPath);
    }
  }
  return results;
}

/**
 * Get the prefix bucket for a block ID
 */
function getPrefix(id) {
  const firstDash = id.indexOf('-');
  return firstDash === -1 ? id : id.slice(0, firstDash);
}

// ─── JSON5 Parser ────────────────────────────────────────────

// Simple JSON5→JSON converter:
// - Strips line comments (//)
// - Strips block comments
// - Removes trailing commas before } and ]
// - Parses result with JSON.parse()
function parseJSON5(text) {
  // Remove line comments (//)
  let cleaned = text.replace(/\/\/.*?$/gm, '');

  // Remove block comments (/* */)
  cleaned = cleaned.replace(/\/\*[\s\S]*?\*\//g, '');

  // Remove trailing commas before } or ]
  cleaned = cleaned.replace(/,(\s*[}\]])/g, '$1');

  return JSON.parse(cleaned);
}

/**
 * Resolve $include directives in a parsed JSON object.
 * Replaces { "$include": "./path.json5" } with the contents of the referenced file.
 * Paths are resolved relative to the vault root.
 */
function resolveIncludes(obj, basePath) {
  if (typeof obj !== 'object' || obj === null) return obj;
  if (Array.isArray(obj)) return obj.map(item => resolveIncludes(item, basePath));

  // Check if this object IS an $include directive
  if (obj['$include'] && Object.keys(obj).length === 1) {
    const includePath = path.resolve(basePath || VAULT_ROOT, obj['$include']);
    if (fs.existsSync(includePath)) {
      const content = fs.readFileSync(includePath, 'utf8');
      try {
        const parsed = parseJSON5(content);
        console.log(`   📎 $include resolved: ${path.relative(VAULT_ROOT, includePath)}`);
        return resolveIncludes(parsed, path.dirname(includePath));
      } catch (e) {
        console.warn(`   ⚠️  Failed to parse $include "${includePath}": ${e.message}`);
        return obj;
      }
    } else {
      console.warn(`   ⚠️  $include file not found: ${includePath}`);
      return obj;
    }
  }

  // Recurse into child properties
  const result = {};
  for (const [key, value] of Object.entries(obj)) {
    result[key] = resolveIncludes(value, basePath);
  }
  return result;
}

/**
 * Generate indexed channel entries from --channels CLI arg.
 * e.g., --channels discord:3 → generates discord, discord1, discord2 entries
 */
function generateChannelEntries(configMap) {
  if (Object.keys(CHANNELS_GEN).length === 0) return;

  if (!configMap.channels) configMap.channels = {};

  for (const [type, count] of Object.entries(CHANNELS_GEN)) {
    // Find an existing channel of this type to use as template
    const template = configMap.channels[type];
    if (!template) {
      console.warn(`   ⚠️  No existing "${type}" channel to use as template. Skipping.`);
      continue;
    }

    console.log(`   🔧 Generating ${count} ${type} channel instances from template`);
    for (let i = 1; i < count; i++) {
      const key = `${type}${i}`;
      if (!configMap.channels[key]) {
        // Deep copy the template
        const entry = JSON.parse(JSON.stringify(template));
        // Update token var to indexed form
        if (entry.botToken) {
          entry.botToken = `\${${type.toUpperCase()}_BOT_TOKEN_AGENT${i}}`;
        }
        if (entry.token) {
          entry.token = `\${${type.toUpperCase()}_BOT_TOKEN_AGENT${i}}`;
        }
        configMap.channels[key] = entry;
        console.log(`     + ${key}`);
      }
    }
  }
}

/**
 * Generate indexed agent entries from --agents CLI arg.
 * e.g., --agents discord-bot:3 → generates discord-bot-1, discord-bot-2, discord-bot-3
 */
function generateAgentEntries(configMap) {
  if (Object.keys(AGENTS_GEN).length === 0) return;

  if (!configMap.agents) configMap.agents = {};
  if (!configMap.agents.list) configMap.agents.list = [];
  if (!configMap.agents.bindings) configMap.agents.bindings = [];

  for (const [prefix, count] of Object.entries(AGENTS_GEN)) {
    console.log(`   🔧 Generating ${count} ${prefix} agent entries`);
    for (let i = 1; i <= count; i++) {
      const id = `${prefix}-${i}`;
      // Skip if agent already exists
      if (configMap.agents.list.some(a => a.id === id)) continue;

      configMap.agents.list.push({
        id,
        workspace: `~/.openclaw/workspace-${id}`,
        heartbeat: { every: '1h', target: 'none', directPolicy: 'suppress' },
      });
      console.log(`     + agent: ${id}`);
    }
  }
}

/**
 * Deep merge two objects. Allows multiple config blocks to contribute
 * to the same nested path (e.g., L2 defines agents.defaults.model and
 * L7 adds agents.defaults.memorySearch — both merge cleanly).
 *
 * Rules:
 *   - Plain objects recurse (keys merge, no overwrite of sibling keys)
 *   - Arrays overwrite (no concat — last block wins)
 *   - Primitives overwrite (last block wins)
 */
function deepMerge(target, source) {
  for (const key of Object.keys(source)) {
    if (
      source[key] && typeof source[key] === 'object' && !Array.isArray(source[key]) &&
      target[key] && typeof target[key] === 'object' && !Array.isArray(target[key])
    ) {
      deepMerge(target[key], source[key]);
    } else {
      target[key] = source[key];
    }
  }
  return target;
}

/**
 * Determine the layer from a filepath
 * e.g., "stack/L1-gateway/config.md" → "L1"
 */
function getLayerFromPath(filePath) {
  const match = filePath.match(/\/L(\d+)-/);
  return match ? `L${match[1]}` : 'unknown';
}

// ─── Builders ────────────────────────────────────────────────

/**
 * Build openclaw.json5 (JSON5 with comments) from all ^config-* blocks
 */
function buildConfigJSON5(allBlocks, versionTag) {
  const configBlocks = allBlocks.filter(b => b.id.startsWith('config-'));

  if (configBlocks.length === 0) {
    console.warn('  ⚠️  No ^config-* blocks found. Skipping openclaw.json5.');
    return null;
  }

  console.log(`\n📦 Building openclaw.json5 from ${configBlocks.length} blocks:`);
  configBlocks.forEach(b => {
    const rel = path.relative(VAULT_ROOT, b.source);
    console.log(`   ^${b.id} ← ${rel}`);
  });

  // Deduplicate: keep first occurrence of each block ID
  const seen = new Set();
  const uniqueBlocks = configBlocks.filter(b => {
    if (seen.has(b.id)) return false;
    seen.add(b.id);
    return true;
  });

  // Output each config block as a commented section
  const sections = uniqueBlocks.map(b => {
    const rel = path.relative(VAULT_ROOT, b.source);
    return `  // ── ^${b.id} (from ${rel}) ──\n  ${b.content.split('\n').join('\n  ')}`;
  });

  let header = `// Crispy Kitsune — openclaw.json5
// Auto-assembled from layer config-reference.md files on ${new Date().toISOString().split('T')[0]}`;
  if (versionTag) {
    header += `\n// Version: ${versionTag}`;
  }
  header += `\n//
// Single source of truth: stack/L*/config-reference.md
// To change a value, edit the layer's config-reference.md, then re-run:
//   node build/scripts/build-config.js
//
// WARNING: This file is generated. Manual edits will be overwritten.
`;

  return header + `\n{\n${sections.join(',\n\n')}\n}\n`;
}

// Validate config against OpenClaw spec
// Returns array of warning strings
function validateOpenClawSchema(configMap) {
  const warnings = [];

  // Check for disallowed top-level keys
  const allowed = new Set(['gateway', 'agents', 'channels', 'tools', 'memory', 'hooks', 'plugins', 'cron', 'skills', 'session', 'bindings', 'env']);
  for (const key of Object.keys(configMap)) {
    if (!allowed.has(key)) {
      warnings.push(`Unknown top-level key "${key}" — Gateway strict validation will reject this`);
    }
  }

  // Check models structure (should be inside agents.defaults, not top-level)
  if (configMap.models) {
    warnings.push('"models" at top level — should be in agents.defaults.model + agents.defaults.models');
  }
  if (configMap.auth) {
    warnings.push('"auth" at top level — auth is handled via env vars and secret refs, not a config block');
  }

  // Check cron field names
  if (configMap.cron?.maxConcurrent !== undefined) {
    warnings.push('cron.maxConcurrent should be cron.maxConcurrentRuns');
  }

  // Check channel field names
  if (configMap.channels?.telegram?.groupPolicy) {
    warnings.push('channels.telegram.groupPolicy should be channels.telegram.groups');
  }
  if (configMap.channels?.telegram?.streamMode) {
    warnings.push('channels.telegram.streamMode should be channels.telegram.streaming');
  }

  // Check agents has model cascade
  if (configMap.agents?.defaults?.model && typeof configMap.agents.defaults.model === 'string') {
    warnings.push('agents.defaults.model is a string — should be object with primary + fallbacks');
  }

  return warnings;
}

/**
 * Build openclaw.json (pure JSON, properly ordered) from all ^config-* blocks
 */
function buildConfigJSON(allBlocks, versionTag) {
  const configBlocks = allBlocks.filter(b => b.id.startsWith('config-'));

  if (configBlocks.length === 0) {
    console.warn('  ⚠️  No ^config-* blocks found. Skipping openclaw.json.');
    return null;
  }

  console.log(`\n📦 Building openclaw.json (pure JSON) from ${configBlocks.length} blocks:`);
  configBlocks.forEach(b => {
    const rel = path.relative(VAULT_ROOT, b.source);
    console.log(`   ^${b.id} ← ${rel}`);
  });

  // Expected property order per OpenClaw spec (no separate models/auth — those go inside agents)
  const propertyOrder = ['gateway', 'agents', 'channels', 'tools', 'memory', 'hooks', 'plugins', 'cron', 'skills'];

  // Deduplicate: keep first occurrence of each block ID (build/ takes priority over stack/)
  const seen = new Set();
  const uniqueBlocks = configBlocks.filter(b => {
    if (seen.has(b.id)) return false;
    seen.add(b.id);
    return true;
  });

  // Parse each config block and extract as JSON
  const configMap = {};
  for (const block of uniqueBlocks) {
    try {
      // Wrap bare content in {} if it doesn't start with { to handle key:value blocks
      let content = block.content.trim();
      if (!content.startsWith('{')) {
        content = '{ ' + content + ' }';
      }
      let parsed = parseJSON5(content);
      // Resolve $include directives
      parsed = resolveIncludes(parsed, path.dirname(block.source));
      deepMerge(configMap, parsed);
    } catch (e) {
      console.warn(`  ⚠️  Failed to parse ^${block.id}: ${e.message}`);
    }
  }

  // Generate channel/agent entries from CLI args (--channels, --agents)
  generateChannelEntries(configMap);
  generateAgentEntries(configMap);

  // Build ordered JSON object
  const ordered = {};
  for (const key of propertyOrder) {
    if (key in configMap) {
      ordered[key] = configMap[key];
    }
  }

  // Add any remaining keys not in the expected order
  for (const key in configMap) {
    if (!(key in ordered)) {
      ordered[key] = configMap[key];
    }
  }

  // Validate against OpenClaw spec
  const warnings = validateOpenClawSchema(ordered);
  if (warnings.length > 0) {
    console.warn('\n⚠️  OpenClaw Schema Warnings:');
    warnings.forEach(w => console.warn(`   - ${w}`));
  }

  return JSON.stringify(ordered, null, 2);
}

/**
 * Build a context file from blocks matching a prefix.
 * Uses getContextPrefix() to route ^ctx-soul-* → SOUL.md, ^ctx-agents-* → AGENTS.md, etc.
 */
function buildContextFile(targetFile, prefix, allBlocks) {
  // Match blocks where getContextPrefix resolves to this prefix
  const blocks = allBlocks.filter(b => getContextPrefix(b.id) === prefix);

  if (blocks.length === 0) {
    console.warn(`  ⚠️  No ^ctx-${prefix}-* blocks found. Skipping ${targetFile}.`);
    return null;
  }

  console.log(`\n📄 Building ${targetFile} from ${blocks.length} ^ctx-${prefix}-* blocks:`);
  blocks.slice(0, 5).forEach(b => {
    const rel = path.relative(VAULT_ROOT, b.source);
    console.log(`   ^${b.id} ← ${rel}`);
  });
  if (blocks.length > 5) {
    console.log(`   ... and ${blocks.length - 5} more`);
  }

  // Title header for context files (cleaner than HTML comments for LLM readers)
  const title = targetFile.replace('.md', '');
  const header = `# ${title}\n\n`;

  // Assemble content: text blocks become paragraphs, code blocks stay fenced
  const parts = blocks.map(b => {
    if (b.type === 'code') {
      return `\`\`\`${b.language}\n${b.content}\n\`\`\``;
    }
    return b.content;
  });

  return header + parts.join('\n\n');
}

/**
 * Build .env from ^env-template block (the bash code block with the full template)
 */
function buildEnv(allBlocks, versionTag) {
  // Primary: look for the ^env-template block which has the full .env template
  const templateBlock = allBlocks.find(b => b.id === 'env-template');

  if (!templateBlock) {
    console.warn('  ⚠️  No ^env-template block found. Skipping .env.');
    return null;
  }

  console.log(`\n🔐 Building .env from ^env-template:`);
  const rel = path.relative(VAULT_ROOT, templateBlock.source);
  console.log(`   ^env-template ← ${rel}`);

  let header = `# .env.example — Auto-assembled from vault on ${new Date().toISOString().split('T')[0]}`;
  if (versionTag) {
    header += `\n# Version: ${versionTag}`;
  }
  header += `\n# Source: ${rel}
# Safe to commit. Copy to .env and fill in real values (chmod 600 .env).
`;

  return header + `\n${templateBlock.content}\n`;
}

/**
 * Build .env.example from ^env-* blocks with placeholder values
 */
function buildEnvExample(allBlocks, versionTag) {
  const envBlocks = allBlocks.filter(b => b.id.startsWith('env-') && b.id !== 'env-template');

  if (envBlocks.length === 0) {
    console.warn('  ⚠️  No ^env-* blocks found. Skipping .env.example.');
    return null;
  }

  console.log(`\n🔐 Building .env.example from ${envBlocks.length} ^env-* blocks:`);
  envBlocks.forEach(b => {
    const rel = path.relative(VAULT_ROOT, b.source);
    console.log(`   ^${b.id} ← ${rel}`);
  });

  let header = `# .env.example — Configuration template
# Auto-assembled from vault on ${new Date().toISOString().split('T')[0]}`;
  if (versionTag) {
    header += `\n# Version: ${versionTag}`;
  }
  header += `\n#
# Copy this file to .env and fill in the actual values.
# WARNING: Never commit .env to version control.
`;

  // Generate placeholder values for each env block
  const entries = envBlocks.map(b => {
    const id = b.id.replace('env-', '');
    // Convert hyphenated names to UPPERCASE with underscores
    const varName = 'OPENCLAW_' + id.replace(/-/g, '_').toUpperCase();

    // Use block content as a description if available
    const description = b.content.split('\n')[0].trim() || `Configuration for ${id}`;

    return `# ${description}\n${varName}=your_${id.replace(/-/g, '_')}_here`;
  });

  return header + `\n\n${entries.join('\n\n')}\n`;
}

/**
 * Build LAYERS-MANIFEST.json mapping blocks to their source layer
 */
function buildLayersManifest(allBlocks, versionTag) {
  console.log(`\n📋 Building LAYERS-MANIFEST.json:`);

  const manifest = {
    version: versionTag || 'unknown',
    generatedAt: new Date().toISOString(),
    layers: {},
  };

  // Group blocks by layer
  const blocksByLayer = {};
  for (const block of allBlocks) {
    const layer = getLayerFromPath(block.source);
    if (!blocksByLayer[layer]) {
      blocksByLayer[layer] = [];
    }
    blocksByLayer[layer].push({
      id: block.id,
      source: path.relative(VAULT_ROOT, block.source),
      type: block.type,
      language: block.language,
    });
  }

  for (const layer of Object.keys(blocksByLayer).sort()) {
    manifest.layers[layer] = blocksByLayer[layer];
  }

  return JSON.stringify(manifest, null, 2);
}

/**
 * Build a .lobster pipeline from ^pipeline-* blocks
 */
function buildPipeline(name, allBlocks) {
  const blockId = `pipeline-${name}`;
  const block = allBlocks.find(b => b.id === blockId);

  if (!block) {
    console.warn(`  ⚠️  No ^${blockId} block found. Skipping ${name}.lobster.`);
    return null;
  }

  console.log(`\n🔧 Building ${name}.lobster:`);
  const rel = path.relative(VAULT_ROOT, block.source);
  console.log(`   ^${block.id} ← ${rel}`);

  return `# ${name}.lobster — Auto-assembled from vault on ${new Date().toISOString().split('T')[0]}\n# Source: ${rel}\n\n${block.content}\n`;
}

/**
 * Build focus mode files from ^mode-*, ^tree-*, ^triggers-*, ^filter-*, ^compaction-*, ^speed-* blocks.
 * Outputs per-category directories: dist/focus/{slug}/mode.md, tree.json, etc.
 */
function buildFocusMode(allBlocks) {
  // Collect all focus blocks grouped by category slug
  const categories = {};
  for (const block of allBlocks) {
    const parsed = parseFocusBlockId(block.id);
    if (!parsed) continue;
    if (!categories[parsed.slug]) categories[parsed.slug] = {};
    categories[parsed.slug][parsed.type] = block;
  }

  const slugs = Object.keys(categories).sort();
  if (slugs.length === 0) {
    console.warn('  ⚠️  No focus mode blocks found. Skipping focus build.');
    return [];
  }

  console.log(`\n🎯 Building focus mode files for ${slugs.length} categories:`);
  const written = [];

  for (const slug of slugs) {
    const catBlocks = categories[slug];
    const catDir = path.join(DIST_DIR, 'focus', slug);
    if (!DRY_RUN) {
      fs.mkdirSync(catDir, { recursive: true });
    }

    for (const [type, info] of Object.entries(FOCUS_BLOCK_MAP)) {
      const block = catBlocks[type];
      if (!block) {
        console.warn(`     ⚠️  No ^${type}-${slug} block found.`);
        continue;
      }

      const outPath = path.join(catDir, info.file);
      const rel = path.relative(VAULT_ROOT, block.source);
      let content;

      if (info.format === 'json') {
        // JSON blocks: output raw content (already JSON from code fence)
        content = block.content;
      } else {
        // Markdown blocks: add a header comment
        content = `<!-- Source: ${rel} -->\n<!-- Block: ^${block.id} -->\n\n${block.content}\n`;
      }

      if (!DRY_RUN) {
        fs.writeFileSync(outPath, content);
        written.push(outPath);
      }
      console.log(`   ✅ → dist/focus/${slug}/${info.file} ← ^${block.id}`);
    }
  }

  return written;
}

// ─── Audit Mode ──────────────────────────────────────────────

function runAudit(allBlocks) {
  console.log('\n📋 BLOCK ID AUDIT');
  console.log('=================\n');

  // Group by prefix
  const byPrefix = {};
  allBlocks.forEach(b => {
    const prefix = getPrefix(b.id);
    if (!byPrefix[prefix]) byPrefix[prefix] = [];
    byPrefix[prefix].push(b);
  });

  // Sort prefixes
  const prefixes = Object.keys(byPrefix).sort();
  for (const prefix of prefixes) {
    const blocks = byPrefix[prefix];
    const category =
      prefix === 'config' ? '→ openclaw.json' :
      prefix === 'ctx' ? '→ dist/context-files/' :
      prefix === 'env' ? '→ .env' :
      prefix === 'pipeline' ? '→ pipelines/*.lobster' :
      prefix === 'guardrail' ? '→ guardrail reference' :
      prefix === 'telegram' ? '→ telegram reference' :
      FOCUS_BLOCK_MAP[prefix] ? `→ dist/focus/*/${FOCUS_BLOCK_MAP[prefix].file}` :
      CONTEXT_PREFIX_MAP[prefix] ? `→ dist/context-files/${CONTEXT_PREFIX_MAP[prefix]}` :
      '→ (unmapped)';

    console.log(`  ${prefix} (${blocks.length} blocks) ${category}`);
    blocks.forEach(b => {
      const rel = path.relative(VAULT_ROOT, b.source);
      const preview = b.content.slice(0, 60).replace(/\n/g, ' ');
      console.log(`    ^${b.id.padEnd(30)} [${b.type}] ${rel}`);
    });
    console.log();
  }

  // Check for duplicates
  const idMap = {};
  let dupes = 0;
  allBlocks.forEach(b => {
    if (idMap[b.id]) {
      if (dupes === 0) console.log('⚠️  DUPLICATE BLOCK IDs:');
      dupes++;
      console.log(`  ^${b.id}`);
      console.log(`    Source 1: ${path.relative(VAULT_ROOT, idMap[b.id].source)}`);
      console.log(`    Source 2: ${path.relative(VAULT_ROOT, b.source)}`);
    }
    idMap[b.id] = b;
  });
  if (dupes === 0) console.log('✅ No duplicate block IDs found.');

  // Summary
  console.log(`\n📊 Total: ${allBlocks.length} blocks across ${prefixes.length} prefixes`);

  // Coverage check for context files (uses ^ctx-{section}-* pattern)
  console.log('\n📄 Context file coverage:');
  for (const [prefix, file] of Object.entries(CONTEXT_PREFIX_MAP)) {
    const count = allBlocks.filter(b => getContextPrefix(b.id) === prefix).length;
    const status = count > 0 ? '✅' : '🔲';
    console.log(`  ${status} ${file.padEnd(16)} ← ${count} ^ctx-${prefix}-* blocks`);
  }

  // Coverage check for config
  console.log('\n📦 Config block coverage:');
  // NOTE: No config-models — models live inside config-agents per OpenClaw spec
  const expectedConfig = [
    'config-gateway', 'config-agents', 'config-channels',
    'config-tools', 'config-memory', 'config-hooks', 'config-plugins',
    'config-cron', 'config-skills',
  ];
  for (const id of expectedConfig) {
    const found = allBlocks.find(b => b.id === id);
    const status = found ? '✅' : '🔲';
    const source = found ? path.relative(VAULT_ROOT, found.source) : 'missing';
    console.log(`  ${status} ^${id.padEnd(24)} ← ${source}`);
  }

  // Pipeline coverage (matches pipeline-main.md)
  console.log('\n🔧 Pipeline block coverage:');
  const expectedPipelines = [
    // L6 core + coding (12)
    'pipeline-brief', 'pipeline-email', 'pipeline-health-check',
    'pipeline-skill-router', 'pipeline-intent-finder', 'pipeline-prompt-builder',
    'pipeline-media', 'pipeline-git', 'pipeline-code-review',
    'pipeline-deploy', 'pipeline-testing', 'pipeline-project-routing',
    // L5 category pipelines (26)
    'pipeline-cooking-grocery-list', 'pipeline-cooking-recipe-search',
    'pipeline-cooking-meal-plan', 'pipeline-cooking-pantry-check',
    'pipeline-finance-market-brief', 'pipeline-finance-position-check',
    'pipeline-finance-backtest', 'pipeline-finance-watchlist',
    'pipeline-finance-budget-review', 'pipeline-finance-expense-tracker',
    'pipeline-fitness-workout-log', 'pipeline-fitness-progress-check',
    'pipeline-fitness-program-generator', 'pipeline-fitness-rest-day-check',
    'pipeline-habits-habit-checkin', 'pipeline-habits-habit-review',
    'pipeline-habits-streak-check', 'pipeline-habits-habit-update', 'pipeline-habits-habit-reminder',
    'pipeline-pet-care-medication-tracker', 'pipeline-pet-care-appointment',
    'pipeline-pet-care-feeding-schedule', 'pipeline-pet-care-supply-list',
    'pipeline-pet-care-training-log', 'pipeline-pet-care-grooming-schedule',
    'pipeline-design-brand-audit',
  ];
  for (const id of expectedPipelines) {
    const found = allBlocks.find(b => b.id === id);
    const status = found ? '✅' : '🔲';
    const source = found ? path.relative(VAULT_ROOT, found.source) : 'not yet tagged';
    console.log(`  ${status} ^${id.padEnd(28)} ← ${source}`);
  }

  // Focus mode coverage (matches focus-main.md)
  console.log('\n🎯 Focus mode block coverage:');
  const expectedCategories = ['cooking', 'coding', 'finance', 'fitness', 'habits', 'pet-care', 'design'];
  const focusTypes = Object.keys(FOCUS_BLOCK_MAP);
  for (const slug of expectedCategories) {
    const found = focusTypes.map(type => {
      const id = `${type}-${slug}`;
      return allBlocks.find(b => b.id === id) ? '✅' : '🔲';
    });
    const summary = focusTypes.map((t, i) => `${found[i]}${t}`).join(' ');
    console.log(`  ${slug.padEnd(10)} ${summary}`);
  }
}

// ─── Main ────────────────────────────────────────────────────

function main() {
  console.log('🦊 Crispy Kitsune Vault Builder');
  console.log('================================\n');

  if (DRY_RUN) console.log('🏜️  DRY RUN — no files will be written\n');

  // 1. Scan vault
  const mdFiles = findMarkdownFiles(VAULT_ROOT);
  console.log(`📂 Found ${mdFiles.length} markdown files in vault`);

  // 2. Extract all tagged blocks
  const allBlocks = [];
  for (const file of mdFiles) {
    const blocks = extractBlocks(file);
    allBlocks.push(...blocks);
  }
  console.log(`🏷️  Found ${allBlocks.length} tagged blocks total`);

  // Summary by prefix
  const prefixCounts = {};
  allBlocks.forEach(b => {
    const prefix = getPrefix(b.id);
    prefixCounts[prefix] = (prefixCounts[prefix] || 0) + 1;
  });
  Object.entries(prefixCounts)
    .sort((a, b) => b[1] - a[1])
    .forEach(([prefix, count]) => {
      console.log(`   ${prefix}: ${count} blocks`);
    });

  // Audit mode — just report and exit
  if (AUDIT) {
    runAudit(allBlocks);
    return;
  }

  // 3. Create dist directory
  if (!DRY_RUN) {
    fs.mkdirSync(DIST_DIR, { recursive: true });
    fs.mkdirSync(path.join(DIST_DIR, 'context-files'), { recursive: true });
    fs.mkdirSync(path.join(DIST_DIR, 'pipelines'), { recursive: true });
    fs.mkdirSync(path.join(DIST_DIR, 'focus'), { recursive: true });
  }

  const written = [];

  // 4. Build openclaw.json5 and openclaw.json
  if (!ONLY || ONLY === 'config') {
    // Build JSON5 version
    const configJSON5 = buildConfigJSON5(allBlocks, VERSION_TAG);
    if (configJSON5) {
      const outPath = path.join(DIST_DIR, 'openclaw.json5');
      if (!DRY_RUN) {
        fs.writeFileSync(outPath, configJSON5);
        written.push(outPath);
      }
      console.log('   ✅ → dist/openclaw.json5');
    }

    // Build pure JSON version
    const configJSON = buildConfigJSON(allBlocks, VERSION_TAG);
    if (configJSON) {
      const outPath = path.join(DIST_DIR, 'openclaw.json');
      if (!DRY_RUN) {
        fs.writeFileSync(outPath, configJSON);
        written.push(outPath);
      }
      console.log('   ✅ → dist/openclaw.json');
    }
  }

  // 5. Build context files
  if (!ONLY || ONLY === 'context') {
    for (const [prefix, targetFile] of Object.entries(CONTEXT_PREFIX_MAP)) {
      const content = buildContextFile(targetFile, prefix, allBlocks);
      if (content) {
        const outPath = path.join(DIST_DIR, 'context-files', targetFile);
        if (!DRY_RUN) {
          fs.writeFileSync(outPath, content);
          written.push(outPath);
        }
        console.log(`   ✅ → dist/context-files/${targetFile}`);
      }
    }
  }

  // 6. Build pipelines (matches pipeline-main.md registry)
  if (!ONLY || ONLY === 'pipelines') {
    const pipelines = [
      // Core pipelines (L6-Processing/pipelines/)
      'brief', 'email', 'health-check', 'skill-router',
      'intent-finder', 'prompt-builder', 'media',
      // Coding pipelines (L6-Processing/coding/)
      'git', 'code-review', 'deploy', 'testing', 'project-routing',
      // L5 Category pipelines (L5-routing/categories/*)
      'cooking-grocery-list', 'cooking-recipe-search', 'cooking-meal-plan', 'cooking-pantry-check',
      'finance-market-brief', 'finance-position-check', 'finance-backtest', 'finance-watchlist',
      'finance-budget-review', 'finance-expense-tracker',
      'fitness-workout-log', 'fitness-progress-check', 'fitness-program-generator', 'fitness-rest-day-check',
      'habits-habit-checkin', 'habits-habit-review', 'habits-streak-check', 'habits-habit-update', 'habits-habit-reminder',
      'pet-care-medication-tracker', 'pet-care-appointment', 'pet-care-feeding-schedule',
      'pet-care-supply-list', 'pet-care-training-log', 'pet-care-grooming-schedule',
      'design-brand-audit',
    ];
    for (const name of pipelines) {
      const content = buildPipeline(name, allBlocks);
      if (content) {
        const outPath = path.join(DIST_DIR, 'pipelines', `${name}.lobster`);
        if (!DRY_RUN) {
          fs.writeFileSync(outPath, content);
          written.push(outPath);
        }
        console.log(`   ✅ → dist/pipelines/${name}.lobster`);
      }
    }
  }

  // 6b. Build focus mode files
  if (!ONLY || ONLY === 'focus') {
    const focusWritten = buildFocusMode(allBlocks);
    written.push(...focusWritten);
  }

  // 7. Build .env.example from ^env-template block (secrets stay out of dist/)
  // Uses buildEnv() which reads the rich ^env-template block from build/env-main.md.
  // buildEnvExample() (auto-generated from individual ^env-* blocks) is kept as dead code below.
  if (!ONLY || ONLY === 'env') {
    const envExampleContent = buildEnv(allBlocks, VERSION_TAG);
    if (envExampleContent) {
      const outPath = path.join(DIST_DIR, '.env.example');
      if (!DRY_RUN) {
        fs.writeFileSync(outPath, envExampleContent);
        written.push(outPath);
      }
      console.log('   ✅ → dist/.env.example');
    }
  }

  // 8. Build LAYERS-MANIFEST.json
  if (!ONLY || ONLY === 'config') {
    const manifestContent = buildLayersManifest(allBlocks, VERSION_TAG);
    if (manifestContent) {
      const outPath = path.join(DIST_DIR, 'LAYERS-MANIFEST.json');
      if (!DRY_RUN) {
        fs.writeFileSync(outPath, manifestContent);
        written.push(outPath);
      }
      console.log('   ✅ → dist/LAYERS-MANIFEST.json');
    }
  }

  // 9. Summary
  console.log('\n================================');
  console.log('📊 Build Summary:\n');

  if (DRY_RUN) {
    console.log('   (dry run — no files written)');
  } else {
    console.log(`   ${written.length} files written to dist/`);
    written.forEach(f => console.log(`   - ${path.relative(VAULT_ROOT, f)}`));
  }

  if (VERSION_TAG) {
    console.log(`\n   📌 Version tag: ${VERSION_TAG}`);
  }

  // Duplicate check
  const idMap = {};
  let dupes = 0;
  allBlocks.forEach(b => {
    if (idMap[b.id]) {
      if (dupes === 0) console.log('\n⚠️  DUPLICATE block IDs found:');
      dupes++;
      console.log(`   ^${b.id} in ${path.relative(VAULT_ROOT, idMap[b.id].source)} AND ${path.relative(VAULT_ROOT, b.source)}`);
    }
    idMap[b.id] = b;
  });
  if (dupes === 0) console.log('\n   ✅ No duplicate block IDs');

  console.log('\n🦊 Done!\n');
}

main();
