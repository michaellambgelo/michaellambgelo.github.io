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

1. Update `_config.yml`:

   - Remove redundant name/title configuration
   - Clean up unused settings

1. Implement asset verification:

   - Add checks for SEO images
   - Verify image paths in posts

1. Add CI/CD checks for:

   - Image asset verification
   - Link validation
   - SEO metadata

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

   - Removed conflicting `jekyll` dependency
   - Updated dependencies to latest versions

1. Updated `_config.yml`:

   - Removed redundant `title` configuration
   - Cleaned up unused settings

1. Created post template and documentation:

   - Added `docs/POST_TEMPLATE.md`
   - Created documentation guidelines

1. Implemented SEO image verification:

   - Created `scripts/verify_seo_images.rb`
   - Added pre-push hook for verification

1. Enhanced markdown linting:

   - Updated `.markdownlint.json`
   - Added pre-commit hook for linting

1. Added CI/CD workflow:

   - Created GitHub Actions workflow
   - Implemented automated checks

### 2025-01-09

1. Improved template organization:

   - Moved post template to dedicated directory
   - Updated documentation references

1. Enhanced documentation:

   - Moved `MAINTENANCE.md` to root directory
   - Improved formatting and organization

1. Updated Spring logo URLs:

   - Changed from `spring-logo.svg` to `spring-2.svg` in Swagger UI posts
   - Modified in `_posts/2022-03-01-spring-boot-swagger-ui.md`
   - Modified in `_posts/2022-09-15-spring-boot-swagger-ui-redux.md`

1. Improved markdown formatting and linting:

   - Updated `.markdownlint.json` with new rules and ignore patterns
   - Added `scripts/fix_markdown.rb` to automatically fix common formatting issues
   - Applied consistent formatting across all markdown files:
     - Proper spacing around headers and lists
     - Consistent code block formatting
     - Normalized front matter spacing
     - Fixed list indentation

1. Moved maintenance log entries to MAINTENANCE.md and fixed formatting.

_This section will be updated as changes are implemented._

---

Note: This is a living document. Updates will be made as issues are resolved and new recommendations are identified.
