# Site Maintenance Documentation

Last Updated: 2025-01-09

This document tracks known issues, recommendations, and maintenance tasks for the website.

## Current Issues

### 1. Gemfile Configuration
- **Issue**: Conflicting Jekyll configurations with both `jekyll` and `github-pages` gems active
- **Status**: 
- **Priority**: High
- **Impact**: Potential version conflicts and build issues

### 2. Future-Dated Posts
- **Issue**: Posts with dates in the future relative to build time
- **Status**: 
- **Priority**: Medium
- **Impact**: Posts may not appear as expected during builds

### 3. SEO and Image Assets
- **Issue**: Unverified SEO image paths and missing asset verification
- **Status**: 
- **Priority**: Medium
- **Impact**: Broken images and incomplete SEO metadata

### 4. Configuration Redundancy
- **Issue**: Duplicate configurations in `_config.yml`
- **Status**: 
- **Priority**: Low
- **Impact**: Code maintenance and clarity

### 5. Pagination Configuration
- **Issue**: Low pagination count (2 posts per page)
- **Status**: 
- **Priority**: Low
- **Impact**: User experience and page load efficiency

### 6. Plugin Management
- **Issue**: Incomplete plugin listing in `_config.yml`
- **Status**: 
- **Priority**: Medium
- **Impact**: Plugin initialization and functionality

### 7. Markdown Linting
- **Issue**: Unused markdown linting configuration
- **Status**: 
- **Priority**: Low
- **Impact**: Code quality and consistency

### 8. Post Front Matter
- **Issue**: Inconsistent front matter formatting
- **Status**: 
- **Priority**: Medium
- **Impact**: Site generation and URL consistency

## Recommendations

### Immediate Actions
1. Update Gemfile to resolve Jekyll configuration:
   ```ruby
   # Remove: gem "jekyll", "~> 3.9.0"
   # Keep: gem "github-pages", group: :jekyll_plugins
   ```

2. Update `_config.yml`:
   - Remove redundant name/title configuration
   - Add complete plugins section
   - Increase pagination count
   - Add `future: true` for future posts

3. Implement asset verification:
   - Add checks for SEO images
   - Create default fallback images
   - Document image requirements

### Future Improvements
1. Create post templates with standardized front matter
2. Implement automated markdown linting
3. Add CI/CD checks for:
   - Image asset verification
   - Front matter validation
   - Markdown linting

## Progress Log

### 2025-01-08
1. Fixed Gemfile configuration:
   - Removed conflicting `jekyll` gem
   - Removed duplicate `jekyll-admin` entry
   - Kept `github-pages` gem for GitHub Pages compatibility

2. Updated `_config.yml`:
   - Removed redundant `title` configuration (using `name` instead)
   - Added complete plugins section with all required plugins
   - Increased pagination count from 2 to 5 posts per page
   - Added `future: true` to allow future-dated posts

3. Created post template and documentation:
   - Added `docs/POST_TEMPLATE.md` with standardized front matter
   - Included guidelines for SEO images
   - Added markdown formatting best practices

4. Implemented SEO image verification:
   - Created `scripts/verify_seo_images.rb` for checking SEO images
   - Added support for default fallback image
   - Automated verification of image paths in front matter

5. Enhanced markdown linting:
   - Updated `.markdownlint.json` with comprehensive rules
   - Added support for code blocks and front matter
   - Configured line length and heading style rules

6. Added CI/CD workflow:
   - Created GitHub Actions workflow for automated checks
   - Added Jekyll build verification
   - Integrated SEO image verification
   - Added markdown linting
   - Added front matter validation

### 2025-01-09
1. Improved template organization:
   - Moved post template to dedicated `_templates` directory
   - Updated config to exclude templates from build
   - Added comprehensive template guidelines
   - Fixed template visibility in navigation

2. Enhanced documentation:
   - Moved `MAINTENANCE.md` to root directory for better visibility
   - Updated progress on all tracked issues
   - Added links to documentation in README

_This section will be updated as changes are implemented._

---
Note: This is a living document. Updates will be made as issues are resolved and new recommendations are identified.
