require 'sinatra/base'
require 'nokogiri'
require 'open-uri'

class ExchangeRate < Sinatra::Base

  set :root, File.dirname(__FILE__)

  configure do
    #at first app run, open xml feed and parse with Nokogiri
    web_contents  = open("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml") {|f| f.read }
    @doc = Nokogiri::XML(web_contents)
  end

  def self.at(date, base_currency, counter_currency)
    day_fx = @doc.css("Cube[@time='#{date}']").css("Cube")
    counter_rate = day_fx.at_css("[@currency='#{counter_currency}']")
    if counter_rate != nil
      counter_rate = counter_rate.values[1].to_f
      return counter_rate
    else
      return "data error"
    end
  end

  def self.convert(amount, counter_rate)
    result = Integer(amount) rescue false
    if result.is_a?(Integer)
      @result = (amount.to_f*counter_rate.to_f).round(4)
      return @result
    else
      return "amount error"
    end
  end

  def self.get_dates()
    # pull dates from xml
    @avail_dates = []
    @doc.css("Cube[@time]").each do |date|
      @avail_dates.push(date.values.slice(0))
    end
    return @avail_dates
  end

  def self.get_base_currencies()
    # all currencies are compared to EURO
    @avail_bases = ['EUR']
    return @avail_bases
  end

  def self.get_counter_currencies()
    # pull all counter currencies from xml
    @avail_counters = []
    @doc.css("Cube[@time]").first.css("Cube[@currency]").each do |cc|
      @avail_counters.push(cc.values.slice(0))
    end
    return @avail_counters
  end

  get '/' do
    @title = "Convert currency"
    @dates = ExchangeRate.get_dates()
    @base_currencies = ExchangeRate.get_base_currencies()
    @counter_currencies = ExchangeRate.get_counter_currencies()

    erb :index
  end

  get '/date/:date/base/:base_currency/counter/:counter_currency/amount/:amount' do
    @amount = params[:amount]
    @date = params[:date]
    @base_currency = params[:base_currency].upcase
    @counter_currency = params[:counter_currency].upcase

    @counter_rate = ExchangeRate.at(@date, @base_currency, @counter_currency)
    if @counter_rate == "data error"
      @title = "Something went wrong..."
      erb :not_found
    else
      @result = ExchangeRate.convert(@amount, @counter_rate)
      if @result == "amount error"
        @title = "Something went wrong..."
        erb :not_found
      else
        @title = "Conversion results"
        erb :currency
      end
    end
  end

  post '/currency' do
    @amount = params[:amount]
    @date = params[:date]
    @base_currency = params[:base_currency]
    @counter_currency = params[:counter_currency]

    redirect to("/date/#{@date}/base/#{@base_currency}/counter/#{@counter_currency}/amount/#{@amount}")
  end

  not_found do
    erb :not_found
  end
end
