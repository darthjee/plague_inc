# frozen_string_literal: true

# rubocop:disable Style/MissingRespondToMissing
module ApplicationHelper
  def angular_link_to(text, path, *args)
    link_to(text, angular_path_to(path), *args)
  end

  def angular_safe_link_to(path_method, path_args = {}, *args)
    path = public_send(
      path_method.to_s.gsub(/(_path)?$/, '_safe_path').to_s, path_args
    )

    link_to(
      angular_path_to(path), *args
    ) do
      yield
    end
  end

  def angular_path_to(path)
    "##{path}"
  end

  def method_missing(method, *args)
    Path::SafePath.new(self, method).call_missing(*args) || super
  end

  def respond_to?(method)
    return true if Path::SafePath.new(self, method).does_respond_to?

    super
  end
end
# rubocop:enable Style/MissingRespondToMissing
