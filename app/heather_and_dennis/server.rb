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

    get "/signed_urls" do
      content_type :json
      { policy: s3_upload_policy_document,
        signature: s3_upload_signature,
        key: "uploads/#{SecureRandom.uuid}/#{params[:doc][:title]}",
        success_action_redirect: "/"
      }.to_json
    end

    not_found do
      redirect '/404.html'
    end

    private

    def s3_upload_policy_document
      Base64.encode64(
        {
          expiration: (Time.now + (30*60)).utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
          conditions: [
            { bucket: 'HeatherAndDennis_WeddingPhotos' },
            { acl: 'public-read' },
            ["starts-with", "$key", "uploads/"],
            { success_action_status: '201' }
          ]
        }.to_json
      ).gsub(/\n|\r/, '')
    end

    def s3_upload_signature
      Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest::Digest.new('sha1'),
          ENV['AWS_SECRET_KEY_ID'],
          s3_upload_policy_document
        )
      ).gsub(/\n/, '')
    end
    
  end
end