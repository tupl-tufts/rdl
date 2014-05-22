require 'rdl'

class String
	extend RDL

	spec :new do
		typesig " ( %any ) -> String "
	end
	
	spec :try_convert do
		typesig " ( Object ) -> String OR nil "
	end
	
	spec :% do
		typesig " ( %any ) -> String "
	end
	
	#Are these neccessary due to implementation with Object?
	spec :+ do
		typesig " ( String ) -> String "
	end
	
	spec :<< do
		typesig " ( Object ) -> String "
	end
	
	spec :<=> do
		typesig " ( String ) -> Integer OR nil "
	end
	
	spec :== do
		typesig " ( Object ) -> %true OR %false "
	end
	
	spec :=== do
		typesig " ( Object ) -> %true OR %false "
	end
	
	spec :=~ do
		typesig " ( Object ) -> Fixnum OR nil "
	end
	
	spec :[] do
		typesig " ( Fixnum OR Range OR Regexp OR String, ? Fixnum OR String ) ->  String OR nil "
	end
	
	spec :[]= do
		typesig " ( Fixnum OR Range OR Regexp OR String, ? Fixnum OR String, String ) ->  String "
	end
	
end