---
name: word-pair-swap
description: Swaps adjacent word pairs in text, with optional N-word rotation. Use when users ask to swap word pairs, rotate word groups, swap every two words, or perform pairwise/N-wise word swapping on text input.
---

# Word Pair Swap

Swap or rotate consecutive word groups in the input text.

## Options

- **Group size (N)**: Number of words per group (default: 2)
  - N=2: Swap pairs (original behavior)
  - N=3+: Rotate groups, moving the last word to the front

## Algorithm

1. Split input text into words (whitespace-separated)
2. Process words in groups of N
3. For each group:
   - If N=2: Swap the two words (`w1 w2` → `w2 w1`)
   - If N>2: Rotate by moving last word to front (`w1 w2 w3` → `w3 w1 w2`)
4. If final group has fewer than N words, leave them in place
5. Join and return the result

## Examples

### Default (N=2) - Pair Swap

| Input | Output |
|-------|--------|
| `hello world` | `world hello` |
| `the quick brown fox` | `quick the fox brown` |
| `one two three` | `two one three` |
| `a` | `a` |

### N=3 - Triple Rotation

| Input | Output |
|-------|--------|
| `w1 w2 w3` | `w3 w1 w2` |
| `the quick brown fox jumps over` | `brown the quick over fox jumps` |
| `one two three four five` | `three one two four five` |
| `a b` | `a b` |

### N=4 - Quad Rotation

| Input | Output |
|-------|--------|
| `w1 w2 w3 w4` | `w4 w1 w2 w3` |
| `one two three four five six seven eight` | `four one two three eight five six seven` |
| `a b c` | `a b c` |

## Usage

Apply directly to user-provided text. If the user specifies a group size (e.g., "rotate by 3s", "groups of 4"), use that value for N. Otherwise default to N=2 (pair swap). Preserve single spaces between words in output.