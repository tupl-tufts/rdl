module RDL::Type
class Parser

macro
  ID (\w|\:\:)+
  SYMBOL :\w+
  SPECIAL_ID %\w+
  FIXNUM -?(\d)+
  FLOAT -?\d\.\d+
  PREDCHAR ([^{}])+

rule
  \s            # skip
  or            { [:OR, text] }
  ->            { [:RARROW, text] }
  =>            { [:RASSOC, text] }
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
  \#T      	    { [:HASH_TYPE, text] }
  \#Q      	    { [:HASH_QUERY, text] }
  \$\{          { [:CONST_BEGIN, text] }
  \.\.\.        { [:DOTS, text] }
  \.            { [:DOT, text] }
  {FLOAT}       { [:FLOAT, text] } # Must go before FIXNUM
  {FIXNUM}      { [:FIXNUM, text] }
  {ID}          { [:ID, text] }
  {SYMBOL}      { [:SYMBOL, text[1..-1]] }
  \:            { [:COLON, text] } # Must come after SYMBOL
  {SPECIAL_ID}  { [:SPECIAL_ID, text] }
  '[^']*'       { [:STRING, text.gsub("'", "")] }
  "[^"]*"       { [:STRING, text.gsub('"', "")] }
  {PREDCHAR}     { [:PREDCHAR, text] }

end
end
