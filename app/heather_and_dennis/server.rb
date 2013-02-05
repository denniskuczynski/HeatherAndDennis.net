module HeatherAndDennis
  class Server < Sinatra::Base

    root = File.dirname(File.expand_path(__FILE__))
    set :root, root
    set :public_folder, File.dirname(__FILE__) + '/../../public/'

    get "/" do
      redirect '/index.html'
    end

    not_found do
      redirect '/404.html'
    end
    
  end
end