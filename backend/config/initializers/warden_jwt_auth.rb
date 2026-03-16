module IgnoreInvalidJwtOnRevocation
  def call(token)
    super
  rescue JWT::DecodeError, JWT::VerificationError
    nil
  end
end

Warden::JWTAuth::TokenRevoker.prepend(IgnoreInvalidJwtOnRevocation)
