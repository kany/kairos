require 'spec_helper'

describe Kairos::Client do

  describe '#enroll' do
    before do
      @config = {
        :app_id          => 'abc1234',
        :app_key         => 'asdfadsfasdfasdfasdf'
      }
      @client = Kairos::Client.new(@config)
    end

    it 'responds to enroll' do
      @client.should respond_to(:enroll)
    end

    context 'with valid credentials' do
      context 'with missing parameters' do
        it 'should not enroll an image' do
          VCR.use_cassette('enroll_with_missing_parameters') do
            response = @client.enroll(:url => 'https://some.image.url/123abc.jpg', :subject_id => 'image123abc')
            response.should eq({"Errors"=>[{"ErrCode"=>1002, "Message"=>"gallery_name one or more required parameters are missing"}]})
          end
        end
      end
      context 'with invalid image url' do
        it 'should not enroll an image' do
          VCR.use_cassette('enroll_with_invalid_image_url') do
            response = @client.enroll(:url => 'https://some.image.url/123abc.jpg', :subject_id => 'image123abc', :gallery_name => 'randomgallery')
            response.should eq({"Errors"=>[{"ErrCode"=>5001, "Message"=>"invalid url was sent"}]})
          end
        end
      end
      context 'with required parameters' do
        before(:each) do
          VCR.use_cassette('enroll') do
            @response = @client.enroll(:url => 'http://www.imperialteutonicorder.com/sitebuildercontent/sitebuilderpictures/jesus4.jpg', :subject_id => 'image123abc', :gallery_name => 'randomgallery')
          end
        end
        describe 'response' do
          it 'contains an images array element' do
            @response.first[0].should eq('images')
          end
          it 'contains 2 hash keys' do
            @response.first[1][0].keys.should include('attributes','transaction')
          end
          it 'contains how long it took to complete the task' do
            @response['images'].first['transaction']['timestamp'].should eq("1490747788528")
          end
          it 'contains the status' do
            @response['images'].first['transaction']['status'].should eq('success')
          end
          it 'contains the api assigned face_id' do
            @response['images'].first['transaction']['face_id'].should eq(1)
          end
          it 'contains the subject_id you assigned' do
            @response['images'].first['transaction']['subject_id'].should eq('image123abc')
          end
          it 'contains the gallery_name you assigned' do
            @response['images'].first['transaction']['gallery_name'].should eq('randomgallery')
          end
        end
      end
    end
  end

end