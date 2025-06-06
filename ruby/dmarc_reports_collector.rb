require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/gmail_v1'
require 'fileutils'
require 'date'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'DMARC Report Fetcher'
CREDENTIALS_PATH = ENV['CREDENTIALS_PATH'] || '/app/credentials.json'
TOKEN_PATH = ENV['TOKEN_PATH'] || '/app/token.yaml'
SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the resulting code after authorization:\n" + url
    print "Enter code: "
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

# Gmail APIのセットアップ
Gmail = Google::Apis::GmailV1
gmail_service = Gmail::GmailService.new
gmail_service.client_options.application_name = APPLICATION_NAME
gmail_service.authorization = authorize

# 引数で日付範囲を受け取る (フォーマット: YYYY-MM-DD)
# 日付を受け取らない場合は、前日分が対象となる
start_date = ARGV[0] ? Date.parse(ARGV[0]) : (Date.today - 1)
end_date   = ARGV[1] ? Date.parse(ARGV[1]) : (Date.today - 1)

# Gmailの検索クエリを作成
# before, afterの指定は日付指定だとPSTタイムゾーンで解釈されてしまうため、UNIXタイムスタンプに変換する
# https://developers.google.com/workspace/gmail/api/guides/filtering?hl=ja
query = [
  'has:attachment',
  'from:(dmarc)',
  "after:#{start_date.to_time.to_i}",
  "before:#{(end_date + 1).to_time.to_i}"
].join(' ')

puts "#{start_date} ~ #{end_date} のDMARCレポートを検索します。"
puts "検索クエリ: #{query}"

# ユーザーID（'me' は認証されたユーザーを指します）
user_id = 'me'

# メールを検索
result = gmail_service.list_user_messages(user_id, q: query)

if result.messages.nil? || result.messages.empty?
  puts "対象のメールは見つかりませんでした。"
  exit
end

# 出力先ディレクトリを準備
output_dir = '/files'
#FileUtils.mkdir_p(output_dir)

# 各メッセージに対して添付ファイルを保存
page_token = nil

loop do
  result = gmail_service.list_user_messages(user_id, q: query, page_token: page_token)
  break if result.messages.nil? || result.messages.empty?

  result.messages.each do |msg|
    message = gmail_service.get_user_message(user_id, msg.id)
    # メールの形式によってpartsがnilになることがあるようなので、その場合はpayloadを直接使用する
    parts = message.payload.parts || [message.payload]

    parts.each do |part|
      next unless part.filename && part.filename != '' && part.body && part.body.attachment_id

      attachment = gmail_service.get_user_message_attachment(user_id, msg.id, part.body.attachment_id)
      file_path = File.join(output_dir, part.filename)

      File.open(file_path, 'wb') do |file|
        file.write(attachment.data)
      end

      headers = part.headers.map{|h| [h.name, h.value]}.to_h
      received_time = headers['X-Received'] ? Time.parse(headers['X-Received'].split(";")[1]).localtime : nil
      puts "----------------------------"
      puts "Subject:#{headers['Subject']}" 
      puts "Received Time: #{received_time}"
      puts "File: #{file_path}"
    end
  end

  # 次のページがある場合は、ページトークンを更新（1回あたり最大100件までしかとれないため）
  page_token = result.next_page_token
  break unless page_token
end
