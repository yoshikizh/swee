module Daemonize
  def safefork
    tryagain = true

    while tryagain
      tryagain = false
      begin
        if pid = fork
          return pid
        end
      rescue Errno::EWOULDBLOCK
        sleep 5
        tryagain = true
      end
    end
  end
end