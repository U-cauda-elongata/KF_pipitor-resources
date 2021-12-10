let List/filter = https://prelude.dhall-lang.org/v21.1.0/List/filter.dhall
  sha256:8ebfede5bbfe09675f246c33eb83964880ac615c4b1be8d856076fdbc4b26ba6

let Pipitor = ./Pipitor.dhall

let account = ./account.dhall
let filter = ./filter.dhall
let topic = ./topic.dhall
let util = ./util.dhall

let Topic = Pipitor.Topic
let Twitter = Pipitor.Topic.Twitter
let Filter = Pipitor.Filter
let Rule = Pipitor.Rule
let Outbox = Pipitor.Outbox

let rx = util.rx

in [
  Rule::{
    topics = List/filter Topic util.Topic/isFeed topic.kf-official,
    -- 全ての投稿がけものフレンズに関連するため `filter` は不要
    outbox = [Outbox.Twitter account.pipitor],
  },
  Rule::{
    topics = List/filter Topic util.Topic/isTwitter topic.kf-official,
    -- これらのアカウント宛のリプライを捕捉するために便宜的にルールに加えているが、
    -- Twitter の場合はそれぞれのアカウントをフォローすれば事足りるためリツイートの対象とはしない。
    outbox = [] : List Outbox,
  },
  Rule::{
    topics = topic.general.ja,
    filter = Some Filter::{ title = filter.basic },
    exclude = Some Filter::{ title = rx.hash "今日のニコニコ生放送" },
    outbox = [Outbox.Twitter account.pipitor],
  },
  Rule::{
    topics = topic.streamer,
    filter = Some Filter::{ title = rx.any [ filter.basic, filter.kemovHashtags ] },
    outbox = [Outbox.Twitter account.pipitor],
  },
  Rule::{
    topics = [
      Twitter 100358790, -- @hanamaru_udon 【讃岐】はなまるうどん
    ],
    filter = Some Filter::{ title = filter.basicMinusHanamaru },
    outbox = [Outbox.Twitter account.pipitor],
  },
  Rule::{
    topics = topic.media,
    filter = Some Filter::{ title = filter.basic },
    exclude = Some Filter::{
      title = rx.any [
        filter.basicExclude,
        rx.i "おはようSGI", -- @SocialGameInfo のダイジェスト
        rx.i "news.nicovideo.jp", -- ニコニコニュースのキュレーション系記事
      ],
    },
    outbox = [Outbox.Twitter account.pipitor],
  },
  Rule::{
    topics = [
      Twitter 456544724, -- @AnimeAnime_jp アニメ！アニメ！
    ],
    filter = Some Filter::{ title = filter.basic },
    exclude = Some Filter::{
      -- アンケート記事
      title = rx.any [
        filter.basicExclude,
        "🏆",
        "アンケート",
        "〆切は",
        "▼回答は",
        "\\d位",
      ],
    },
    outbox = [Outbox.Twitter account.pipitor],
  },
  Rule::{
    topics = topic.individual.ja,
    filter = Some Filter::{ title = filter.individual },
    outbox = [Outbox.Twitter account.pipitorIndv],
  },
  -- 日英バイリンガルアカウント（個人）の日本語投稿
  Rule::{
    topics = topic.individual.en-ja,
    filter = Some Filter::{ title = rx.hash filter.individualJa },
    outbox = [Outbox.Twitter account.pipitorIndv],
  },
  -- English posts from en/ja bilingual accounts (individual)
  Rule::{
    topics = topic.individual.en-ja,
    filter = Some Filter::{ title = rx.hash filter.individualEn },
    -- 多重リツイートの抑止。日本語を優先する
    exclude = Some Filter::{ title = rx.hash filter.individualJa },
    outbox = [Outbox.Twitter account.pipitorIntl],
  },
  Rule::{
    topics = topic.individual.streamer,
    filter = Some Filter::{ title = rx.any [ filter.individual, filter.kemovHashtags ] },
    outbox = [Outbox.Twitter account.pipitorIndv],
  },
  Rule::{
    topics = topic.zoo-aquarium,
    filter = Some Filter::{ title = rx.any [ filter.basic, "吉崎\\s*観音", "吉崎先生" ] },
    outbox = [Outbox.Twitter account.pipitor],
  },
  Rule::{
    topics = topic.general.en,
    filter = Some Filter::{ title = filter.basic },
    exclude = Some Filter::{ title = filter.basicExclude },
    outbox = [Outbox.Twitter account.pipitorIntl],
  },
  Pipitor.Rule::{
    topics = topic.individual.en,
    filter = Some Filter::{ title = filter.individual },
    outbox = [Outbox.Twitter account.pipitorIntl],
  },
]
