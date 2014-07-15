# -*- coding: utf-8 -*-
require 'rdl'

# RDL Annotations for Ruby 2.1.1

class String
  extend RDL

  typesig(:new, "(str : ?String) -> new_str : String") { new_str.include?(str) unless str.empty? }

  typesig(:try_convert, "(obj : Object) -> ret : String or nil") { ret.nil? || ret==obj.to_str }

  typesig(:%, "(Object) -> String")

  typesig(:*, "(Fixnum) -> String")
  post_cond { |ret,prm| prm[0]>=0 && !(ret[0]=~/(#{self}){#{prm[0]}}/).nil? }

  typesig(:+, "(String) -> String")
  post_cond { |ret,prm| ret[0].include?(prm[0]) && ret[0].include?(self) }

  typesig( :<<, " ( Object ) -> String " ) {|prm,ret| ret[0].include?(prm[0]) && ret[0].include?(self)}

  typesig(:<=>, "(other : String) -> ret : Fixnum or nil" ) { ret.nil? || ret.abs < 2 }

  typesig( :== , " ( Object ) -> %bool " )

  typesig( :=== , " ( Object ) -> %bool " )

typesig( :=~ , " ( Object ) -> Fixnum or nil " )

typesig( :[] , " ( Fixnum or Range or Regexp or String, ? Fixnum or String ) ->  String or nil " ) {|prm,ret| ret[0].nil? ? prm[0]>self.length : ret[0].length==1}

typesig( :[]= , " ( Fixnum or Range or Regexp or String, ? Fixnum or String, String ) ->  String " ) {|prm,ret| prm[0]<self.length} # TODO: embed pre (timing)

typesig( :ascii_only? , " ( ) -> %bool" ) {|prm,ret| ret[0]==self.force_encoding("UTF-8").ascii_only?}

typesig( :b , " ( ) -> String " ) {|prm,ret| ret[0].force_encoding("UTF-8").ascii_only?}

typesig( :bytes , " ( ) -> Array<Object> " )# TODO: bindings to parameterized (vars)

typesig( :bytesize , " ( ) -> Fixnum " )

typesig( :byteslice , " ( Fixnum, ? Fixnum ) -> String or nil " )

typesig( :byteslice , " ( Range ) -> String or nil " )

typesig( :capitalize , " ( ) -> String " ) {|prm,ret| ret[0][0]=~/[A-Z]/ && ret[0][1,ret[0].length]=~/^[A-Z]/}

typesig( :capitalize! , " ( ) -> String or nil " ) {|prm,ret| ret[0][0]=~/[A-Z]/ && ret[0][1,ret[0].length]=~/^[A-Z]/ && ret[0].eql?(self)}

typesig( :casecmp , " ( String ) -> nil or Fixnum " ) {|prm,ret| ret[0].nil? ? true:ret[0].abs<2}

typesig( :center , " ( Fixnum , ? String ) -> String " ) {|prm,ret| ret[0].length==[self.length,prm[0]].max}

typesig( :chars , " ( ) -> Array " ) #deprecated

typesig( :chomp , " ( ? String ) -> String " ) {|prm,ret| ret[0].length<=self.length}

typesig( :chomp! , " ( String ) -> String or nil " ) {|prm,ret| ret[0].length<=self.length} #State-modifying methods: no original value stored

typesig( :chop , " ( ) -> String " ) {|prm,ret| ret[0].length<=self.length}

typesig( :chop! , " ( ) -> String or nil " ) {|prm,ret| ret[0].length<=self.length} #Same original val problem

typesig( :chr , " ( ) -> String " ) {|prm,ret| ret[0].length.abs<2}

typesig( :clear , " ( ) -> String ") {|prm,ret| ret[0].eql?("")}

typesig( :codepoints , " ( ? { ( ? %any ) -> %any } ) -> Array<Fixnum> " ) {|prm,ret| prm[0].nil? ? ret[0].eql?(self.each_codepoint(*prm)):ret[0].eql?(self.each_codepoint.to_a)} # No grammar for generic block

typesig( :concat , " ( Fixnum or Object ) -> String ") {|prm,ret| prm[0].class<=Fixnum ? ret[0].eql?(self.concat(prm[0].chr)):ret[0].eql?(self<<prm[0])} #easier way to check against other method?

typesig( :count , " ( *String ) -> Fixnum " )

typesig(:crypt , " ( String ) -> String " )

typesig( :delete , " ( *String ) -> String " ) {|prm,ret| ret[0].length<=self.length}

typesig( :delete! , " ( *String ) -> String " ) {|prm,ret| ret[0].length<=self.length} #same original val problem

typesig( :downcase , " ( ) -> String or nil " ) {|prm,ret| ret[0][0]=~/[a-z]/ && ret[0][1,ret[0].length]=~/^[a-z]/}

typesig( :downcase! , " ( ) -> String or nil " ) {|prm,ret| ret[0][0]=~/[a-z]/ && ret[0][1,ret[0].length]=~/^[a-z]/} #Same original val problem

typesig( :dump , " ( ) -> String " )

typesig( :each_byte , " ( { ( Fixnum ) -> %any } ) -> String " )

typesig( :each_byte , " ( ) -> Enumerator " ) {|prm,ret| ret[0].size==self.length}

typesig( :each_char , " ( { ( String ) -> %any } ) -> String " )

typesig( :each_char , " ( ) -> Enumerator " ) {|prm,ret| ret[0].size==self.length}

typesig( :each_codepoint , " ( { ( Fixnum ) -> %any } ) -> String " )

typesig( :each_codepoint , " ( ) -> Enumerator " ) {|prm,ret| ret[0].size==self.length}

typesig( :each_line , " ( { ( Fixnum ) -> %any }, ? String ) -> String " )

typesig( :each_line , " ( ? String ) -> Enumerator " ) {|prm,ret| ret[0].size==self.length}

typesig( :empty? , " ( ) -> %bool " ) {|prm,ret| self.send(:[],0).nil? != ret[0]}

typesig( :encode , " ( ? Encoding, ? Encoding, * Symbol ) -> String " ) # {|prm,ret| if(prm[1].is_a? Encoding) ret[0].encoding.eql?(prm[1]); elsif(prm[0].is_a? Encoding) ret[0].encoding.eql?(prm[0]); else ret[0].encoding.eql?(Encoding.default_internal) end} #Unknown bindings to Encodings 1,2,*3

typesig( :encode! , " ( Encoding, ? Encoding, * Symbol ) -> String " ) # {|prm,ret| if(prm[1].is_a? Encoding) ret[0].encoding.eql?(prm[1]); elsif(prm[0].is_a? Encoding) ret[0].encoding.eql?(prm[0]); else ret[0].encoding.eql?(Encoding.default_internal) end} #Same original val problem

typesig( :encoding , " ( ) -> Encoding " ) {|prm,ret| self.encode(ret[0]).eql?(self)}

typesig( :end_with? , " ( *String ) -> %bool " ) {|prm,ret| true} #temp

typesig( :eql? , " ( String ) -> %bool " ) {|prm,ret| ((prm[0].length==self.length)&&(self.codepoints.uniq.sort==prm[0].codepoints.uniq.sort))==ret[0]}

typesig( :force_encoding , " ( Encoding ) -> String " ) {|prm,ret| ret[0].encoding==prm[0]}

typesig( :getbyte , " ( Fixnum ) -> Fixnum or nil " ) {|prm,ret| (prm[0]>0 && prm[0]<self.length) ? (0..255).member?(ret[0]) : ret[0].nil?}

typesig( :gsub , " ( Regexp or String , String ) -> String " )

typesig( :gsub , " ( Regexp or String , Hash ) -> String " )

typesig( :gsub , " ( Regexp or String , { ( String ) -> %any } ) -> String " )

typesig( :gsub , " ( Regexp or String ) ->  Enumerator " )

typesig( :gsub! , " ( Regexp or String , String ) -> String or nil " ) # {|prm,ret| ret[0].nil? ? self.eql?(orig) : true} #Original val problem

typesig( :gsub! , " ( Regexp or String , { ( String ) -> %any } ) -> String or nil " ) #Same original val problem

typesig( :gsub! , " ( Regexp or String ) -> Enumerator " )

typesig( :hash , " ( ) -> Fixnum " )

typesig( :hex , " ( ) -> Fixnum " ) {|prm,ret| (self.send(:[],0)=~/^[0-9a-fA-F]/) ? true:ret[0]==0} #recursive def with :index ?

typesig( :include? , " ( String ) -> %bool " ) #todo via regexp

typesig( :index , " ( Regexp or String , ? Fixnum ) -> Fixnum or nil " )

typesig( :replace , " ( String ) -> String " ) #Same original val problem

typesig( :insert , " ( Fixnum , String ) -> String " ) {|prm,ret| ret[0].length==self.length+prm[1].length}

typesig( :inspect , " ( ) -> String " )

typesig( :intern , " ( ) -> Symbol " )

typesig( :length , " ( ) -> Fixnum " )

typesig( :lines , " ( ? String ) -> Array<String> " ) {|prm,ret| prm[0] ? ret[0]==self.each_line(prm[0]).to_a : ret[0]==self.each_line().to_a}

typesig( :ljust , " ( Fixnum, ? String ) -> String " ) #todo

typesig( :lstrip , " ( ) -> String " ) {|prm,ret| ret[0].length<=self.length}

typesig( :lstrip! , " ( ) -> String or nil " ) #Same original val problem

typesig( :match , " ( Regexp or String , ? { ( %any ) -> %any } ) -> MatchData " ) #todo

typesig( :next , " ( ) -> String " ) {|prm,ret| ret[0]==self.succ}

typesig( :next! , " ( ) -> String " ) #same original val problem

typesig( :oct , " ( ) -> Fixnum " ) {|prm,ret| (self.send(:[],0)=~/^[0-7]/) ? true:ret[0]==0} #recursive def with :index ?

typesig( :ord , " ( ) -> Fixnum " ) {|prm,ret| self.length>1 ? ret[0]==self.send(:[],0).ord : true}

typesig( :partition , " ( Regexp or String ) -> Array<String> " ) {|prm,ret| ret[0].length==3 && ret[0][0]+ret[0][1]+ret[0][2]==self}

typesig( :prepend , " ( String ) -> String " ) #Same original value problem

typesig( :reverse , " ( ) -> String " ) {|prm,ret| ret[0].reverse.eql?(self)} #recursive definitions?

typesig( :rindex , " ( String or Regexp , ? Fixnum ) -> Fixnum or nil " ) #todo

typesig( :rjust , " ( Fixnum , ? String ) -> String " ) #todo

typesig( :rpartition , " ( String or Regexp ) -> Array<String> " ) {|prm,ret| ret[0].length==3 && ret[0][0]+ret[0][1]+ret[0][2]==self}

typesig( :rstrip , " ( ) -> String " ) {|prm,ret| ret[0].length<=self.length}

typesig( :rstrip! , " ( ) -> String " ) #Same original value problem

typesig( :scan , " ( Regexp or String ) -> Array<String or Array<String>> " ) #todo

typesig( :scan , " ( Regexp or String , { ( * %any ) -> %any } ) " )

typesig( :scrub , " ( ? String , ? { ( %any ) -> %any } ) -> String " )

typesig( :scrub! , " ( ) ->  " ) #Same original value problem

typesig( :set_byte , " ( Fixnum , Fixnum ) -> Fixnum " ) #Same original val problem, same pre cond problem

typesig( :size , " ( ) -> Fixnum " ) {|prm,ret| ret[0]==self.length}

typesig( :slice , " ( Fixnum or Range or Regexp or String ) -> String or nil " ) #todo diff b/w slice and [] ?

typesig( :slice , " ( Fixnum , Fixnum ) -> String or nil " ) #todo

typesig( :slice , " ( Regexp , Fixnum or String ) -> String or nil " ) #todo

typesig( :slice! , " ( Fixnum or Range or Regexp or String ) -> String or nil " ) #Same original value problem

typesig( :slice! , " ( Fixnum , Fixnum ) -> String or nil " ) #Same original value problem

typesig( :split , " ( Regexp or String , ? Fixnum) -> Array<String> " )

typesig( :squeeze , " ( ? String ) -> String " )

typesig( :squeeze! , " ( ? String ) -> String " ) #Same original value problem

typesig( :start_with? , " ( * String ) -> %bool " )

typesig( :strip , " ( ) -> String " ) {|prm,ret| ret[0].length<=self.length}

typesig( :strip! , " ( ) -> String " )#Same Original value problem

typesig( :sub , " ( Regexp or String , String or Hash or { ( String ) -> %any} ) -> String " )

typesig( :sub! , " ( Regexp or String , String or { ( String ) -> %any} ) -> String or nil " ) #Same original value problem

typesig( :succ , " ( ) -> String " )

typesig( :sum , " ( ? Fixnum ) -> Fixnum " ) {|prm,ret| x = (prm[0] ? prm[0]:16); sum = 0; self.to_a.each{|t| sum += t.to_i(2)}; ret[0]==sum%(2**x-1);}

typesig( :swapcase , " ( ) -> String " ) {|prm,ret| self.eql?(ret[0].swapcase)} #recursive defs?

typesig( :swapcase! , " ( ) -> String or nil " ) #Same original val problem

typesig( :to_c , " ( ) -> Complex " )

typesig( :to_f , " ( ) -> Float " )

typesig( :fo_i , " ( ? Fixnum ) -> Fixnum " ) {|prm,ret| x = (prm[0] ? prm[0]:10); (x>=2 && x<=36)}

typesig( :to_r , " ( ) -> Rational " )

typesig( :to_s , " ( ) -> String " ) {|prm,ret| ret[0].equal? self}

typesig( :to_str , " ( ) -> String " ) {|prm,ret| ret[0].equal? self}

typesig( :to_sym , " ( ) -> Symbol " )

typesig( :tr , " ( String , String ) -> String " ) {|prm,ret| ret[0].length>=self.length}

typesig( :tr! , " ( String , String ) -> String or nil " ) #Same original val problem

typesig( :tr_s , " ( String , String ) -> String " )

typesig( :tr_s! , " ( String , String) -> String or nil " ) #Same original val problem

typesig( :unpack , " ( String ) -> Array<String> " ) {|prm,ret| }

typesig( :upcase , " ( ) -> String " ) {|prm,ret| ret[0].eql?(self.downcase.swapcase)}

typesig( :upcase! , " ( ) -> String or nil " ) #Same original val problem

typesig( :upto , " ( String , ? bool ) -> Enumerator " ) #bool defaults to FALSECLASS

typesig( :upto , " ( String , ? bool , { ( String ) -> %any } ) -> String " ) #bool defaults to FALSECLASS

typesig( :valid_encoding? , " ( ) -> %bool " )

end











