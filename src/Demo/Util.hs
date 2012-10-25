-- -----------------------------------------------------------------------------
module Demo.Util(
  printSlaveResume, nidNode, expandNodenames, filterNodes ) where

-- -----------------------------------------------------------------------------
import Control.Arrow( (&&&) )
import Control.Monad( forM_ )
import Control.Distributed.Process( NodeId )
import Text.Regex.TDFA( (=~) )
import Data.List( sort, group )
import qualified Data.Text as T( Text, pack, unpack, append )
import Text.Parsec.Text( Parser )
import Text.Parsec.Prim( (<|>), (<?>), try, parse )
import Text.Parsec.Combinator( many1, sepBy1 )
import Text.Parsec.Char( char, alphaNum, digit )

-- -----------------------------------------------------------------------------
nidNode :: NodeId -> T.Text
nidNode nid = case regres of
  [_:nn:_] -> T.pack nn
  _ -> T.pack "*"
  where
    regres = show nid =~ "nid://(.+):(.+):(.+)" :: [[String]]

-- -----------------------------------------------------------------------------
rle :: [NodeId] -> [(Int, T.Text)]
rle slaves = map (length &&& head) sorted
  where
    sorted = group . sort . map nidNode $ slaves

-- -----------------------------------------------------------------------------
printSlaveResume :: String -> [NodeId] -> IO ()
printSlaveResume pre slaves = do
  putStrLn $ pre ++ " " ++ (show . length $ slaves) ++ " slave/s"
  forM_ (rle slaves) $ \(n,name) ->
    putStrLn $ pre ++ " ->" ++ T.unpack name ++ " = " ++ show n

-- -----------------------------------------------------------------------------
expandNodenames :: T.Text -> [T.Text]
expandNodenames def = case parse nodeList "" def of
  Left err -> error $ show err
  Right x -> x

-- -----------------------------------------------------------------------------
filterNodes :: [NodeId] -> String -> [NodeId]
filterNodes slaves names = filter ((`elem` assigned) . nidNode) slaves
  where
    assigned = expandNodenames . T.pack $ names

-- -----------------------------------------------------------------------------
nodeList :: Parser [T.Text]
nodeList = do {
                  l <- sepBy1 nodes $ char ',';
                  return $ concat l
                } <?> "node list"

-- -----------------------------------------------------------------------------
nodes :: Parser [T.Text]
nodes = do {
             pre <- nodePrefix;
             l <- intList <|> return [];
             if null l
               then return [pre]
               else return $ map (T.append pre . T.pack . show) l
           } <?> "nodes"

-- -----------------------------------------------------------------------------
nodePrefix :: Parser T.Text
nodePrefix = fmap T.pack $ many1 alphaNum

-- -----------------------------------------------------------------------------
intList :: Parser [Integer]
intList = do {
          _ <- char '[';
          l <- sepBy1 intSequence $ char ',';
          _ <- char ']';
          return . sort $ concat l
        } <?> "intList"

-- -----------------------------------------------------------------------------
intSequence :: Parser [Integer]
intSequence = try (
                 do {
                   a <- number;
                   _ <- char '-';
                   b <- number;
                   return [a..b]
                 })
            <|>
            do {
              n <- number;
              return [n]
            } <?> "intSequence"

-- -----------------------------------------------------------------------------
number :: Parser Integer
number = do {
           ds <- many1 digit;
           return $ read ds
         } <?> "number"

-- -----------------------------------------------------------------------------
