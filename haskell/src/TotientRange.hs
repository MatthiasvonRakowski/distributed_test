---------------------------------------------------------------------------
-- Sequential Euler Totient Function
---------------------------------------------------------------------------
-- This program calculates the sum of the totients between a lower and an
-- upper limit.
--
-- Phil Trinder, 26/6/03
-- Based on earlier work by Nathan Charles, Hans-Wolfgang Loidl and
-- Colin Runciman
---------------------------------------------------------------------------

module TotientRange where

-- this is the module with:
--   rpar, parallel strategies for lists, etc.
--
-- See:
-- http://hackage.haskell.org/package/parallel-3.2.2.0/docs/Control-Parallel-Strategies.html
import Control.Parallel.Strategies
import Data.Bool (Bool(True))

-----------------------------------
-- Main functions for Totient Range
-----------------------------------
-- The main function, sumTotient
-- 1. Generates a list of integers between lower and upper
-- 2. Applies Euler function to every element of the list
-- 3. Returns the sum of the results

-- devide and conquer
divideAndConquer :: (problem -> solution) -> problem -> (problem -> Bool) ->
  ([solution] -> solution) -> (problem -> [problem]) -> solution
divideAndConquer f arg threshold conquer divide = go arg
  where
    go splitData = case divide splitData of
      [] ->
        f splitData
      splits -> conquer results `using` strat
        where
          results = map go splits
          strat x = do
            mapM_ chosenStrategy results
            return x
          chosenStrategy
            | threshold splitData = rseq
            | otherwise = rpar


-- sequential
sumTotientSequential :: (Int, Int) -> Int
sumTotientSequential (lower, upper) =
  sum (totients lower upper Nothing Nothing)

-- sequential, using evalList strategy
sumTotientEvalList :: (Int, Int) -> Int
sumTotientEvalList (lower, upper) =
  sum (totients lower upper Nothing Nothing `using` evalList rseq)

-- TODO: add more sum totient implementations below using the
-- evaluation strategies from the Control.Parallel.Strategies module.
-- Then edit the application in app/Main.hs to create a parallel
-- profile for visualising with Threadscope.
--
-- They should always have the same type as the two functions above, i.e.:
--
sumTotient :: (Int, Int, Maybe Int, Maybe Int, Maybe Bool, Maybe (Int, Int)) -> Int
sumTotient (lower, upper, sumCluster, eulCluster, naiveParallel, Nothing) = sum (totients lower upper sumCluster eulCluster `using` if naiveParallel == Just True then parList rpar else evalList rseq)
sumTotient (lower, upper, sumClust, eulClust, _, Just (skelClust, divider)) = 
  divideAndConquer baseCase (lower, upper) isSmall conquer split
  where
    baseCase (l, u) = sum (totients l u sumClust eulClust)
    isSmall (l, u) = (u - l) <= skelClust
    conquer results = sum results
    split (l, u)
      | l == u    = []
      | otherwise = let mid = l + (u - l) `div` divider
                    in [(l, mid), (mid + 1, u)]

-------------------
-- Totient function
-------------------

totients :: Int -> Int -> Maybe Int -> Maybe Int -> [Int]
totients lower upper  Nothing eulCluster = map (\x -> euler x eulCluster) [lower, lower + 1 .. upper]
totients lower upper (Just clusterSize) eulCluster = map (\x -> euler x eulCluster) [lower, lower + 1 .. upper] `using` parListChunk clusterSize rpar

--------
-- euler
--------
-- The euler n function
-- 1. Generates a list [1,2,3, ... n-1,n]
-- 2. Select only those elements of the list that are relative prime to n
-- 3. Returns a count of the number of relatively prime elements

euler :: Int -> Maybe Int -> Int
euler n Nothing = length (filter (relprime n) [1 .. n])
euler n (Just clusterSize) = length (filter (relprime n) [1 .. n] `using` parListChunk clusterSize rpar)

-----------
-- relprime
-----------
-- The relprime function returns true if it's arguments are relatively
-- prime, i.e. the highest common factor is 1.

relprime :: Int -> Int -> Bool
relprime x y = hcf x y == 1

------
-- hcf
------
-- The hcf function returns the highest common factor of 2 integers

hcf :: Int -> Int -> Int
hcf x 0 = x
hcf x y = hcf y (rem x y)
