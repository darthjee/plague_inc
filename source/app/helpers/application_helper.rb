# frozen_string_literal: true

# rubocop:disable Style/MissingRespondToMissing
module ApplicationHelper
  def angular_link_to(text, path, *)
    link_to(text, angular_path_to(path), *)
  end

  def angular_safe_link_to(path_method, path_args = {}, *, &)
    path = angular_path_to(path_method, path_args)
    link_to(path, *, &)
  end

  def angular_path_to(path_method, path_args = {})
    path = public_send(
      path_method.to_s.gsub(/(_path)?$/, '_safe_path').to_s, path_args
    )
    "##{path}"
  end

  def method_missing(method, *)
    Path::SafePath.new(self, method).call_missing(*) || super
  end

  def respond_to?(method)
    return true if Path::SafePath.new(self, method).does_respond_to?

    super
  end
end
# rubocop:enable Style/MissingRespondToMissing
