// Three-way merge of a package.json file at the JSON level, used when merging
// an upstream release. Keys we changed keep our value, keys upstream changed
// take theirs, and a key both sides changed differently is a conflict. When a
// version is given, "version" is set to it instead of being merged.
//
// Usage: node merge-package-json.mjs <base-ref> <theirs-ref> <file> [version]
// Exit codes: 0 merged and written; 2 conflicting keys, file left untouched.

import { execFileSync } from 'node:child_process'
import { writeFileSync } from 'node:fs'

const [baseRef, theirsRef, file, version] = process.argv.slice(2)

function read(ref) {
  try {
    const text = execFileSync('git', ['show', `${ref}:${file}`], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    })
    return JSON.parse(text)
  } catch {
    return undefined
  }
}

const isObject = v => v !== null && typeof v === 'object' && !Array.isArray(v)
const same = (a, b) => JSON.stringify(a) === JSON.stringify(b)
const isSorted = keys => keys.every((k, i) => i === 0 || keys[i - 1] <= k)

const conflicts = []

function merge(base, ours, theirs, path) {
  if (same(ours, base)) {
    return theirs
  }
  if (same(theirs, base) || same(ours, theirs)) {
    return ours
  }
  if (isObject(ours) && isObject(theirs)) {
    const b = isObject(base) ? base : {}
    const keys = [
      ...Object.keys(theirs),
      ...Object.keys(ours).filter(k => !(k in theirs)),
    ]
    if (isSorted(Object.keys(theirs))) {
      keys.sort()
    }
    const result = {}
    for (const key of keys) {
      const value = merge(b[key], ours[key], theirs[key], [...path, key])
      if (value !== undefined) {
        result[key] = value
      }
    }
    return result
  }
  conflicts.push(path.join('.') || '(root)')
  return ours
}

const base = read(baseRef)
const ours = read('HEAD')
const theirs = read(theirsRef)

if (version !== undefined) {
  for (const doc of [base, ours, theirs]) {
    if (isObject(doc)) {
      doc.version = version
    }
  }
}

const merged = merge(base, ours, theirs, [])

if (conflicts.length > 0) {
  console.error(`${file}: conflicting keys: ${conflicts.join(', ')}`)
  process.exit(2)
}

writeFileSync(file, `${JSON.stringify(merged, null, 2)}\n`)
console.log(`${file}: merged`)
