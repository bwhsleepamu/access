class LoaderLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n"
  end
end

logfile = File.open(Rails.root.to_s + '/log/loader.log', 'w+')  #create log file
logfile.sync = true  #automatically flushes data to file
LOAD_LOG = LoaderLogger.new(logfile)  #constant accessible anywhere

class MyLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{severity}: #{msg}\n"
  end
end
logfile2 = File.open(Rails.root.to_s + '/log/my.log', 'w')  #create log file
logfile2.sync = true  #automatically flushes data to file
MY_LOG = MyLogger.new(logfile2)  #constant accessible anywhere

class SqlLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n"
  end
end
logfile3 = File.open(Rails.root.to_s + '/log/sql.log', 'w')  #create log file
logfile3.sync = true  #automatically flushes data to file
SQL_LOG = SqlLogger.new(logfile3)  #constant accessible anywhere
