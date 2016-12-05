#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

FlickrawOptions = { :lazyload => true, :timeout => 2 }
require 'flickraw'
require 'flickraw-cached'
require 'open-uri'
require 'fileutils'


# 各キーとユーザID
FlickRaw.api_key= nil
FlickRaw.shared_secret=nil


# 保存先とDLサイズ
url_size = 'url_o'

# urlとディレクトリを指定しファイルを保存
# ディレクトリの存在をチェックし、なければ作成する
# すでにDL済みファイル(=ファイル名でチェック)はスキップする
def save_file(url,dir)
  FileUtils.mkdir_p(dir) unless File.exist?(dir)

  filename = File.join(dir ,File.basename(url))
  if File.exist?(filename) == false then
    open(filename, 'wb') do |file|
      open(url) do |data|
        file.write(data.read)
      end
    end
  else
    puts "  ->skip"
  end
end


# photostreamから最近1ヶ月でアップロードしたファイルのみDL対象として処理する
def fetch_photos(flickr, user_id, base_dir, url_size)

  last_update = Time.now - 31*(60*60*24) #1ヶ月前
  t = last_update.strftime("%Y-%m-%d %H:%M:%S")

  tmp = flickr.people.getPhotos :user_id => user_id, :per_page => '1', :min_upload_date => t

  per_page_ = 100
  n = tmp.total.to_i / per_page_ + 1

  for i in 1..n do
    extras = url_size + ",date_taken"
    photo_list = flickr.people.getPhotos :user_id => user_id, :extras => extras, :page => i.to_s, :per_page => per_page_.to_s, :min_upload_date => t

    photo_list.each_with_index do |photo,index|
      datetaken = Date.strptime(photo.datetaken,'%Y-%m-%d %H:%M:%S')
      print("#{per_page_*(i-1)+index+1}/#{tmp.total} #{photo.url_o} #{photo.datetaken}\n")

      save_file(photo.url_o, File.join(base_dir, datetaken.year.to_s))
    end
  end
end


#main
begin
  puts ARGV.count

  base_dir = ARGV[0]
  user_id  = ARGV[1]
  FlickRaw.api_key = ARGV[2]
  FlickRaw.shared_secret = ARGV[3]
  flickr.access_token  = ARGV[4]
  flickr.access_secret = ARGV[5]

  fetch_photos(flickr, user_id, base_dir, url_size)
end
