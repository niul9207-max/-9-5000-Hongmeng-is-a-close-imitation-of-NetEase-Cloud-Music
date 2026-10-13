import image from '@ohos.multimedia.image';
import { AvplayerUtils } from '../utils/AvplayerUtils';
import {
  players,
  playertunnel, playertunnel1, playertunnel2, player_0, player_1,
  PlayState,
  SongItemType, songs } from '../utils/common';
import { emitter } from '@kit.BasicServicesKit';
import { dailyRecommend, momentList, recommendList, swiperList } from '../constant/MusicConstants';
import { MomentListType, RecommendDailyType, RecommendListType } from '../module/player';

@Entry
@Component
struct PageIndex {
  @State message: string = 'Hello World';
  @State current:number=0
  @Builder
  bottomicon(image:Resource,tabname:string){
    Column(){
      // Image($r('app.media.bottom1')).height(20).aspectRatio(1)
      Image(image).height(20).aspectRatio(1)
      Text(tabname)
    }

  }
  @State isone:boolean=true
  // @State isplayer:boolean=true
  //   @State total:number=0
  //   @State time:number=0
  @State
  playstate:PlayState= new PlayState()

  //千算万算没算到init是异步的所以这个赋值会直接错过去,要么就等,用emitter传值我没试过,刚写好没试过,等会试试
  async aboutToAppear(): Promise<void> {
    emitter.on(playertunnel2,(date:emitter.EventData)=>{
      let d=date.data as players
      this.playstate=JSON.parse(d.mydata)
      console.log('ken','现在数据'+JSON.stringify(d.mydata))
    })
    AvplayerUtils.init()
    // this.playstate=AvplayerUtils.playstate
    // console.log('ken',JSON.stringify(this.playstate))

    emitter.on(playertunnel,(date:emitter.EventData)=>{
      let d=date.data as player_0
      this.playstate.duration=d.total
    })
    emitter.on(playertunnel1,(date)=>{
      let d=date.data as player_1
      this.playstate.time=d.time
    })
  }

  build() {
    Column() {
      Tabs({barPosition:BarPosition.End,index:$$this.current}){
        TabContent(){
homeitem()

        }.tabBar(
          this.bottomicon($r('app.media.bottom1'),'首页')
        )
        TabContent(){
find()

        }.tabBar(
          this.bottomicon($r('app.media.ic_find'),'发现')
        )
        TabContent(){
         manyou()

        }.tabBar(
          this.bottomicon($r('app.media.ic_logo'),'漫游')
        )
        TabContent(){
          Dynamic()
        }.tabBar(
          this.bottomicon($r('app.media.ic_moment'),'动态')
        )
        TabContent(){
          Text('我的')
        }.tabBar(
          this.bottomicon($r('app.media.ic_mine'),'我的')
        )

      }.layoutWeight(1)
      // Row(){
      //   Image($r('app.media.pre')).onClick((event: ClickEvent) => {
      //     this.isone=true
      //     AvplayerUtils.pre()
      //   }).height(30).aspectRatio(1)
      //   Image(this.playstate.isPlay?$r('app.media.play'):$r('app.media.suspend')).onClick((event: ClickEvent) => {
      //     if(this.playstate.isPlay){
      //       if(this.isone){
      //         AvplayerUtils.play()
      //         this.isone=false
      //       }else{
      //         AvplayerUtils.resume()
      //       }
      //
      //     }else {
      //       AvplayerUtils.pause()
      //     }
      //     this.playstate.isPlay=!this.playstate.isPlay
      //   }).height(30).aspectRatio(1)
      //   Image($r('app.media.next')).onClick((event: ClickEvent) => {
      //     this.isone=true
      //     AvplayerUtils.next()
      //   }).height(30).aspectRatio(1)
      //
      // }.justifyContent(FlexAlign.SpaceAround)
      // .width('100%')
    }
    .height('100%')
    .width('100%')
  }
}

@Component
struct homeitem {
  build() {
    List(){
      ListItem(){
        Swiper(){
          ForEach(swiperList,(item:string)=>{
              Image(item).width('100%')
          })
        }.autoPlay(true)
        .loop(true)
        .indicator(true)
        .width('85%')


      }
      ListItem(){
        Column(){
          Row(){
            Text('每日推荐').fontColor('#C4C4C4')
            Blank()
            Text('更多') .fontColor('#454546')
          }.width('100%')
          .margin({top:10,bottom:10})
          List(){
            ForEach(dailyRecommend,(item:RecommendDailyType)=>{
              ListItem(){
                Column(){
                  Text(item.type)
                    .backgroundColor(item.top)
                    .width('100%')
                    .textAlign(TextAlign.Center)


                  Image(item.img).width('100%')
                  Text(item.title)
                    .backgroundColor(item.bottom)
                    .width('100%')
                    .fontSize(12)
                    .layoutWeight(1)

                }
                // .height(150)
                .width('30%')
                .borderRadius(80)
                .height(180)
                .margin({right:10})
              }

            })
          }
          .listDirection(Axis.Horizontal)
        }.borderRadius(20)

      }.margin({top:20})
      ListItem(){
        // Text('推荐歌单').fontColor(Color.White)//和上面那个过渡的很像去抄上面的
        Row(){
          Text('推荐歌单').fontColor('#C4C4C4')
          Blank()
          Text('更多') .fontColor('#454546')
        }.width('100%')
        .margin({top:10,bottom:10})
      }.width('100%')
      ListItem(){
        List(){
          ForEach(recommendList,(item:RecommendListType)=>{
            ListItem(){
              Column(){
                Stack(){
                  Image(item.img).width('100%').borderRadius(20)
                  Text(item.count).position({x:10,y:10}).fontColor(Color.White)

                }.width('100%')
                Text(item.title).layoutWeight(1).fontColor(Color.White).width('100%')
                  .padding({left:10,right:10})
                  .fontSize(12)
              }.width('32%').height(180)
              .margin({right:15})

            }
          })
        }.listDirection(Axis.Horizontal)
      }

    }.height('100%')
    .width('100%')
    .alignListItem(ListItemAlign.Center)
    .backgroundColor('#111113')
  }
}


@Component
struct manyou {
  build() {
    Column(){
      Column(){
        Row(){
          Image($r('app.media.ic_favorite'))
            .height(100).aspectRatio(1)
            .fillColor('#FF588B')
            .backgroundColor(Color.White)
          Column(){
            Text('我喜欢的音乐')
              .margin({bottom:10})
              .fontColor(Color.White)
            Text('咸鱼音乐')
              .fontColor('#4F4843')
          }.alignSelf(ItemAlign.Center)
          .margin({left:10})
        }.margin({top:30})
        .width('100%')
        Row(){
          Row(){
            Image($r('app.media.ic_share'))
              .height(15).aspectRatio(1)
              .fillColor('#EC5C87')
            Text('分享').fontColor(Color.White)
          }.alignSelf(ItemAlign.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(20)
          .backgroundColor('#353333')
          .width(80)
          .height(30)
          Row(){
            Image($r('app.media.ic_comment')).height(15).aspectRatio(1)
              .fillColor('#EC5C87')
            Text('评论').fontColor(Color.White)
          }
          .alignSelf(ItemAlign.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(20)
          .backgroundColor('#353333')
          .width(80)
          .height(30)
          Row(){
            Image($r('app.media.ic_collect')).height(15).aspectRatio(1)
              .fillColor('#EC5C87')
            Text('收藏').fontColor(Color.White)
          }.alignSelf(ItemAlign.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(20)
          .backgroundColor('#353333')
          .width(80)
          .height(30)

        }.justifyContent(FlexAlign.SpaceEvenly)
        .width('100%')
        .layoutWeight(1)
      }.padding({left:20})
      .radialGradient({
        colors:[['#6B4A12',0],['#121215',1]]
      ,center:['100%','0%'],
        radius:'70%'
      })
      .height(200)
      Column(){
        Row(){
          Image($r('app.media.ic_play')).height(20).aspectRatio(1)
            .fillColor('#FF5186')
          Text('播放全部')
        }.height(40)
        .justifyContent(FlexAlign.Start)
        .width('100%')
        .margin({left:20,bottom:10})

        List(){
          ForEach(songs,(item:SongItemType)=>{
            ListItem(){
              Row(){
                Image(item.img).height(45).aspectRatio(1)
                Column(){
                  Text(item.name).alignSelf(ItemAlign.Start)
                  Text(item.author).alignSelf(ItemAlign.Start)
                }.margin({left:10})
              }.borderRadius(20)
              .margin({left:20,bottom:10})
            }
          })
        }
      }.backgroundColor('#353333')
      .borderRadius({topLeft:20,topRight:20})
      .layoutWeight(1)

    }.width('100%')
    .height('100%')
    .backgroundColor('#121215')
  }
}

@Component
struct find {
  build() {
    Column(){
      Text('猜你喜欢')
        .height(40)
        .width('100%')
        .fontColor(Color.White)
        .margin({left:25})
      List(){
        ForEach(songs,(item:SongItemType)=>{
          ListItem(){
            Row(){
              Image(item.img).height(45).aspectRatio(1)
                .borderRadius(8)
              Column(){
                Text(item.name).alignSelf(ItemAlign.Start).fontSize(20).fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
                Text(item.author).alignSelf(ItemAlign.Start).fontSize(20).fontColor(Color.White)
              }.margin({left:10})
            }.borderRadius(20)
            .margin({left:20,bottom:10})
          }
        })
      }.layoutWeight(1)
    }.backgroundColor('#121215')

  }
}

@Component
struct Dynamic {
  build() {
    List(){
      ListItem(){
        Text('互动广场')
          .fontColor(Color.White)
      }
      .height(60)

        ForEach(momentList,(item:MomentListType)=>{
          ListItem(){
            Column(){
              Text(item.author).fontSize(20).fontColor('#E9E9E7')
              Text(item.content).fontSize(16).fontColor('#424145')
              Row(){
                Image(item.song.img).width(60)
                Column(){
                  Text(item.song.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#E9E9E7')
                  Text(item.song.author).fontSize(14).fontColor('#424145')

                }
                Image($r('app.media.ic_single_play')).width(20)
              }
              Row(){
                Row(){
                  Image($r('app.media.ic_share')).width(20)
                  Text('分享').fontSize(16).fontColor('#424145')
                }
                Row(){
                  Image($r('app.media.ic_comment_o')).width(20)
                  Text(item.comment+'').fontSize(16).fontColor('#424145')
                }
                Row(){
                  Image($r('app.media.ic_like')).width(20)
                  Text(item.like+'').fontSize(16).fontColor('#424145')
                }

              }
            }
          }



        })


    }.backgroundColor('#121215')
  }
}