module Pork
  class Key < ::String
    def initialize(*parts)
      string = File.join(parts.flatten.compact)
      parts = string.sub(%r|^/+|,'').sub(%r|/+$|,'').split(%r|/+|)
      replace File.join(*parts)
    end
  end
end
