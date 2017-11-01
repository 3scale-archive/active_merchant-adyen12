require 'test_helper'

class Adyen12Test < Test::Unit::TestCase
  include CommStub

  def setup
    @gateway = Adyen12Gateway.new(
      login: 'ws@example.com',
      password: 'password',
      merchantAccount: 'Mercantor'
    )

    # @credit_card = credit_card
    # Credit card is represented by an encrypted string
    # It is provided by adyen JS library in EE for the initial payment
    @credit_card = credit_card('4111111111111111',
    :month => 8,
    :year => 2018,
    :first_name => 'Test',
    :last_name => 'Card',
    :verification_value => '737',
    :brand => 'visa'
    )
    @amount = 100

    @options = {
      reference: '1'
    }
  end

  # Tests for fields requirements on authorize

  def test_authorize_requirements
    assert_raise ArgumentError, "Missing required parameter: reference" do
      @gateway.authorize(@amount, @credit_card, {})
    end
  end

  def test_successful_authorize
    @gateway.expects(:ssl_post).returns(successful_authorize_response)

    response = @gateway.authorize(@amount, @credit_card, @options)
    assert_success response

    assert_equal '1234567890123456', response.authorization
    assert response.test?
  end

  def test_failed_authorize
    @gateway.expects(:ssl_post).returns(failed_authorize_response)

    response = @gateway.authorize(@amount, @credit_card, @options)
    assert_equal 'You have reached your payment threshold', response.message
    assert_failure response
  end

  def test_successful_purchase
    response = stub_comms do
      @gateway.purchase(@amount, @credit_card, @options)
    end.respond_with(successful_purchase_response, successful_capture_response)
    assert_success response

    assert_equal '098765432109876', response.authorization
    assert response.test?
  end

  def test_failed_purchase
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_equal 'You do not have enough money', response.message
    assert_failure response
  end


  def test_successful_capture
    @gateway.expects(:ssl_post).returns(successful_capture_response)
    response = @gateway.capture(@amount, 'pspReference')
    assert_equal '098765432109876', response.authorization
    assert_equal '[capture-received]', response.message
    assert response.test?
  end

  def test_failed_capture
    @gateway.expects(:ssl_post).returns(failed_capture_response)
    response = @gateway.capture(-@amount, 'pspReference')
    assert_nil response.authorization
    assert_equal 'Invalid amount specified', response.message
    assert_failure response
  end

  def test_successful_refund
    @gateway.expects(:ssl_post).returns(successful_refund_response)
    response = @gateway.refund(@amount, 'pspReference')
    assert_equal 'authorization-12345', response.authorization
    assert_equal '[refund-received]', response.message
    assert response.test?
  end

  def test_failed_refund
    @gateway.expects(:ssl_post).returns(failed_refund_response)
    response = @gateway.refund(0, '')
    assert_nil response.authorization
    assert_equal 'No amount specified', response.message
    assert_failure response
  end

  def test_successful_void
    @gateway.expects(:ssl_post).returns(successful_void_response)
    response = @gateway.refund(@amount, 'pspReference')
    assert_equal 'void-reference-12345', response.authorization
    assert_equal '[cancel-received]', response.message
    assert response.test?
  end

  def test_failed_void
    @gateway.expects(:ssl_post).returns(failed_void_response)
    response = @gateway.void('')
    assert_nil response.authorization
    assert_equal 'Original pspReference required for this operation', response.message
    assert_failure response
  end

  def test_successful_verify
    response = stub_comms do
      @gateway.verify(@credit_card, @options)
    end.respond_with(successful_authorize_response)
    assert_success response
    assert_equal "Authorised", response.message
    assert response.test?
  end

  def test_successful_submit_recurring
    @gateway.expects(:ssl_post).returns(successful_recurring_response)
    options = {
      shopperReference: 'John Doe',
      reference: 'payment-1',
      recurring: 'RECURRING',
      shopperInteraction: 'ContAuth',
      selectedRecurringDetailReference: 'LATEST'
    }
    assert_nothing_raised do
      @gateway.submit_recurring(@amount, options)
    end
  end

  def test_successful_verify_with_failed_void
  end

  def test_failed_verify
  end

  private

  def successful_authorize_response
    %(
    {
        "pspReference" : "1234567890123456",
        "resultCode" : "Authorised",
        "authCode": "64158"
    }
    )
  end

  def failed_purchase_response
    %(
     {
       "pspReference": "1234567890123456",
       "resultCode": "Refused",
       "authCode": "",
       "refusalReason": "You do not have enough money"
     }
    )
  end

  def successful_purchase_response
    %(
    {
        "pspReference" : "8413547924770610",
        "resultCode" : "Authorised",
        "authCode": "12345"
    }
    )
  end

  def failed_authorize_response
    %(
     {
       "pspReference": "1234567890123456",
       "resultCode": "Refused",
       "authCode": "",
       "refusalReason": "You have reached your payment threshold"
     }
    )
  end

  def successful_capture_response
    %(
    {
        "pspReference" : "098765432109876",
        "response" : "[capture-received]"
    }
    )
  end

  def failed_capture_response
    %(
    {
      "status":422,
      "errorCode":"137",
      "message":"Invalid amount specified",
      "errorType":"validation"
    }
    )
  end

  def successful_refund_response
    %(
    {
        "pspReference" : "authorization-12345",
        "response" : "[refund-received]"
    }
    )
  end

  def failed_refund_response
    %(
    {
      "status":422,
      "errorCode":"100",
      "message":"No amount specified",
      "errorType":"validation"
    }
    )
  end

  def successful_void_response
    %(
    {
        "pspReference" : "void-reference-12345",
        "response" : "[cancel-received]"
    }
    )
  end

  def failed_void_response
    %(
    {
       "errorCode" : "167",
       "errorType" : "validation",
       "message" : "Original pspReference required for this operation",
       "status" : 422
    }
    )
  end

  def successful_verify_response
    %(
    {
        "pspReference" : "1234567890123456",
        "resultCode" : "Authorised",
        "authCode": "64158"
    }
    )
  end

  def successful_recurring_response
    %(
    {
        "pspReference" : "1234567890123456",
        "resultCode" : "Authorised",
        "authCode": "64158"
    }
    )
  end
end
