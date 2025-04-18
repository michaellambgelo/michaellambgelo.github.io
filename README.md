# michaellambgelo.github.io

This is a tech & life blog written and maintained by Michael Lamb

Available at https://michaellamb.dev

## About

Michael Lamb is a software engineer living in Jackson, Mississippi
He organizes meetups with Jackson Film Club, Jackson Devs, and C Spire Gaming around the Jackson area.

Reach out by email if you're interested in connecting at one of these events!
[michael@michaellamb.dev](mailto:michael@michaellamb.dev)

### A note from Michael

You'll find posts about a variety of topics at michaellamb.dev.
I'm interested in exploring distributed systems both to educate myself and others.
When this blog project started, I built and documented a Pi cluster as the initial posts.
Most content has been generated about this environment. Some posts are more community or professional oriented.
A little bit of personality is sprinkled in.

I want my blog to be accessible, but still have my fingerprints on it.

If anything in my blog inspires you, I'd love to know about it.

## Documentation

- [Maintenance Guide](MAINTENANCE.md) - Track site issues, improvements, and progress
- [Post Template](_templates/post.md) - Template for creating new blog posts

## SEO Images

Each post should have an associated SEO image in the `/seo` directory. The image filename should match the post date (e.g., `2025-01-09.png`).

To verify SEO images for all posts:

```bash

# Run the verification script

ruby scripts/verify_seo_images.rb

# The script will:

# 1. Check if all posts have an SEO image specified in front matter

# 2. Verify that the specified images exist

# 3. Check for the default fallback image (default.png)

# 4. Report any missing or invalid images

```

## Git Hooks

This repository includes Git hooks to automate certain checks:

1. Install the hooks:

```bash

# Make the install script executable

chmod +x scripts/install-hooks.sh

# Run the install script

./scripts/install-hooks.sh

```

1. Pre-push hook:

   - Automatically runs SEO image verification before each push
   - Prevents pushing if any SEO images are missing
   - Can be bypassed in emergencies with `git push --no-verify`

1. Pre-commit hook:

   - Runs markdownlint on staged markdown files
   - Ensures consistent markdown formatting
   - Prevents commits if linting fails
   - Can be bypassed with `git commit --no-verify`

## Contributing

Contributions are welcome! Please read the maintenance guide for current issues and improvements being tracked.

## Resources

[run this project locally](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll)

[jekyll-seo-tag usage](https://github.com/jekyll/jekyll-seo-tag/blob/master/docs/usage.md)

## Credit

This website was built using the gh-pages-blog project.

[https://thedereck.github.io/gh-pages-blog/](https://thedereck.github.io/gh-pages-blog/) by Dereck Curry

[GitHub:Pages](http://pages.github.com) by GitHub

[Bootstrap](http://twitter.github.com/bootstrap/) by Twitter

[jQuery](http://jquery.com/) by jQuery Foundation

[Font Awesome 5](https://fontawesome.com/)

[syntax.css](https://github.com/mojombo/jekyll) by Tom Preston-Werner

[Discord Embed](https://discord.com) by Discord

## License

Except where noted below and elsewhere in the code and repository, the gh-pages-blog code is &copy; Copyright 2013 by Dereck Curry and is licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

[Bootstrap](http://twitter.github.com/bootstrap/) - &copy; Copyright 2012, Twitter, Inc.

- Bootstrap code is licensed under Apache License v2.0 - [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
- Bootstrap documentation is licensed under CC BY 3.0 - [http://creativecommons.org/licenses/by/3.0/](http://creativecommons.org/licenses/by/3.0/).
- Glyphicons Free licensed under CC BY 3.0 - [http://creativecommons.org/licenses/by/3.0/](http://creativecommons.org/licenses/by/3.0/).

[jQuery](http://jquery.com/) - &copy; Copyright 2013 jQuery Foundation and other contributors

- jQuery is licensed under MIT License - [https://github.com/jquery/jquery/blob/master/MIT-LICENSE.txt](https://github.com/jquery/jquery/blob/master/MIT-LICENSE.txt).

[Font Awesome](http://fortawesome.github.com/Font-Awesome/)

- The Font Awesome font is licensed under the SIL Open Font License - [http://scripts.sil.org/OFL](http://scripts.sil.org/OFL).
- Font Awesome CSS, LESS, and SASS files are licensed under the MIT License - [http://opensource.org/licenses/mit-license.html](http://opensource.org/licenses/mit-license.html).
- The Font Awesome pictograms are licensed under the CC BY 3.0 License - [http://creativecommons.org/licenses/by/3.0/](http://creativecommons.org/licenses/by/3.0/).

[syntax.css](https://github.com/mojombo/jekyll) by Tom Preston-Werner

- The syntax.css is licensed under the MIT License - [http://opensource.org/licenses/mit-license.html](http://opensource.org/licenses/mit-license.html).

# Categories

[a11y](https://michaellamb.dev/filter.html?category=a11y)

[cluster-computing](https://michaellamb.dev/filter.html?category=cluster-computing)

[conference](https://michaellamb.dev/filter.html?category=cluster-computing)

[distributed-systems](https://michaellamb.dev/distributed-systems/2022/08/30/redis-hackathon.html)

[docker](https://michaellamb.dev/distributed-systems/2022/08/30/redis-hackathon.html)

[golang](https://michaellamb.dev/distributed-systems/2022/08/30/redis-hackathon.html)

[machine-intelligence](https://michaellamb.dev/filter.html?category=machine-intelligence)

[social](https://michaellamb.dev/filter.html?category=social)

[spring](https://michaellamb.dev/filter.html?category=spring)
