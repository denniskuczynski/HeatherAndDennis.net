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
      @key = "uploads/#{SecureRandom.uuid}/${filename}"
      @policy = s3_upload_policy_document(@key)
      @signature = s3_upload_signature(@key)
      @photo_bucket = get_s3_photo_bucket
      erb :photos
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

    def s3_upload_policy_document(key)
      Base64.encode64(
        {
          expiration: (Time.now + (30*60)).utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
          conditions: [
            { bucket: 'heatheranddennis_wedding' },
            { acl: 'public-read' },
            ["starts-with", '$key', ""],
            { success_action_status: '201' }
          ]
        }.to_json
      ).gsub(/\n|\r/, '')
    end

    def s3_upload_signature(key)
      Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest::Digest.new('sha1'),
          ENV['AWS_SECRET_KEY'],
          s3_upload_policy_document(key)
        )
      ).gsub(/\n/, '')
    end

    def get_s3_photo_bucket
      AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['AWS_ACCESS_KEY_ID'], 
        :secret_access_key => ENV['AWS_SECRET_KEY']
      )
      photo_bucket = AWS::S3::Bucket.find('heatheranddennis_wedding')
    end
    
  end
end