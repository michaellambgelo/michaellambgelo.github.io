# Guided Tour: michaellambgelo.github.io

## Overview

This is a comprehensive guided tour of Michael Lamb's Jekyll-powered static blog, showcasing modern web development practices, automated workflows, and thoughtful content management. The site demonstrates professional-grade CI/CD implementation, SEO optimization, and user experience enhancements.

The content was generated using Claude Sonnet 4 and Windsurf Cascade and edited by Michael for accuracy.

**Live Site:** https://blog.michaellamb.dev

**Repository:** https://github.com/michaellambgelo/michaellambgelo.github.io

---

### 🏗️ Architecture & Technology Stack

### Core Technologies

- **Jekyll 4.x** - Static site generator with Ruby
- **Bootstrap 2.x** - Responsive CSS framework (legacy but functional)
- **jQuery 1.9.1** - JavaScript library for interactivity
- **GitHub Pages** - Hosting and deployment platform
- **GitHub Actions** - CI/CD automation

### Key Features

- **52+ blog posts** spanning 4+ years of content
- **Developer-focused comment system** powered by Giscus and GitHub Discussions
- **SEO optimization** with automated image verification
- **Newsletter integration** via Hakanai.io
- **Monitoring integration** with Grafana Faro Web SDK
- **Responsive design** with mobile-first approach

---

## 🚀 Demonstration Flow

### 1. Site Navigation & User Experience

**Start Here:** Visit https://blog.michaellamb.dev

#### Homepage Features

- **Clean, professional layout** with Bootstrap grid system
- **Bio section** with author photo and social links
- **Recent posts** with pagination (5 posts per page)
- **Responsive navbar** with dropdown menus for categories/tags
- **Newsletter signup** prominently featured

#### Navigation Structure

```text
├── Home (/)
├── Categories (dropdown)
│   ├── Development
│   ├── Infrastructure  
│   ├── Machine Intelligence
│   ├── Community
│   ├── Projects
│   ├── Tutorials
│   └── Reflections
├── GitHub Projects (dropdown)
├── External Links (dropdown)
└── Newsletter (/newsletter.html)
```

**Demo Points:**

- Show responsive design by resizing browser
- Navigate through different categories
- Demonstrate dropdown functionality
- Show newsletter signup form

### 2. Content Management & Structure

#### Blog Post Structure

**Example Post:** `/2025-09-30-comfort-movies/`

**Front Matter Example:**

```yaml
---
title: Why any movie can be a comfort movie
image: seo/2025-09-30.png
category: personal
date: '2025-09-30 00:00:00'
tags:
- movies
- personal
- opinion
layout: post
---
```

**Demo Points:**

- Show how posts are organized by date
- Explain the taxonomy system (categories + tags)
- Demonstrate SEO image integration
- Show embedded media (YouTube videos)

#### Content Templates

Located in `_templates/`:

- **Post Template** (`post.md`) - Standardized format for new posts
- **Taxonomy Guide** (`taxonomy.md`) - Comprehensive tag/category system

**Demo the Taxonomy System:**

```text
Categories (1 per post):
├── development
├── infrastructure
├── machine-intelligence
├── community
├── projects
├── tutorials
└── reflections

Tags (2-5 per post):
├── Technology: golang, kubernetes, docker, raspberry-pi
├── Content Type: tutorial, feature, guide, review
├── Projects: cluster, web-app, api, automation
└── General: community, learning, troubleshooting
```

### 3. CI/CD Pipeline & Quality Assurance

#### GitHub Actions Workflow (`.github/workflows/ci.yml`)

**Automated Checks on Every Push/PR:**

1. **Ruby Environment Setup**

   ```yaml
   - Ruby 2.7.4 with bundler caching
   - Dependency installation with Bundler 2.4.22
   ```

2. **Jekyll Build Verification**

   ```bash
   bundle exec jekyll build --safe
   ```

3. **SEO Image Verification**

   ```bash
   ruby scripts/verify_seo_images.rb
   ```

4. **Markdown Linting**

   ```yaml
   - DavidAnson/markdownlint-cli2-action@v11
   - Custom rules in .markdownlint.json
   ```

5. **Front Matter Validation**

   ```bash
   bundle exec jekyll doctor
   bundle exec jekyll build --strict_front_matter
   ```

**Demo Points:**

- Show recent workflow runs in GitHub Actions
- Explain how failures prevent deployment
- Demonstrate the safety net for content quality

### 4. Git Hooks & Local Development

#### Pre-Commit Hook (`git-hooks/pre-commit`)

```bash
# Runs markdownlint on staged markdown files
# Prevents commits with formatting issues
# Can be bypassed with --no-verify
```

#### Pre-Push Hook (`git-hooks/pre-push`)

```bash
# Runs SEO image verification
# Prevents pushing without required images
# Ensures content completeness
```

**Installation:**

```bash
chmod +x scripts/install-hooks.sh
./scripts/install-hooks.sh
```

**Demo Points:**

- Show how hooks prevent bad commits
- Explain the safety mechanisms
- Demonstrate bypass options for emergencies

### 5. SEO & Performance Optimization

#### SEO Image System

**Every post requires an SEO image:**

- Located in `/seo/` directory
- Named by post date (e.g., `2025-09-30.png`)
- Verified by automated script
- Fallback to `default.png`

#### SEO Features

- **Jekyll SEO Tag** plugin for meta tags
- **Structured data** for search engines
- **Open Graph** and **Twitter Card** support
- **RSS feed** for syndication
- **Sitemap** generation

#### Performance Features

- **Static site generation** for fast loading
- **CDN delivery** via GitHub Pages
- **Responsive images** with proper sizing
- **Minified CSS/JS** for production

### 6. Newsletter Integration

#### Hakanai.io Integration

**Two newsletter touchpoints:**

1. **Dedicated Newsletter Page** (`/newsletter.html`)
   - Full-featured signup experience
   - Detailed benefits explanation
   - Professional styling

2. **Inline Newsletter Widget** (on all pages)
   - Subtle call-to-action
   - Consistent branding
   - Non-intrusive placement

**Demo Points:**

- Show both newsletter forms
- Explain the dual-approach strategy
- Demonstrate responsive design

### 7. Monitoring & Analytics

#### Grafana Faro Web SDK Integration

```javascript
// Environment-specific configuration
// Local development: no-cors mode
// Production: full monitoring
```

**Features:**

- **Real User Monitoring (RUM)**
- **Error tracking and reporting**
- **Performance metrics collection**
- **User interaction analytics**

### 8. Content Showcase

#### Diverse Content Portfolio

**52+ posts covering:**

- **Technical Tutorials** (Kubernetes, Docker, Go)
- **Project Showcases** (Grafana Faro Proxy, Letterboxd Viewer)
- **Community Content** (MagnoliaJS, Jackson Devs)
- **Personal Reflections** (Movies, Life Updates)
- **Infrastructure Deep-Dives** (K3s, Raspberry Pi Clusters)

#### Recent Highlights

- **Machine Intelligence series** (AI/ML exploration)
- **Grafana Faro implementation** (Monitoring setup)
- **Community survey results** (Jackson Devs)
- **Personal movie analysis** (Comfort Films essay)

---

## 🎯 Key Demonstration Points

### For Technical Audiences

1. **Modern CI/CD Pipeline** - Automated testing, linting, and validation
2. **Quality Gates** - Pre-commit hooks and automated checks
3. **SEO Automation** - Image verification and metadata management
4. **Performance Optimization** - Static generation with CDN delivery
5. **Monitoring Integration** - Real-time performance tracking

### For Content Creators

1. **Structured Content Management** - Templates and taxonomy system
2. **SEO Best Practices** - Automated image requirements and metadata
3. **User Experience Focus** - Commenting, search, and navigation
4. **Newsletter Integration** - Multiple touchpoints for audience building
5. **Responsive Design** - Mobile-first approach

### For Business Stakeholders

1. **Professional Presentation** - Clean, modern design
2. **Content Discoverability** - Advanced filtering and categorization
3. **Audience Engagement** - Newsletter integration and social links
4. **Reliability** - Automated testing and quality assurance
5. **Scalability** - Static site architecture with GitHub Pages

---

## 🔧 Local Development Setup

### Prerequisites

```bash
# Ruby 2.7.4 (check .ruby-version)
# Bundler 2.4.22
# Git hooks (optional but recommended)
```

### Quick Start

```bash
# Clone the repository
git clone https://github.com/michaellambgelo/michaellambgelo.github.io.git
cd michaellambgelo.github.io

# Install dependencies
gem install bundler -v 2.4.22
bundle install

# Install git hooks (recommended)
chmod +x scripts/install-hooks.sh
./scripts/install-hooks.sh

# Start development server
bundle exec jekyll serve

# Visit http://localhost:4000
# Admin panel: http://localhost:4000/admin
```

### Development Workflow

1. **Create new post** using template or admin panel
2. **Add SEO image** to `/seo/` directory
3. **Test locally** with `bundle exec jekyll serve`
4. **Verify SEO images** with `ruby scripts/verify_seo_images.rb`
5. **Commit changes** (hooks will run automatically)
6. **Push to GitHub** (CI/CD pipeline will validate)

---

## 📊 Metrics & Success Indicators

### Content Metrics

- **52+ blog posts** over 4+ years
- **7 categories** with consistent taxonomy
- **50+ unique tags** for content discovery
- **100% SEO image compliance** (automated verification)

### Technical Metrics

- **100% uptime** via GitHub Pages
- **Automated CI/CD** with 5 quality gates
- **Zero manual deployment** steps
- **Sub-second page loads** via static generation

### User Experience Metrics

- **Responsive design** across all devices
- **Newsletter integration** for audience building
- **Professional presentation** with modern UX

---

## 🎉 Conclusion

This Jekyll blog demonstrates a sophisticated approach to static site development, combining:

- **Modern development practices** (CI/CD, automated testing)
- **Content management excellence** (templates, taxonomy, SEO)
- **User experience focus** (responsive design, commenting, navigation)
- **Professional presentation** (clean design, performance optimization)

The site serves as an example of how static site generators can power professional blogs with enterprise-grade quality assurance and modern web development practices.

**Perfect for demonstrating:**

- Static site architecture and benefits
- CI/CD implementation for content sites
- SEO optimization and automation
- Modern web development workflows
- Content management best practices
