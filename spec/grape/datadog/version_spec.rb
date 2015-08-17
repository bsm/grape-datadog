require 'spec_helper'

describe Grape::Datadog do
  it "has a version" do
    expect(Grape::Datadog::VERSION).to be_instance_of(String)
  end
end
