sub_dir = Rails.env == 'test' ? Rails.env : ""
log_dir = File.join(Rails.root, "log", sub_dir)

class LoaderLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n"
  end
end

logfile = File.open(File.join(log_dir, 'loader.log'), 'w+')  #create log file
logfile.sync = true  #automatically flushes data to file
LOAD_LOG = LoaderLogger.new(logfile)  #constant accessible anywhere

class MyLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{severity}: #{msg}\n"
  end
end
logfile2 = File.open(File.join(log_dir, 'my.log'), 'w')  #create log file
logfile2.sync = true  #automatically flushes data to file
MY_LOG = MyLogger.new(logfile2)  #constant accessible anywhere

class SqlLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n"
  end
end
logfile3 = File.open(File.join(log_dir, 'sql.log'), 'w')  #create log file
logfile3.sync = true  #automatically flushes data to file
SQL_LOG = SqlLogger.new(logfile3)  #constant accessible anywhere
