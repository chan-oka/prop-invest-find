# frozen_string_literal: true

require 'nokogiri'
require 'cgi'

class HtmlCleanerService
  def self.html_to_plain_text(html_content)
    return '' unless html_content.present?

    # HTMLをパース
    doc = Nokogiri::HTML(html_content)

    # スクリプトとスタイルタグを削除
    doc.search('script, style').remove

    # テキストのみを抽出
    text = doc.text

    # 連続する空白文字を1つの空白に置換
    text = text.gsub(/\s+/, ' ')

    # 先頭と末尾の空白を削除
    text = text.strip

    # HTMLエンティティをデコード
    CGI.unescapeHTML(text)
  end
end
