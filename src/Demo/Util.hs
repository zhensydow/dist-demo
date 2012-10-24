-- -----------------------------------------------------------------------------
module Demo.Util( printSlaveResume ) where

-- -----------------------------------------------------------------------------
import Control.Monad( forM_ )
import Control.Distributed.Process( NodeId )
import Text.Regex.TDFA( (=~) )
import Control.Arrow( (&&&) )
import Data.List( sort, group )

-- -----------------------------------------------------------------------------
readNID :: NodeId -> String
readNID nid = case regres of
  [(_:nn:_)] -> nn
  _ -> "*"
  where
    regres = show nid =~ "nid://(.+):(.+):(.+)" :: [[String]]

-- -----------------------------------------------------------------------------
rle :: [NodeId] -> [(Int, String)]
rle slaves = map (length &&& head) sorted
  where
    sorted = group . sort . map readNID $ slaves
  
-- -----------------------------------------------------------------------------
printSlaveResume :: String -> [NodeId] -> IO ()
printSlaveResume pre slaves = do
  putStrLn $ pre ++ " " ++ (show . length $ slaves) ++ " slave/s"
  forM_ (rle slaves) $ \(n,name) -> do
    putStrLn $ pre ++ " ->" ++ name ++ " = " ++ show n
  
-- -----------------------------------------------------------------------------
