// Public: The main entry point to the frontend application.
window.App = {
  username: null,
  token: null,

  init: function() {
    this.commandbar = new window.CommandBarView;
    this.replies = new window.RepliesView;
  },

  request: function(url, data, callback) {
    $.ajax(url, {
      type: 'POST',
      data: data,
      success: function(data)  {
        callback(null, data);
      },
      error: function(xhr, status, err) {
        callback(err, null);
      },
    });
  },

  submitUsername: function(username) {
    var data = {
      username: username,
    };

    var self = this;
    var callback = function(err, data) {
      if (err) {
        console.log(err);
        self.addReply('#user-failed', {});
      }
      else {
        console.log(data);
        self.addReply('#user-success', data);
        self.username = data.login;
      }
    };

    this.request('/github/identity/username', data, callback);
  },

  submitToken: function(token) {
    var data = {
      username: this.username,
      token: token,
    };

    var self = this;
    var callback = function(err, data) {
      if (err) {
        console.log(err);
        self.addReply('#token-failed', {});
      }
      else {
        console.log(data);
        self.addReply('#token-success', data);
        self.token = token;
      }
    };

    this.request('/github/identity/token', data, callback);
  },

  addReply: function(template, model) {
    var view = new window.ReplyView({ template: template, model: model });
    if (model.avatar_url) {
      $('.js-avatar img').attr('src', model.avatar_url);
      $('.js-avatar').fadeIn();
    }
    this.replies.add(view);
  },
};

// Internal: The view for handling replies from hubot.
window.RepliesView = Backbone.View.extend({
  el: '.js-replies',

  add: function(reply) {
    var self = this;
    this.$('.message').fadeOut('fast', function() {
      self.$el.empty();
      self.$el.append(reply.render().el);
    });
  },
});

// Internal: The view for handling a single reply from hubot.
window.ReplyView = Backbone.View.extend({
  className: 'message',

  initialize: function(options) {
    this.template = _.template($(options.template).html());
  },

  render: function() {
    this.$el.html(this.template(this.model));
    return this;
  },
});

// Internal: The view for handling the command bar input.
window.CommandBarView = Backbone.View.extend({
  el: '.js-command-bar',

  events: {
    'keypress .js-command-input': 'submit',
  },

  initialize: function() {
    this.commandinput = this.$('.js-command-input');
    this.commandinput.focus();
  },

  submit: function(e) {
    if (e.keyCode != 13) return;
    if (!this.commandinput.val()) return;

    var input = this.commandinput.val();
    this.commandinput.val('');

    if (!window.App.username && !window.App.token) {
      window.App.submitUsername(input);
    }
    else if (window.App.username && !window.App.token) {
      window.App.submitToken(input);
    }
  },
});
