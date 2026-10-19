[README.md](https://github.com/user-attachments/files/33663679/README.md)
# test_0 · 鸿蒙低仿网易云音乐（ArkTS / ArkUI）

一个 HarmonyOS NEXT _stageMode_ 学习项目：仿网易云音乐移动端界面 + 网络音频播放。
5 个底部 Tab（首页 / 发现 / 漫游 / 动态 / 我的）、迷你播放条、全屏播放器（CD 转盘 + 封面取色渐变背景 + 播放列表抽屉）、顺序/单曲/随机三种播放模式。

> 练手项目，界面与音频素材用于学习，不含真实业务与版权内容，请勿用于分发。

---

## 1. 环境与工具

| 项 | 值 |
| --- | --- |
| IDE | DevEco Studio（模型版本 `6.1.1`） |
| runtimeOS | HarmonyOS |
| targetSdkVersion | `6.1.1(24)` |
| compatibleSdkVersion | `5.0.1(13)` |
| bundleName | `com.example.test_0` |
| deviceTypes | `phone` |
| 主要 API | `@ohos.multimedia.media`(AVPlayer)、`@kit.ArkUI`(router/Window)、`@kit.BasicServicesKit`(emitter)、`@kit.ImageKit` + `@kit.ArkGraphics2D`(colorPicker 取色)、`@kit.NetworkKit`(http) |
| 依赖 | 仅测试依赖 `@ohos/hypium@1.0.25`、`@ohos/hamock@1.0.0`；无第三方业务库 |
| 权限 | `ohos.permission.INTERNET`（见 `entry/src/main/module.json5`） |

## 2. 目录结构

```
test_0/
├── AppScope/app.json5              # 应用级配置（包名、版本、图标）
├── build-profile.json5             # SDK 版本、product、模块声明（签名配置为空）
├── oh-package.json5                # 仓级依赖
├── entry/
│   └── src/main/
│       ├── module.json5            # entry 模块配置、权限、Ability 注册
│       ├── ets/
│       │   ├── entryability/EntryAbility.ets        # 启动 Ability，初始化 AppStorage('mode')，加载 pages/PageSplash
│       │   ├── entrybackupability/                  # 备份扩展 Ability（脚手架）
│       │   ├── pages/
│       │   │   ├── PageSplash.ets                    # 启动页/彩蛋页 → router.replace 到 PageIndex
│       │   │   ├── PageIndex.ets (745 行)            # 主框架：Tabs + 5 个子页面 + 迷你播放条
│       │   │   └── Index.ets (394 行)                # 全屏播放器（CD/唱臂/进度条/模式切换/列表抽屉）
│       │   ├── utils/
│       │   │   ├── AvplayerUtils.ets                 # 播放器封装：init/play/resume/pause/seek/pre/next/toggle/togglemusic/findmusic_play/updateBg
│       │   │   └── common.ets                        # PlayState / SongItemType / songs(16 首) / emitter 事件号
│       │   ├── module/player.ets                     # 数据模型接口 + LazyForEach 用 IDataSource(looperlist)
│       │   └── constant/
│       │       ├── MusicConstants.ets                # 轮播、每日推荐、歌单、动态、歌曲等静态数据
│       │       └── data.ets                          # 全局运行期播放列表 ss
│       └── resources/base/media/                     # 图标/封面（svg、png、gif）
├── 鸿蒙低仿网易云音乐计划表.xlsx    # 开发计划与任务拆分
└── hs_err_pid74920.log              # 遗留 JVM 崩溃日志，可删
```

## 3. 功能一览

| 页面 | 组件 | 已实现 |
| --- | --- | --- |
| PageSplash | `struct PageSplash` | 启动图 + 按钮，点击 `router.replace` 进主页；含彩蛋文案与"逃跑按钮"注释版；`aboutToAppear` 内的 2s 自动跳转已注释 |
| PageIndex | `struct PageIndex` + `homeitem` / `find` / `manyou` / `Dynamic` / `me` | Tabs（barPosition 底部，`scrollable(false)`，`index` 双向绑定控制高亮 `#EC6C87`）；首页搜索框 `issearch` 状态切换搜索结果列表，命中即 `AvplayerUtils.findmusic_play`；推荐列表用 `LazyForEach + looperlist`；层叠布局 `Stack` 上悬浮迷你播放条（封面/歌名/歌手 + 上一首/播放暂停/下一首），点击播放条 `router.pushUrl('pages/Index')`；"我的" Tab 下隐藏迷你条 |
| Index | `struct Index` | CD 盘 + 唱臂（`rotate` + `animation` 跟随播放状态）；`Slider` 进度条 + 时间格式化（补零）；播放模式图标切换（`@StorageLink('mode')` 顺序→单曲→随机）；歌曲列表抽屉（`showlist`）；`AvplayerUtils.updateBg` 下载封面 → PixelMap → ColorPicker 主色，做上下渐变背景（带 `lastBgUrl` 竞态保护） |
| 播放能力 | `AvplayerUtils` | AVPlayer 生命周期事件（initialized→prepare→prepared→play、completed 按 mode 分支）、`timeUpdate`/`durationUpdate` 回抛 UI、上一首/下一首/切歌/搜索播放 |

状态同步方式：`AvplayerUtils.playstate` 为唯一母体，变化时通过 `emitter` + `JSON.stringify` 广播（事件号 `playertunnel`/`playertunnel1`/`playertunnel2`），`PageIndex` 与 `Index` 各自 `emitter.on` 订阅后刷新 `@State`。

## 4. 运行

1. DevEco Studio → `File > Open` 选择本目录（`build-profile.json5` 所在层）。
2. 等待 Sync，或手动 `ohpm install`。
3. 首次真机运行前需配置签名：当前 `build-profile.json5` 里 `"signingConfigs": []` 为空，请在 `File > Project Structure > Signing Configs` 勾选 Automatically generate signature（模拟器等 DevEco 自动签名后再 Build）。
4. Run ▶ 选 Local Emulator 或已连接设备；运行期请保持联网（音频与封面是 `http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/...` 远端地址，离线会播放失败/封面空白）。
5. 命令行构建需 DevEco 自带 hvigor（仓库未提交 `hvigorw` 包装脚本），日常建议直接用 IDE 的 `Build > Build Hap(s)`。

## 5. 已知问题（代码里自己记下的 + 阅读结论）

- **状态总线用 emitter 而非 AppStorage**：三处 `emit`、多处 `on`，事件号是字符串 `'0'/'1'/'2'`，易混易漏订阅；注释已标注"下次一定用 AppStorage"。
- **`toggle()` 的 `isPlay` 语义是反的**：playing 分支里置 `isPlay=true`，非 playing 分支置 `false`，与字段名相反；Index.ets 里还额外做了一次 `!isPlay` 补偿，改动播放/暂停逻辑时要小心。
- **顺序播放到头不循环**：`pre()` 在 `playIndex<=0`、`next()` 在 `playIndex>=length-1` 时直接 `return`，不自动续播。
- **随机索引分布不均**：`Math.floor(Math.random()*10000 % playList.length)`，超出列表长度的取模会让前面的歌曲命中概率偏高。
- **`findmusic_play` 自带 "这个东西有bug" 注释**：命中列表内歌曲走切歌逻辑；未命中时把歌插进全局 `ss` 并重建整个 `PlayState`，与 `playList` 来源混用。
- **单曲循环依赖 `nextN()` 的 `seek(0)`**，`completed` 分支里的 mode 判断与 AppStorage 值有"搞混"注释，以实际运行结果为准。
- **取色渐变是异步的**，注释说"调不好，先放着"；`lastBgUrl` 只解决了结果过期，首帧背景仍是默认深色。
- **Index.ets 前 105 行是整段注释的历史版本**，可清理。
- **测试是脚手架**：`entry/src/test`、`entry/src/ohosTest` 只有模板用例，无业务测试。
- **`local.properties` / `.idea` / `oh_modules` / `.hvigor` 已在 .gitignore**，拉取后由 IDE 生成，无需手动提交。

## 6. 建议的下一步

1. 用 `AppStorage`/单例收敛 `playstate`，删掉 emitter 广播链路。
2. 合并 `songs`（`utils/common.ets`）与 `MusicConstants.ets` 中重复的歌曲数据源，列表来源单一化。
3. 修完上面第 5 节的播放模式边界：顺序循环、随机不重复、切歌后 `playIndex` 与列表一致。
4. 补后台播放与通知栏（AVSession），当前仅前台播放。
5. 按 `鸿蒙低仿网易云音乐计划表.xlsx` 对齐剩余任务，并为播放器状态写 hypium 用例。
