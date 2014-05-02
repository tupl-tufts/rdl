########################################################################
# The latest rexical generator on github supports matching against the 
# end of string. For this file to work correctly, you MUST use the
# latest upstream rexical.
########################################################################


# ######################################################################
# DRuby annotation language parser
# Adapted directly from DRuby source file typeAnnotationLexer.mll
# Version of GitHub DRuby repo commit 0cda0264851bcdf6b301c3d7f564e9a3ee220e45
# ######################################################################
module RDL::Type
class Parser

macro
  ID \w+
  SYMBOL :\w+
  ARG [\?\*]?\w+
  NAME %\w+

rule
# rules take the form:
# [:state] pattern [actions]

# ####################
# tokens
# ####################

  \s        { }
  or        { [:OR, text] }
  =>        { [:ASSOC, text] } 
  \::       { [:DOUBLE_COLON, text] }
  ->        { [:RARROW, text] }
  {ID}      { [:ID, text] }
  {SYMBOL}  { [:SYMBOL, text[1..-1] }
  {ARG}     { [:ARG, text] }
  {NAME}    { [:NAME, text] }
  '[^']*'   { [:STRING, text.gsub("'", "")] }

end
