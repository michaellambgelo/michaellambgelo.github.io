#!/usr/bin/env ruby
# encoding: utf-8
# scripts/migrate_seo_images.rb
#
# Regenerates ALL SEO images using generate_seo_image.rb and produces
# a branding-only seo/default.png.
#
# Usage (run from repo root):
#   ruby scripts/migrate_seo_images.rb
#
# A backup of the current seo/ directory is written to seo_backup/ before
# any changes are made. Delete seo_backup/ once you are satisfied.

require 'yaml'
require 'date'
require 'fileutils'

REPO_ROOT = Dir.pwd

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
  @magick_binary ||=
    if system('which magick > /dev/null 2>&1')   then 'magick'
    elsif system('which convert > /dev/null 2>&1') then 'convert'
    end
end

# ---------------------------------------------------------------------------
# default.png — branding-only card (no post metadata)
# ---------------------------------------------------------------------------
def generate_default
  output  = File.join(REPO_ROOT, 'seo', 'default.png')
  favicon = File.join(REPO_ROOT, 'img', 'favicon.png')
  font    = find_font
  font_flags = font ? ['-font', font] : []

  cmd = [
    magick_binary,
    # Background: same left-to-right blue-to-purple gradient as post cards
    '-size', '630x1200', 'gradient:#3b82f6-#8b5cf6', '-rotate', '-90',
    # Favicon centred, large
    *(File.exist?(favicon) ? [
      '(', favicon, '-resize', '200x200', ')',
      '-gravity', 'Center', '-geometry', '+0-60', '-composite',
      '-gravity', 'NorthWest'
    ] : []),
    # Site name as hero text, centred below favicon
    '-gravity', 'Center',
    *font_flags, '-pointsize', '72', '-fill', 'white',
    '-annotate', '+0+130', 'MICHAELLAMB.DEV',
    # Tagline beneath
    *font_flags, '-pointsize', '28', '-fill', '#e2e8f0',
    '-annotate', '+0+215', 'a blog written by a software engineer',
    '-gravity', 'NorthWest',
    '-depth', '8',
    output
  ]

  if system(*cmd)
    puts "Generated: seo/default.png"
  else
    warn "FAILED: seo/default.png"
  end
end

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def image_path_for(post_path)
  content = File.read(post_path, encoding: 'utf-8')
  return nil unless content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m

  fm = YAML.safe_load(Regexp.last_match(1), permitted_classes: [Date, Time]) rescue nil
  return nil unless fm && fm['image']

  image_val = fm['image'].to_s
  return nil if image_val =~ /^https?:\/\//

  File.join(REPO_ROOT, image_val.sub(/^\//, ''))
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
unless magick_binary
  warn 'ImageMagick not found. Install with: brew install imagemagick'
  exit 1
end

# 1. Backup
backup_dir = File.join(REPO_ROOT, 'seo_backup')
if Dir.exist?(backup_dir)
  puts "seo_backup/ already exists — skipping backup (delete it first to re-backup)."
else
  FileUtils.cp_r(File.join(REPO_ROOT, 'seo'), backup_dir)
  puts "Backed up seo/ → seo_backup/"
end

# 2. Remove orphaned files not tied to any post
orphans = %w[career-update.png].map { |f| File.join(REPO_ROOT, 'seo', f) }
orphans.each do |path|
  next unless File.exist?(path)
  File.delete(path)
  puts "Removed orphaned #{path.sub("#{REPO_ROOT}/", '')}"
end

# 3. Generate default.png
puts "\nGenerating default card..."
default_path = File.join(REPO_ROOT, 'seo', 'default.png')
File.delete(default_path) if File.exist?(default_path)
generate_default

# 4. Regenerate every post
posts = Dir.glob(File.join(REPO_ROOT, '_posts', '*.md')).sort
puts "\nRegenerating #{posts.length} posts..."
puts

generated = 0
failed    = 0

posts.each do |post|
  img = image_path_for(post)
  File.delete(img) if img && File.exist?(img)

  output = `ruby scripts/generate_seo_image.rb "#{post}" 2>&1`
  # Strip noisy gem warnings before printing
  clean = output.lines.reject { |l| l.start_with?('Ignoring ') }.join
  print clean unless clean.strip.empty?

  if output.include?('Generated SEO image:')
    generated += 1
  elsif output.include?('already exists')
    warn "WARNING: #{File.basename(post)} image was not deleted before regeneration"
    failed += 1
  else
    warn "FAILED: #{File.basename(post)}"
    failed += 1
  end
end

# 5. Summary + verify
puts
puts "━" * 50
puts "#{generated} generated  |  #{failed} failed"
puts "━" * 50
puts
system('ruby scripts/verify_seo_images.rb')
