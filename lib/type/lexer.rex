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
class Parser < Racc::Parser

macro
  SPACE_RE [\t\ ]
  CAP_RE   [A-Z]
  LOW_RE   [a-z]
  NUM_RE   [0-9]
  ALPHA_RE [A-Za-z]
  ALPHANUM_RE [A-Za-z0-9]

  IDENT_RE \w

  INST_ID_RE [A-Za-z_]+\w*
  CONST_ID_RE [A-Z]+\w*
  TYPE_ID_RE [a-z_]+\w*\'?
  SCOPED_ID_RE ([A-Za-z_]+\w*|self)\.(\w|\[|\]|=)+[\?\!\=]?
  SUFFIXED_ID_RE [A-Za-z_]+\w*[\?\!\=]
  SYMBOL_RE :[A-Za-z_][A-Za-z_0-9]*
  TYPE_NAME_RE %[A-Za-z][A-Za-z_0-9]*'?
#in order to match spaces, you have to define an RE. Yes this is ridiculous
  CLASS_RE class\ 
  METACLASS_RE metaclass\ 
  REQUIRE_RE require\ 
  ALIAS_RE alias\ 
  MODULE_RE require\  
  END_RE end\ 
  TYPE_RE type\ 
  TYPEVAR_RE typevar\ 
  DOUBLE_HASH \#\#
rule
# rules take the form:
# [:state] pattern [actions]

# ####################
# tokens
# ####################

  {SPACE_RE}+                          # nothing
  #{SPACE_RE}*\n{SPACE_RE}*\#\#\%      # nothing
  ##\%                                 { [:T_BEGIN_LINE, text] }
  #(?:[^\#\n][^\n]*)?                  # nothing
  \n{SPACE_RE}*\=begin                 { @state = :COMMENT }

# keywords
  {CLASS_RE}                                { [:K_CLASS, text] }
  {METACLASS_RE}                            { [:K_METACLASS, text]}
  {MODULE_RE}                                { [:K_MODULE, text] }
  {ALIAS_RE}                                { [:K_ALIAS, text] }
  {REQUIRE_RE}                               { [:K_REQUIRE, text] }
  {END_RE}                                   { [:K_END, text] }
  {TYPE_RE}                                  { [:K_TYPE, text] }
  %none					     { [:T_BOTTOM, text] }
  %any					     { [:T_TOP, text] }
  %false                                     { [:T_FALSE, text] }
  %true                                      { [:T_TRUE, text] }
  %bool                                      { [:T_BOOL, text] }
  {TYPE_NAME_RE}                             { [:T_TYPE_NAME, text[1..-1]] }
  

# keywords
  or                                   { [:K_OR, text] }
  self                                 { [:K_SELF, text] }
  Tuple                                { [:K_TUPLE, text] }
  nil								   { [:K_NIL, text] }
  {TYPE_ID_RE}						   { [:T_LOCAL_ID, text] }
  {CONST_ID_RE}                        { [:T_CONST_ID, text] }
  {SCOPED_ID_RE}					   { [:T_SCOPED_ID, text] }
  {SUFFIXED_ID_RE}					   { [:T_SUFFIXED_ID, text] }
  {SYMBOL_RE}						   { [:T_SYMBOL, text] }
  {DOUBLE_HASH}						   { [:T_DOUBLE_HASH, text] }

# built in type constructors
  \*                                   { [:T_STAR, text] }
  \?                                   { [:T_QUESTION, text] }
  \^                                   { [:T_CARROT, text] }
      
  \@FIXME                              {fail "ERROR at line #{lineno}: " +
                                        "deprecated @@FIXME in '#{text}', " +
                                        "use !FIXME"}
                                       # text can't contain "'", so gsub is okay
  '[^']*'                         { [:T_STRING, text.gsub("'", "")] }
  =>                                   { [:T_ASSOC, text] } 

  \<\=                                 { [:T_SUBTYPE, text] }
  @{INST_ID_RE}                        { [:T_IVAR, text] }
  @@{INST_ID_RE}                       { [:T_CVAR, text] }
  \${INST_ID_RE}                       { [:T_GVAR, text] }
  \!                                   { [:T_BANG, text] }
  \::                                 { [:T_DOUBLE_COLON, text] }
  \:                                    { [:T_COLON, text] }
  \.                                   { [:T_DOT, text] }
  ->                                   { [:T_RARROW, text] }
  \(                                   { [:T_LPAREN, text] }
  \)                                   { [:T_RPAREN, text] }
  \[                                   { [:T_LBRACKET, text] }
  \]                                   { [:T_RBRACKET, text] }
  ,                                    { [:T_COMMA, text] }
  \{                                   { [:T_LBRACE, text] }
  \}                                   { [:T_RBRACE, text] }
  <                                    { [:T_LESS, text] }
  >                                    { [:T_GREATER, text] }
  ;                                    { [:T_SEMICOLON, text] }
  \n                                   { }
  \=                                   { [:T_EQUAL, text] }

  $                                   { @state = :END; [:T_EOF, ""] }
  :END $ { }


# ####################
# comments
# ####################
  :COMMENT  {SPACE_RE}*\=end[^\n]*\n         { state = nil }
  :COMMENT  [^\n]*\n                         # nothing
inner

  # def scan_str(str)
  #   scan_setup str
  #   @yydebug = true
  #   begin
  #     r = do_parse
  #   rescue => e
  #     fail e
  #   end
  #   r
  # end

end

end
