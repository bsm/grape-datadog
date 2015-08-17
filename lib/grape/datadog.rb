%w|version middleware|.each do |name|
  require "grape/datadog/#{name}"
end
