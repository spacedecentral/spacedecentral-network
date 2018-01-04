class UrlValidator < ActiveModel::EachValidator
  RESERVED_OPTIONS = [:schemes, :no_local]

  def initialize(options)
    options.reverse_merge!(:schemes => %w(http https))
    options.reverse_merge!(:message => :url)
    options.reverse_merge!(:no_local => false)

    super(options)
  end

  def validate_each(record, attribute, value)
    schemes = [*options.fetch(:schemes)].map(&:to_s)
    begin
      uri = URI.parse(value)
      unless uri && uri.host && schemes.include?(uri.scheme) && (!options.fetch(:no_local) || uri.host.include?('.'))
        record.errors.add(attribute, :url, filtered_options(value))
      end
    rescue URI::InvalidURIError
      record.errors.add(attribute, :url, filtered_options(value))
    end
  end

  protected

  def filtered_options(value)
    filtered = options.except(*RESERVED_OPTIONS)
    filtered[:value] = value
    filtered
  end
end
