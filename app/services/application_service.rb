class ApplicationService
  include LoggerHelper

  def self.call(...)
    new(...).call
  end
end