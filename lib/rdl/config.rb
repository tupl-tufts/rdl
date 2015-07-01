require 'singleton'

class RDL::Config
  include Singleton

  attr_reader :nowrap

  def initialize
    @nowrap = Set.new
  end

  def add_nowrap(*klasses)
    klasses.each { |klass| @nowrap.add klass }
  end

  def remove_nowrap(*klasses)
    klasses.each { |klass| @nowrap.delete klass }
  end
end