module HeatherAndDennis
  class Server < Sinatra::Base

    root = File.dirname(File.expand_path(__FILE__))
    set :root, root
    set :public_folder, File.dirname(__FILE__) + '/../../public/'
    set :views,  "#{root}/views"

    get "/" do
      erb :index
    end

    get "/information" do
      erb :information
    end

    get "/photos" do
      erb :photos
    end

    get "/quiz" do
      erb :quiz
    end

    post "/submit-quiz" do
      @quiz = params[:quiz]
      @correct = 0
      @correct = @correct + 1 if @quiz['one'] == 'b'
      @correct = @correct + 1 if @quiz['two'] == 'a'
      @correct = @correct + 1 if @quiz['three'] == 'c'
      @correct = @correct + 1 if @quiz['four'] == 'a'
      @correct = @correct + 1 if @quiz['five'] == 'c'
      @correct = @correct + 1 if @quiz['six'] == 'a'
      erb :quiz_results
    end

    get "/registry" do
      erb :registry
    end

    not_found do
      redirect '/404.html'
    end
    
  end
end