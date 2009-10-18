module Pork
  class Inbox
    fattr :actor
    fattr(:db){ Db.new(self) }

    def initialize(actor)
      @actor = actor
    end

    def recvmsg(*key, &block)
      conditions = []
      unless key.empty?
        key = Key.new(*key)
        condition = "#{ key }%"
        conditions << "key LIKE #{ condition.inspect }"
      end
      conditions.push("status='new'")
      #conditions.push("deleted_at=NULL")
      conditions.push('42==42') if conditions.empty?
      where_clause = conditions.join(' and ')
      sql = <<-__
        select * from messages where( #{ where_clause } ) order by created_at;
      __
      result = []
      db.execute(sql) do |row|
        data = row['data']
        if block
          block.call(data)
        else
          result.push(data)
        end
        db.execute("update messages set status='old' where id=#{ row['id'] }")
      end
      block ? nil : result
    end

    def sendmsg(*args)
      data = args.pop
      key = args.size == 0 ? nil : Key.new(*args)
      sql = <<-__
        insert into messages values(
          NULL,
          ?,
          ?,
          'new',
          current_timestamp,
          current_timestamp,
          NULL
        );
      __
      db.execute(sql, [key, data])
    end

    class Db
      Schema = <<-__
        create table messages(
          id integer primary key,
          key string,
          data text,
          status string,
          created_at timestamp,
          updated_at timestamp,
          deleted_at timestamp
        );

        create index if not exists messages_key_index on messages (key);
        create index if not exists messages_status_index on messages (status);
        create index if not exists messages_created_at_index on messages (created_at);
        create index if not exists messages_updated_at_index on messages (updated_at);
        create index if not exists messages_deleted_at_index on messages (deleted_at);
      __

      fattr :inbox
      fattr :path
      fattr :db

      def initialize(inbox)
        @inbox = inbox
        @path = File.join(Pork.dir, inbox.actor.key, 'inbox.db')
        FileUtils.mkdir_p(File.dirname(@path))
        @db = Amalgalite::Database.new(@path)
        setup unless setup?
      end

      def execute(*args, &block)
        @db.execute(*args, &block)
      end

      def escape(value)
        @db.escape(value)
      end

      def quote(value)
        @db.quote(value)
      end

      def value(value)
        return 'NULL' if value.nil?
        @db.quote(@db.escape(value))
      end

      def setup?
        tables.include?('messages')
      end

      def tables
        execute("select * from sqlite_master where type='table'").map{|row| row[1]}
      end

      def setup
        execute(Schema)
      end
    end
  end
end
