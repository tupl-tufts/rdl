#!/usr/bin/env ruby

 require 'bigdecimal'
 require 'rdl'
 require 'rdl_types'

MAX_FIXNUM = 2**(0.size*8-2)-1 #Largest fixnum. -2 since 1 bit used for sign, 1 bit used as int marker.
MIN_FIXNUM = -(2**(0.size*8-2)) #Smallest fixnum.

 def test()
	x = gen_number(0.2,0.2,0.2,0.05,0.05,0.2,0,0.1)
	type_one = x.class.to_s
	if type_one=="BigDecimal"
		y = gen_number(0.25,0.25,0.2,0,0,0.2,0,0.1)
		type_two = y.class.to_s
	elsif type_one=="Rational"
		y = gen_number(0.2,0.2,0.2,0.1,0,0.2,0,0.1)
		type_two = y.class.to_s		
	elsif x.is_a?(Float)&&(x==Float::INFINITY|| x.nan?)
		y = gen_number(0.2,0.2,0,0.1,0.1,0.3,0,0.1)
		type_two = y.class.to_s
	else
		y = gen_number(0.2,0.2,0.2,0.05,0.05,0.2,0,0.1)
	        type_two = y.class.to_s
	end
	#puts "Arg1= #{x} and type = #{type_one}"
	#puts "Arg2= #{y} and type = #{type_two}"
	operation_type = query(type_one+'#modulo',y)
	expected_type = operation_type[operation_type.index('->')+3..-1]
	w = x.modulo(y)
	#puts "here"
	test_result = w.is_a?(Object.const_get(expected_type))
	if !test_result
		puts "Arg1= #{x} (type: #{type_one})"
		puts "Arg2= #{y} (type: #{type_two})"
		puts "Res= #{w}"
		puts "Expected type: #{expected_type}"
		puts "Received type: #{w.class}"
	end
	#puts test_result
 	return test_result
 end

def gen_fixnum()
	return Random.rand(MIN_FIXNUM..MAX_FIXNUM)
end

def gen_bignum()
	r = Random.rand()
	if r<0.5
		return Random.rand(MAX_FIXNUM+1..MAX_FIXNUM*1000)
	else
		return -1*Random.rand(MAX_FIXNUM+1..MAX_FIXNUM*1000)
	end
end

def gen_float()
	r = Random.rand()
	if r<0.5
		return Float::MAX*Random.rand
	else
		return -1*Float::MAX*Random.rand
	end
end

def gen_bigdec()
	r = Random.rand()
	if r<0.33
		return BigDecimal.new(gen_fixnum())
	elsif r<0.66
		return BigDecimal.new(gen_bignum())
	else
		return BigDecimal.new(gen_float(),0)
	end
end

def gen_complex()
	x = gen_number(0.2,0.2,0.1,0.05,0.05,0.3,0,0.1)
	#puts x
	y = gen_number(0.2,0.2,0.1,0.05,0.05,0.3,0,0.1)
	#puts y
	return Complex(x,y)
end

def gen_rational()
	x = gen_fixnum()
	y = gen_fixnum()
	return Rational(x,y)
end
	

def gen_number(probFixnum,probBignum,probBigDec,probInf,probNAN,probFloat,probComplex,probRational)
	r = Random.rand()
	if r<probFixnum then
		#Fixnum type
		x = gen_fixnum()
	elsif r<(probFixnum+probBignum)
		x = gen_bignum()
	elsif r<(probFixnum+probBignum+probBigDec)
		#BigDecimal type
		x = gen_bigdec()
	elsif r<(probFixnum+probBignum+probBigDec+probInf)
		x=Float::INFINITY
	elsif r<(probFixnum+probBignum+probBigDec+probInf+probNAN)
		x=Float::NAN
	elsif r<(probFixnum+probBignum+probBigDec+probInf+probNAN+probFloat)
		#Random Float type
		x = gen_float()
        elsif r<(probFixnum+probBignum+probBigDec+probInf+probNAN+probFloat+probComplex)
		x= gen_complex()
	elsif (probFixnum+probBignum+probBigDec+probInf+probNAN+probFloat+probComplex+probRational)
		x = gen_rational()
	end
	return x
end

 def rounds(x)
	counter = 0
	for i in 0..x
		b= test()
		if (!b) then
			counter=counter+1
		end
	
	end
	return counter
 end	


def query(q,y)
    $__rdl_contract_switch.off {
      if q =~ /^(\w+(#|\.))?(\w+(!|\?|=)?|!|~|\+|\*\*|-|\*|\/|%|<<|>>|&|\||\^|<|<=|=>|>|==|===|!=|=~|!~|<=>|\[\]|\[\]=)$/
        klass = nil
        klass_pref = nil
        meth = nil
        if q =~ /(.+)#(.+)/
          klass = $1
          klass_pref = "#{klass}#"
          meth = $2.to_sym
        elsif q =~ /(.+)\.(.+)/
          klass_pref = "#{$1}."
          klass = RDL::Util.add_singleton_marker($1)
          meth = $2.to_sym
        else
          klass = self.class.to_s
          klass_pref = "#{klass}#"
          meth = q.to_sym
        end
        if RDL::Wrap.has_contracts?(klass, meth, :type)
          typs = RDL::Wrap.get_contracts(klass, meth, :type)
          typs.each { |t|
            #puts "#{klass_pref}#{meth}: #{t}"
	    t_string = "#{t}"
	    t_string =~ /\((\w*)\)(.+)/
	
	    #puts y
	    if y.is_a?(Object.const_get($1))
		return t_string
	    end
	    #return "#{t}" 
          }
          nil
        else
          #puts "No type for #{klass_pref}#{meth}"
        end
      else
        #puts "Not implemented"
      end
    }
  end

