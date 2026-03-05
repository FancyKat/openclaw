/**
 * Crispy Vault — Build Validation Tests
 *
 * Run from crispy-vault/: node test/build.test.js
 * Verifies the build script produces valid, complete output.
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const VAULT_ROOT = path.resolve(__dirname, '..');
const DIST = path.join(VAULT_ROOT, 'dist');

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    console.log(`  ✅ ${name}`);
    passed++;
  } catch (err) {
    console.log(`  ❌ ${name}`);
    console.log(`     ${err.message}`);
    failed++;
  }
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

// ── Run the build first ──────────────────────────────────────
console.log('\n🔨 Running build...');
try {
  execSync('node build/scripts/build-config.js', {
    cwd: VAULT_ROOT,
    stdio: 'pipe',
  });
  console.log('  Build completed\n');
} catch (err) {
  console.error('  ❌ Build failed:\n', err.stdout?.toString(), err.stderr?.toString());
  process.exit(1);
}

// ── Config output ────────────────────────────────────────────
console.log('📋 Config output');

test('dist/openclaw.json exists', () => {
  assert(fs.existsSync(path.join(DIST, 'openclaw.json')), 'File not found');
});

test('dist/openclaw.json is valid JSON', () => {
  const raw = fs.readFileSync(path.join(DIST, 'openclaw.json'), 'utf8');
  const parsed = JSON.parse(raw);
  assert(typeof parsed === 'object', 'Not an object');
});

test('dist/openclaw.json has required top-level keys', () => {
  const parsed = JSON.parse(fs.readFileSync(path.join(DIST, 'openclaw.json'), 'utf8'));
  const required = ['gateway', 'agents', 'channels', 'tools'];
  for (const key of required) {
    assert(key in parsed, `Missing key: ${key}`);
  }
});

// ── Context files ────────────────────────────────────────────
console.log('\n📁 Context files');

test('dist/context-files/ exists', () => {
  assert(fs.existsSync(path.join(DIST, 'context-files')), 'Directory not found');
});

test('dist/context-files/ has at least 8 files', () => {
  const files = fs.readdirSync(path.join(DIST, 'context-files')).filter(f => f.endsWith('.md'));
  assert(files.length >= 8, `Only ${files.length} context files found`);
});

// ── Pipelines ────────────────────────────────────────────────
console.log('\n🔧 Pipelines');

test('dist/pipelines/ has lobster files', () => {
  const files = fs.readdirSync(path.join(DIST, 'pipelines')).filter(f => f.endsWith('.lobster'));
  assert(files.length > 0, 'No .lobster files found');
});

// ── Focus modes ──────────────────────────────────────────────
console.log('\n🎯 Focus modes');

const EXPECTED_CATEGORIES = ['cooking', 'coding', 'finance', 'fitness', 'habits', 'pet-care', 'design'];

test('all 7 focus categories exist', () => {
  for (const cat of EXPECTED_CATEGORIES) {
    const catPath = path.join(DIST, 'focus', cat);
    assert(fs.existsSync(catPath), `Missing category: ${cat}`);
  }
});

test('each category has mode.md and tree.json', () => {
  for (const cat of EXPECTED_CATEGORIES) {
    const catPath = path.join(DIST, 'focus', cat);
    assert(fs.existsSync(path.join(catPath, 'mode.md')), `${cat}/mode.md missing`);
    assert(fs.existsSync(path.join(catPath, 'tree.json')), `${cat}/tree.json missing`);
  }
});

test('all focus JSON files are valid', () => {
  const focusDir = path.join(DIST, 'focus');
  const jsonFiles = [];
  for (const cat of EXPECTED_CATEGORIES) {
    const catDir = path.join(focusDir, cat);
    fs.readdirSync(catDir)
      .filter(f => f.endsWith('.json'))
      .forEach(f => jsonFiles.push(path.join(catDir, f)));
  }
  for (const f of jsonFiles) {
    try {
      JSON.parse(fs.readFileSync(f, 'utf8'));
    } catch {
      throw new Error(`Invalid JSON: ${path.relative(VAULT_ROOT, f)}`);
    }
  }
});

// ── Manifest ─────────────────────────────────────────────────
console.log('\n📦 Manifest');

test('dist/LAYERS-MANIFEST.json is valid JSON', () => {
  const raw = fs.readFileSync(path.join(DIST, 'LAYERS-MANIFEST.json'), 'utf8');
  const parsed = JSON.parse(raw);
  assert(typeof parsed === 'object', 'Not an object');
});

// ── Summary ──────────────────────────────────────────────────
console.log(`\n${'─'.repeat(40)}`);
console.log(`  ${passed} passed  ${failed > 0 ? failed + ' failed' : ''}`);
if (failed > 0) {
  console.log('');
  process.exit(1);
}
console.log('');
