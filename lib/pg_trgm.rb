require 'pg_trgm/version'

require 'set'

module PgTrgm
  def self.trigrams(v)
    memo = Set.new
    v.to_s.split(/[\W_]+/).each do |word|
      next if word.empty?
      # Each word is considered to have two spaces prefixed and one space suffixed when determining the set of trigrams contained in the string
      word = "  #{word.downcase} "
      word.chars.each_cons(3).map do |cons|
        memo << cons.join
      end
    end
    memo
  end

    
  # inspired by https://gist.github.com/komasaru/41b0c93e264be75eabfa
  def self.similarity(v1, v2)
    v1_trigrams = PgTrgm.trigrams v1
    v2_trigrams = PgTrgm.trigrams v2
    return 0 if v1_trigrams.empty? and v2_trigrams.empty?
    count_dup = (v1_trigrams & v2_trigrams).length
    count_all = (v1_trigrams + v2_trigrams).length
    count_dup / count_all.to_f
  end
  
  def self.sim_ngram(str1, str2, n = 3)
    # 空白文字(半角スペース、改行、復帰、改ページ、水平タブ)は除去
    strings = [str1.gsub(/\s+/, ""), str2.gsub(/\s+/, "")]
    lengths = strings.map { |s| s.split(//).size }
    # 文字列の文字数が N より少なければ例外スロー
    raise "Length of a str1 string is shorter than N(=#{n})" if lengths[0] < n
    raise "Length of a str2 string is shorter than N(=#{n})" if lengths[1] < n

    # N 文字ずつ分割
    arrays = strings.map { |s| s.chars.each_cons(n).collect(&:join) }
    # 重複要素数
    count_dup = (arrays[0] & arrays[1]).size
    # 全要素数
    count_all = (arrays[0] + arrays[1]).uniq.size
    # 類似度返却
    return count_dup / count_all.to_f
  end
  
end
