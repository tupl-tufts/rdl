require 'rdl'

class String
	extend RDL

	typesig :new , " ( %any ) -> String "
	
	typesig :try_convert , " ( Object ) -> String OR nil "
	
	typesig :% , " ( %any ) -> String "
	
	#Are these neccessary due to implementation with Object?
	typesig :+ " ( String ) -> String "
	
	typesig :<< " ( Object ) -> String "
	
	typesig :<=> " ( String ) -> Integer OR nil "
	
	typesig :== , " ( Object ) -> %bool "
	
	typesig :=== , " ( Object ) -> %bool "
	
	typesig :=~ , " ( Object ) -> Fixnum OR nil "
	
	typesig, :[] , " ( Fixnum OR Range OR Regexp OR String, ? Fixnum OR String ) ->  String OR nil "
	
	typesig :[]= , " ( Fixnum OR Range OR Regexp OR String, ? Fixnum OR String, String ) ->  String "
	
	typesig :ascii_only? , " ( ) -> %bool"
	
	typesig :b , " ( ) -> String "
	
	typesig :bytes , " ( ) -> Array<Byte> "
	
	typesig :bytesize , " ( ) -> Fixnum "
	
	typesig :byteslice , " ( Fixnum, ? Fixnum ) -> String OR nil "
	
	typesig :byteslice , " ( Range ) -> String or nil "
	
	typesig :capitalize , " ( ) -> String "
	
	typesig :capitalize , " ( ) -> String OR nil "
	
end