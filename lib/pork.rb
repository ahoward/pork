module Pork
  require 'fileutils'

  require 'rubygems'

  require 'arrayfields'
  require 'fattr'
  require 'amalgalite'

  begin
    porklib = File.dirname(File.expand_path(__FILE__))
    $LOAD_PATH.unshift(porklib)
    require 'pork/util'
    require 'pork/key'
    require 'pork/actor'
    require 'pork/inbox'
  ensure
    $LOAD_PATH.shift
  end

  Fattr(:dir){ File.join(Util.home, '.pork') }

  def Pork.call
    Actor.list.each{|actor| actor.call}
    sleep
  end
end

module Kernel
private
  def pork(*args, &block)
    if(args.empty? and block.nil?)
      Pork
    else
      if block
        Pork::Actor.new(*args, &block)
      else
        Pork::Actor.list[Pork::Key.new(*args)]
      end
    end
  end
end


if $0 == __FILE__
  pork('bar/foo') do |actor|
    p actor
    actor.recvmsg do |msg|
      p actor.pid => msg
    end
  end

  pork('foo/bar') do |actor|
    p actor
    sleep 1 # fucking HACK
    42.times do |i|
      pork('bar/foo').sendmsg("hullo #{ i }...")
    end
  end

  pork.call
end
