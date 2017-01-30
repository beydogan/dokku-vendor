require 'sinatra'
require 'ap'
require "open-uri"

DOWNLOAD_DIR = "/tmp/dokku-vendor/"
VENDOR_URL = "https://s3-external-1.amazonaws.com/"

get '/:buildpack/*.tgz' do
  buildpack = params[:buildpack]
  file_path = params[:captures][1]
  send_file get_file(buildpack, file_path)
end

def get_file(buildpack, file_path)
  if file_path.include? "/"
    file_data = file_path.split("/")
    dir = file_data[0]
    file_name = file_data[1] + ".tgz"
  else
    dir = ""
    file_name = file_path + ".tgz"
  end

  absolute_dir_path = DOWNLOAD_DIR + buildpack + "/" + dir
  absolute_file_path = absolute_dir_path + "/#{file_name}"

  if File.exists?(absolute_file_path)
    return absolute_file_path
  else
    puts "NO FILE - DOWNLOAD"
    FileUtils.mkdir_p  absolute_dir_path unless File.exists?(absolute_dir_path) # Create dir first
    remote_url = VENDOR_URL + "#{buildpack}/#{file_path}.tgz"
    download_file(absolute_file_path, remote_url)
    get_file(buildpack, file_path)
  end
end

def download_file(local_path, remote_url)
  ap "DOWNLOADING FILE"
  ap remote_url
  File.open(local_path, "w") do |f|
    IO.copy_stream(open(remote_url), f)
  end

end
