export let playertunnel='0'
export let playertunnel1='1'

export interface player_0{
  total:number
}

export interface player_1{
  time:number
}

export class PlayState {

  img: string = "" // 音乐封面  *
  name: string = "" // 音乐名称  *
  author: string = "" // 作者  *
  url: string = "" // 当前播放连接  *
  playIndex: number = 0 // 当前在播放列表中的播放索引  *
  time: number = 0 // 播放时间  *
  duration: number = 0 // 音乐的播放时长 *
  isPlay: boolean = false // 是否正在播放
  playMode: 'auto' | 'repeat' | 'random' = "auto" // 播放模式
  playList: SongItemType[] = [] // 当前的播放列表
  cacheImg?: string // 缓存图片地址--只有这个现在暂时不需要考虑

}


/**
 * 歌曲信息
 */
export interface SongItemType {

  id: string
  url: string
  name: string
  author: string
  img: string
}

export const songs: SongItemType[] = [
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/0.jpg',
    name: '直到世界的尽头',
    author: 'WANDS',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/0.m4a',
    id: '0000'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/1.jpg',
    name: '画',
    author: '赵磊',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/1.mp3',
    id: '0001'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/2.jpg',
    name: 'Sweet Dreams',
    author: 'TPaul Sax / Eurythmics',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/2.mp3',
    id: '0002'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/3.jpg',
    name: '奢香夫人',
    author: '凤凰传奇',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/3.m4a',
    id: '0003'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/4.jpg',
    name: '空心',
    author: '光泽',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/4.mp3',
    id: '0004'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/5.jpg',
    name: '反转地球',
    author: '潘玮柏',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/5.mp3',
    id: '0005'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/6.jpg',
    name: 'No.9',
    author: 'T-ara',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/6.m4a',
    id: '0006'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/7.jpg',
    name: '孤独',
    author: 'G.E.M.邓紫棋',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/7.m4a',
    id: '0007'
  },

  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/8.jpg',
    name: 'Lose Control',
    author: 'Hedley',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/8.m4a',
    id: '0008'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/9.jpg',
    name: '倩女幽魂',
    author: '张国荣',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/9.m4a',
    id: '0009'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/10.jpg',
    name: '北京北京',
    author: '汪峰',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/10.m4a',
    id: '0010'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/11.jpg',
    name: '苦笑',
    author: '汪苏泷',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/11.mp3',
    id: '0011'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/12.jpg',
    name: '一生所爱',
    author: '卢冠廷 / 莫文蔚',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/12.m4a',
    id: '0012'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/13.jpg',
    name: '月半小夜曲',
    author: '李克勤',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/13.mp3',
    id: '0013'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/14.jpg',
    name: 'Rolling in the Deep',
    author: 'Adele',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/14.m4a',
    id: '0014'
  },
  {
    img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/15.jpg',
    name: '海阔天空',
    author: 'Beyond',
    url: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/15.m4a',
    id: '0015'
  }
]