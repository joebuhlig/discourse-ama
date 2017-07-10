# name: discourse-ama
# about: Adds tweaks to allow a more fluid AMA.
# version: 0.1
# author: Joe Buhlig joebuhlig.com
# url: https://www.github.com/joebuhlig/discourse-ama

enabled_site_setting :ama_enabled

register_asset "stylesheets/discourse-ama.scss"

after_initialize do

  require_dependency 'basic_category_serializer'
  class ::BasicCategorySerializer
    attributes :can_ama

    def include_can_ama?
      Category.can_ama?(object.id)
    end

    def can_ama
      true
    end

  end

  class ::Category
    def self.reset_ama_cache
      @allowed_ama_cache["allowed"] =
        begin
          Set.new(
            CategoryCustomField
              .where(name: "enable_topic_ama", value: "true")
              .pluck(:category_id)
          )
        end
    end

    @allowed_ama_cache = DistributedCache.new("allowed_ama")

    def self.can_ama?(category_id)
      return false unless SiteSetting.ama_enabled

      unless set = @allowed_ama_cache["allowed"]
        set = reset_ama_cache
      end
      set.include?(category_id)
    end


    after_save :reset_ama_cache


    protected
    def reset_ama_cache
      ::Category.reset_ama_cache
    end
  end

end

load File.expand_path('../lib/discourse_ama/engine.rb', __FILE__)