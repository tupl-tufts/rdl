require 'singleton'

class RDL::Config
  include Singleton

  attr_accessor :nowrap
  attr_accessor :gather_stats
  
  def initialize
    @nowrap = Set.new
    @gather_stats = true
  end

  def add_nowrap(*klasses)
    klasses.each { |klass| @nowrap.add klass }
  end

  def remove_nowrap(*klasses)
    klasses.each { |klass| @nowrap.delete klass }
  end
end