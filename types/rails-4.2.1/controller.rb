class TalksController < ApplicationController
#class ApplicationController < ActionController::Base
  def user_authorized?(user, action, rec)
    if can?(action, rec)
      return true
    else 
      return false
    end
  end

  def db_diff(old_recs, new_recs)
    old_attr_recs = old_recs.map {|r| r.attributes}
    new_attr_recs = new_recs.map {|r| r.attributes}
    old_attr_rec_set = Set.new old_attr_recs
    new_attr_rec_set = Set.new new_attr_recs
    d1 = Set.new
    d2 = Set.new

    old_recs.zip(old_attr_recs).each {|r, attr_r|
      d1.add(r) if not new_attr_rec_set.include?(attr_r)
    }

    new_recs.zip(new_attr_recs).each {|r, attr_r|
      d2.add(r) if not old_attr_rec_set.include?(attr_r)
    }

    [d1.to_a, d2.to_a]
  end

  def destroy_post(ret, *args)
    id = params["id"]
    model_name = self.class.name.split('Controller')[0].camelize(:lower).singularize
    model_cls = eval model_name.camelize
    rec = instance_variable_get("@#{model_name}".to_sym)
    recs_post = model_cls.all

    if user_authorized?(current_user, :edit, rec) # action is also edit
      d1, d2 = db_diff($recs_pre, recs_post)
      return false if not d2.empty?
      d1.size == 1 and d1[0].id == id.to_i
    else
      d1, d2 = db_diff($recs_pre, recs_post)
      d1.empty? and d2.empty?
    end
  end

  def update_post(ret, *args)
    id = params["id"]
    model_name = self.class.name.split('Controller')[0].camelize(:lower).singularize
    model_cls = eval model_name.camelize
    rec = instance_variable_get("@#{model_name}".to_sym)
    recs_post = model_cls.all

    if $recs_pre.size != recs_post.size
      false
    else
      if user_authorized?(current_user, :edit, rec)
        d1, d2 = db_diff($recs_pre, recs_post)
        return true if d1.empty? and d2.empty?
        d1.size == 1 and d2.size == 1 and d1[0].id == id.to_i and d2[0].id == id.to_i
      else
        d1, d2 = db_diff($recs_pre, recs_post)
        d1.empty? and d2.empty?
      end
    end
  end

  def create_post(ret, *args)
    model_name = self.class.name.split('Controller')[0].camelize(:lower).singularize
    model_cls = eval model_name.camelize
    rec = instance_variable_get("@#{model_name}".to_sym)
    recs_post = model_cls.all

    if user_authorized?(current_user, :create, rec)
      d1, d2 = db_diff($recs_pre, recs_post)
      d1.empty? and (d2.size == 1 or d2.size == 0)
    else
      d1, d2 = db_diff($recs_pre, recs_post)
      d1.empty? and d2.empty?
    end
  end

  def pre_db(*args) 
    model_name = self.class.name.split('Controller')[0].camelize(:lower).singularize
    model_cls = eval model_name.camelize
    $recs_pre = model_cls.all
    true
  end

  pre :create do |*args|
    pre_db(*args)
  end

  post :create do |ret, *args|
    create_post(ret, *args)
  end

  pre :destroy do |*args|
    pre_db(*args)
  end

  post :destroy do |ret, *args|
    destroy_post(ret, *args)
  end

  pre :update do |*args|
    pre_db(*args)
  end

  post :update do |ret, *args|
    update_post(ret, *args)
  end
end

#cls.each {|c|#
#post(TalksController, :update) {|*args|
#  update_post(*args)
#}

