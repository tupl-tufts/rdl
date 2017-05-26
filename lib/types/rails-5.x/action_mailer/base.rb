class ActionMailer::Base
  type :mail, '({subject: ?String, to: ?String, from: ?String, cc: ?String or Array<String>, bcc: ?String or Array<String>, reply_to: ?String, date: ?String}) -> Mail::Message'
end
