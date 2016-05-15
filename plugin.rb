# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.2
# authors: Arpit Jalan
# url: https://github.com/discourse/discourse-watch-category-mcneel

module ::WatchCategory
  def self.watch_category!
    referendum_category = Category.find_by_slug("referendum")
    referendum_group = Group.find_by_name("referendum")
    return if referendum_category.nil? || referendum_group.nil?

    referendum_group.users.each do |user|
      watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], referendum_category.id) unless watched_categories.include?(referendum_category.id)
    end
  end
end

after_initialize do
  module ::WatchCategory
    class WatchCategoryJob < ::Jobs::Scheduled
      every 1.day

      def execute(args)
        WatchCategory.watch_category!
      end
    end
  end
end
