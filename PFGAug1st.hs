{- ============================================================================
   PFGAug1st.hs - Variant Haskell Poetry Form Generator
   ============================================================================

   DESIGN DECISION: Parameter variation experiment.
   This file is nearly identical to PoetryFormGenerator.hs but with different
   parameter ranges, representing an experiment to find better generation settings.

   KEY DIFFERENCE: Line length range changed from [4,10] to [3,20]
   - Original: medianLine ∈ [4,10] (narrow range, shorter lines)
   - This version: medianLine ∈ [3,20] (wider range, allows longer lines)

   DESIGN RATIONALE: Exploring parameter space.
   The original range felt too constrained. This version allows for:
   - Shorter haiku-like forms (3-syllable lines)
   - Longer epic-style lines (20 syllables)
   - Greater variety in line length within poems

   This represents an experimental iteration on the same architectural foundation,
   showing how the generator's aesthetic output can be tuned through parameters
   without changing the underlying algorithm.
   -}

{- This is a poetry form generator. It'll get more sophisticated as I go,
but to start it'll come up with a number of lines, stanzas, and syllables per
line, then add in different constraints as we go. -}

import Control.Monad.Random

data Poem = PS [([Int],[IntraStanza])] [InterStanza]
  deriving (Eq)

instance Show Poem where
  show (PS stanzas _) = unlines $ map stanzaShow stanzas
    where stanzaShow (ls,_) = unlines $ map (\x -> lineshow x x) ls
          lineshow m n | n > 0 = '-' : (lineshow m $ n - 1)
                       | otherwise = ": "++(show m)

data IntraStanza = Indent Int Int
                 | Length Int Int
                 | RhymeMatch Int Int
                 | SlantMatch Int Int
                 deriving (Eq,Show)

data InterStanza = Rotational Int Int Int
                 | LineShare Int Int Int Int
                 deriving (Eq,Show)
                 

-- the initial version of things is going to involve picking a line length
-- per stanza and then varying it up and down, choosing a number of stanzas
-- and lines per stanza of a reasonable amount

makeLine m = do
  shift <- getRandomR (-m `div` 2,m `div` 2)
  return $ shift + m

genStanzaNoCons :: Rand StdGen ([Int], [IntraStanza])
genStanzaNoCons = do
  linesNum <- getRandomR (2 :: Int,10)
  -- PARAMETER CHANGE: This is the key difference from PoetryFormGenerator.hs
  -- Original: getRandomR (4 :: Int,10)
  -- This version: getRandomR (3 :: Int,20)
  -- Result: More diverse line lengths, from very short to quite long
  medianLine <- getRandomR (3 :: Int,20)
  -- generate exactly linesNum lines
  ls <- mapM (\_ -> makeLine medianLine) [1..linesNum]
  return $ (ls,[])

genPoem :: Int -> Rand StdGen Poem
genPoem stanzaNum = do
  -- COMMENTED OUT: Commented code shows evolution of thinking
  -- Originally considered making stanza count random here too,
  -- but decided to take it as parameter instead (cleaner interface)
  -- stanzaNum <- getRandomR (1 :: Int,5)

  -- generate exactly stanzaNum stanzas
  stanzas <- mapM (\_ -> genStanzaNoCons) [1..stanzaNum]
  return $ PS stanzas []

gen n = do
  p <- evalRandIO $ genPoem n
  print p
