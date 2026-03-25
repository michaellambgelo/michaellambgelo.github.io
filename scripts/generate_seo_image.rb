#!/usr/bin/env ruby
# encoding: utf-8
# scripts/generate_seo_image.rb
# Generates a 1200x630 OG image card for a blog post.
# Usage: ruby scripts/generate_seo_image.rb <post_path>

require 'yaml'
require 'date'

REPO_ROOT = Dir.pwd
SITE_URL  = 'HTTPS://MICHAELLAMB.DEV'
TAGLINE   = 'a blog written by a software engineer'

FAVICON_PATH = File.join(REPO_ROOT, 'img', 'favicon.png')

FONT_CANDIDATES = [
  '/System/Library/Fonts/HelveticaNeue.ttc',
  '/System/Library/Fonts/Helvetica.ttc',
  '/Library/Fonts/HelveticaNeue.ttc',
  '/Library/Fonts/Helvetica.ttc',
  '/Library/Fonts/Avenir Next.ttc',
  nil
].freeze

def find_font
  FONT_CANDIDATES.find { |f| f.nil? || File.exist?(f) }
end

def magick_binary
  # ImageMagick 7 prefers `magick`; fall back to `convert` for older versions
  @magick_binary ||= begin
    if system('which magick > /dev/null 2>&1')
      'magick'
    elsif system('which convert > /dev/null 2>&1')
      'convert'
    end
  end
end

def convert_available?
  !magick_binary.nil?
end

def parse_front_matter(post_path)
  content = File.read(post_path, encoding: 'utf-8')
  return nil unless content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m

  YAML.safe_load(Regexp.last_match(1), permitted_classes: [Date, Time])
rescue => e
  warn "Warning: could not parse front matter for #{post_path}: #{e.message}"
  nil
end

def resolve_output_path(fm, post_path)
  if fm && fm['image']
    image_val = fm['image'].to_s
    if image_val =~ /^https?:\/\//
      warn "Warning: 'image' field is a URL for #{post_path}; skipping generation."
      return nil
    end
    rel = image_val.sub(/^\//, '')
    File.join(REPO_ROOT, rel)
  else
    date_str = File.basename(post_path)[/\d{4}-\d{2}-\d{2}/]
    unless date_str
      warn "Warning: cannot determine date from filename #{post_path}; skipping generation."
      return nil
    end
    warn "Warning: no 'image' field in front matter for #{post_path}; defaulting to seo/#{date_str}.png"
    File.join(REPO_ROOT, 'seo', "#{date_str}.png")
  end
end

def generate(post_path)
  unless convert_available?
    warn 'Warning: ImageMagick not found (`magick` or `convert`). Skipping SEO image generation.'
    warn 'Install with: brew install imagemagick'
    return nil
  end

  fm          = parse_front_matter(post_path)
  output_path = resolve_output_path(fm, post_path)
  return nil if output_path.nil?

  rel_output = output_path.sub("#{REPO_ROOT}/", '')

  if File.exist?(output_path)
    puts "SEO image already exists, skipping: #{rel_output}"
    return output_path
  end

  title    = (fm && fm['title'])&.to_s ||
             File.basename(post_path, '.md').sub(/^\d{4}-\d{2}-\d{2}-/, '').tr('-', ' ').capitalize
  title    = "#{title[0..76]}..." if title.length > 79
  category = (fm && fm['category'])&.to_s&.upcase || ''
  date_str = (fm && fm['date']&.to_s&.[](/\d{4}-\d{2}-\d{2}/)) ||
             File.basename(post_path)[/\d{4}-\d{2}-\d{2}/] || ''

  Dir.mkdir(File.join(REPO_ROOT, 'seo')) unless Dir.exist?(File.join(REPO_ROOT, 'seo'))

  font = find_font
  font_flags = font ? ['-font', font] : []

  cmd = [
    magick_binary,
    # 1. Background: left-to-right blue-to-purple gradient
    #    Create vertical gradient then rotate -90° so blue is on left, purple on right
    '-size', '630x1200', 'gradient:#3b82f6-#8b5cf6', '-rotate', '-90',
    # 2. Left accent bar (white for contrast against gradient)
    '-fill', 'white', '-draw', 'rectangle 55,0 59,630',
    # 3. Tagline
    *font_flags, '-pointsize', '26', '-fill', '#e2e8f0',
    '-annotate', '+90+75', TAGLINE,
    # 4. Category pill background (white pill, purple text)
    '-fill', 'white', '-draw', 'roundrectangle 88,90 368,130 8,8',
    # 5. Category pill text
    *font_flags, '-pointsize', '22', '-fill', '#5a4fcf',
    '-annotate', '+102+121', category,
    # 6. Title caption (word-wraps to fit 1000x330 box)
    '(', '-size', '1000x400', '-background', 'none',
    *font_flags, '-fill', 'white', '-pointsize', '72',
    "caption:#{title}",
    ')',
    '-geometry', '+88+148', '-composite',
    # 7. URL footer: SouthWest +x+y = x from left, y from bottom
    '-gravity', 'SouthWest',
    *font_flags, '-pointsize', '26', '-fill', '#e2e8f0',
    '-annotate', '+90+36', SITE_URL,
    # 8. Date footer: SouthEast +x+y = x from right, y from bottom
    #    Offset enough to clear the 128x128 favicon at +40+40 (favicon left edge ≈ 1032px)
    '-gravity', 'SouthEast',
    *font_flags, '-pointsize', '26', '-fill', '#e2e8f0',
    '-annotate', '+215+36', date_str,
    # 10. Favicon: SouthEast 128x128, composited last so nothing overlaps it
    *(File.exist?(FAVICON_PATH) ? [
      '(', FAVICON_PATH, '-resize', '128x128', ')',
      '-geometry', '+40+40', '-composite'
    ] : []),
    # Reset gravity for any future operations
    '-gravity', 'NorthWest',
    # Output
    '-depth', '8',
    output_path
  ]

  success = system(*cmd)
  if success
    puts "Generated SEO image: #{rel_output}"
    output_path
  else
    warn "Warning: SEO image generation failed for #{post_path}."
    warn "Please create #{rel_output} manually before pushing."
    nil
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    warn "Usage: ruby scripts/generate_seo_image.rb <post_path>"
    exit 1
  end
  generate(ARGV[0])
end
