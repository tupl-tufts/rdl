
# Rubydoc annotation parser for RDL
module RDL::Type::Lib
class Parser
    
macro
    ID \w+
    SPECIAL_ID %\w+
    
rule

\s                              #skip
<span class="method-callseq">   { [:BEGIN, text] }
</span>                         { [:END, text] }
or                              { [:OR, text] }
&rarr;                          { [:RARROW, text] }
,                               { [:COMMA, text] }
|                               { [:BLK, text] }
=                               { [:EQ, text] }
'[^']*'                         { [:STRING, text] }
{ID}                            { [:ID, text] }
{SPECIAL_ID}                    { [:SP_ID, text] }
\(                              { [:LPAREN, text] }
\)                              { [:RPAREN, text] }
\[                              { [:LBRACKET, text] }
\]                              { [:RBRACKET, text] }
\{                              { [:LCURLY, text] }
\}                              { [:RCURLY, text] }

end