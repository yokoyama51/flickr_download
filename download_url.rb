#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

FlickrawOptions = { :lazyload => true, :timeout => 2 }
require 'flickraw'
require 'flickraw-cached'
require 'open-uri'


# 各キーとユーザID
FlickRaw.api_key= nil
FlickRaw.shared_secret=nil


# 保存先とDLサイズ
url_size = 'url_o'



# photostreamから最近1ヶ月でアップロードしたファイルのみDL対象として処理する
def fetch_photos(flickr, prev_day, user_id, url_size)

  t = Date.today.prev_day(prev_day).strftime("%Y-%m-%d %H:%M:%S")

  tmp = flickr.people.getPhotos :user_id => user_id, :per_page => '1', :min_upload_date => t

  per_page_ = 100
  n = tmp.total.to_i / per_page_ + 1

  for i in 1..n do
    extras = url_size + ",date_taken"
    photo_list = flickr.people.getPhotos :user_id => user_id, :extras => extras, :page => i.to_s, :per_page => per_page_.to_s, :min_upload_date => t

    photo_list.each_with_index do |photo,index|
      datetaken = Date.strptime(photo.datetaken,'%Y-%m-%d %H:%M:%S')
      print("#{photo.url_o} #{photo.datetaken}\n")
    end
  end
end


#main
begin
  prev_day                = ARGV[0]
  user_id                 = ARGV[1]
  FlickRaw.api_key        = ARGV[2]
  FlickRaw.shared_secret  = ARGV[3]
  flickr.access_token     = ARGV[4]
  flickr.access_secret    = ARGV[5]

  fetch_photos(flickr, prev_day.to_i, user_id, url_size)
end
