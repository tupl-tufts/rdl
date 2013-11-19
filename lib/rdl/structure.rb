require 'rdl'
require 'set'

class NilClass
  def cls
    NilClass
  end

  def name
    "nil_name"
  end
end


class RDL::MethodID
  attr_reader :cls
  attr_reader :method

  def initialize(cls, method)
    @cls = cls
    @method = method
  end

  def ==(other)
    @cls == other.cls and @method == other.method
  end

  def eql?(other)
    @cls.eql?(other.cls) and @method.eql?(other.method)
  end

  def hash
    @cls.hash + @method.hash
  end

  def to_s
    "#{@cls} #{@method}"
  end

  def match(*args)
    self.to_s.match(*args)
  end

  def gsub(*args)
    self.to_s.gsub(*args)
  end
end


class RDL::Method
  attr_accessor :cls
  attr_accessor :name
  attr_accessor :sid
  attr_accessor :parent_sid

  def initialize(cls, name, sid, parent_sid)
    @cls = cls
    @name = name
    @sid = sid
    @parent_sid = parent_sid
  end
end

class RDL::Lang
  attr_accessor :methods
  attr_accessor :orders

  def initialize(methods, orders, edges = nil)
    @methods = methods
    @orders = orders
    @edges = edges
  end
end

module RDL::Structure
 class << self
    attr_accessor :lang_call_map
    attr_accessor :sid_method_map
    attr_accessor :call_stack
    attr_accessor :langs
    attr_accessor :top_id
    attr_accessor :orders
    attr_accessor :lang_map
    attr_accessor :descendant_map
    attr_accessor :call_map
    attr_accessor :all_calls
  end

  def self.get_lang_info
    lang_info = {}

    orders.each {|entry_sid, order_sids|
      entry_info = sid_method_map[entry_sid]
      order_info = order_sids.map {|x| sid_method_map[x]}
      order_names = order_info.map {|x| x.name} 
      lang_name = order_info[0].cls
      lang_info[lang_name] = {} if not lang_info.keys.include?(lang_name)
      entry = {:class => entry_info.cls, :name => entry_info.name}
      lang_info[lang_name][entry] = {} if not lang_info[lang_name].keys.include?(entry)
      lang_info[lang_name][entry][:methods] = Set.new if not lang_info[lang_name][entry].keys.include?(:methods)
      lang_info[lang_name][entry][:orders] = Set.new if not lang_info[lang_name][entry].keys.include?(:orders)
      methods = order_info.map {|x| x.name}
      orders = order_names.to_edge_array
      lang_info[lang_name][entry][:methods] = lang_info[lang_name][entry][:methods] + methods
      lang_info[lang_name][entry][:orders] = lang_info[lang_name][entry][:orders] + orders
    }

    lang_info.each {|k, v|
      lang_methods = Set.new
      v.each {|k2, v2|
        lang_methods = lang_methods + v2[:methods]
      }

      v.each {|k2, v2|
        lang_info[k][k2][:lang_methods] = lang_methods
      }

#      lang_info[k][:lang_methods] = lang_methods
    }

    lang_info
  end

  # this is good enough for routing, but needs to be fixed later, only 3  levels

  def self.is_ancestor?(sid1, sid2)
    sid2_p = sid_method_map[sid2].parent_sid

    while sid2_p do
      return true if sid1 == sid2_p
      sid2_p = sid_method_map[sid2_p].parent_sid
    end

    false
  end

=begin
  def self.is_ancestor?(sid1, sid2)
    sid2_parent_id = sid_method_map[sid2].parent_sid
    return true if sid1 == sid2_parent_id
   
    if sid2_parent_id
      sid2_parent_id_2 = sid_method_map[sid2_parent_id].parent_sid
      return true if sid1 == sid2_parent_id_2

      if sid2_parent_id_2
        sid2_parent_id_3 = sid_method_map[sid2_parent_id_2].parent_sid
        return true if sid1 == sid2_parent_id_3
      end
    end

    false
  end
=end

  def self.write_test2(outfile)
    missing_stmt_map = get_missing_nested_stmts

    f = File.open(outfile, 'w')

    missing_stmt_map.each {|k, v|
      v.each {|v|
        k_info = "#{sid_method_map[k].cls} #{sid_method_map[k].name}"
        v_info = "#{sid_method_map[v].cls} #{sid_method_map[v].name}"
        f.write("#{k}|#{v}|#{k_info}|#{v_info}\n")
      }
    }

    f.close
  end

  def self.get_missing_nested_stmts
    lang_call_map = {}
    observed_parent_call_map = {}
    observed_parent_call_map_simple = {}
    observed_parent_call_cls_map = {}
    missing_stmt_map = {}

    all_calls.each {|c|
      lang_call_map[c.cls] ||= Set.new
      lang_call_map[c.cls].add(c.name)

      p = sid_method_map[c.parent_sid]
      p_name = RDL::MethodID.new(p.cls, p.name)
      
      observed_parent_call_map[p_name] ||= Set.new
      observed_parent_call_map[p_name].add c
    }

    observed_parent_call_map.each {|k, v|
      observed_parent_call_cls_map[k] ||= Set.new
      observed_parent_call_map_simple[k] ||= Set.new

      v.each {|i|
        observed_parent_call_cls_map[k].add(i.cls)
        observed_parent_call_map_simple[k].add(i.name)
      }
    }

    classes = Set.new
    class_inheritance_map = {}

    observed_parent_call_cls_map.each {|k, v|
      v.each {|i|
        classes.add(i)
      }
    }

    classes.each {|c1|
      class_inheritance_map[c1] = Set.new [c1]

      classes.each {|c2|
        if inherits_from?(c1, c2) or share_methods?(c1, c2)
          class_inheritance_map[c1].add(c2)
        end
      }
    }

    full_parent_call_cls_map = {}

    observed_parent_call_cls_map.each {|k, v|
      full_parent_call_cls_map[k] = Set.new

      v.each {|i|
        class_inheritance_map[i].each {|j|
          full_parent_call_cls_map[k].add(j)
        }
      }
    }

    full_lang_call_map = {}

    full_parent_call_cls_map.each {|k, v|
      full_lang_call_map[k] = Set.new


      v.each {|i|
        lang_call_map[i].each {|j|
          full_lang_call_map[k].add(j)
        }
      }
    }

    missing_method_map = {}

    observed_parent_call_map.each {|k, v|
      method_names = v.map {|i| i.name}
      observed_method_names = Set.new method_names
      all_method_names = full_lang_call_map[k]
      missing_method_names = all_method_names - observed_method_names

      missing_method_map[k] = missing_method_names
      #puts "K = #{k.inspect}"
      #puts "observed = #{observed_method_names.inspect}"
      #puts "all = #{all_method_names.inspect}"
      #puts "miss = #{missing_method_names.inspect}"
    }

    all_call_map = {}
    all_call_map2 = {}

    all_calls.each {|c|
      m = RDL::MethodID.new(c.cls, c.name)
      all_call_map[m] ||= Set.new
      all_call_map[m].add(c)

      all_call_map2[c.name] ||= Set.new
      all_call_map2[c.name].add(c)
    }


    missing_method_map.each {|k, v|
      v.each {|i|
        parent = all_call_map[k]
        parent = [] if not parent

        all_call_map2[i].each {|j|
          candidate_cls = j.cls

          if full_parent_call_cls_map[k].include?(candidate_cls)
            parent.each {|p|
              #puts "Adding stmt #{j.sid} to parent #{p.sid}"
              missing_stmt_map[p.sid] ||= Set.new
              missing_stmt_map[p.sid].add(j.sid)
            }
          end
        }
      }
    }

    missing_stmt_map
  end

  def self.write_test_info(outfile)
    fo = File.open(outfile, 'w')

    lang_call_map.each {|k, v|
      #puts "K = #{k}    V = #{v.inspect}"
      #puts v.map {|x| sid_method_map[x].inspect}
      #puts "-----------------------------------"

      v.each {|v1|
        v1_psid = sid_method_map[v1].parent_sid
        v1_p_info = sid_method_map[v1_psid]
        v1_p = RDL::MethodID.new(v1_p_info.cls, v1_p_info.name)
        v1_name = sid_method_map[v1].name

        v.each {|v2|
          v2_psid = sid_method_map[v2].parent_sid
          v2_p_info = sid_method_map[v2_psid]
          v2_p = RDL::MethodID.new(v2_p_info.cls, v2_p_info.name)
          v2_name = sid_method_map[v2].name

          if v1 == v2
            fo.write "#{v1}|#{v2}|#{k}|#{v1_name}|#{v2_name}|#{v1_p}|#{v2_p}|copy1\n"
          else
            fo.write "#{v1}|#{v2}|#{k}|#{v1_name}|#{v2_name}|#{v1_p}|#{v2_p}|copy1\n"
            fo.write "#{v1}|#{v2}|#{k}|#{v1_name}|#{v2_name}|#{v1_p}|#{v2_p}|copy2\n"

            if is_ancestor?(v1, v2)
              fo.write "#{v1}|#{v2}|#{k}|#{v1_name}|#{v2_name}|#{v1_p}|#{v2_p}|move2\n"
            elsif is_ancestor?(v2, v1)
              fo.write "#{v1}|#{v2}|#{k}|#{v1_name}|#{v2_name}|#{v1_p}|#{v2_p}|move1\n"
            else
              fo.write "#{v1}|#{v2}|#{k}|#{v1_name}|#{v2_name}|#{v1_p}|#{v2_p}|move1\n"
              fo.write "#{v1}|#{v2}|#{k}|#{v1_name}|#{v2_name}|#{v1_p}|#{v2_p}|move2\n"
            end
          end

=begin
          if (v1 != v2) 
            if is_ancestor?(v1, v2)
              puts "EXCLUDE #{v1}|#{v2}|move1"
            elsif is_ancestor?(v2, v1)
              puts "EXCLUDE #{v1}|#{v2}|move2"
            end
          end

          fo.write "#{v1}|#{v2}|#{k}|#{v1_name}|#{v2_name}|#{v1_p}|#{v2_p}\n"
=end          
        }
      }
    }

    fo.close
  end

  def self.write_lang_info(outdir)
    if not File.exists?(outdir)
      raise Exception, "output directory #{outdir} is invalid"
    end

    counter = 0
    lang_info = get_lang_info

    lang_info.each {|lang_name, v|
      v.each {|k2, v2|
        counter = counter + 1
        filename = outdir + File::SEPARATOR + "lang" + counter.to_s + ".txt"
        f = File.open(filename, 'w')

        methods = v2[:methods].map {|x| x.to_s}.join(' ')
        lang_methods = v2[:lang_methods].map {|x| x.to_s}.join(' ')

        f.write "lang: #{lang_name}\n"
        f.write "entry_method: #{k2[:class]} #{k2[:name]}\n"
        f.write "methods: #{methods}\n"
        f.write "lang_methods: #{lang_methods}\n"

        o = v2[:orders].each {|e0, e1|
          f.write "edge: #{e0.to_s} #{e1.to_s}\n"
        }

        f.close
      }
    }
  end

  def self.get_descendant_map
    sid_method_map.each {|sid, method_info|
      parent_sid = method_info.sid
      descendant_map[parent_sid] = Set.new if not descendant_map.keys.include?(parent_sid)
      descendant_map[parent_sid].add(sid)
    }
  end

  def self.get_missing_edges(observed_orders, method_names)
    observed_edges = Set.new

    observed_orders.each {|o|
      o_edges = o.to_edge_array
      o_edges = o_edges.select {|x| x.size == 2}
      o_edges.each {|x| observed_edges.add(x)}
    }

    possible_edges = method_names.product(method_names)
    #possible_edges = possible_edges.select {|x| x[0] != x[1]}
    possible_edges - observed_edges.to_a
  end

  def self.get_intra_edges(e, parent)
    edges = []

    orders.each {|k, v|
      k_info = sid_method_map[k]
      if k_info.cls == parent.cls and k_info.name == parent.method
        e0s = v.select {|x| sid_method_map[x].name == e[0]}
        e1s = v.select {|x| sid_method_map[x].name == e[1]}

        if e0s.size > 0 and e1s.size > 0
          first_e0 = e0s[0]
          first_e1 = e1s[0]
          b = e0s.select {|x| sid_method_map[x].sid < first_e1}
          
          if b.size > 0
            edges.push([b[-1], first_e1])

          else
            edges.push([first_e0, first_e1])
          end
        end
      end
    }

    edges
  end

  def self.get_inter_edges(e, parent, cls, name_method_map, intra_edges)
    edges = []
    e0m = RDL::MethodID.new(cls, e[0])
    e1m = RDL::MethodID.new(cls, e[1])

    intra_edge_set = Set.new
    
    intra_edges.each {|e0, e1|
      e0_name = sid_method_map[e0].name
      e1_name = sid_method_map[e1].name
      intra_edge_set.add([e0_name, e1_name])
    }

    e0ms = name_method_map[e0m].select {|x| 
      p = sid_method_map[x.parent_sid]            
      RDL::MethodID.new(p.cls, p.name) == parent
    }
    
    e1ms = name_method_map[e1m].select {|x| 
      p = sid_method_map[x.parent_sid]            
      RDL::MethodID.new(p.cls, p.name) == parent
    }
    
    e1ms.each {|e1|
      e0ms.each {|e0|
        if e0.parent_sid != e1.parent_sid and not intra_edge_set.include?([e0.name, e1.name])
          edges.push([e0.sid, e1.sid])
        end
      }
    }

    edges
  end

  def self.get_inter2_edges(missing_methods_from_lang, parent, cls, name_method_map)
    first_method = nil
    edges = []

    orders.each {|k, v|
      v0 = sid_method_map[v[0]]
      if v0.cls == cls 
        pi = sid_method_map[v0.parent_sid]
            
        if pi.cls == parent.cls and pi.name == parent.method
          first_method = v0
          break
        end
      end
    }

    missing_methods_from_lang.each {|m|
      m = RDL::MethodID.new(cls, m)
      m = name_method_map[m][0]

      #xpi = sid_method_map[first_method.parent_sid]
      #xp = RDL::MethodID.new(xpi.cls, xpi.name)

      #f.write "#{cls}|#{xp}|#{first_method.name}|#{m.name}|#{first_method.sid}|#{m.sid}|inter2\n"
      edges.push([first_method, m])
    }

    edges
  end


  def self.get_inter2_edges_move_all(inter2_edges)
    e0 = inter2_edges[0][0]
    e1 = inter2_edges.map {|e| e[1]}
    [e0, e1]
  end

#  def self.get_lang_orders
  def self.write_test_gen_inputs(filename)

    lang_order_map = {}
    lang_method_sid_map = {}
    lang_method_name_map = {}
    method_name_sid_map = {}
    name_method_map = {}

    sid_method_map.each {|k, x|
      new_key = RDL::MethodID.new(x.cls, x.name)
      name_method_map[new_key] = [] if not name_method_map.keys.include?(new_key)
      name_method_map[new_key].push(x)
    }

    observed_structures = {}

    orders.map {|k, v|
      observed_structures[sid_method_map[k]] = v.map {|x| sid_method_map[x]}
    }

    observed_structures.each {|parent, order|
      cls = order[0].cls
      lang_order_map[cls] = [] if not lang_order_map.keys.include?(cls)
      lang_order_map[cls].push(order)
    }

    f = File.open(filename, 'w')

    lang_order_map.each {|cls, lang_orders|
      entry_method_orders = {}
      entry_method_orders_simple = {}
      all_lang_methods = Set.new

      lang_orders.each {|o|
        parent_info = sid_method_map[o[0].parent_sid]
        entry_method = RDL::MethodID.new(parent_info.cls, parent_info.name)
        entry_method_orders[entry_method] = [] if not entry_method_orders.keys.include?(entry_method)
        entry_method_orders[entry_method].push(o)
        entry_method_orders_simple[entry_method] = Set.new if not entry_method_orders_simple.keys.include?(entry_method)
        o_simple = o.map {|x| x.name}
        all_lang_methods = all_lang_methods + o_simple
        entry_method_orders_simple[entry_method].add(o_simple)
      }

      entry_method_orders_simple.each {|parent, p_orders|
        blk_methods = Set.new(p_orders.to_a.flatten)
        missing_edges = get_missing_edges(p_orders.to_a, blk_methods.to_a)
        missing_methods_from_lang = all_lang_methods - blk_methods


        missing_edges.each {|e|
          # puts "    missing_edge #{e.inspect}"

          #puts "LANG = #{cls}  parent = #{parent.inspect}"
          intra_edges = get_intra_edges(e, parent)
          intra_edges.each {|x|
            f.write "#{cls}|#{parent}|#{e[0]}|#{e[1]}|#{x[0]}|#{x[1]}|intra\n"
          }
          #puts intra_edges.inspect

          inter_edges = get_inter_edges(e, parent, cls, name_method_map, intra_edges)

          inter_edges.each {|x|
            f.write "#{cls}|#{parent}|#{e[0]}|#{e[1]}|#{x[0]}|#{x[1]}|inter\n"
          }
        }

        # FROM OTHER

        inter2_edges = get_inter2_edges(missing_methods_from_lang, parent, cls, name_method_map)

        inter2_edges.each {|e|
          xpi = sid_method_map[e[0].parent_sid]
          xp = RDL::MethodID.new(xpi.cls, xpi.name)
          f.write "#{cls}|#{xp}|#{e[0].name}|#{e[1].name}|#{e[0].sid}|#{e[1].sid}|inter2\n"
        }

        if not inter2_edges.empty?
          inter2_edges_move_all = get_inter2_edges_move_all(inter2_edges)
        end
        
=begin
        first_methods = []

        orders.each {|k, v|
          v0 = sid_method_map[v[0]]
          if v0.cls == cls 
            pi = sid_method_map[v0.parent_sid]
            
            if pi.cls == parent.cls and pi.name == parent.method
              first_methods.push(v0)
            end
          end
        }

        missing_methods_from_lang.each {|m|
          m = RDL::MethodID.new(cls, m)
          ms = name_method_map[m]
          
          ms.each {|x|

            first_methods.each {|y|
              xpi = sid_method_map[y.parent_sid]
              xp = RDL::MethodID.new(xpi.cls, xpi.name)
              #xp = RDL::MethodID.new(x.cls, x.name)

              if x.sid != y.sid
                 f.write "#{cls}|#{xp}|#{x.name}|#{y.name}|#{x.sid}|#{y.sid}|inter2\n"
              end
            }
          }
        }

=end

      }
    }

    f.close
  end
end

class Array
  def to_edge_array
    s = self.clone
    x = s.each_slice(2).to_a
    s.shift

    if s
      y = s.each_slice(2).to_a
    else
      y = []
    end

    r = x + y
    #r.select! {|x| x.size == 2}
    r = r.select {|x| x.size == 2}
  end
end

class Object
  def inherits_from?(s, d)
    s < d
  end

  def share_methods?(s, d)
    #return false if d.ancestors.include?(s)

    #return false if s == d
    
    i = s.ancestors & d.ancestors

    [Class, Module, Object, Kernel, BasicObject].each {|c|
      i.delete(c)
    }

#    if i.empty?
#      puts "S = #{s.inspect}   D = #{d.inspect}"
#    end

    not i.empty?
  end
  
  def get_class
    if self.class == Class or self.class == Module
      class << self ; self ; end
    else
      self.class
    end
  end

  def dsl_log_entry(fun, sid, target, *args, &blk)
    r = dsl_log(fun, sid, target, *args, &blk)

    c  = get_class
    p = nil
    fun = fun.to_sym
    m = RDL::Method.new(c, fun, sid, p)
    RDL::Structure.all_calls = [] if not RDL::Structure.all_calls
    RDL::Structure.all_calls.push(m)

    r
  end
  
  def dsl_log(fun, sid, target, *args, &blk)
    RDL::Structure.call_stack = [] if not RDL::Structure.call_stack
    RDL::Structure.orders = {} if not RDL::Structure.orders
    RDL::Structure.sid_method_map = {} if not RDL::Structure.sid_method_map
    RDL::Structure.lang_call_map = {} if not RDL::Structure.lang_call_map

    fun = fun.to_sym
    p = RDL::Structure.call_stack[-1]

    if ($top_id == self.object_id) and (p and target == 0)
      c  = get_class

      #if c.instance_methods.include?(fun)  or self.methods.include?(fun)
      if self.methods.include?(fun)
      #if c.instance_methods.include?(fun)  

        m = RDL::Method.new(c, fun, sid, p)

        RDL::Structure.sid_method_map[sid] = m

        if p
          RDL::Structure.lang_call_map[c] = Set.new if not RDL::Structure.lang_call_map.keys.include?(c)
          RDL::Structure.lang_call_map[c].add(sid)

          if not RDL::Structure.orders.keys.include?(p)
            RDL::Structure.orders[p] = []
          end
          
#puts "PUSHING S #{fun}"
          RDL::Structure.orders[p].push(sid)
        end

        RDL::Structure.call_stack.push(sid)
        r = self.send(fun, *args, &blk)

        k = RDL::MethodID.new(m.cls, m.name)
        RDL::Structure.call_map ||= {}
        RDL::Structure.call_map[m.cls] ||= {}
        RDL::Structure.call_map[m.cls][k] = m
#        RDL::Structure.call_map[k] = m

        RDL::Structure.all_calls = [] if not RDL::Structure.all_calls
        RDL::Structure.all_calls.push(m)

#puts "POP S #{fun}"
        RDL::Structure.call_stack.pop
      else
        r = self.send(fun, *args, &blk)
      end
    # elsif ($top_id != self.object_id) and (target == 1 and not p)
    elsif (not p)
#puts "**************** #{fun}"
      c = get_class
      m = RDL::Method.new(c, fun, sid, p)

      RDL::Structure.sid_method_map[sid] = m
#puts "PUSHING S #{fun}"
      RDL::Structure.call_stack.push(sid)

      r = self.send(fun, *args, &blk)

#puts "POP S #{fun}"
      RDL::Structure.call_stack.pop
    else
      r = self.send(fun, *args, &blk)
    end

    r
  end
end
