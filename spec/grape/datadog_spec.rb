require 'spec_helper'

describe Grape::Datadog do

  def app; TestAPI; end

  before  { subject.statsd.buffer.clear }
  subject { described_class.instance }

  it 'should be configurable' do
    expect(subject.tags.size).to eq(3)
    expect(subject.tags).to include("host:test.host")
    expect(subject.tags).to include("custom:tag")
    expect(subject.statsd).to be_instance_of(MockStatsd)
  end

  it 'should send an increment and timing event for each request' do
    get '/echo/1/1234'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('1 1234')

    expect(subject.statsd.buffer).to eq([
      "grape.request:1|c|#custom:tag,format:txt,host:test.host,method:GET,path:/echo/_key1_/_key2_",
      "grape.request.time:333|ms|#custom:tag,format:txt,host:test.host,method:GET,path:/echo/_key1_/_key2_",
    ])
  end

  it 'should support namespaces and versioning' do
    get '/api/v1/sub/versioned'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('OK')

    expect(subject.statsd.buffer).to eq([
      "grape.request:1|c|#custom:tag,format:txt,host:test.host,method:GET,path:/sub/versioned,version:v1  ",
      "grape.request.time:333|ms|#custom:tag,format:txt,host:test.host,method:GET,path:/sub/versioned,version:v1  ",
    ])
  end

  it 'should support deep nesting' do
    get '/sub/nest/resource'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('{}')

    expect(subject.statsd.buffer).to eq([
      "grape.request:1|c|#custom:tag,format:txt,host:test.host,method:GET,path:/sub/versioned,version:v1  ",
      "grape.request.time:333|ms|#custom:tag,format:txt,host:test.host,method:GET,path:/sub/versioned,version:v1  ",
    ])
  end

end
