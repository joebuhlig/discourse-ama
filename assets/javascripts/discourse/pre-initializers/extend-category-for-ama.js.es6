import computed from 'ember-addons/ember-computed-decorators';
import Category from 'discourse/models/category';
import { withPluginApi } from 'discourse/lib/plugin-api';

function initialize(api, container) {
  api.decorateWidget('post-contents:before', function(h) {
    if (h.attrs.replyCount > 0){
      h.widget.sendWidgetAction('toggleRepliesBelow');
    }
  })
}

export default {
  name: 'extend-category-for-ama',
  before: 'inject-discourse-objects',
  initialize(container) {

    withPluginApi('0.8.4', api => {
      initialize(api, container);
    });

    Category.reopen({

      @computed('custom_fields.enable_topic_ama')
      enable_topic_ama: {
        get(enableField) {
          return enableField === "true";
        },
        set(value) {
          value = value ? "true" : "false";
          this.set("custom_fields.enable_topic_ama", value);
          return value;
        }
      }

    });
  }
};