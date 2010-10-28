# -*- coding: utf-8 -*-
require 'test_helper'
require 'handsoap/parser.rb'

# Amazon is rpc + literal and is self-contained
class TestParserForRPCLiteral < Test::Unit::TestCase
  def test_can_connect_and_read_wsdl
    wsdl_from_the_internets = Handsoap::Parser::Wsdl.read('http://soap.amazon.com/schemas2/AmazonWebServices.wsdl')
    assert_kind_of Handsoap::Parser::Interface, wsdl_from_the_internets.interfaces.first
  end

  def wsdl
    @wsdl ||= Handsoap::Parser::Wsdl.read File.join(File.dirname(__FILE__), "amazon_web_services.wsdl")
  end

  def test_can_parse_services
    services = wsdl.endpoints
    assert_kind_of Array, services
    assert_kind_of Handsoap::Parser::Endpoint, services.first
    assert_equal 'AmazonSearchPort', services.first.name
    assert_equal 'typens:AmazonSearchBinding', services.first.binding
  end

  def test_can_parse_port_types
    port_types = wsdl.interfaces
    assert_kind_of Array, port_types
    assert_kind_of Handsoap::Parser::Interface, port_types.first
    assert_equal 'AmazonSearchPort', port_types.first.name
    assert_kind_of Array, port_types.first.operations
    assert_equal 'KeywordSearchRequest', port_types.first.operations.first.name
  end

  def test_can_parse_bindings
    bindings = wsdl.bindings
    assert_kind_of Array, bindings
    assert_equal 'AmazonSearchBinding', bindings.first.name
    assert_kind_of Array, bindings.first.actions
    assert_equal 'KeywordSearchRequest', bindings.first.actions.first.name
  end
end

# IDService is rpc + document and has external type definitions
class TestParserForRPCDocument < Test::Unit::TestCase
  def wsdl
    @wsdl ||= Handsoap::Parser::Wsdl.read File.join(File.dirname(__FILE__), "id_service.wsdl")
  end

  def test_can_parse_services
    services = wsdl.endpoints
    assert_kind_of Array, services
    assert_kind_of Handsoap::Parser::Endpoint, services.first
    assert_equal 'IDServicePort', services.first.name
    assert_equal 'tns:IDServiceBinding', services.first.binding
  end

  def test_can_parse_port_types
    port_types = wsdl.interfaces
    assert_kind_of Array, port_types
    assert_kind_of Handsoap::Parser::Interface, port_types.first
    assert_equal 'IDServicePT', port_types.first.name
    assert_kind_of Array, port_types.first.operations
    assert_equal 'generate', port_types.first.operations.first.name
  end

  def test_can_parse_bindings
    bindings = wsdl.bindings
    assert_kind_of Array, bindings
    assert_equal 'IDServiceBinding', bindings.first.name
    assert_kind_of Array, bindings.first.actions
    assert_equal 'generate', bindings.first.actions.first.name
  end
end
