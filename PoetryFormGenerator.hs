{- ============================================================================
   PoetryFormGenerator.hs - Haskell Implementation of Poetry Form Generator
   ============================================================================

   DESIGN DECISION: Explore type-safe approach to poetry generation.
   This Haskell version represents an alternative architectural approach to
   the Lisp implementation, emphasizing:
   - Strong static typing for constraints
   - Explicit constraint types (no runtime type checking needed)
   - Pure functional architecture
   - Monadic random generation

   DESIGN EVOLUTION: This is a parallel exploration, not a port.
   Written alongside the Lisp versions to explore different design tradeoffs.
   The Lisp version evolved toward runtime flexibility and dynamic constraints,
   while this Haskell version explores compile-time type safety.

   KEY DIFFERENCES FROM LISP VERSION:
   - Explicit data types for all constraint kinds
   - Constraints are part of the data structure (not separate arrays)
   - Random generation is explicit via Rand monad
   - Immutable data structures throughout
   -}

{- This is a poetry form generator. It'll get more sophisticated as I go,
but to start it'll come up with a number of lines, stanzas, and syllables per
line, then add in different constraints as we go. -}

import Control.Monad.Random

-- DESIGN DECISION: Poem structure combines stanzas with constraints.
-- [([Int],[IntraStanza])] = list of stanzas, each containing:
--   - [Int]: line lengths (syllable counts)
--   - [IntraStanza]: constraints within this stanza
-- [InterStanza]: constraints between different stanzas
--
-- This structure makes constraint types explicit and type-checkable.
data Poem = PS [([Int],[IntraStanza])] [InterStanza]
  deriving (Eq)

-- DESIGN DECISION: Visual output matches Lisp version.
-- Use dashes to show line length, with ": length" suffix.
-- Currently ignores constraints in output (but they're available in data).
instance Show Poem where
  show (PS stanzas _) = unlines $ map stanzaShow stanzas
    where stanzaShow (ls,_) = unlines $ map (\x -> lineshow x x) ls
          lineshow m n | n > 0 = '-' : (lineshow m $ n - 1)
                       | otherwise = ": "++(show m)

-- DESIGN DECISION: Type-safe intra-stanza constraint representation.
-- Each constraint type is a distinct constructor with typed parameters:
-- - Indent: lines i and j should have same indentation
-- - Length: lines i and j should have same length
-- - RhymeMatch: lines i and j should rhyme (full rhyme)
-- - SlantMatch: lines i and j should slant rhyme (near rhyme)
--
-- Compare to Lisp: Lisp uses symbols ('rhyme, 'slant) with runtime checking.
-- Haskell: Impossible to create invalid constraint types.
data IntraStanza = Indent Int Int
                 | Length Int Int
                 | RhymeMatch Int Int
                 | SlantMatch Int Int
                 deriving (Eq,Show)

-- DESIGN DECISION: Type-safe inter-stanza constraint representation.
-- - Rotational: stanza i is rotation of stanza j by k positions
-- - LineShare: line i1 of stanza s1 equals line i2 of stanza s2
--
-- These enable complex forms like villanelles, pantoums, etc.
-- The type system ensures all references are well-formed integers.
data InterStanza = Rotational Int Int Int
                 | LineShare Int Int Int Int
                 deriving (Eq,Show)
                 

-- ============================================================================
-- POEM GENERATION (Basic Version - No Constraints Yet)
-- ============================================================================

-- the initial version of things is going to involve picking a line length
-- per stanza and then varying it up and down, choosing a number of stanzas
-- and lines per stanza of a reasonable amount

-- DESIGN DECISION: Monadic random generation.
-- The Rand monad makes randomness explicit in type signatures, unlike Lisp's
-- implicit global random state. This is more verbose but makes data flow clear.
makeLine m = do
  shift <- getRandomR (-m `div` 2,m `div` 2)
  return $ shift + m

-- DESIGN DECISION: Generate stanza without constraints initially.
-- This is the base case (like the Lisp versions' first implementations).
-- Returns empty constraint list [] - future versions would populate this.
--
-- DESIGN RATIONALE: Start simple, add complexity incrementally.
-- linesNum ∈ [2,10]: reasonable stanza sizes
-- medianLine ∈ [4,10]: reasonable line lengths
genStanzaNoCons :: Rand StdGen ([Int], [IntraStanza])
genStanzaNoCons = do
  linesNum <- getRandomR (2 :: Int,10)
  medianLine <- getRandomR (4 :: Int,10)
  -- generate exactly linesNum lines
  ls <- mapM (\_ -> makeLine medianLine) [1..linesNum]
  return $ (ls,[])

-- DESIGN DECISION: Pure functional poem generation.
-- Takes stanza count as parameter, returns Rand monad wrapping Poem.
-- All randomness is encapsulated in the monad, making the function referentially
-- transparent (same seed = same output).
genPoem :: Int -> Rand StdGen Poem
genPoem stanzaNum = do
  -- generate exactly stanzaNum stanzas
  stanzas <- mapM (\_ -> genStanzaNoCons) [1..stanzaNum]
  return $ PS stanzas []  -- Empty inter-stanza constraints (not yet implemented)

-- DESIGN DECISION: Separate generation from IO.
-- gen takes pure value n, does generation, then prints.
-- This separation enables testing without IO.
gen n = do
  p <- evalRandIO $ genPoem n
  print p

-- DESIGN DECISION: Random stanza count at top level.
-- Each run generates 1-4 stanzas, creating variety in poem scale.
-- Compare to Lisp: Lisp takes parameters from command line.
-- Haskell: Hardcoded range for simplicity in this exploratory version.
main = do
  stanzaNum <- getRandomR (1 :: Int,4)
  gen stanzaNum
