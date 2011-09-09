class Testing::SiegeLoadTestsController < ActionController::Base
  layout '/testing/layouts/siege_load_test'
  helper :all

  def index
    @load_tests = SiegeLoadTest.all.reverse
  end

  def new
    @load_test = SiegeLoadTest.new
  end

  def create
    @load_test = if params[:mark]
      SiegeLoadTest.find(params[:mark])
    else
      params[:siege_load_test][:urls] = params[:siege_load_test][:urls].split("\n")
      SiegeLoadTest.new(params[:siege_load_test])
    end
    @load_test.asynchronous = true
    if @load_test.perform
      redirect_to testing_siege_load_test_path(@load_test.mark, :wait_to => @load_test.wait_to.to_s(:db))
    else
      render :new
    end
  end

  def show
    @wait_to = params[:wait_to]
    @load_test = SiegeLoadTest.find(params[:id])
  end
  
end
