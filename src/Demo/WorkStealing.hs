-- -----------------------------------------------------------------------------
module Demo.WorkStealing where

-- -----------------------------------------------------------------------------
import Control.Distributed.Process(
  ProcessId, Process, NodeId, 
  getSelfPid, match, send, receiveWait, expect, spawnLocal, spawn )
import Control.Distributed.Process.Closure( remotable, mkClosure )
import Control.Monad( forM_, forever )

-- -----------------------------------------------------------------------------
calculate :: Integer -> Integer
calculate = (*2)

-- -----------------------------------------------------------------------------
slave :: (ProcessId, ProcessId) -> Process ()
slave (master, workQueue) = do
    us <- getSelfPid
    go us
  where
    go us = do
      -- Ask the queue for work
      send workQueue us

      -- If there is work, do it, otherwise terminate
      receiveWait
        [ match $ \n  -> send master (calculate n) >> go us
        , match $ \() -> return ()
        ]

-- -----------------------------------------------------------------------------
remotable ['slave]

-- -----------------------------------------------------------------------------
-- | Wait for n integers and sum them all up
sumIntegers :: Int -> Process Integer
sumIntegers = go 0
  where
    go :: Integer -> Int -> Process Integer
    go !acc 0 = return acc
    go !acc n = do
      m <- expect
      go (acc + m) (n - 1)

master :: Integer -> [NodeId] -> Process Integer
master n slaves = do
  us <- getSelfPid

  workQueue <- spawnLocal $ do
    -- Reply with the next bit of work to be done 
    forM_ [1 .. n] $ \m -> do
      them <- expect 
      send them m 

    -- Once all the work is done, tell the slaves to terminate
    forever $ do
      pid <- expect
      send pid ()

  -- Start slave processes 
  forM_ slaves $ \nid -> spawn nid ($(mkClosure 'slave) (us, workQueue))

  -- Wait for the result
  sumIntegers (fromIntegral n)
                                      
-- -----------------------------------------------------------------------------
