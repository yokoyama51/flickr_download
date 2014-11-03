#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

FlickrawOptions = { :lazyload => true, :timeout => 2 }
require 'flickraw-cached'
require 'open-uri'
require 'fileutils'


# 各キーとユーザID
FlickRaw.api_key="xxxx"
FlickRaw.shared_secret="xxxx"
flickr.access_token = "xxxxx"
flickr.access_secret = "xxxx" 
user_id = "xxxx"

# 保存先とDLサイズ
base_dir = "/mnt/usbhdd/pic/flickr/"
url_size = 'url_o'

# urlとディレクトリを指定しファイルを保存
# ディレクトリの存在をチェックし、なければ作成する
# すでにDL済みファイル(=ファイル名でチェック)はスキップする
def save_file(url,dir)
  FileUtils.mkdir_p(dir) unless File.exist?(dir)
  
  filename = dir + File.basename(url)
  if File.exist?(filename) == false then
     open(dir + File.basename(url), 'wb') do |file|
       open(url) do |data|
         file.write(data.read)
       end
     end
  else
     puts "  ->skip"
  end
end


# photostreamから最近1ヶ月でアップロードしたファイルのみDL対象として処理する
def fetch_photos(user_id, base_dir, url_size)
 
  last_update = Time.now - 31*(60*60*24) #1ヶ月前
  t = last_update.strftime("%Y-%m-%d %H:%M:%S")

  tmp = flickr.people.getPhotos :user_id => user_id, :per_page => '1', :min_upload_date => t
  
  per_page_ = 100
  n = tmp.total.to_i / per_page_ + 1
  
  cnt = 1
  for i in 1..n do
  	photo_list = flickr.people.getPhotos :user_id => user_id, :extras => url_size, :page => i.to_s, :per_page => per_page_.to_s, :min_upload_date => t
  	

	photo_list.each_with_index do |photo,index|
		
		print("#{per_page_*(i-1)+index+1}/#{tmp.total} #{photo.url_o}\n") 
		save_file(photo.url_o, base_dir)
	end
  end
end


#main
begin
  fetch_photos(user_id, base_dir, url_size)
end
