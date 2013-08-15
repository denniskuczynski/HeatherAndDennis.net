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

    get "/events" do
      erb :events
    end

    get "/photos" do
      @photo_bucket = get_s3_photo_bucket
      erb :photos
    end

    post "/submitPhoto" do
      bytes = params['file'][:tempfile].read
      ImageVoodoo.with_bytes(bytes) do |img|
        img.thumbnail(610) do |img2|
          save_to_s3 params['file'][:filename], bytes
          save_to_s3 'thumb_'+params['file'][:filename], img2.bytes('png')
        end
      end
      return { :success => :ok }.to_json
    end

    get "/quiz" do
      erb :quiz
    end

    get "/music" do
      erb :music
    end

    post "/submit-quiz" do
      @quiz = params[:quiz]
      @correct = 0
      if @quiz
        @correct = @correct + 1 if @quiz['one'] == 'b'
        @correct = @correct + 1 if @quiz['two'] == 'a'
        @correct = @correct + 1 if @quiz['three'] == 'c'
        @correct = @correct + 1 if @quiz['four'] == 'a'
        @correct = @correct + 1 if @quiz['five'] == 'c'
        @correct = @correct + 1 if @quiz['six'] == 'a'
      end
      erb :quiz_results
    end

    get "/registry" do
      erb :registry
    end

    not_found do
      redirect '/404.html'
    end

    private

    def get_s3_photo_bucket
      AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['AWS_ACCESS_KEY_ID'], 
        :secret_access_key => ENV['AWS_SECRET_KEY']
      )
      photo_bucket = AWS::S3::Bucket.find('heatheranddennis_wedding')
    end

    def save_to_s3(filename, file)
      AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['AWS_ACCESS_KEY_ID'], 
        :secret_access_key => ENV['AWS_SECRET_KEY']
      )
      AWS::S3::S3Object.store(filename, file, 'heatheranddennis_wedding')
    end
    
  end
end