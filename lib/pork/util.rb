module Pork
  module Util
    def home
      home =
        catch :home do
          ["HOME", "USERPROFILE"].each do |key|
            throw(:home, ENV[key]) if ENV[key]
          end
          if ENV["HOMEDRIVE"] and ENV["HOMEPATH"]
            throw(:home, "#{ ENV['HOMEDRIVE'] }:#{ ENV['HOMEPATH'] }")
          end
          File.expand_path("~") rescue(File::ALT_SEPARATOR ? "C:/" : "/")
        end
      File.expand_path(home)
    end

    extend self
  end
end
