# Poetry Forms - Code Organization Refactoring

## Overview

This document describes the refactoring of the Poetry Forms codebase from standalone scripts to a proper Common Lisp library with shared utilities and clean package structure.

## Goals

1. **Eliminate code duplication** - Extract ~100+ lines of duplicated utility functions
2. **Create proper library structure** - Enable loading as `(ql:quickload :poetry-forms)`
3. **Improve maintainability** - Single source of truth for algorithms
4. **Maintain backward compatibility** - Original files remain unchanged

## New Directory Structure

```
PoetryForms/
├── poetry-forms.asd          # ASDF system definition
├── src/
│   ├── package.lisp          # Package definitions
│   ├── utils.lisp            # Shared utilities
│   └── generators/
│       ├── basic.lisp        # Basic form generation (refactored PoetryGen.lisp)
│       ├── spatial.lisp      # Spatial/indentation (refactored PoetryGenSpace.lisp)
│       ├── rhyme-basic.lisp  # Basic rhyme (TODO: refactor PoetryGenRhyme3.lisp)
│       ├── whitespace.lisp   # Fine whitespace (TODO: refactor PoetryWhitespace.lisp)
│       ├── metrical.lisp     # Metrical feet (TODO: refactor PoetryMetre.lisp)
│       └── constrained.lisp  # Constraints (TODO: refactor PoetryRhyme2.lisp)
├── examples/
│   └── generate.lisp         # Usage examples
└── [original files remain unchanged for reference]
```

## Package Structure

### `poetry-forms.utils`
Shared utilities used across all generators:
- **Random variation**: `up-down`, `up-down-half`, `random-from`
- **Signal generation**: `sines` (sine wave superposition)
- **List utilities**: `rand-list`, `palindrome`, `make-list-f`, `rotate-list`, `rot-array`

### `poetry-forms.generators`
Core generator implementations:
- State variables: `*poem-line*`, `*avg-line*`, etc.
- Line generation strategies
- Stanza and poem structure generation
- Output/visualization functions

### `poetry-forms`
Main package with high-level API:
- `generate-basic-poem`
- `generate-spatial-poem`
- More to come as refactoring continues...

## What's Been Refactored

✅ **Completed:**
- `src/utils.lisp` - All shared utilities extracted
- `src/package.lisp` - Package definitions
- `poetry-forms.asd` - ASDF system definition
- `src/generators/basic.lisp` - Fully refactored PoetryGen.lisp
- `src/generators/spatial.lisp` - Fully refactored PoetryGenSpace.lisp
- `examples/generate.lisp` - Comprehensive usage examples

🚧 **TODO (Placeholders created):**
- `src/generators/rhyme-basic.lisp` - Refactor PoetryGenRhyme3.lisp
- `src/generators/whitespace.lisp` - Refactor PoetryWhitespace.lisp
- `src/generators/metrical.lisp` - Refactor PoetryMetre.lisp
- `src/generators/constrained.lisp` - Refactor PoetryRhyme2.lisp

## Benefits of Refactoring

### Before (Original Structure)
```lisp
;; PoetryGen.lisp
(defun up-down (r) ...)
(defun sines (&rest args) ...)
(defun gen-poem (...) ...)

;; PoetryGenSpace.lisp
(defun up-down (r) ...)      ; DUPLICATE!
(defun sines (&rest args) ...)  ; DUPLICATE!
(defun gen-poem (...) ...)

;; PoetryMetre.lisp
(defun up-down (r) ...)      ; DUPLICATE!
(defun sines (&rest args) ...)  ; DUPLICATE!
(defun gen-poem (...) ...)

;; ... 7 files total, all duplicating utilities
```

### After (Refactored Structure)
```lisp
;; src/utils.lisp (ONE PLACE!)
(defun up-down (r) ...)
(defun sines (&rest args) ...)

;; src/generators/basic.lisp
(use-package :poetry-forms.utils)
(defun gen-poem (...) ...)  ; Uses shared up-down, sines

;; src/generators/spatial.lisp
(use-package :poetry-forms.utils)
(defun gen-poem (...) ...)  ; Uses shared up-down, sines
```

**Lines saved**: ~100+ lines of duplicated code eliminated!

## Usage

### Loading the Library

```lisp
;; Using ASDF directly
(asdf:load-system :poetry-forms)

;; Or via Quicklisp (if published)
(ql:quickload :poetry-forms)
```

### High-Level API

```lisp
(use-package :poetry-forms)

;; Generate a basic random poem
(let ((poem (generate-basic-poem :stanzas 3 :avg-stanza 4 :avg-line 8)))
  (print-poem poem))

;; Generate with sine wave pattern
(generate-basic-poem :stanzas 4 :avg-line 10 :generator :sine)

;; Generate spatial poem with indentation
(let ((poem (generate-spatial-poem :generator :pyramid)))
  (print-poem-spatial poem))
```

### Low-Level API

```lisp
(use-package :poetry-forms.generators)

;; Direct access to generators
(let ((*avg-line* 10))
  (gen-poem 3 4 #'gen-line-sine))
```

### Running Examples

```lisp
(load "examples/generate.lisp")
(run-all-examples)  ; Run all example functions

;; Or run individually
(example-basic-random)
(example-pyramid)
(example-cascade)
```

## Migration Guide

### For Users of Original Files

Original files remain unchanged. You can continue using them as before:
```bash
sbcl --script PoetryGen.lisp 0 3 4 8
```

### For Code Using the Library

New code should use the refactored library:

```lisp
;; OLD (using original files):
(load "PoetryGen.lisp")
(let ((*avg-line* 8))
  (gen-poem 3 4 #'gen-line-rand))

;; NEW (using refactored library):
(asdf:load-system :poetry-forms)
(poetry-forms:generate-basic-poem :stanzas 3 :avg-stanza 4
                                  :avg-line 8 :generator :random)
```

## Code Quality Improvements

1. **Single Source of Truth**
   - Utilities in one place
   - Bug fixes apply everywhere
   - Easier to understand algorithms

2. **Better Documentation**
   - Docstrings on all public functions
   - Examples in code comments
   - Usage examples in `examples/` directory

3. **Modular Design**
   - Clear separation of concerns
   - Packages isolate functionality
   - Easy to extend with new generators

4. **Maintainability**
   - Less code duplication
   - Clearer dependencies
   - Standard Common Lisp packaging

## Next Steps

### Immediate TODO
1. Complete refactoring of remaining generators:
   - `rhyme-basic.lisp` (from PoetryGenRhyme3.lisp)
   - `whitespace.lisp` (from PoetryWhitespace.lisp)
   - `metrical.lisp` (from PoetryMetre.lisp)
   - `constrained.lisp` (from PoetryRhyme2.lisp)

2. Add test suite (using FiveAM or similar)

3. Add high-level API module for convenience functions

### Future Enhancements
- CLI tool using the library
- Web interface
- Multiple output formats (LaTeX, JSON, HTML)
- Named form templates (sonnet, villanelle, etc.)
- Configuration system for probabilities
- Documentation generation

## Testing the Refactored Code

```lisp
;; In a Common Lisp REPL:
(asdf:load-system :poetry-forms)

;; Test basic generation
(poetry-forms:generate-basic-poem)

;; Test spatial generation
(let ((poem (poetry-forms:generate-spatial-poem :generator :pyramid)))
  (poetry-forms.generators:print-poem-spatial poem))

;; Test utilities
(funcall (poetry-forms.utils:up-down 5) 10)  ; Should be in [5, 15]
(poetry-forms.utils:palindrome '(a b c))       ; Should be (a b c c b a)
```

## Contributing

When adding new generators:

1. Create file in `src/generators/`
2. Use `(in-package #:poetry-forms.generators)`
3. Import utilities: `(use-package :poetry-forms.utils)`
4. Add to `poetry-forms.asd` components list
5. Export public API in `src/package.lisp`
6. Add examples to `examples/generate.lisp`

Example template:
```lisp
;;;; src/generators/my-generator.lisp

(in-package #:poetry-forms.generators)

(defun my-line-generator (i)
  "Generate lines using my strategy"
  ;; Use shared utilities
  (funcall (up-down 3) *avg-line*))

(defun generate-my-poem (&key (stanzas 3))
  "High-level API for my generator"
  (let ((*avg-line* 8))
    (gen-poem stanzas 4 #'my-line-generator)))
```

## Questions?

See `examples/generate.lisp` for comprehensive usage examples, or examine the refactored generators in `src/generators/` for implementation patterns.
