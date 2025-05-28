require 'googleauth'
require 'google/apis/gmail_v1'
require 'fileutils'
require 'date'

# Gmail APIのセットアップ
Gmail = Google::Apis::GmailV1
gmail_service = Gmail::GmailService.new
gmail_service.client_options.application_name = 'DMARC Report Fetcher'
gmail_service.authorization = Google::Auth.get_application_default(
  ['https://www.googleapis.com/auth/gmail.readonly']
)

# 引数で日付範囲を受け取る (フォーマット: YYYY-MM-DD)
start_date = ARGV[0] ? Date.parse(ARGV[0]) : Date.today - 7
end_date   = ARGV[1] ? Date.parse(ARGV[1]) : Date.today

# Gmailの検索クエリを作成
query = [
  'has:attachment',
  'subject:(dmarc)',
  "after:#{start_date.strftime('%Y/%m/%d')}",
  "before:#{(end_date + 1).strftime('%Y/%m/%d')}"
].join(' ')

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
result.messages.each do |msg|
  message = gmail_service.get_user_message(user_id, msg.id)
  p message

  parts = message.payload.parts || []
  parts.each do |part|
    next unless part.filename && part.body.attachment_id

    attachment = gmail_service.get_user_message_attachment(user_id, msg.id, part.body.attachment_id)
    file_path = File.join(output_dir, part.filename)

    File.open(file_path, 'wb') do |file|
      file.write(attachment.data.unpack1('m0'))  # Base64デコードして書き込む
    end

    puts "保存しました: #{file_path}"
  end
end
