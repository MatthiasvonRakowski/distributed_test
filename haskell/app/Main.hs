module Main where

import Control.DeepSeq
import Control.Exception
import Criterion.Measurement
import Numeric
import System.Environment
import TotientRange
import Data.Bool (Bool(True))

{-
On a normal computer:

    cabal build

then:

    cabal exec -- haskell-totient 1 10000

On the Robotarium e.g. using 4 CPU cores on a compute node:

    cabal build

then:

    srun --cpus-per-task=4 cabal exec -- haskell-totient 1 10000 +RTS -N4 -RTS

To check that your code produces the correct output,
uncomment and use the `main` function at the bottom.
To measure your runtime in seconds, uncomment and use
the `main` function directly beneat this comment.
-}

-- | time an IO action.

data RunInfo = RunInfo {
  sumCluster :: Maybe Int,
  eulerCluster :: Maybe Int,
  naiveParallel :: Maybe Bool
}

defaultRunInfo :: RunInfo
defaultRunInfo = RunInfo {
    sumCluster = Nothing,
    eulerCluster = Nothing,
    naiveParallel = Nothing
  }

time_ :: IO a -> IO Double
time_ act = do
  initializeTime
  start <- getTime
  _ <- act
  end <- getTime
  return $! end - start


parseArgs :: RunInfo -> [String] -> (RunInfo, [String])
parseArgs run [] = (run, [])
parseArgs run ("-s":nb:xs) = parseArgs (run {sumCluster = Just (read nb :: Int)}) xs
parseArgs run ("-e":nb:xs) = parseArgs (run {eulerCluster = Just (read nb :: Int)}) xs
parseArgs run ("-n":xs) = parseArgs (run {naiveParallel = Just True}) xs
parseArgs run (_:xs) = parseArgs run xs

-- | use this function to print the execution time, in seconds.
main :: IO ()
main = do
  args <- getArgs

  let lower = read (head args) :: Int
      upper = read (args !! 1) :: Int
      (runInfo, _) = parseArgs defaultRunInfo args
      theProgram = sumTotient (lower, upper, sumCluster runInfo, eulerCluster runInfo, naiveParallel runInfo)

  theTime <- time_ (evaluate (force theProgram))
  putStrLn (showFFloat (Just 2) theTime "")

-- -- | Use this function for checkout that sum totient prints the
-- -- correct result.
-- main :: IO ()
-- main = do
  -- args <- getArgs

  -- let lower = read (head args) :: Int
  --     upper = read (args !! 1) :: Int
  --     (runInfo, _) = parseArgs defaultRunInfo args
  --     theProgram = sumTotient (lower, upper, sumCluster runInfo, eulerCluster runInfo)

  -- theTime <- time_ (evaluate (force theProgram))
  -- putStrLn (showFFloat (Just 2) theTime "")
--   -- replace (comment out) code above in the definition for `result`,
--   -- i.e. replace the sum function call line, with parallel versions
--   -- of sum totient and put them below
--   putStrLn
--     ( "Sum of Totients between ["
--         ++ show lower
--         ++ ".."
--         ++ show upper
--         ++ "] is "
--         ++ show result
--     )
