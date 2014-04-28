require 'set'
require 'rdl'

class Set
  extend RDL

  spec :& do
    pre_task do |arg|
      $set_amp_old_self = [] if not $set_amp_old_self
      $set_amp_arg = [] if not $set_amp_arg
      $set_amp_old_self.push self.dup
      $set_amp_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_amp_old_self.pop
           arg = $set_amp_arg.pop

           r.all? {|i| old_self.include?(i) && old_self.include?(i)} &&
           old_self.size >= r.size && arg.size >= r.size 
         })
  end

  spec :+ do
    pre_task do |arg|
      $set_plus_old_self = [] if not $set_plus_old_self
      $set_plus_arg = [] if not $set_plus_arg
      $set_plus_old_self.push self.dup
      $set_plus_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_plus_old_self.pop
           arg = $set_plus_arg.pop

           r.all? {|i| old_self.include?(i) || arg.include?(i)} &&
           old_self.size <= r.size && arg.size <= r.size 
         })
  end

  spec :- do
    pre_task do |arg|
      $set_sub_old_self = [] if not $set_sub_old_self
      $set_sub_arg = [] if not $set_sub_arg
      $set_sub_old_self.push self.dup
      $set_sub_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_sub_old_self.pop
           arg = $set_sub_arg.pop

           r.all? {|i| old_self.include?(i)} &&
           old_self.size >= r.size 
         })
  end

  spec :^ do
    pre_task do |arg|
      $set_caret_old_self = [] if not $set_caret_old_self
      $set_caret_arg = [] if not $set_caret_arg
      $set_caret_old_self.push self.dup
      $set_caret_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_caret_old_self.pop
           arg = $set_caret_arg.pop

           r.all? {|i| old_self.include?(i) ^ arg.include?(i)} 
         })
  end

  spec :merge do
    pre_task do |arg|
      $set_merge_old_self = [] if not $set_merge_old_self
      $set_merge_arg = [] if not $set_merge_arg
      $set_merge_old_self.push self.dup
      $set_merge_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_merge_old_self.pop
           arg = $set_merge_arg.pop

           r.all? {|i| old_self.include?(i) || arg.include?(i)} &&
           old_self.size <= r.size && arg.size <= r.size
         })
  end

  spec :replace do
    pre_task do |arg|
      $set_replace_old_self = [] if not $set_replace_old_self
      $set_replace_arg = [] if not $set_replace_arg
      $set_replace_old_self.push self.dup
      $set_replace_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_replace_old_self.pop
           arg = $set_replace_arg.pop

           r.all? {|i| arg.include?(i)} &&
           arg.size <= r.size
         })
  end

  spec :subset? do
    pre_task do |arg|
      $set_subset_old_self = [] if not $set_subset_old_self
      $set_subset_arg = [] if not $set_subset_arg
      $set_subset_old_self.push self.dup
      $set_subset_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_subset_old_self.pop
           arg = $set_subset_arg.pop

           (r == true && 
            old_self.all? {|i| arg.include?(i)} &&
            old_self.size <= arg.size) ||
           (r == false && 
            !old_self.all? {|i| arg.include?(i)})
         })
  end

  spec :proper_subset? do
    pre_task do |arg|
      $set_proper_subset_old_self = [] if not $set_proper_subset_old_self
      $set_proper_subset_arg = [] if not $set_proper_subset_arg
      $set_proper_subset_old_self.push self.dup
      $set_proper_subset_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_proper_subset_old_self.pop
           arg = $set_proper_subset_arg.pop

           (r == true && 
            old_self.all? {|i| arg.include?(i)} &&
            old_self.size < arg.size) ||
           (r == false)
         })
  end

  spec :superset? do
    pre_task do |arg|
      $set_superset_old_self = [] if not $set_superset_old_self
      $set_superset_arg = [] if not $set_superset_arg
      $set_superset_old_self.push self.dup
      $set_superset_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_superset_old_self.pop
           arg = $set_superset_arg.pop

           (r == true && 
            arg.all? {|i| old_self.include?(i)} &&
            arg.size <= old_self.size) ||
           (r == false && 
            !arg.all? {|i| old_self.include?(i)})
         })
  end

  spec :proper_superset? do
    pre_task do |arg|
      $set_proper_superset_old_self = [] if not $set_proper_superset_old_self
      $set_proper_superset_arg = [] if not $set_proper_superset_arg
      $set_proper_superset_old_self.push self.dup
      $set_proper_superset_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_proper_superset_old_self.pop
           arg = $set_proper_superset_arg.pop

           (r == true && 
            arg.all? {|i| old_self.include?(i)} &&
            arg.size < old_self.size) ||
           (r == false)
         })
  end

  spec :eql? do
    pre_task do |arg|
      $set_eql_old_self = [] if not $set_eql_old_self
      $set_eql_arg = [] if not $set_eql_arg
      $set_eql_old_self.push self.dup
      $set_eql_arg.push arg.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_eql_old_self.pop
           arg = $set_eql_arg.pop

           (r == true && 
            arg.all? {|i| old_self.include?(i)} &&
            arg.size == old_self.size) ||
           (r == false)
         })
  end

  spec :size do
    pre_task do 
      $set_size_old_self = [] if not $set_size_old_self
      $set_size_old_self.push self.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_size_old_self.pop

           r >= 0
         })
  end

  spec :hash do
    pre_task do 
      $set_hash_old_self = [] if not $set_hash_old_self
      $set_hash_old_self.push self.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_hash_old_self.pop

           r.class == Fixnum
         })
  end

  spec :empty? do
    pre_task do 
      $set_size_old_self = [] if not $set_size_old_self
      $set_size_old_self.push self.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_size_old_self.pop

           (r == true && old_self.size == 0) ||
           (r == false && old_self.size > 0)
         })
  end

  spec :clear do
    pre_task do 
      $set_clear_old_self = [] if not $set_clear_old_self
      $set_clear_old_self.push self.dup
    end

    ret (RDL.flat {|r|
           #old_self = $set_clear_old_self.pop

           r.size == 0
         })
  end

  spec :include? do
    pre_task do |arg|
      $set_include_old_self = [] if not $set_include_old_self
      $set_include_arg = [] if not $set_include_arg
      $set_include_old_self.push self.dup
      $set_include_arg.push arg
    end

    ret (RDL.flat {|r|
           old_self = $set_include_old_self.pop
           arg = $set_include_arg.pop

           
           (r == true && old_self.any? {|i| i == arg}) ||
           (r == false) 
         })
  end

  spec :add do
    pre_task do |arg|
      $set_add_old_self = [] if not $set_add_old_self
      $set_add_arg = [] if not $set_add_arg
      $set_add_old_self.push self.dup
      $set_add_arg.push arg
    end

    ret (RDL.flat {|r|
           old_self = $set_add_old_self.pop
           arg = $set_add_arg.pop

           old_self.subset?(r) && r.include?(arg) &&
           (old_self.size == r.size || old_self.size == r.size - 1)
         })
  end

  spec :delete do
    pre_task do |arg|
      $set_delete_old_self = [] if not $set_delete_old_self
      $set_delete_arg = [] if not $set_delete_arg
      $set_delete_old_self.push self.dup
      $set_delete_arg.push arg
    end

    ret (RDL.flat {|r|
           old_self = $set_delete_old_self.pop
           arg = $set_delete_arg.pop

           r.subset?(old_self) && !r.include?(arg) &&
           (old_self.size == r.size || old_self.size == r.size + 1)
         })
  end

  spec :add? do
    pre_task do |arg|
      $set_addq_old_self = [] if not $set_addq_old_self
      $set_addq_arg = [] if not $set_addq_arg
      $set_addq_old_self.push self.dup
      $set_addq_arg.push arg
    end

    ret (RDL.flat {|r|
           old_self = $set_addq_old_self.pop
           arg = $set_addq_arg.pop

           (r != nil && old_self.subset?(r) && r.include?(arg) &&
            (old_self.size == r.size || old_self.size == r.size - 1)) ||
           (r == nil && old_self.include?(arg))
         })
  end

  spec :delete? do
    pre_task do |arg|
      $set_deleteq_old_self = [] if not $set_deleteq_old_self
      $set_deleteq_arg = [] if not $set_deleteq_arg
      $set_deleteq_old_self.push self.dup
      $set_deleteq_arg.push arg
    end

    ret (RDL.flat {|r|
           old_self = $set_deleteq_old_self.pop
           arg = $set_deleteq_arg.pop

           (r != nil && r.subset?(old_self) && !r.include?(arg) &&
            (old_self.size == r.size || old_self.size == r.size + 1)) ||
           (r == nil && !old_self.include?(arg))
         })
  end

  spec :to_a do
    pre_task do 
      $set_to_a_old_self = [] if not $set_to_a_old_self
      $set_to_a_old_self.push self.dup
    end

    ret (RDL.flat {|r|
           old_self = $set_to_a_old_self.pop

           r.size == old_self.size
         })
  end
end

s = Set.new [1,2,3]
s.add(5)
#s.add(true)

s1 = Set.new [1,2,3]
s2 = Set.new [3,4,5]
s1 & s2


s1 = Set.new [1,2,3]
s2 = Set.new [3,4,5]
s1 + s2

s1 = Set.new [1,2,3]
s2 = Set.new [3,4,5]
s1 - s2

s1 = Set.new [1,2,3]
s2 = Set.new [3,4,5]
s1 ^ s2

s1 = Set.new [1,2,3]
s2 = Set.new [3,4,5]
s1.merge(s2)

s1 = Set.new [1,2,3]
s2 = Set.new [3,4,5]
s1.replace(s2)

s3 = Set.new [0]
s4 = Set.new [7,1]
s5 = Set.new []

s1.subset?(s2)
s2.subset?(s3)
s3.subset?(s4)

s1.superset?(s2)
s2.superset?(s3)
s3.superset?(s4)

s1.proper_subset?(s2)
s2.proper_subset?(s3)
s3.proper_subset?(s4)
s3.proper_subset?(s3)

s1.proper_superset?(s2)
s2.proper_superset?(s3)
s3.proper_superset?(s4)
s3.proper_superset?(s3)

s1.eql?(s2)
s2.eql?(s3)
s3.eql?(s4)
s3.eql?(s3)

s1.size
s2.size
s3.size
s3.size

s1.hash
s2.hash
s3.hash

s1.empty?
s2.empty?
s4.empty?
s5.empty?

s4.clear
s5.clear

s1.include?(1)
s2.include?(1)
s5.include?(1)

s1.add(3)
s1.add(7)

s1.delete(3)
s1.delete(8)

s1.add?(6)
s1.add?(7)

s1.delete?(1)
s1.delete?(3)
s1.delete?(9)
s5.delete?(0)

s1.to_a
s5.to_a
