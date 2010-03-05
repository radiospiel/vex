module ActiveRecord::ConnectionAdapters
  class SQLiteAdapter < AbstractAdapter
    def locked(lock, opts = {}, &block)
      database = instance_variable_get("@config")[:database]
      return yield if database == ":memory:"

      File.locked("#{database}.#{lock}", &block)
    end
  end
end

#
# Note: these tests are un within multiple threads of a single application.
# This is not the usual intention of locking code: AbstractAdapter#lock
# should be used to lock across processes!
#
# Consequently locking does not work on in-memory sqlite databases.
module ActiveRecord::AdvisoryLock::Etest
  class Test < ActiveRecord::Base
    establish_connection :adapter => "sqlite3",
      :database => "#{App.tmpdir}/lock.sqlite3"
  end
  
  def test_sqlite
    @run = 0

    connection = Test.connection

    #
    # In this example th2 would run first, because th1 goes to sleep
    # first.
    th1 = Thread.new { 
      Thread.sleep 0.1
      connection.locked("etest") do
        assert_equal(2, @run)
        @run = 1
      end
    }

    th2 = Thread.new { 
      Thread.sleep 0.05
      connection.locked("etest") do
        @run = 2
      end
    }

    th1.join
    th2.join
    
    assert_equal(1, @run)

    #
    # In this example th1 would lock using the connection before th2 tries to
    # lock it. Consequenty the th1 action would run first.
    @run = 0
    
    th1 = Thread.new { 
      connection.locked("etest") do
        Thread.sleep 0.1
        assert_equal(0, @run)
        @run = 1
      end
    }

    th2 = Thread.new { 
      Thread.sleep 0.05
      connection.locked("etest") do
        assert_equal(1, @run)
        @run = 2
      end
    }

    th1.join
    th2.join
    
    assert_equal(2, @run)
  end
end
