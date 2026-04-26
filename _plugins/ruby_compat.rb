# Patch for Ruby 3.2+ compatibility: String#tainted? was removed in Ruby 3.2
# but liquid-4.0.3 (locked by github-pages 223) still calls it.
if RUBY_VERSION >= "3.2"
  class String
    def tainted?
      false
    end
  end

  class Object
    def tainted?
      false
    end
  end
end
