module Mpx::DownloadToken
  #
  # returns a download token for the self model. The download_token
  # might include the file size
  def download_token
    opts = { :access => "download" }
    opts[:file_size] = file_size if self.respond_to?(:file_size)

    ModelToken.for(self, opts).to_s
  end

  def token_download_filename
    File.basename(public_filename)
  end
  
  def download_url
    "#{MPCP_URL}/download/#{token_download_filename}?token=#{download_token}"
  end

  def self.validate(token)
    ModelToken.validate(token, :access => "download")
  end

  def self.validated_model(token)
    validate(token).model
  end
end
