require 'bigdecimal'
require 'rdl'
require 'types/core'

## This file contains tests for the Numeric method types specified in lib/types/core-ruby-2.x/.
## Each method test_x will generate a random Numeric object and call the method :x on that object,
## checking to ensure that the returned type matches the type specified in the corresponding type
## file. In order to run a particular test multiple times, call the "rounds" method with that test
## and the number of rounds you wish to run it as arguments. For example, to run the "test_mod"
## test 100 times, call TypeTest.rounds(:test_mod, 100). 

MAX_FIXNUM = 2**(0.size*8-2)-1 #Largest fixnum. -2 since 1 bit used for sign, 1 bit used as int marker.
MIN_FIXNUM = -(2**(0.size*8-2)) #Smallest fixnum.

class TypeTest

  def self.test_mod()
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
    operation_type, bind = query(type_one+'#%',x,y)
    w = x%y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_and()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    y = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_two = y.class.to_s
    operation_type, bind = query(type_one+'#&',x,y)
    w = x&y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_add()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    if type_one=="BigDecimal"
      y = gen_number(0.25,0.25,0.2,0,0,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Float)&&(x==Float::INFINITY|| x.nan?)
      y = gen_number(0.2,0.2,0,0.1,0.1,0.3,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Complex)
      y = gen_number(0.3,0.3,0,0,0,0.3,0,0.1)
      type_two = y.class.to_s
    else
      y = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
      type_two = y.class.to_s
    end
    operation_type, bind = query(type_one+'#+',x,y)
    w = x+y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_sub()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    if type_one=="BigDecimal"
      y = gen_number(0.25,0.25,0.2,0,0,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Float)&&(x==Float::INFINITY|| x.nan?)
      y = gen_number(0.2,0.2,0,0.1,0.1,0.3,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Complex)
      y = gen_number(0.3,0.3,0,0,0,0.3,0,0.1)
      type_two = y.class.to_s
    else
      y = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
      type_two = y.class.to_s
    end
    operation_type, bind = query(type_one+'#-',x,y)
    w = x-y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_ones_comp()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#~',x,nil)
    w = ~x
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_mult()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    if type_one=="BigDecimal"
      y = gen_number(0.25,0.25,0.2,0,0,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Float)&&(x==Float::INFINITY|| x.nan?)
      y = gen_number(0.25,0.25,0,0.1,0.1,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Complex)
      y = gen_number(0.3,0.3,0,0,0,0.3,0,0.1)
      type_two = y.class.to_s
    else
      y = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
      type_two = y.class.to_s
    end
    operation_type, bind = query(type_one+'#*',x,y)
    w = x*y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_lt()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0,0.2)
    type_one = x.class.to_s
    if type_one=="BigDecimal"
      y = gen_number(0.25,0.25,0.2,0,0,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Float)&&(x==Float::INFINITY|| x.nan?)
      y = gen_number(0.2,0.2,0,0.1,0.1,0.3,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Rational)
      y = gen_number(0.2,0.2,0,0.1,0,0.3,0,0.2)
      type_two = y.class.to_s
    else
      y = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0,0.2)
      type_two = y.class.to_s
    end
    operation_type, bind = query(type_one+'#<',x,y)
    w = x<y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end
  
  def self.test_pow()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    if x.is_a?(Float)&&(x==Float::INFINITY|| x.nan?)
      y = gen_number(0.25,0.25,0,0.1,0.1,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Complex)
      y = gen_number(0.3,0.3,0,0,0,0.3,0,0.1)
      type_two = y.class.to_s
    elsif type_one=="BigDecimal"
      if x<0
	y = gen_number(0.25,0.25,0.2,0,0,0.3,0,0,true)
	type_two = y.class.to_s
      else
	y = gen_number(0.25,0.25,0.2,0,0,0.2,0,0.1)
	type_two = y.class.to_s
      end
    elsif x<0
      y = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1,true)
      type_two = y.class.to_s
    else
      y = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1,true)
      type_two = y.class.to_s
    end
    operation_type, bind = query(type_one+'#**',x,y)
    w = x**y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_shiftl()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    y = Random.rand(-1000000000..1000000000)
    type_two = y.class.to_s
    operation_type, bind = query(type_one+'#<<',x,y)
    w = x << y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_shiftr()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    y = Random.rand(-1000000000..1000000000)
    type_two = y.class.to_s
    operation_type, bind = query(type_one+'#>>',x,y)
    w = x >> y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_bitref()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    if (x.is_a?(Bignum))
      y = gen_number(0.4,0.4,0,0,0,0,0,0.2)
    else
      y = gen_number(0.2,0.2,0.2,0,0,0.2,0,0.2)
    end
    type_two = y.class.to_s
    operation_type,bind = query(type_one+'#[]',x,y)
    w = x[y]
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_xor()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    y = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_two = y.class.to_s
    operation_type,bind = query(type_one+'#^',x,y)
    w = x^y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_abs()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#abs',x,nil)
    w = x.abs
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_abs2()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#abs2',x,nil)
    w = x.abs
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_angle()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#angle',x,nil)
    w = x.angle
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_arg()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#arg',x,nil)
    w = x.arg
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_bitlength()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#bit_length',x,nil)
    w = x.bit_length
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_ceil()
    x = gen_number(0.2,0.2,0.2,0,0,0.2,0,0.2)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#ceil',x,nil)
    w = x.ceil
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_ceil_rational()
    x = gen_number(0,0,0,0,0,0,0,1)
    type_one = x.class.to_s
    y = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_two = y.class.to_s
    operation_type,bind = query(type_one+'#ceil',x,y)
    w = x.ceil(y)
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_conj()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#conj',x,nil)
    w = x.conj
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_denominator()
    x = gen_number(0.2,0.2,0.1,0,0,0.2,0.1,0.2)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#denominator',x,nil)
    w = x.denominator
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end
  
  def self.test_div()
    x = gen_number(0.2,0.2,0.2,0,0,0.2,0,0.2)
    type_one = x.class.to_s
    if type_one=="Float"
      y = gen_number(0.3,0.3,0.2,0,0,0.2,0,0)
    else
      y = gen_number(0.2,0.2,0.2,0,0,0.2,0,0.2)
    end
    type_two = y.class.to_s
    operation_type,bind = query(type_one+'#div',x,y)
    w = x.div(y)
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_divslash()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    if type_one=="BigDecimal"
      y = gen_number(0.25,0.25,0.2,0,0,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Float)&&(x==Float::INFINITY|| x.nan?)
      y = gen_number(0.25,0.25,0,0.1,0.1,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Complex)
      y = gen_number(0.3,0.3,0,0,0,0.3,0,0.1)
      type_two = y.class.to_s
    else
      y = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
      type_two = y.class.to_s
    end
    operation_type,bind = query(type_one+'#/',x,y)
    w = x/y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_even?()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#even?',x,nil)
    w = x.even?
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_finite?()
    x = gen_number(0,0,0.5,0.05,0.05,0.4,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#finite?',x,nil)
    w = x.finite?
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_floor()
    x = gen_number(0.2,0.2,0.2,0,0,0.2,0,0.2)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#floor',x,nil)
    w = x.floor
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_floor_rational()
    x = gen_number(0,0,0,0,0,0,0,1)
    type_one = x.class.to_s
    y = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_two = y.class.to_s
    operation_type,bind = query(type_one+'#floor',x,y)
    w = x.floor(y)
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_hash()
    x = gen_number(0.2,0.2,0.1,0.1,0.1,0.1,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#hash',x,nil)
    w = x.hash
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_imag()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#imag',x,nil)
    w = x.imag
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  
  def self.test_infinite?()
    x = gen_number(0,0,0.5,0.05,0.05,0.4,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#infinite?',x,nil)
    w = x.infinite?
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_modulo()
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
    operation_type,bind = query(type_one+'#modulo',x,y)
    w = x.modulo(y)
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_nan?()
    x = gen_number(0,0,0.5,0.05,0.05,0.4,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#nan?',x,nil)
    w = x.nan?
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_neg()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#-',x,nil)
    w = -x
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_next()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#next',x,nil)
    w = x.next
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_next_float()
    x = gen_number(0,0,0,0.05,0.05,0.9,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#next_float',x,nil)
    w = x.next_float
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_numerator()
    x = gen_number(0.2,0.2,0.1,0,0,0.2,0.1,0.2)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#numerator',x,nil)
    w = x.numerator
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_phase()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#phase',x,nil)
    w = x.phase
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_prevfloat()
    x = gen_number(0,0,0,0.05,0.05,0.9,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#prev_float',x,nil)
    w = x.prev_float
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_quo()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    if type_one=="BigDecimal"
      y = gen_number(0.25,0.25,0.2,0,0,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Float)&&(x==Float::INFINITY|| x.nan?)
      y = gen_number(0.25,0.25,0,0.1,0.1,0.2,0,0.1)
      type_two = y.class.to_s
    elsif x.is_a?(Complex)
      y = gen_number(0.3,0.3,0,0,0,0.3,0,0.1)
      type_two = y.class.to_s
    else
      y = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
      type_two = y.class.to_s
    end
    operation_type,bind = query(type_one+'#quo',x,y)
    w = x.quo(y)
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_rationalize()
    x = gen_number(0.2,0.2,0,0,0,0.2,0.2,0.2)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#rationalize',x,nil)
    w = x.rationalize
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_rationalize_arg()
    x = gen_number(0.2,0.2,0,0,0,0.2,0.2,0.2)
    type_one = x.class.to_s
    if x.is_a?(Rational) || x.is_a?(Float) || x.is_a?(Complex)
      y = gen_number(0.2,0.2,0,0,0,0.2,0.2,0.2)
    else
      y = gen_number2(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    end
    type_two = y.class.to_s
    operation_type,bind = query(type_one+'#rationalize',x,y)
    w = x.rationalize(y)
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_real()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#real',x,nil)
    w = x.real
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_real?()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#real?',x,nil)
    w = x.real?
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  def self.test_round()
    x = gen_number(0.2,0.2,0.2,0,0,0.2,0,0.2)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#round',x,nil)
    w = x.round
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  def self.test_round_arg()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0,0.2)
    type_one = x.class.to_s
    if type_one=="BigDecimal"
      y = gen_number(1,0,0,0,0,0,0,0)
      type_two = y.class.to_s
    elsif x.is_a?(Rational)
      y = gen_number(0.5,0.5,0,0,0,0,0,0)
      type_two = y.class.to_s
    else
      y = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0,0.2)
      type_two = y.class.to_s
    end
    operation_type,bind = query(type_one+'#round',x,y)
    w = x.round(y)
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end

  def self.test_size()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#size',x,nil)
    w = x.size
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  def self.test_to_c()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#to_c',x,nil)
    w = x.to_c
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  def self.test_to_f()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1,false,true)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#to_f',x,nil)
    w = x.to_f
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  
  def self.test_to_i()
    x = gen_number(0.2,0.2,0.1,0,0,0.2,0.2,0.1,false,true,true)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#to_i',x,nil)
    w = x.to_i
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  def self.test_to_r()
    x = gen_number(0.2,0.2,0.1,0,0,0.2,0.2,0.1,false,true,true)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#to_r',x,nil)
    w = x.to_r
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  
  def self.test_to_s()
    x = gen_number(0.2,0.2,0.1,0.1,0.1,0.1,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#to_s',x,nil)
    w = x.to_s
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  def self.test_truncate()
    x = gen_number(0.2,0.2,0.2,0,0,0.2,0,0.2)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#truncate',x,nil)
    w = x.truncate
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  def self.test_zero?()
    x = gen_number(0.2,0.2,0.1,0.05,0.05,0.2,0.1,0.1)
    type_one = x.class.to_s
    operation_type,bind = query(type_one+'#zero?',x,nil)
    w = x.zero?
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, nil)
    print_error(x, nil, type_one, nil, operation_type.ret, new_ret) if !test_result    
    return test_result
  end

  def self.test_bitor()
    x = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_one = x.class.to_s
    y = gen_number(0.5,0.5,0,0,0,0,0,0)
    type_two = y.class.to_s
    operation_type,bind = query(type_one+'#|',x,y)
    w = x|y
    test_result,new_ret = operation_type.post_cond?(x, true, w, bind, y)
    print_error(x, y, type_one, type_two, operation_type.ret, new_ret) if !test_result
    return test_result
  end
  
  def self.print_error(arg1, arg2, type_one, type_two, extype, rec)
    puts "First argument was #{arg1} (type: #{type_one})"
    puts "Second argument was #{arg2} (type: #{type_two})" if arg2
    puts "Result was #{rec}"
    puts "Expected result type: #{extype}"
    puts "Received result type: #{rec.class}"
  end
  
  def self.gen_fixnum()
    return Random.rand(MIN_FIXNUM..MAX_FIXNUM)
  end

  def self.gen_bignum()
    r = Random.rand()
    if r<0.5
      return Random.rand(MAX_FIXNUM+1..MAX_FIXNUM*1000)
    else
      return -1*Random.rand(MAX_FIXNUM+1..MAX_FIXNUM*1000)
    end
  end

  def self.gen_float(pos=false)
    #return Float::MAX*Random.rand if pos
    return 2**32*Random.rand if pos
    r = Random.rand()
    if r<0.5
      return Float::MAX*Random.rand
    else
      return -1*Float::MAX*Random.rand
    end
  end

  def self.gen_bigdec()
    r = Random.rand()
    if r<0.33
      return BigDecimal.new(gen_fixnum())
    elsif r<0.66
      return BigDecimal.new(gen_bignum())
    else
      return BigDecimal.new(gen_float(),0)
    end
  end

  def self.gen_complex(real=false,nonin=false)
    if nonin
      x = gen_number(0.25,0.25,0.1,0,0,0.3,0,0.1)
    else
      x = gen_number(0.2,0.2,0.1,0.05,0.05,0.3,0,0.1)
    end
    return Complex(x,0) if real
    y = gen_number(0.2,0.2,0.1,0.05,0.05,0.3,0,0.1)
    return Complex(x,y)
  end

  def self.gen_rational()
    x = gen_fixnum()
    y = gen_fixnum()
    return Rational(x,y)
  end


  def self.gen_number(probFixnum,probBignum,probBigDec,probInf,probNAN,probFloat,probComplex,probRational,posfloat=false,real=false,noninfnan=false)
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
      x = gen_float(posfloat)
    elsif r<(probFixnum+probBignum+probBigDec+probInf+probNAN+probFloat+probComplex)
      x= gen_complex(real,noninfnan)
    elsif (probFixnum+probBignum+probBigDec+probInf+probNAN+probFloat+probComplex+probRational)
      x = gen_rational()
    end
    return x
  end

  def self.rounds(meth, num)
    counter = 0
    for i in 0..num
      b = send(meth)
      counter=counter+1 if !b
    end
    return counter
  end


  def self.query(q,x,y)
    RDL.contract_switch.off {
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
        if RDL.info.has?(klass, meth, :type)
          typs = RDL.info.get(klass, meth, :type)
          typs.each { |t|
            return [t, x.get_binding] if y.nil?
            res, args, blk, bind = t.pre_cond?(blk, x, true, x.get_binding, y)
	    return [t, bind] if res
          }
        end
        raise TypeError, "Method #{q} for argument type #{y.class} not found."
      else
        puts "Not implemented"
      end
    }
  end

end

class Fixnum
  
  def get_binding()
    return binding
  end
  
end

class Bignum
  
  def get_binding()
    return binding
  end
  
end

class Rational
  
  def get_binding
    return binding
  end

end

class BigDecimal

  def get_binding
    return binding
  end

end

class Float

  def get_binding
    return binding
  end

end

class Complex

  def get_binding
    return binding
  end

end
