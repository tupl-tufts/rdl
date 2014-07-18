# -*- coding: utf-8 -*-
require 'rdl'

# RDL Annotations for Ruby 2.1.1

class String
  extend RDL

  typesig :new, "(?String:str) -> String:new_str", post() { new_str.include?(str) unless str.empty? }

  typesig :try_convert, "(Object:obj) -> String:new_string or nil", post(){ ret.nil? || ret==obj.to_str }

  typesig :%, "(Object) -> String"

  typesig :*, "(Fixnum) -> String", post() { prm[0]>=0 && !(ret=~/(#{self}){#{prm[0]}}/).nil? }

  typesig :+, "(String) -> String", post() { ret.include?(prm[0]) && ret.include?(self) }

  typesig :<<, " ( Object ) -> String ", post() { ret.include?(prm[0]) && ret.include?(self)}

  typesig :<=>, "(other : String) -> ret : Fixnum or nil", post() { ret.nil? || ret.abs < 2 }

  typesig :== , " ( Object ) -> %bool "

  typesig :=== , " ( Object ) -> %bool "

  typesig  :=~ , " ( Object ) -> Fixnum or nil "

  typesig  :[] , " ( Fixnum or Range or Regexp or String, ? Fixnum or String ) ->  String or nil ", post() { ret.nil? ? prm[0]>self.length : ret.length==1 }

  typesig  :[]= , " ( Fixnum or Range or Regexp or String, ? Fixnum or String, String ) ->  String ", pre() { prm[0]<self.length }

  typesig  :ascii_only? , " ( ) -> %bool", post() { ret==self.force_encoding("UTF-8").ascii_only? }

  typesig  :b , " ( ) -> String ", post() { ret.force_encoding("UTF-8").ascii_only? }

  typesig  :bytes , " ( ) -> Array " # TODO: bindings to parameterized (vars)

  typesig  :bytesize , " ( ) -> Fixnum "

  typesig  :byteslice , " ( Fixnum, ? Fixnum ) -> String or nil "

  typesig  :byteslice , " ( Range ) -> String or nil "

  typesig  :capitalize , " ( ) -> String ", post() { ret=~/[A-Z]/ && ret[1,ret.length]=~/^[A-Z]/ }

typesig  :capitalize! , " ( ) -> String or nil ", post() { ret=~/[A-Z]/ && ret[1,ret.length]=~/^[A-Z]/ && ret.eql?(self) }

typesig  :casecmp , " ( String ) -> nil or Fixnum ", post() { ret.nil? || ret.abs<2}

typesig  :center , " ( Fixnum , ? String ) -> String ", post() { ret.length==[self.length,prm[0]].max}

typesig  :chars , " ( ) -> Array "  #deprecated

typesig  :chomp , " ( ? String ) -> String ", post() { ret.length<=self.length}

typesig  :chomp! , " ( String ) -> String or nil " ) { ret.length<=self.length} #State-modifying methods: no original value stored

typesig  :chop , " ( ) -> String " ) { ret.length<=self.length}

typesig  :chop! , " ( ) -> String or nil " ) { ret.length<=self.length} #Same original val problem

typesig  :chr , " ( ) -> String " ) { ret.length.abs<2}

typesig  :clear , " ( ) -> String ") { ret.eql?("")}

typesig  :codepoints , " ( ? { ( ? %any ) -> %any } ) -> Array<Fixnum> " ) { prm[0].nil? ? ret.eql?(self.each_codepoint(*prm)):ret.eql?(self.each_codepoint.to_a)} # No grammar for generic block

typesig  :concat , " ( Fixnum or Object ) -> String ") { prm[0].class<=Fixnum ? ret.eql?(self.concat(prm[0].chr)):ret.eql?(self<<prm[0])} #easier way to check against other method?

typesig  :count , " ( *String ) -> Fixnum " )

typesig :crypt , " ( String ) -> String " )

typesig  :delete , " ( *String ) -> String " ) { ret.length<=self.length}

typesig  :delete! , " ( *String ) -> String " ) { ret.length<=self.length} #same original val problem

typesig  :downcase , " ( ) -> String or nil " ) { ret=~/[a-z]/ && ret[1,ret.length]=~/^[a-z]/}

typesig  :downcase! , " ( ) -> String or nil " ) { ret=~/[a-z]/ && ret[1,ret.length]=~/^[a-z]/} #Same original val problem

typesig  :dump , " ( ) -> String " )

typesig  :each_byte , " ( { ( Fixnum ) -> %any } ) -> String " )

typesig  :each_byte , " ( ) -> Enumerator " ) { ret.size==self.length}

typesig  :each_char , " ( { ( String ) -> %any } ) -> String " )

typesig  :each_char , " ( ) -> Enumerator " ) { ret.size==self.length}

typesig  :each_codepoint , " ( { ( Fixnum ) -> %any } ) -> String " )

typesig  :each_codepoint , " ( ) -> Enumerator " ) { ret.size==self.length}

typesig  :each_line , " ( { ( Fixnum ) -> %any }, ? String ) -> String " )

typesig  :each_line , " ( ? String ) -> Enumerator " ) { ret.size==self.length}

typesig  :empty? , " ( ) -> %bool " ) { self.send(:[],0).nil? != ret}

typesig  :encode , " ( ? Encoding, ? Encoding, * Symbol ) -> String " ) # { if(prm[1].is_a? Encoding) ret.encoding.eql?(prm[1]); elsif(prm[0].is_a? Encoding) ret.encoding.eql?(prm[0]); else ret.encoding.eql?(Encoding.default_internal) end} #Unknown bindings to Encodings 1,2,*3

typesig  :encode! , " ( Encoding, ? Encoding, * Symbol ) -> String " ) # { if(prm[1].is_a? Encoding) ret.encoding.eql?(prm[1]); elsif(prm[0].is_a? Encoding) ret.encoding.eql?(prm[0]); else ret.encoding.eql?(Encoding.default_internal) end} #Same original val problem

typesig  :encoding , " ( ) -> Encoding " ) { self.encode(ret).eql?(self)}

typesig  :end_with? , " ( *String ) -> %bool " ) { true} #temp

typesig  :eql? , " ( String ) -> %bool " ) { ((prm[0].length==self.length)&&(self.codepoints.uniq.sort==prm[0].codepoints.uniq.sort))==ret}

typesig  :force_encoding , " ( Encoding ) -> String " ) { ret.encoding==prm[0]}

typesig  :getbyte , " ( Fixnum ) -> Fixnum or nil " ) { (prm[0]>0 && prm[0]<self.length) ? (0..255).member?(ret) : ret.nil?}

typesig  :gsub , " ( Regexp or String , String ) -> String " )

typesig  :gsub , " ( Regexp or String , Hash ) -> String " )

typesig  :gsub , " ( Regexp or String , { ( String ) -> %any } ) -> String " )

typesig  :gsub , " ( Regexp or String ) ->  Enumerator " )

typesig  :gsub! , " ( Regexp or String , String ) -> String or nil " ) # { ret.nil? ? self.eql?(orig) : true} #Original val problem

typesig  :gsub! , " ( Regexp or String , { ( String ) -> %any } ) -> String or nil " ) #Same original val problem

typesig  :gsub! , " ( Regexp or String ) -> Enumerator " )

typesig  :hash , " ( ) -> Fixnum " )

typesig  :hex , " ( ) -> Fixnum " ) { (self.send(:[],0)=~/^[0-9a-fA-F]/) ? true:ret==0} #recursive def with :index ?

typesig  :include? , " ( String ) -> %bool " ) #todo via regexp

typesig  :index , " ( Regexp or String , ? Fixnum ) -> Fixnum or nil " )

typesig  :replace , " ( String ) -> String " ) #Same original val problem

typesig  :insert , " ( Fixnum , String ) -> String " ) { ret.length==self.length+prm[1].length}

typesig  :inspect , " ( ) -> String " )

typesig  :intern , " ( ) -> Symbol " )

typesig  :length , " ( ) -> Fixnum " )

typesig  :lines , " ( ? String ) -> Array<String> " ) { prm[0] ? ret==self.each_line(prm[0]).to_a : ret==self.each_line().to_a}

typesig  :ljust , " ( Fixnum, ? String ) -> String " ) #todo

typesig  :lstrip , " ( ) -> String " ) { ret.length<=self.length}

typesig  :lstrip! , " ( ) -> String or nil " ) #Same original val problem

typesig  :match , " ( Regexp or String , ? { ( %any ) -> %any } ) -> MatchData " ) #todo

typesig  :next , " ( ) -> String " ) { ret==self.succ}

typesig  :next! , " ( ) -> String " ) #same original val problem

typesig  :oct , " ( ) -> Fixnum " ) { (self.send(:[],0)=~/^[0-7]/) ? true:ret==0} #recursive def with :index ?

typesig  :ord , " ( ) -> Fixnum " ) { self.length>1 ? ret==self.send(:[],0).ord : true}

typesig  :partition , " ( Regexp or String ) -> Array<String> " ) { ret.length==3 && ret+ret[1]+ret[2]==self}

typesig  :prepend , " ( String ) -> String " ) #Same original value problem

typesig  :reverse , " ( ) -> String " ) { ret.reverse.eql?(self)} #recursive definitions?

typesig  :rindex , " ( String or Regexp , ? Fixnum ) -> Fixnum or nil " ) #todo

typesig  :rjust , " ( Fixnum , ? String ) -> String " ) #todo

typesig  :rpartition , " ( String or Regexp ) -> Array<String> " ) { ret.length==3 && ret+ret[1]+ret[2]==self}

typesig  :rstrip , " ( ) -> String " ) { ret.length<=self.length}

typesig  :rstrip! , " ( ) -> String " ) #Same original value problem

typesig  :scan , " ( Regexp or String ) -> Array<String or Array<String>> " ) #todo

typesig  :scan , " ( Regexp or String , { ( * %any ) -> %any } ) " )

typesig  :scrub , " ( ? String , ? { ( %any ) -> %any } ) -> String " )

typesig  :scrub! , " ( ) ->  " ) #Same original value problem

typesig  :set_byte , " ( Fixnum , Fixnum ) -> Fixnum " ) #Same original val problem, same pre cond problem

typesig  :size , " ( ) -> Fixnum " ) { ret==self.length}

typesig  :slice , " ( Fixnum or Range or Regexp or String ) -> String or nil " ) #todo diff b/w slice and [] ?

typesig  :slice , " ( Fixnum , Fixnum ) -> String or nil " ) #todo

typesig  :slice , " ( Regexp , Fixnum or String ) -> String or nil " ) #todo

typesig  :slice! , " ( Fixnum or Range or Regexp or String ) -> String or nil " ) #Same original value problem

typesig  :slice! , " ( Fixnum , Fixnum ) -> String or nil " ) #Same original value problem

typesig  :split , " ( Regexp or String , ? Fixnum) -> Array<String> " )

typesig  :squeeze , " ( ? String ) -> String " )

typesig  :squeeze! , " ( ? String ) -> String " ) #Same original value problem

typesig  :start_with? , " ( * String ) -> %bool " )

typesig  :strip , " ( ) -> String " ) { ret.length<=self.length}

typesig  :strip! , " ( ) -> String " )#Same Original value problem

typesig  :sub , " ( Regexp or String , String or Hash or { ( String ) -> %any} ) -> String " )

typesig  :sub! , " ( Regexp or String , String or { ( String ) -> %any} ) -> String or nil " ) #Same original value problem

typesig  :succ , " ( ) -> String " )

typesig  :sum , " ( ? Fixnum ) -> Fixnum " ) { x = (prm[0] ? prm[0]:16); sum = 0; self.to_a.each{|t| sum += t.to_i(2)}; ret==sum%(2**x-1);}

typesig  :swapcase , " ( ) -> String " ) { self.eql?(ret.swapcase)} #recursive defs?

typesig  :swapcase! , " ( ) -> String or nil " ) #Same original val problem

typesig  :to_c , " ( ) -> Complex " )

typesig  :to_f , " ( ) -> Float " )

typesig  :fo_i , " ( ? Fixnum ) -> Fixnum " ) { x = (prm[0] ? prm[0]:10); (x>=2 && x<=36)}

typesig  :to_r , " ( ) -> Rational " )

typesig  :to_s , " ( ) -> String " ) { ret.equal? self}

typesig  :to_str , " ( ) -> String " ) { ret.equal? self}

typesig  :to_sym , " ( ) -> Symbol " )

typesig  :tr , " ( String , String ) -> String " ) { ret.length>=self.length}

typesig  :tr! , " ( String , String ) -> String or nil " ) #Same original val problem

typesig  :tr_s , " ( String , String ) -> String " )

typesig  :tr_s! , " ( String , String) -> String or nil " ) #Same original val problem

typesig  :unpack , " ( String ) -> Array<String> " ) { }

typesig  :upcase , " ( ) -> String " ) { ret.eql?(self.downcase.swapcase)}

typesig  :upcase! , " ( ) -> String or nil " ) #Same original val problem

typesig  :upto , " ( String , ? bool ) -> Enumerator " ) #bool defaults to FALSECLASS

typesig  :upto , " ( String , ? bool , { ( String ) -> %any } ) -> String " ) #bool defaults to FALSECLASS

typesig  :valid_encoding? , " ( ) -> %bool " )

end











