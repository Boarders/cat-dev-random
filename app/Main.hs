{-# LANGUAGE ScopedTypeVariables #-}
module Main where

-- base
import           Data.Bits
import           System.CPUTime

-- pipes
import           Pipes                 (Producer, runEffect, yield, (>->))

-- pipes-bytestring
import qualified Pipes.ByteString      as Pipes

-- bytestring
import           Data.ByteString       (ByteString)

-- random
import           System.Random

-- time
import           Data.Time.Clock.POSIX


main :: IO ()
main = do
  seed <- genEntropy                 -- create initial seed
  let initialGen = mkStdGen seed     -- turn seed into generator
  runEffect $
 -- generate bytes which are fed upstream to stdout
    genBytes initialGen  >-> Pipes.stdout


-- |
-- genBytes takes an initial generator, `StdGen`, and then produces a bytestring
-- to be consumed upstream.
genBytes :: StdGen -> Producer ByteString IO ()
genBytes gen = do
                   -- generate random bytestring of size 1024
  let (bytes, gen') = genByteString 1024 gen
  yield bytes
  genBytes gen'

-- |
-- genEntropy gives a source of randomness using the system time. As such,
-- it is not cryptographically secure.
genEntropy :: IO Int
genEntropy = do
  posixTime <- getPOSIXTime
  let
    seed1 :: Int
    seed1 = truncate posixTime
  cpuTime <- getCPUTime
  let
    seed2 :: Int
    seed2 = fromIntegral (cpuTime `div` cpuTimePrecision)
  pure ((seed1 `shiftL` 32) `xor` seed2)
