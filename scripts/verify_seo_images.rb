#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'pathname'

def verify_seo_images
  posts_dir = File.join(Dir.pwd, '_posts')
  seo_dir = File.join(Dir.pwd, 'seo')
  issues = []

  # Create seo directory if it doesn't exist
  Dir.mkdir(seo_dir) unless Dir.exist?(seo_dir)

  # Check if default SEO image exists
  default_seo = File.join(seo_dir, 'default.png')
  issues << "Missing default SEO image: #{default_seo}" unless File.exist?(default_seo)

  # Scan all posts
  Dir.glob(File.join(posts_dir, '*.md')).each do |post|
    begin
      content = File.read(post, encoding: 'utf-8')
      # Extract YAML front matter
      if content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
        front_matter = YAML.safe_load($1, permitted_classes: [Time])
        
        if front_matter && front_matter['image']
          image_path = front_matter['image']
          # Remove leading slash if present
          image_path = image_path.sub(/^\//, '')
          full_path = File.join(Dir.pwd, image_path)
          
          unless File.exist?(full_path)
            issues << "Missing SEO image for post #{File.basename(post)}: #{image_path}"
          end
        else
          issues << "No SEO image specified in front matter for: #{File.basename(post)}"
        end
      end
    rescue => e
      issues << "Error processing #{File.basename(post)}: #{e.message}"
    end
  end

  if issues.empty?
    puts "✅ All SEO images verified successfully!"
  else
    puts "❌ Found #{issues.length} issue(s):"
    issues.each { |issue| puts "  - #{issue}" }
    exit 1
  end
end

if __FILE__ == $0
  verify_seo_images
end
