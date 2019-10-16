/* eslint-disable strict */
const Helper = require('hubot-test-helper');

// helper loads all scripts passed a directory
const helper = new Helper('../scripts/famiscript.js');

const co = require('co');
const expect = require('chai').expect;

xdescribe('famiscript', () => {
  beforeEach(() => {
    this.room = helper.createRoom({ name: 'room', httpd: false });
  });
  afterEach(() => {
    this.room.destroy();
  });

  context('user asks how many badgers', () => {
    // eslint-disable-next-line func-names
    beforeEach(() => co(function* () {
      yield this.room.user.say('alice', '@hutbot I\'m alice.');
      yield this.room.user.say('alice', '@hutbot how many badgers?');
    }.bind(this)));
  });

  context('how many badgers?', () => {
    it('should tell us how many badgers', () => {
      // eslint-disable-next-line no-console
      console.log(this.room.messages);
      expect(this.room.messages).to.eql([
        ['alice', '@hutbot I\'m alice.'],
        ['alice', 'how many badgers?'],
        ['hubot', 'The total number of badger messages is 1']
      ]);
    });
  });
});
