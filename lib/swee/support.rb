# -*- encoding: utf-8 -*-
class Object
  def try(*a, &b)
    try!(*a, &b) if a.empty? || respond_to?(a.first)
  end

  def try!(*a, &b)
    if a.empty? && block_given?
      if b.arity.zero?
        instance_eval(&b)
      else
        yield self
      end
    else
      public_send(*a, &b)
    end
  end

  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end
  def present?
    !blank?
  end

  def presence
    self if present?
  end
end

class NilClass
  def try(*args)
    nil
  end

  def try!(*args)
    nil
  end

  def blank?
    true
  end
end

class FalseClass
  def blank?
    true
  end
end

class TrueClass
  def blank?
    false
  end
end

class Array
  alias_method :blank?, :empty?
end

class Hash
  alias_method :blank?, :empty?
end

class String
  BLANK_RE = /\A[[:space:]]*\z/
  def blank?
    BLANK_RE === self
  end

  def html_safe
    self.gsub /[&"'><]/, { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;', "'" => '&#39;' }
  end
end

class Numeric
  def blank?
    false
  end
end
