module Pork
  class Actor
    Fattr :list => Array.fields 

    fattr :key
    fattr :inbox
    fattr :pid
    fattr(:actor){ self }

    def initialize(*key, &block)
      @key = Key.new(*key)
      @block = block
      @inbox = Inbox.new(actor)
      Actor.list[@key] = actor
    end

    def inspect
      "#{ key }(pid:#{ defined?(@pid) ? @pid : nil }, db:#{ db.path })".inspect
    end

    def call
      @pid =
        fork do
          @pid = Process.pid 
          @block.call(actor)
          exit
        end
    end

    def db
      inbox.db
    end

# TODO - needs to block
    def recvmsg(*args, &block)
      inbox.recvmsg(*args, &block)
    end

# TODO - needs to block
    def sendmsg(*args, &block)
      inbox.sendmsg(*args, &block)
    end
  end
end
