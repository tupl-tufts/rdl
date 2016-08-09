module Process
  rdl_nowrap

  type 'self.abort', '(?String msg) -> %any'
  type 'self.argv0', '() -> String frozen_string'
  type 'self.clock_getres', '(Symbol or Fixnum clock_id, ?Symbol unit) -> Float or Integer'
  type 'self.clock_gettime', '(Symbol or Fixnum clock_id, ?Symbol unit) -> Float or Integer'
  type 'self.daemon', '(?%any nochdir, ?%any noclose) -> 0'
  type 'self.detach', '(Fixnum pid) -> Thread'
  type 'self.egid', '() -> Fixnum'
  type 'self.egid=', '(Fixnum) -> Fixnum'
  type 'self.euid', '() -> Fixnum'
  type 'self.euid=', '(Fixnum) -> Fixnum user'
  #  type 'self.exec', '(env: ?Hash<String, String>, command:String, args:*String) -> %any' # TODO: env
  type 'self.exit', '(?Fixnum status) -> %any'
  type 'self.exit!', '(?Fixnum status) -> %any'
  type 'self.fork', '() -> Fixnum or nil'
  type 'self.fork', '() { () -> %any } -> Fixnum or nil'
  type 'self.getpgid', '(Fixnum pid) -> Fixnum'
  type 'self.getpgrp', '() -> Fixnum'
  type 'self.getpriority', '(Fixnum kind, Fixnum) -> Fixnum'
  type 'self.getrlimit', '(Symbol or String or Fixnum resource) -> [Fixnum, Fixnum] cur_max_limit'
  type 'self.getsid', '(?Fixnum pid) -> Integer'
  type 'self.gid', '() -> Fixnum'
  type 'self.gid=', '(Fixnum) -> Fixnum'
  type 'self.groups', '() -> Array<Fixnum>'
  type 'self.groups=', '(Array<Fixnum>) -> Array<Fixnum>'
  type 'self.initgroups', '(String username, Fixnum gid) -> Array<Fixnum>'
  type 'self.kill', '(Fixnum or Symbol or String signal, *Fixnum pids) -> Fixnum'
  type 'self.maxgroups', '() -> Fixnum'
  type 'self.maxgroups=', '(Fixnum) -> Fixnum'
  type 'self.pid', '() -> Fixnum'
  type 'self.ppid', '() -> Fixnum'
  type 'self.pgid', '(Fixnum pid, Fixnum) -> Fixnum'
  type 'self.setpriority', '(Fixnum kind, Fixnum, Fixnum priority) -> 0'
  type 'self.setproctitle', '(String) -> String'
  type 'self.setrlimit', '(Symbol or String or Fixnum resource, Fixnum cur_limit, ?Fixnum max_limit) -> nil'
  type 'self.setsid', '() -> Fixnum'
  #  type 'self.spawn', '(?Hash<String, String> env, String command, *String args) -> %any' # TODO: env
  type 'self.times', '() -> Process::Tms'
  type 'self.uid', '() -> Fixnum'
  type 'self.uid=', '(Fixnum user) -> Fixnum'
  type 'self.wait', '(?Fixnum pid, ?Fixnum flags) -> Fixnum'
  type 'self.wait2', '(?Fixnum pid, ?Fixnum flags) -> [Fixnum, Fixnum] pid_and_status'
  type 'self.waitall', '() -> Array<[Fixnum, Fixnum]>'
  type 'self.waitpid', '(?Fixnum pid, ?Fixnum flags) -> Fixnum'
  type 'self.waitpid2', '(?Fixnum pid, ?Fixnum flags) -> [Fixnum, Fixnum] pid_and_status'

  module GID
    rdl_nowrap

    type 'self.change_privilege', '(Fixnum group) -> Fixnum'
    type 'self.eid', '() -> Fixnum'
    type 'self.from_name', '(String name) -> Fixnum gid'
    type 'self.grant_privilege', '(Fixnum group) -> Fixnum'
    rdl_alias 'self.eid=', 'self.grant_privilege'
    type 'self.re_exchange', '() -> Fixnum'
    type 'self.re_exchangeable?', '() -> %bool'
    type 'self.rid', '() -> Fixnum'
    type 'self.sid_available?', '() -> %bool'
    type 'self.switch', '() -> Fixnum'
    type 'self.switch', '() { () -> t } -> t'
  end

  module UID
    rdl_nowrap

    type 'self.change_privilege', '(Fixnum user) -> Fixnum'
    type 'self.eid', '() -> Fixnum'
    type 'self.from_name', '(String name) -> Fixnum uid'
    type 'self.grant_privilege', '(Fixnum user) -> Fixnum'
    rdl_alias 'self.eid=', 'self.grant_privilege'
    type 'self.re_exchange', '() -> Fixnum'
    type 'self.re_exchangeable?', '() -> %bool'
    type 'self.rid', '() -> Fixnum'
    type 'self.sid_available?', '() -> %bool'
    type 'self.switch', '() -> Fixnum'
    type 'self.switch', '() { () -> t } -> t'
  end

  class Status
    rdl_nowrap

    type :&, '(Fixnum num) -> Fixnum'
    type :==, '(%any other) -> %bool'
    type :>>, '(Fixnum num) -> Fixnum'
    type :coredump?, '() -> %bool'
    type :exited?, '() -> %bool'
    type :exitstatus, '() -> Fixnum or nil'
    type :inspect, '() -> String'
    type :pid, '() -> Fixnum'
    type :signaled?, '() -> %bool'
    type :stopped?, '() -> %bool'
    type :stopsig, '() -> Fixnum or nil'
    type :success?, '() -> %bool'
    type :termsig, '() -> Fixnum or nil'
    type :to_i, '() -> Fixnum'
    rdl_alias :to_int, :to_i
    type :to_s, '() -> String'
  end

  module Sys
    rdl_nowrap

    type 'self.geteid', '() -> Fixnum'
    type 'self.geteuid', '() -> Fixnum'
    type 'self.getgid', '() -> Fixnum'
    type 'self.getuid', '() -> Fixnum'
    type 'self.issetugid', '() -> %bool'
    type 'self.setegid', '(Fixnum group) -> nil'
    type 'self.seteuid', '(Fixnum user) -> nil'
    type 'self.setgid', '(Fixnum group) -> nil'
    type 'self.setregid', '(Fixnum rid, Fixnum eid) -> nil'
    type 'self.setresgid', '(Fixnum rid, Fixnum eid, Fixnum sid) -> nil'
    type 'self.setresuid', '(Fixnum rid, Fixnum eid, Fixnum sid) -> nil'
    type 'self.setreuid', '(Fixnum rid, Fixnum eid) -> nil'
    type 'self.setrgid', '(Fixnum group) -> nil'
    type 'self.setruid', '(Fixnum user) -> nil'
    type 'self.setuid', '(Fixnum user) -> nil'
  end

  class Waiter
    rdl_nowrap

    type 'pid', '() -> Fixnum'
  end
end
