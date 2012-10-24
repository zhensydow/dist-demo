-- -----------------------------------------------------------------------------
module Main where

-- -----------------------------------------------------------------------------
import System.IO( BufferMode(..), hSetBuffering, stdout )
import Control.Distributed.Process( RemoteTable )
import Control.Distributed.Process.Node( initRemoteTable )
import Control.Distributed.Process.Backend.SimpleLocalnet( 
  initializeBackend, startSlave, startMaster )
import Control.Monad.IO.Class( liftIO )
import System.Environment( getArgs )
import Demo.WorkStealing( __remoteTable, master )
import Demo.Util( printSlaveResume )

-- -----------------------------------------------------------------------------
rtable :: RemoteTable
rtable = Demo.WorkStealing.__remoteTable initRemoteTable

-- -----------------------------------------------------------------------------
main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  args <- getArgs
  case args of
    ["master", host, port, n] -> do
      putStrLn $ "START Master on: " ++ host ++ " " ++ port
      backend <- initializeBackend host port rtable 
      startMaster backend $ \slaves -> do
        liftIO $ printSlaveResume (" + [" ++ host ++ ":" ++ port ++ "]") slaves
        result <- master (read n) slaves
        liftIO $ print result 
      putStrLn "END Master"
    ["slave", host, port] -> do
      putStrLn $ "START slave on: " ++ host ++ " " ++ port
      backend <- initializeBackend host port rtable 
      putStrLn $ " - [" ++ host ++ ":" ++ port ++ "] running..."
      startSlave backend
      putStrLn "END slave"
    _ -> do
      putStrLn "Invalid Args"

-- -----------------------------------------------------------------------------
