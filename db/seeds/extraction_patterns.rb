# frozen_string_literal: true

extraction_patterns = [
  {
    sender_email_domain: 'plac.jp',
    pattern_type: 'price',
    pattern: '■価[ \\s]*格:(\\d{1,3}(,\\d{3})*)万円',
    description: 'PLAC用価格パターン',
    priority: 1
  },
  {
    sender_email_domain: 'kenbiya.com',
    pattern_type: 'price',
    pattern: '価格/利回り:([\\d,]+)万?円?',
    description: '健美家価格パターン',
    priority: 1
  },
  {
    sender_email_domain: 'rakumachi.jp',
    pattern_type: 'separator',
    pattern: '◆\\d+◆-+\\s*(.+?)\\s*(物件種別[\\s\\S]+?)(?=◆|\\z)',
    description: '楽侍区切りパターン',
    priority: 1
  },
  {
    sender_email_domain: 'rakumachi.jp',
    pattern_type: 'price',
    pattern: '価格\\s*:\\s*([\\d,]+)?万?円',
    description: '楽侍価格パターン',
    priority: 1
  },
  {
    sender_email_domain: 'athome.jp',
    pattern_type: 'separator',
    pattern: '={32}\\s*(.+?)\\s*={32}\\s*([\\s\\S]*?)(?=={32}|\\z)',
    description: 'アットホーム区切りパターン',
    priority: 1
  },
  {
    sender_email_domain: 'athome.jp',
    pattern_type: 'price',
    pattern: '^([\\d,]+)万円(?:\\s*\(管理費等:[^)]*\\))?\\s*(?:使用部分:)?',
    description: 'アットホーム価格パターン',
    priority: 1
  }
]

extraction_patterns.each do |pattern_data|
  ExtractionPattern.find_or_create_by!(
    sender_email_domain: pattern_data[:sender_email_domain],
    pattern_type: pattern_data[:pattern_type]
  ) do |pattern|
    pattern.pattern = pattern_data[:pattern]
    pattern.description = pattern_data[:description]
    pattern.priority = pattern_data[:priority]
    pattern.save!
  end
end

puts 'Extraction patterns seeded successfully!'
