export interface TabClass {
  title: string
  name: string
  icon: Resource // $r() 返回的类型
}

export interface RecommendDailyType {
  img: string
  title: string
  type: string
  top: string    // 渐变上端颜色
  bottom: string // 渐变下端颜色
}

export interface RecommendListType {
  img: string
  title: string
  count: string
}

export interface SongItemType {
  img: string
  name: string
  author: string
  url: string
  id: string
}

export interface FavoriteListType {
  name: string
  nickName: string
  avatar: Resource
  songs: SongItemType[]
}

export interface MomentListType {
  author: string
  avatar: string
  content: string
  comment: number
  like: number
  song: SongItemType
}