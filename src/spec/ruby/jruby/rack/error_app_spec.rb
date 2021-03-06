#--
# Copyright (c) 2010-2012 Engine Yard, Inc.
# Copyright (c) 2007-2009 Sun Microsystems, Inc.
# This source code is available under the MIT license.
# See the file LICENSE.txt for details.
#++

require File.expand_path('spec_helper', File.dirname(__FILE__) + '/../..')
require 'jruby/rack/errors'

describe JRuby::Rack::ErrorApp do
  
  before :each do
    @servlet_request = mock "servlet request"
    @env = {'java.servlet_request' => @servlet_request}
    @file_server = mock "file server"
    @error_app = JRuby::Rack::ErrorApp.new @file_server
  end

  def init_exception(cause = nil)
    @exception = org.jruby.rack.RackInitializationException.new("something went wrong", cause)
    @env[org.jruby.rack.RackEnvironment::EXCEPTION] = @exception
  end

  it "should determine the response status code based on the exception in the servlet attribute" do
    init_exception
    @file_server.stub!(:call).and_return [404, {}, []]
    @error_app.call(@env).should == [500, {}, []]
    @env["rack.showstatus.detail"].should == "something went wrong"
  end

  it "should return 503 if there is a nested InterruptedException" do
    init_exception java.lang.InterruptedException.new
    @file_server.stub!(:call).and_return [404, {}, []]
    @error_app.call(@env).should == [503, {}, []]
  end

  it "should invoke the file server with PATH_INFO=/500.html" do
    init_exception
    @file_server.should_receive(:call).and_return do |env|
      env["PATH_INFO"].should == "/500.html"
      [200, {"Content-Type" => "text/html"}, ["custom error page"]]
    end
    @error_app.call(@env).should == [500, {"Content-Type" => "text/html"}, ["custom error page"]]
    @env["rack.showstatus.detail"].should be_nil
  end

  it "should cache responses from the file server" do
    init_exception
    @file_server.should_receive(:call).once.and_return do |env|
      env["PATH_INFO"].should == "/500.html"
      [200, {"Content-Type" => "text/html"}, ["custom error page"]]
    end
    @error_app.call(@env)
    @error_app.call(@env)
    @error_app.call(@env).should == [500, {"Content-Type" => "text/html"}, ["custom error page"]]
  end

  it "should expand and cache the body of the file" do
    init_exception
    object = Object.new
    def object.each
      yield "1"
      yield "2"
      yield "3"
    end
    @file_server.should_receive(:call).once.and_return do |env|
      env["PATH_INFO"].should == "/500.html"
      [200, {"Content-Type" => "text/html"}, object]
    end
    @error_app.call(@env)
    @error_app.call(@env)
    @error_app.call(@env).should == [500, {"Content-Type" => "text/html"}, ["123"]]
  end
end

describe 'JRuby::Rack::Errors' do
  it "still works (backward compat)" do
    expect( JRuby::Rack::Errors ).to be JRuby::Rack::ErrorApp
  end
end
