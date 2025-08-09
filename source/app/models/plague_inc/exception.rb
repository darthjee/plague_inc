# frozen_string_literal: true

module PlagueInc
  class Exception < StandardError
    class LoginFailed  < PlagueInc::Exception; end
    class Unauthorized < PlagueInc::Exception; end
    class NotLogged    < PlagueInc::Exception; end
  end
end
