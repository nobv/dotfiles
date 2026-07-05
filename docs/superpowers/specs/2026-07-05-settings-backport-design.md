# Claude Code settings.json バックポート機能 設計

- 日付: 2026-07-05
- ステータス: Draft(spec レビュー待ち)
- 関連: PR #50(`fix(home-manager)`: activation backup のタイムスタンプ化)

## 背景

`~/.claude/settings.json` は `modules/ai/claude-code/default.nix` により、repo 実体
(`modules/ai/claude-code/settings.json`)を指す **out-of-store symlink** として配置される。
symlink が生きている限り、Claude Code の書き込みは repo 実体へ直接反映され `git diff` に現れる
=「取り込み」は本来不要。

ところが実運用では **settings.json だけ symlink が外れ実ファイルに drift** する現象が起きる
(CLAUDE.md など他ファイルは symlink 維持)。原因は Claude Code が settings.json を更新する際の
atomic write(tmpfile → rename)で symlink 実体が置き換わるためと考えられる。drift 後は
Claude Code の変更(plugin 有効化・hook 追加など)がライブ実ファイルにだけ溜まり、repo と乖離する。

既存の `scripts/claude-plugin-sync.sh`(`just claude plugins`)は
「repo の `enabledPlugins`/`extraKnownMarketplaces` → `claude plugin install/marketplace add`」という
**宣言 → 適用の一方向・冪等・非対話**フローのみを持ち、逆方向(ライブ実ファイル → repo)が存在しない。
本機能はこの逆方向を担う。

## 目的

Claude Code がライブ `settings.json`(drift した実ファイル)へ書き込んだ設定を、
**差分承認式**で repo 実体に選択的に取り込み(バックポートし)、既定で **PR 作成 → マージまで**自動化する。

## スコープ

### やること
- ライブ `settings.json` と repo 実体のトップレベルキー差分を検出し、取り込む項目をユーザーが選ぶ。
- 承認したキーを repo 実体にマージ(書き込み)する。
- 既定で、専用ブランチに commit → push → PR 作成 → PR マージまで自動化する
  (`--no-merge` / `--no-pr` / `--dry-run` で段階的に抑制)。
- 既存 `scripts/`/`just` の流儀(bash + jq、`scripts/lib.sh` のログ関数、`just claude` 配下)に合わせる。

### やらないこと(非目標 / YAGNI)
- deep merge(`hooks` 配列の要素単位 union など)。トップレベルキー単位の丸ごと採用に留める。
- `darwin-rebuild switch` の自動化。switch は PR merge 後に main から手動で行う
  (規約: switch は worktree でなく main から)。
- 自動トリガー(SessionEnd hook 等での無人実行)。差分承認は対話が前提なので手動実行のみ。
- profiles(`cfg.profiles.*.settingsSource`)の settings.json。今回は primary の
  `~/.claude/settings.json` のみ対象(将来拡張)。

## 前提と入力

- **ライブ**: `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json`
- **repo ターゲット**: 既定 `modules/ai/claude-code/settings.json`(第1引数で上書き可)。
  Nix option `cfg.settingsSource` の既定値と一致。
- `jq` 必須。`gh` は PR 作成・マージ(既定モード)に必須(`--no-pr` / `--dry-run` 時は不要)。

## 自動マージの前提(main ruleset)

現状の `main` ruleset に依存する:

- `pull_request` 必須(直 push / force push 不可)、**`required_approving_review_count: 0`**(approval 不要)。
- **CODEOWNERS 不在**のため `require_code_owner_review` は実質無効。
- `required_review_thread_resolution: true` → **自動 PR には GitHub レビューコメントを付けない**
  (未解決スレッドがあるとマージが弾かれる)。

将来 approval 必須化 or CODEOWNERS 追加でセルフマージが不可になっても壊れないよう、
`gh pr merge` 失敗時は **PR を残して正常終了**(= `--no-merge` 相当に自動フォールバック)する。

## 実行モード(フラグ)

| モード | 挙動 |
|---|---|
| 既定 | 差分承認 → マージ → commit → push → PR 作成 → **PR マージ + ブランチ削除** |
| `--no-merge` | PR 作成まで(マージしない) |
| `--no-pr` | commit まで(push / PR しない) |
| `--dry-run` | 差分候補を表示するだけ(repo・git ともに無変更) |
| `--all` | 差分候補をすべて無条件に取り込む(対話選択を省略) |
| `--edit` | マージ結果の一時ファイルを `$EDITOR` で微調整してから確定 |

## アーキテクチャ

- `scripts/claude-settings-backport.sh` — 本体。`scripts/lib.sh` を source してログ関数を流用。
- `just/claude.just` に recipe を追加:
  ```just
  # Backport live settings.json into the repo, open a PR and merge it (interactive, live->repo)
  backport *ARGS:
      ./scripts/claude-settings-backport.sh {{ARGS}}
  ```

## データフロー

1. **前提チェック** — `jq`・ライブ settings.json の存在を確認(既定モードでは `gh` も)。
   無ければ `log_error` して非0終了。
2. **drift 判定** — ライブ settings.json が **symlink(`[ -L ]`)なら「drift なし」で正常終了**
   (取り込むべき差分は既に git 追跡下にある)。実ファイルのときのみ以降へ進む。
3. **差分検出** — トップレベルキー単位で比較する:
   - 各キー `k` について、ライブに存在し、かつ「repo に存在しない」または
     「`jq -S`(キー再帰ソート)で正規化した値が repo と異なる」場合に **差分候補**とする。
   - **repo にのみ存在するキー(例: `model`)は対象外**。取り込みは追加・更新のみで、削除はしない。
   - 差分候補ゼロなら `log_success "取り込むものなし"` で正常終了(冪等)。
   - `--dry-run` なら差分候補を表示してここで終了(repo・git 無変更)。
4. **承認** — 差分候補ごとに、ライブ側の値を整形表示(`jq .`)して `y/N` で選択。
   `--all` は全取り込み、`--edit` はマージ結果を `$EDITOR` で微調整。
   **承認が唯一の人間ゲート**(以降 PR マージまで自動なので、ここで入るものが main に入る)。
5. **マージ** — 承認された各キー `k` を、`jq --arg k "$k" --argjson v <live値> '.[$k] = $v'` で
   repo 実体に反映。書き込みは一時ファイル → `mv` で atomic に行う。マージ後 `git diff` を表示。
6. **commit & push & PR**(`--no-pr` なら commit で停止)—
   - **ブランチ準備**: 固定ブランチ `chore/claude-settings-backport` を用意する。
     ローカル/リモートに未 merge の同名ブランチがあれば checkout して積む。merge 済み or 不在なら
     `origin/main` から切り直す。
   - **commit**: 取り込んだキーを列挙したメッセージ(`chore(claude): backport settings.json (<キー>)`)。
   - **push & PR**: push し、既存 PR が無ければ `gh pr create`、あれば push で自動更新。
7. **マージ**(既定 / `--no-merge` でスキップ)— `gh pr merge --merge --delete-branch`。
   成功なら PR 番号を表示。失敗(approval 要求・未解決スレッド等)なら `log_warning` +
   PR URL を表示して **正常終了**(commit/push は完了済みなので破棄しない = `--no-merge` 相当に退避)。
8. **switch は含めない** — symlink 復元は PR merge 後に `just apply`(main)で行う。
   settings.json は symlink なので、マージ済みでも switch するまでライブ環境には影響しない。

## マージ粒度と既知の限界

**トップレベルキー単位で、ライブの値を丸ごと採用**する(deep merge はしない)。
`enabledPlugins`・`hooks`・`permissions` などを、承認したキーごとに置換する。
Claude Code は基本「追加」しかせず既存を消さないため、実運用では概ね `ライブ ⊇ repo` が成り立ち、
丸ごと採用でも喪失は起きにくい。

- **「削除しない」の定義**: repo にのみ存在する**トップレベルキー**(例: `model`)は消さない、の意。
  一方、採用したキーの**内部**はライブ値で置換されるため、ライブ側でそのキーの項目が repo より
  少ない場合はキー内部で項目が減りうる。承認時にライブ値を全表示するのでユーザーが検知でき、
  必要なら `--edit` で調整する。厳密な union が必要なキーが実際に現れたら、将来 deep merge を
  個別検討する(現時点では非目標)。
- **配列を含むキーの順序ノイズ**: `jq -S` はオブジェクトのキーをソートするが配列はソートしない。
  そのため `hooks` のように配列を含むキーは、**順序差だけでも差分候補に上がる**ことがある。
  丸ごと採用なので機能上は無害(表示上のノイズに留まる)。

## エラー処理

| 条件 | 挙動 |
|---|---|
| `jq` が無い | `log_error` → 非0終了 |
| 既定モードで `gh` が無い | `log_error` → 非0終了 |
| ライブ settings.json が無い | `log_error` → 非0終了 |
| ライブ settings.json が不正 JSON | `jq` 失敗を検知し `log_error` → 非0終了(repo は無変更) |
| repo ターゲットが無い | `log_error` → 非0終了 |
| ライブが symlink(drift なし) | `log_info` して正常終了(no-op) |
| 差分ゼロ | `log_success "取り込むものなし"` で正常終了(冪等) |
| push / `gh pr create` 失敗 | `log_error` → 非0終了(ローカルの commit は残る) |
| `gh pr merge` 失敗 | `log_warning` + PR URL 表示で **正常終了**(PR は残す) |

## 運用フロー全体

```
Claude がライブ settings.json に書き込む → symlink が外れ drift
  → just claude backport      # 差分承認→マージ→commit→push→PR 作成→PR マージ
  → just apply (switch)       # symlink 復元・ライブは *.backup.日時 へ退避(PR #50)
```

バックポート(repo 更新 + PR + マージ)と backup タイムスタンプ化(PR #50)は独立。両者が揃うと
「drift → 取り込み → 復元」が安全な往復として閉じる。

## テスト観点

- ライブが symlink → no-op で正常終了。
- ライブが実ファイルで差分あり → 承認したキーだけが repo に反映され、非承認キーと
  repo 固有キー(`model`)は不変。
- 差分ゼロ → no-op。
- 不正 JSON / ファイル欠如 → 非0終了、repo 無変更。
- `--dry-run`: 差分表示のみで repo・git ともに無変更。
- `--no-pr`: マージ + commit まで(push / PR しない)。
- `--no-merge`: PR 作成まで(マージしない)。
- 既定: 未 merge の同名ブランチがあれば更新、無ければ `origin/main` から作成し PR を open/更新 → マージ。
- `gh pr merge` 失敗時に PR を残して正常終了(フォールバック)。
- `--all` / `--edit` の各経路。
