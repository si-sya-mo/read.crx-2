module('app.board');

(function() {
  var ch_url, ch_text, ch_expected,
      machi_url, machi_text, machi_expected,
      jbbs_url, jbbs_text, jbbs_expected;

  ch_url = 'http://qb5.2ch.net/operate/';
  ch_text = [
    '1301664644.dat<>【粛々と】シークレット★忍法帖巻物 8【情報収集、集約スレ】 (174)',
    '1301751706.dat<>【news】ニュース速報運用情報759【ν】 (221)',
    '1301761019.dat<>[test] 書き込みテスト 専用スレッド 240 [ﾃｽﾄ] (401)',
    '1295975106.dat<>重い重い重い重い重い重い重い×70＠運用情報 (668)',
    '1294363063.dat<>【お止め組。】出動予定＆連絡 詰所◆13 (312)'
  ].join('\n');
  ch_expected = [
    {
      url: 'http://qb5.2ch.net/test/read.cgi/operate/1301664644/',
      title: '【粛々と】シークレット★忍法帖巻物 8【情報収集、集約スレ】',
      res_count: 174
    },
    {
      url: 'http://qb5.2ch.net/test/read.cgi/operate/1301751706/',
      title: '【news】ニュース速報運用情報759【ν】',
      res_count: 221
    },
    {
      url: 'http://qb5.2ch.net/test/read.cgi/operate/1301761019/',
      title: '[test] 書き込みテスト 専用スレッド 240 [ﾃｽﾄ]',
      res_count: 401
    },
    {
      url: 'http://qb5.2ch.net/test/read.cgi/operate/1295975106/',
      title: '重い重い重い重い重い重い重い×70＠運用情報',
      res_count: 668
    },
    {
      url: 'http://qb5.2ch.net/test/read.cgi/operate/1294363063/',
      title: '【お止め組。】出動予定＆連絡 詰所◆13',
      res_count: 312
    },
  ];

  machi_url = 'http://www.machi.to/tawara/';
  machi_text = [
    '1<>1269441710<>～削除依頼はこちらから～(1)',
    '2<>1299160555<>関東板削除依頼スレッド54(134)',
    '3<>1239604919<>●ホスト規制中第32巻●(973)',
    '4<>1300530242<>東北板　削除依頼スレッド【Part38】(210)',
    '5<>1187437274<>東北板管理人**********不信任スレ(350)'
  ].join('\n');
  machi_expected = [
    {
      url: 'http://www.machi.to/bbs/read.cgi/tawara/1269441710/',
      title: '～削除依頼はこちらから～',
      res_count: 1
    },
    {
      url: 'http://www.machi.to/bbs/read.cgi/tawara/1299160555/',
      title: '関東板削除依頼スレッド54',
      res_count: 134
    },
    {
      url: 'http://www.machi.to/bbs/read.cgi/tawara/1239604919/',
      title: '●ホスト規制中第32巻●',
      res_count: 973
    },
    {
      url: 'http://www.machi.to/bbs/read.cgi/tawara/1300530242/',
      title: '東北板　削除依頼スレッド【Part38】',
      res_count: 210
    },
    {
      url: 'http://www.machi.to/bbs/read.cgi/tawara/1187437274/',
      title: '東北板管理人**********不信任スレ',
      res_count: 350
    }
  ];

  jbbs_url = 'http://jbbs.livedoor.jp/computer/42710/';
  jbbs_text = [
    '1290070091.cgi,read.crx総合 part2(354)',
    '1290070123.cgi,read.crx CSSスレ(31)',
    '1273802908.cgi,read.crx総合(1000)',
    '1273732874.cgi,テストスレ(413)',
    '1273734819.cgi,スレスト(1)',
    '1290070091.cgi,read.crx総合 part2(354)'
  ].join('\n');
  jbbs_expected = [
    {
      url: 'http://jbbs.livedoor.jp/bbs/read.cgi/computer/42710/1290070091/',
      title: 'read.crx総合 part2',
      res_count: 354
    },
    {
      url: 'http://jbbs.livedoor.jp/bbs/read.cgi/computer/42710/1290070123/',
      title: 'read.crx CSSスレ',
      res_count: 31
    },
    {
      url: 'http://jbbs.livedoor.jp/bbs/read.cgi/computer/42710/1273802908/',
      title: 'read.crx総合',
      res_count: 1000
    },
    {
      url: 'http://jbbs.livedoor.jp/bbs/read.cgi/computer/42710/1273732874/',
      title: 'テストスレ',
      res_count: 413
    },
    {
      url: 'http://jbbs.livedoor.jp/bbs/read.cgi/computer/42710/1273734819/',
      title: 'スレスト',
      res_count: 1
    }
  ];

  test('実例パーステスト', function() {
    deepEqual(app.board.parse(ch_url, ch_text), ch_expected);
    deepEqual(app.board.parse(machi_url, machi_text), machi_expected);
    deepEqual(app.board.parse(jbbs_url, jbbs_text), jbbs_expected);
  });
})();