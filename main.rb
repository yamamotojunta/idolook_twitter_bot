# -*- coding: utf-8 -*-
require 'mechanize'
require 'twitter'
require './const.rb'

agent = Mechanize.new
agent.user_agent_alias = 'Windows Mozilla'
agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

page = agent.get('https://idolook.aikatsu.com/')

main_page = agent.page.form_with(:id => 'MMemberLoginForm') do |form|
  form.field_with(:id => 'MMemberMail'){|field|
    field.value = USER_NAME
  }
  form.field_with(:id => 'MMemberPassword'){|field|
    field.value = USER_PASSWORD
  }
  form.click_button
end.submit

def conv_date(d)
  date = Date.strptime(d, "%Y年%m月%d日")
  today = Date::today

  diff = (today - date).to_i

  if diff == 0
    '今日アイカツしたよ！'
  elsif diff > 0 and (7 * 4) > diff
    diff.to_s + '日前にアイカツしたよ！'
  else
    '4週間以上アイカツしてないよ！'
  end
end

# // ニックネーム
# .profData .nickname span
# // 遊んだ日
# .profData .date
# 
# // ランク
# #dateArea .rank
# // 現行段ファン数 [XX 人]
# #dateArea .funCount
# // トータルファン数
# #dateArea .funTotalCount [XX人]
# 
# // コイン数
# #coinCun span

nickname    = main_page.search('.profData .nickname span').text.strip
play_date   = main_page.search('.profData .date').text.strip
rank        = main_page.search('#dateArea .rank').text.strip
current_fun = main_page.search('#dateArea .funCount').text.delete('人').strip
total_fun   = main_page.search('#dateArea .funTotalCount').text.delete('人').strip
coin        = main_page.search('#coinCun span').text.strip

tweet = <<OUT
#{nickname}ちゃんは#{conv_date(play_date)}(遊んだ日#{play_date})。
ランクは#{rank}。ファン数は#{current_fun}/#{total_fun}(現段/合計)だよ。
アイカツコインは#{coin}枚！
OUT

# # debug code
# p nickname
# p play_date
# p rank
# p current_fun
# p total_fun
# p coin
# 
# p NKF.nkf('-wxm0', main_page.body)

# Tweet
client = Twitter::REST::Client.new do |config|
    config.consumer_key        = TWITTER_CONSUMER_KEY
    config.consumer_secret     = TWITTER_CONSUMER_SECRET
    config.access_token        = TWITTER_ACCESS_TOKEN
    config.access_token_secret = TWITTER_ACCESS_TOKEN_SECRET
end

client.update(tweet)
# p tweet
