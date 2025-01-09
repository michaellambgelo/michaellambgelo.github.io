#!/usr/bin/env ruby
# encoding: utf-8

def is_list_item?(line)
  stripped = line.sub(/^\s*>\s*/, '')  # Remove blockquote marker for checking
  stripped.match?(/^[-*]|\d+\./)
end

def is_blockquote?(line)
  line.start_with?('>')
end

def get_list_context(line)
  indent = line[/^\s*/].length
  is_blockquote = is_blockquote?(line)
  [indent, is_blockquote]
end

def fix_markdown_file(file_path)
  content = File.read(file_path, encoding: 'utf-8')
  
  # Fix trailing spaces (MD009)
  content.gsub!(/[ \t]+$/, '')
  
  # Fix unordered list style (MD004)
  # Replace asterisks with dashes in lists
  content.gsub!(/^\s*\* /, '- ')
  content.gsub!(/^\s*>\s*\* /, '> - ')
  
  # Fix list marker spacing (MD030)
  content.gsub!(/^(\s*[-*])\s{2,}/, '\1 ')
  content.gsub!(/^(\s*>\s*[-*])\s{2,}/, '\1 ')
  
  # Fix ordered list marker spacing
  content.gsub!(/^(\s*\d+\.)\s{2,}/, '\1 ')
  content.gsub!(/^(\s*>\s*\d+\.)\s{2,}/, '\1 ')
  
  # Fix trailing punctuation in headings (MD026)
  content.gsub!(/^(#+[^#\n]+)[.!?](\s*)$/) { |m| "#{$1}#{$2}" }
  
  # Fix multiple consecutive blank lines (MD012)
  content.gsub!(/\n{3,}/, "\n\n")
  
  # Fix heading style (MD003)
  content.gsub!(/^(#+[^#\n]+)#+\s*$/, '\1')
  
  # Process the content line by line
  lines = content.split("\n")
  new_lines = []
  in_embed_block = false
  embed_type = nil
  
  lines.each do |line|
    # Check for various embed block markers
    if line.include?('<blockquote class="twitter-tweet"') ||
       line.include?('<blockquote class="instagram-media"') ||
       (line.include?('<iframe') && 
        (line.include?('spotify.com') || line.include?('docs.google.com')))
      in_embed_block = true
      embed_type = if line.include?('twitter-tweet')
                    'twitter'
                  elsif line.include?('instagram-media')
                    'instagram'
                  elsif line.include?('spotify.com')
                    'spotify'
                  else
                    'google-docs'
                  end
    elsif (line.include?('</blockquote>') && ['twitter', 'instagram'].include?(embed_type)) ||
          (line.include?('</iframe>') && ['spotify', 'google-docs'].include?(embed_type))
      in_embed_block = false
      embed_type = nil
    end
    
    # Skip processing if we're in an embed block
    if in_embed_block
      new_lines << line
      next
    end
    
    # Apply other fixes but skip URL wrapping
    line = line.gsub(/[ \t]+$/, '') # Fix trailing spaces
    line = line.gsub(/^\s*\* /, '- ') # Fix list markers
    line = line.gsub(/^\s*>\s*\* /, '> - ')
    line = line.gsub(/^(\s*[-*])\s{2,}/, '\1 ')
    line = line.gsub(/^(\s*>\s*[-*])\s{2,}/, '\1 ')
    line = line.gsub(/^(\s*\d+\.)\s{2,}/, '\1 ')
    line = line.gsub(/^(\s*>\s*\d+\.)\s{2,}/, '\1 ')
    line = line.gsub(/^(#+[^#\n]+)[.!?](\s*)$/) { |m| "#{$1}#{$2}" }
    line = line.gsub(/^(#+[^#\n]+)#+\s*$/, '\1')
    
    new_lines << line
  end
  
  content = new_lines.join("\n")
  # Fix multiple consecutive blank lines
  content.gsub!(/\n{3,}/, "\n\n")
  
  # Fix ordered list numbering (MD029)
  lines = content.split("\n")
  list_counters = {}  # Track counters for different indent levels and blockquote states
  
  lines.map! do |line|
    indent, is_blockquote = get_list_context(line)
    list_key = "#{indent}-#{is_blockquote}"
    
    if line.match?(/^\s*(?:>\s*)?\d+\. /)
      list_counters[list_key] = 1 unless list_counters.key?(list_key)
      line = line.sub(/(\s*(?:>\s*)?)\d+/, "\\1#{list_counters[list_key]}")
      list_counters[list_key] += 1
    else
      list_counters.delete(list_key) if line.strip.empty?
    end
    line
  end
  
  content = lines.join("\n")
  
  # Fix blanks around fenced code blocks (MD031)
  lines = content.split("\n")
  new_lines = []
  in_code_block = false
  
  lines.each_with_index do |line, i|
    is_fence = line.match?(/^```/)
    prev_blank = i == 0 || lines[i-1].strip.empty?
    next_blank = i == lines.length - 1 || lines[i+1].strip.empty?
    
    new_lines << "" if is_fence && !prev_blank
    new_lines << line
    new_lines << "" if is_fence && !next_blank && !in_code_block
    
    in_code_block = !in_code_block if is_fence
  end
  
  content = new_lines.join("\n")
  
  # Fix list indentation (MD007)
  content.gsub!(/^(\s{2,})([-*])/, '\2')
  content.gsub!(/^(\s*>\s*\s{2,})([-*])/, '\1')
  
  # Fix multiple consecutive blank lines (MD012) - one final pass
  content.gsub!(/\n{3,}/, "\n\n")
  
  # Ensure single newline at end of file (MD047)
  content = content.strip + "\n"
  
  # Write the fixed content back to the file
  File.write(file_path, content, encoding: 'utf-8')
end

def process_markdown_files
  posts_dir = File.join(Dir.pwd, '_posts')
  
  Dir.glob(File.join(posts_dir, '*.md')).each do |file|
    puts "Fixing #{File.basename(file)}..."
    fix_markdown_file(file)
  end
end

if __FILE__ == $0
  process_markdown_files
end
