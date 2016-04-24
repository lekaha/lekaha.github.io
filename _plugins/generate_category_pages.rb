module Jekyll
  # Page class it-self, contains data through this specific list of posts
  # like nextUrl, prevUrl, number of posts or page number
  class PostSubSetPage < Page
      def initialize(site, base, dir, detail, page, posts, more, pages)
          @site = site
          @base = base
          @dir = dir
          @name = "index.html"
          if page > 1
            @name = "page#{page}.html"
          end

          # Define data which can be used in category.html
          self.process(@name)
          self.read_yaml(File.join(base, '_layouts'), detail['layout'])
          self.data['category'] = detail['category']
          self.data['weight'] = detail['weight']
          self.data['title'] = detail['title']
          self.data['posts'] = posts
          self.data['number'] = page
          self.data['pages'] = pages
          self.data['more'] = more
          self.data['sitemap'] = false

          # Add next button for navigation
          if more
            nextNumber = page + 1
            self.data['nextUrl'] = File.join('', dir, "page#{nextNumber}")
          end
          # Add prev button for navigation
          if page > 1
              prevNumber = page - 1
              if prevNumber == 1
                self.data['prevUrl'] = File.join('', dir)
              else
                self.data['prevUrl'] = File.join('', dir, "page#{prevNumber}")  
              end
          end
      end
  end

  # Page generatore, iterates through all available posts and creates pages
  # for configurated categories. Pages are sorted descending by date
  class PaginatorGenerator < Generator
    safe true

    def generateList(site, list, dir, category, details, config)
        detail = details[category] || {}
        detail['pagination'] = detail['pagination'] || config['pagination'] || 5
        detail['category'] = category
        detail['layout'] = detail['layout'] || config['layout'] || 'category.html'

        # Sort by date descending
        list = list.sort! { |a,b| b.date <=> a.date }
        # Put each page file in a subfolder of dir
        dir = File.join(dir, category)
        # Calculate number of pages
        pages = (list.length.to_f / detail['pagination'] ).ceil

        # Iterate through all posts
        number = 1
        counter = 0
        posts = []
        list.each do |post|
          posts.push(post)
          counter += 1
          if posts.length == detail['pagination']
            site.pages << PostSubSetPage.new(site, site.source, dir, detail, number, posts, counter < list.length, pages)
            number += 1
            posts = []
          end
        end
        # Generate final page
        if posts.length != 0
          site.pages << PostSubSetPage.new(site, site.source, dir, detail, number, posts, false, pages)
        end
    end

    def generate(site)
        categories = {}
        
        # Fetch all category via posts
        site.posts.docs.each do |post|
          p post
          post.data['categories'].each do |category| 
            (categories[category] ||= []) << post
          end
        end

        config = site.config['categories'] || {}
        details = config['details'] || {}

        # Generate pages with category
        categories.each do |category, list|
          if category != 'all' && details[category]
            self.generateList(site, list, '.', category, details, config)
          end
        end
    end
  end
end