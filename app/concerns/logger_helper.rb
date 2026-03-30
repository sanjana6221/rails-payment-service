module LoggerHelper
  extend ActiveSupport::Concern

  def log_info(message)
    Rails.logger.info("[#{self.class.name}] #{message}")
  end

  def log_warn(message)
    Rails.logger.warn("[#{self.class.name}] #{message}")
  end

  def log_error(message)
    Rails.logger.error("[#{self.class.name}] #{message}")
  end
end
