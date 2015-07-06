module RDL::Type
class Parser

macro
  ID (\w|\:\:)+
  SYMBOL :\w+
  SPECIAL_ID %\w+
  FIXNUM (\d)+

rule
  \s            # skip
  or            { [:OR, text] }
  =>            { [:ASSOC, text] } 
  ->            { [:RARROW, text] }
  \(            { [:LPAREN, text] }
  \)            { [:RPAREN, text] }
  \{            { [:LBRACE, text] }
  \}            { [:RBRACE, text] }
  \[            { [:LBRACKET, text] }
  \]            { [:RBRACKET, text] }
  <             { [:LESS, text] }
  >             { [:GREATER, text] }
  ,             { [:COMMA, text] }
  \?            { [:QUERY, text] }
  \*            { [:STAR, text] }
  \#\#      	{ [:DOUBLE_HASH, text] }
  {FIXNUM}      { [:FIXNUM, text] }
  {ID}          { [:ID, text] }
  {SYMBOL}      { [:SYMBOL, text[1..-1]] }
  \:            { [:COLON, text] } # Must come after SYMBOL
  {SPECIAL_ID}  { [:SPECIAL_ID, text] }
  '[^']*'       { [:STRING, text.gsub("'", "")] }

end
end
