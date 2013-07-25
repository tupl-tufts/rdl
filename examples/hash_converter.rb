# http://rubydoc.info/gems/hash_converter/0.0.2/frames

require "hash_converter"

class << HashConverter
  extend RDL

  spec :convert do
    pre_task do |arg|
      RDL.state[:hashconv] = arg
    end

    dsl do
      spec :path do
        pre_task do |arg|
          @spec_path = [] if not @spec_path
          @spec_path.push(arg.to_sym)
        end

        pre_cond do |arg|
          x = RDL.state[:hashconv]

          @spec_path.all? { |i|
            x.keys.include?(i)
            x = x[i]
          }
        end

        post_task do
          @spec_path.pop
        end
      end

      spec :map do
        pre_cond do |arg1, arg2, arg3|
          x = RDL.state[:hashconv]
          @spec_path.each {|i| x = x[i]}

          arg1.gsub(KEY_REGEX).all? {|v|
            v = v.split('{')[1]
            v = v.split('}')[0].to_sym
            x.keys.include?(v)
          }
        end
      end
    end
  end
end
