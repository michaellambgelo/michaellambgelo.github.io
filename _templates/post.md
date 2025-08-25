# Post Template

This is a template for creating new blog posts. Copy this file to the `_posts` directory and rename it following the format: `YYYY-MM-DD-title.md`.

> **Note:** Please refer to `_templates/taxonomy.md` for the complete list of standardized categories and tags.

---

layout: post
title: "Your Post Title Here"
date: YYYY-MM-DD
# Choose exactly ONE category from: development, infrastructure, machine-intelligence, community, projects, tutorials, reflections
category: category-name
image: "/seo/YYYY-MM-DD.png"
# Include 2-5 relevant tags from the taxonomy document
tags:
- tag1
- tag2
- tag3

published: true

---

Your post content here. Some guidelines:

1. Use proper markdown formatting
2. Include code blocks with language specification:

   ```python
   def example():
       return "Hello, World!"
   ```

1. Use proper heading hierarchy (H2 -> H3 -> H4, as H1 is reserved for the post title)
2. Include alt text for images:

   ![Alt text for image](image-url)

## SEO Guidelines

1. Always include a relevant image in the front matter
2. Keep titles under 60 characters
3. Use descriptive categories and tags from the taxonomy document
4. Ensure the post has a clear description

## Formatting Tips

1. Break up long paragraphs
2. Use lists and headings for better readability
3. Include code examples where relevant
4. Link to related posts when possible
