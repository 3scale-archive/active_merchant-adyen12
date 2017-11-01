require 'test_helper'

class RemoteAdyen12Test < Test::Unit::TestCase
  def setup
    @gateway = Adyen12Gateway.new(fixtures(:adyen12))

    @amount = 100

    # https://www.adyen.com/home/support/knowledgebase/implementation-articles?article=kb_imp_17
    @credit_card = credit_card('4111111111111111',
    :month => 8,
    :year => 2018,
    :first_name => 'Test',
    :last_name => 'Card',
    :verification_value => '737',
    :brand => 'visa'
    )

    @declined_card = credit_card('4000300011112220')

    @options = {
      reference: '3',
      shopperEmail: "s.hopper@test.com",
      shopperIP: "61.294.12.12",
      shopperReference: "Simon Hopper"
    }
    @recurring = {
      recurring:  'RECURRING'
    }
    @recurring_submission = {
      shopperInteraction: 'ContAuth',
      selectedRecurringDetailReference: 'LATEST'
    }
  end

  def test_successful_purchase
    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal '[capture-received]', response.message
  end

  def test_failed_purchase
    response = @gateway.purchase(@amount, @declined_card, @options)
    assert_failure response
    assert_equal 'Refused', response.message
  end

  def test_successful_recurring_purchase
    response = @gateway.authorize_recurring(0, @credit_card, @options.merge(@recurring))
    recurring = @gateway.submit_recurring(1500, @options.merge(@recurring.merge(@recurring_submission)))
    assert_success response
    assert_success recurring
    assert_equal 'Authorised', response.message
    assert_equal 'Authorised', recurring.message
  end

  def test_failed_recurring_purchase
    response = @gateway.authorize_recurring(0, @credit_card, @options.merge(@recurring))
    recurring = @gateway.submit_recurring(1500, @options.merge({
      shopperInteraction: 'ContAuth',
      selectedRecurringDetailReference: 'NonExistent'
    }))
    assert_success response
    assert_failure recurring
    assert_equal 'Unknown', recurring.message
  end

  def test_list_recurring_details
    response = @gateway.authorize_recurring(0, @credit_card, @options.merge(@recurring))
    recurring = @gateway.submit_recurring(1500, @options.merge(@recurring.merge(@recurring_submission)))
    details = @gateway.list_recurring_details(@options[:shopperReference], recurring: 'RECURRING')

    assert_success details

    details_hash = details.params['details'][0]['RecurringDetail']
    assert_equal '1111', details_hash['card']['number']
    assert_equal '8', details_hash['card']['expiryMonth']
    assert_equal '2018', details_hash['card']['expiryYear']
    assert_equal 'John Doe', details_hash['card']['holderName']
  end

  def test_successful_authorize_and_capture
    auth = @gateway.authorize(@amount, @credit_card, @options)
    assert_success auth

    assert capture = @gateway.capture(@amount, auth.authorization, @options.slice(:reference))
    assert_success capture
  end

  def test_failed_authorize
    response = @gateway.authorize(@amount, @declined_card, @options)
    assert_failure response
  end

  def test_partial_capture
    auth = @gateway.authorize(@amount, @credit_card, @options)
    assert_success auth

    assert capture = @gateway.capture(@amount - 1, auth.authorization)
    assert_success capture
  end

  def test_failed_capture
    response = @gateway.capture(nil, '')
    assert_failure response
  end

  def test_successful_refund
    purchase = @gateway.purchase(@amount, @credit_card, @options)
    assert_success purchase

    assert refund = @gateway.refund(@amount, purchase.authorization)
    assert_success refund
  end

  def test_partial_refund
    purchase = @gateway.purchase(@amount, @credit_card, @options)
    assert_success purchase

    assert refund = @gateway.refund(@amount-1, purchase.authorization)
    assert_success refund
  end

  def test_failed_refund
    response = @gateway.refund(0, '')
    assert_failure response
  end

  def test_successful_void
    auth = @gateway.authorize(@amount, @credit_card, @options)
    assert_success auth

    assert void = @gateway.void(auth.authorization)
    assert_success void
  end

  def test_failed_void
    response = @gateway.void('')
    assert_failure response
  end

  def test_successful_verify
    response = @gateway.verify(@credit_card, @options)
    assert_success response
    assert_match 'Authorised', response.message
  end

  def test_failed_verify
    response = @gateway.verify(@declined_card, @options)
    assert_failure response
    assert_match 'Refused', response.message
  end

  def test_invalid_login
    gateway = Adyen12Gateway.new(
      login: '',
      password: '',
      merchantAccount: 'hello'
    )
    response = gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
  end
end
