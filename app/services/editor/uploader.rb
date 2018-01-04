require 'fileutils'
require 'aws-sdk'

module Editor
  class Uploader
    attr_accessor :path, :success, :error

    def initialize(attachment)
      @attachment = attachment
    end

    def execute
      begin
        extension = File.extname(@attachment.path)
        key = ['uploads/editor/', URI.encode(@attachment.original_filename), SecureRandom.hex(15), extension].join

        obj = s3_bucket.object(key)
        obj.upload_file(@attachment.tempfile)
        obj.acl.put({ acl: "public-read" })

        @path = obj.public_url
        @success = true
      rescue Exception => error
        puts error.message
        @error = error.message
      end
    end

    private
      def s3_bucket
        Aws.config.update({
          region: aws_config['region'],
          credentials: Aws::Credentials.new(
            aws_config['access_key_id'],
            aws_config['secret_access_key'],
          )
        })

        resource = Aws::S3::Resource.new
        @bucket ||= resource.bucket(aws_config['bucket'])
      end

      def aws_config
        @config ||= YAML.load(
          ERB.new(File.read("#{Rails.root}/config/aws.yml")).result
        )[Rails.env]
      end
  end
end
