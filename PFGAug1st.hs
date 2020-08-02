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
  medianLine <- getRandomR (3 :: Int,20)
  ls <- mapM (\x -> makeLine medianLine) [0..linesNum]
  return $ (ls,[])

genPoem :: Int -> Rand StdGen Poem
genPoem stanzaNum = do
  -- stanzaNum <- getRandomR (1 :: Int,5)
  stanzas <- mapM (\x -> genStanzaNoCons) [0..stanzaNum]
  return $ PS stanzas []

gen n = do
  p <- evalRandIO $ genPoem n
  print p
