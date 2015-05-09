import Control.Applicative((<*>), (<*), (*>))
import Text.Parsec
import Text.Parsec.String
import Text.Parsec.Token
import Text.Parsec.Language
import Data.Functor
import System.IO.Unsafe

data Opcode    = ADD | SUB | ABS deriving (Show, Eq, Enum, Bounded)
data FUid      = F0  | F1  | F2  deriving (Show, Eq, Enum, Bounded)
data FUreg     = RF0 | RF1 | RF2 deriving (Show, Eq, Enum, Bounded)
data RFid      = RA  | RB  | RC  deriving (Show, Eq, Enum, Bounded)  
data Oper      = OCF FUreg | OCI Integer | OCR RFid Integer deriving (Show, Eq)
data InstrList = Seq [Instr] | Err String deriving (Show)
data Instr     = P1 FUid Opcode Oper Oper
               | P2 FUid Opcode Oper
               | P3 RFid Integer Oper 
               | NOP deriving (Show, Eq)

-- Define language symbols and tokens, see doc. Text.Parsec.Token
def = emptyDef { commentStart = "/*", commentEnd = "*/"
               , reservedOpNames = ["=", ":="], reservedNames = ["NOP"] ++
                 getAllConstrsStrs ADD ++ getAllConstrsStrs F0 ++  
                 getAllConstrsStrs RF0 ++ getAllConstrsStrs RA }

-- Make token parsers
TokenParser { reservedOp = m_reservedOp, reserved = m_reserved
            , semiSep1 = m_semiSep1, natural = m_natural } = makeTokenParser def

-- Start parsing the recieved string
startParser :: String -> InstrList
startParser str = do
    case parse pMain "" str of
      { Left err -> error (show err) ; Right res -> res }

-- Main statement parser
pMain :: Parser InstrList
pMain = spaces >> fmap Seq (m_semiSep1 instr1) <* eof where
  instr1 = try (m_reserved "NOP" >> return NOP)
    <|> try (P1 <$> pThisType <*> pThisType <*> pOper <*> pOper)
    <|> try (P2 <$> pThisType <*> pThisType <*> pOper)
    <|> P3 <$> pThisType <* m_reservedOp ":" <*> m_natural <* m_reservedOp "=" <*> pOper

-- Infer type and try to parse any of its constructors
pThisType :: (Show a, Enum a, Bounded a) => Parser a
pThisType = foldl1 (<|>) $ 
  map (\x -> m_reserved (show x) >> return x) [minBound .. maxBound]

-- Parse an operand
pOper :: Parser Oper
pOper =  try (OCF <$> pThisType) <|> try (OCI <$> m_natural) 
     <|> try (OCR <$> pThisType <* m_reservedOp ":" <*> m_natural) 
     
-- Create a list of all constructor strings for a specific data type
getAllConstrsStrs :: (Enum a, Show a, Bounded a) => a -> [String]
getAllConstrsStrs x = drop 1 $ map show (x:[minBound .. maxBound])
