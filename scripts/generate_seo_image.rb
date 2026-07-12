#!/usr/bin/env ruby
# encoding: utf-8
# scripts/generate_seo_image.rb
# Generates a 1200x630 OG image card for a blog post.
#
# Usage:
#   ruby scripts/generate_seo_image.rb <post_path>          # skips if the card exists
#   ruby scripts/generate_seo_image.rb --force <post_path>  # regenerates in place
#   ruby scripts/generate_seo_image.rb --force --all        # regenerates every post's card
#
# Design
# ------
# The card is a 1200x630 rendering of the site's own post hero band, using the
# same tokens as css/theme.css, so the social preview and the page agree:
#
#   surface   --sk-bg-dark  #000000  (or --sk-bg-light #f5f5f7 when hero_tone: light)
#   eyebrow   the category, in the tone's link color
#   title     --sk-text-inverse / --sk-text-primary, 600 weight, tight tracking
#   footer    --sk-text-tertiary, above a --sk-rule hairline
#
# `hero_tone: light` in front matter flips the card exactly as it flips the hero.
#
# Type is Inter — the same face the site serves. ImageMagick cannot read woff2,
# so `font/inter/*.ttf` sit alongside the woff2 files purely for this script.
# They are the same typeface at the same weights (SemiBold 600 / Regular 400),
# which keeps the card machine-independent: no reliance on macOS system fonts.

require 'yaml'
require 'date'

REPO_ROOT = Dir.pwd
SITE_URL  = 'michaellamb.dev'

LOGO_PATH = File.join(REPO_ROOT, 'img', 'favicon.png')
LOGO_SIZE = 340

# Shared, hand-maintained images that a post may *point at* but must never
# overwrite. `seo/default.png` is the site-wide OG fallback declared in
# _config.yml; a couple of older posts set `image: "/seo/default.png"` rather
# than carrying their own card, and without this guard `--all` renders each of
# them straight over the site default.
RESERVED_IMAGES = ['seo/default.png'].freeze

# The logo's letterforms are a rich black (#231F20) over a grey Mississippi
# outline, with cyan/red chromatic fringing. That reads well on the light card
# and disappears entirely on the black one — only the fringes survive. On the
# dark tone the letterforms are recolored to the site's light surface; the
# fringing and the state outline are left alone.
LOGO_INK       = '#231F20'
LOGO_INK_ON_BG = '#f5f5f7' # --sk-bg-light

# --- design tokens, mirrored from css/theme.css ------------------------------

TONES = {
  'dark' => {
    bg:       '#000000',                 # --sk-bg-dark
    title:    '#ffffff',                 # --sk-text-inverse
    tertiary: 'rgba(255,255,255,0.56)',  # --sk-text-inverse-tertiary
    accent:   '#2997ff',                 # --sk-link-dark-bg
    rule:     'rgba(255,255,255,0.12)'   # --sk-rule-inverse
  },
  'light' => {
    bg:       '#f5f5f7',                 # --sk-bg-light
    title:    '#1d1d1f',                 # --sk-text-primary
    tertiary: 'rgba(0,0,0,0.48)',        # --sk-text-tertiary
    accent:   '#0066cc',                 # --sk-link
    rule:     'rgba(0,0,0,0.08)'         # --sk-rule
  }
}.freeze

# Inter, vendored as TTF for ImageMagick's benefit (it cannot read woff2).
# ImageMagick has no fontconfig here, so `-weight` is a no-op on variable fonts
# and collections — the weight must come from the file itself.
FONT_SEMIBOLD = File.join(REPO_ROOT, 'font', 'inter', 'Inter-SemiBold.ttf')
FONT_REGULAR  = File.join(REPO_ROOT, 'font', 'inter', 'Inter-Regular.ttf')

# Last-resort fallbacks if the vendored TTFs are ever missing.
FALLBACK_SEMIBOLD = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FALLBACK_REGULAR  = '/System/Library/Fonts/SFNS.ttf'

def font_semibold
  File.exist?(FONT_SEMIBOLD) ? FONT_SEMIBOLD : FALLBACK_SEMIBOLD
end

def font_regular
  File.exist?(FONT_REGULAR) ? FONT_REGULAR : FALLBACK_REGULAR
end

def magick_binary
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
    File.join(REPO_ROOT, image_val.sub(/^\//, ''))
  else
    basename = File.basename(post_path, '.md')
    unless basename =~ /\A\d{4}-\d{2}-\d{2}-/
      warn "Warning: cannot determine date from filename #{post_path}; skipping generation."
      return nil
    end
    warn "Warning: no 'image' field in front matter for #{post_path}; defaulting to seo/#{basename}.png"
    File.join(REPO_ROOT, 'seo', "#{basename}.png")
  end
end

def generate(post_path, force: false)
  unless convert_available?
    warn 'Warning: ImageMagick not found (`magick` or `convert`). Skipping SEO image generation.'
    warn 'Install with: brew install imagemagick'
    return nil
  end

  fm          = parse_front_matter(post_path)
  output_path = resolve_output_path(fm, post_path)
  return nil if output_path.nil?

  rel_output = output_path.sub("#{REPO_ROOT}/", '')

  if RESERVED_IMAGES.include?(rel_output)
    puts "Shared image, refusing to overwrite: #{rel_output}  (#{File.basename(post_path)} points at it)"
    return output_path
  end

  if File.exist?(output_path) && !force
    puts "SEO image already exists, skipping: #{rel_output}  (use --force to regenerate)"
    return output_path
  end

  title = (fm && fm['title'])&.to_s ||
          File.basename(post_path, '.md').sub(/^\d{4}-\d{2}-\d{2}-/, '').tr('-', ' ').capitalize
  title = "#{title[0..76]}..." if title.length > 79

  category = (fm && fm['category'])&.to_s&.upcase || ''

  date_raw = (fm && fm['date']&.to_s&.[](/\d{4}-\d{2}-\d{2}/)) ||
             File.basename(post_path)[/\d{4}-\d{2}-\d{2}/] || ''
  # Match the byline format the post footer renders: "July 13, 2026"
  date_str = begin
    date_raw.empty? ? '' : Date.parse(date_raw).strftime('%B %-d, %Y')
  rescue ArgumentError
    date_raw
  end

  tone = TONES[(fm && fm['hero_tone']).to_s] || TONES['dark']

  Dir.mkdir(File.join(REPO_ROOT, 'seo')) unless Dir.exist?(File.join(REPO_ROOT, 'seo'))

  semibold = font_semibold
  regular  = font_regular

  # The eyebrow and title are built as one stacked group and composited as a
  # unit, anchored so the title's baseline always sits a fixed distance above
  # the footer rule. Short and long titles then share the same relationship to
  # the rule, and the group simply grows upward as the title wraps.
  #
  # (A fixed-height title box, or centering the group, strands a short title in
  # the middle of a large void — which is what the previous card did.)
  # The logo occupies the right of the card, so the text column is narrowed to
  # clear it. 79 characters (the title cap) still wraps to at most four lines.
  text_width = 640

  # Recolor the logo's ink for the dark tone. Transparent pixels are RGBA
  # (0,0,0,0) and fall inside the fuzz radius, but recoloring a fully
  # transparent pixel is a no-op, so alpha is preserved.
  logo_recolor = tone[:bg] == '#000000' ? ['-fuzz', '15%', '-fill', LOGO_INK_ON_BG, '-opaque', LOGO_INK] : []

  cmd = [
    magick_binary,
    '-size', '1200x630', "xc:#{tone[:bg]}",

    # Logo — right side, centered in the band above the rule.
    *(File.exist?(LOGO_PATH) ? [
      '(',
        LOGO_PATH, *logo_recolor,
        '-resize', "#{LOGO_SIZE}x#{LOGO_SIZE}",
      ')',
      '-gravity', 'NorthEast', '-geometry', "+88+#{(529 - LOGO_SIZE) / 2}", '-composite'
    ] : []),

    '(',
      # Eyebrow — the category, in the tone's link color.
      '(',
        '-size', "#{text_width}x", '-background', 'none',
        '-font', semibold, '-pointsize', '24', '-kerning', '-0.4',
        '-fill', tone[:accent], '-gravity', 'NorthWest',
        "caption:#{category}",
      ')',
      # Gap between eyebrow and title (the hero's 12px, scaled for the card).
      '(', '-size', "#{text_width}x20", 'xc:none', ')',
      # Title — the hero's treatment: 600 weight, negative tracking, tight leading.
      '(',
        '-size', "#{text_width}x", '-background', 'none',
        '-font', semibold, '-pointsize', '62',
        '-kerning', '-0.31', '-interline-spacing', '-6',
        '-fill', tone[:title], '-gravity', 'NorthWest',
        "caption:#{title}",
      ')',
      '-append',
    ')',
    # Bottom of the group sits 60px above the rule (630 - 529 + 60 = 161).
    '-gravity', 'SouthWest', '-geometry', '+88+161', '-composite',

    # Hairline above the footer — --sk-rule.
    '-gravity', 'NorthWest',
    '-fill', tone[:rule], '-draw', 'rectangle 88,529 1112,530',

    # Footer row: site URL left, date right, both tertiary. The logo now carries
    # the brand, so the footer no longer repeats it as a favicon.
    '-font', regular, '-pointsize', '26', '-kerning', '0',
    '-fill', tone[:tertiary],
    '-annotate', '+88+570', SITE_URL,

    '-gravity', 'SouthEast',
    '-font', regular, '-pointsize', '26',
    '-fill', tone[:tertiary],
    '-annotate', '+88+38', date_str,

    '-gravity', 'NorthWest',
    '-depth', '8',
    output_path
  ]

  if system(*cmd)
    puts "Generated SEO image: #{rel_output}"
    output_path
  else
    warn "Warning: SEO image generation failed for #{post_path}."
    warn "Please create #{rel_output} manually before pushing."
    nil
  end
end

if __FILE__ == $PROGRAM_NAME
  args  = ARGV.dup
  force = !args.delete('--force').nil?
  all   = !args.delete('--all').nil?

  posts = all ? Dir[File.join(REPO_ROOT, '_posts', '*.md')].sort : args

  if posts.empty?
    warn 'Usage: ruby scripts/generate_seo_image.rb [--force] [--all] <post_path>'
    exit 1
  end

  posts.each { |p| generate(p, force: force) }
end
