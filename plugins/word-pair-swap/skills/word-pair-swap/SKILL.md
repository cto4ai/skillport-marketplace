---
name: word-pair-swap
description: Swaps adjacent word pairs in text. Use when users ask to swap word pairs, swap every two words, or perform pairwise word swapping on text input.
---

# Word Pair Swap

Swap every two consecutive words in the input text.

## Algorithm

1. Split input text into words (whitespace-separated)
2. Process words in pairs, swapping positions
3. If odd number of words, leave the last word in place
4. Join and return the result

## Examples

| Input | Output |
|-------|--------|
| `hello world` | `world hello` |
| `the quick brown fox` | `quick the fox brown` |
| `one two three` | `two one three` |
| `a` | `a` |

## Usage

Apply directly to user-provided text. Preserve original whitespace style in output when practical (single spaces between words).
