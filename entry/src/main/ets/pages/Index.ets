// import { AvplayerUtils } from '../utils/AvplayerUtils'
// import { emitter } from '@kit.BasicServicesKit'
// import { players, playertunnel, playertunnel1, playertunnel2, player_0, player_1, PlayState } from '../utils/common'
//
// @Entry
// @Component
// struct Index {
//   // @State message: string = 'Hello World';
//   @State isone:boolean=true
// // @State isplayer:boolean=true
// //   @State total:number=0
// //   @State time:number=0
//   @State
//   playstate:PlayState= new PlayState()
//
//   //千算万算没算到init是异步的所以这个赋值会直接错过去,要么就等,用emitter传值我没试过,刚写好没试过,等会试试
//   async aboutToAppear(): Promise<void> {
//     emitter.on(playertunnel2,(date:emitter.EventData)=>{
//       let d=date.data as players
//       this.playstate=JSON.parse(d.mydata)
//       console.log('ken','现在数据'+JSON.stringify(d.mydata))
//     })
//      AvplayerUtils.init()
//     // this.playstate=AvplayerUtils.playstate
//     // console.log('ken',JSON.stringify(this.playstate))
//
//     emitter.on(playertunnel,(date:emitter.EventData)=>{
//       let d=date.data as player_0
//       this.playstate.duration=d.total
//     })
//     emitter.on(playertunnel1,(date)=>{
//       let d=date.data as player_1
//       this.playstate.time=d.time
//     })
//   }
//   build() {
//     Column() {
//       Stack(){
//         Image($r('app.media.ic_cd')).height(300).width(300).borderRadius(150)
//         Image(this.playstate.img).height(200).width(200).borderRadius(100).objectFit(ImageFit.Cover)
//           // .backgroundColor(Color.Red)
//           .margin({top:150})
//       }.alignContent(Alignment.Center)
//
//
//       Column(){
//         Text(this.playstate.name).fontSize(22).fontWeight(FontWeight.Bold)
//         Text(this.playstate.author).fontSize(13)
//       }.layoutWeight(1)
//
//       .justifyContent(FlexAlign.Center)
//
//       Row(){
//         Text(Math.floor((this.playstate.time)/1000/60)+':'+Math.floor((this.playstate.time)/1000%60))
//         Slider({
//           min:0,
//           max:this.playstate.duration,
//           value:this.playstate.time
//         }).onChange((val)=>{
//           this.playstate.time=val
//           AvplayerUtils.avplayer.seek(val)
//         }).layoutWeight(1)
//         Text(Math.floor((this.playstate.duration)/1000/60)+':'+Math.floor((this.playstate.duration)/1000%60))
//       }
//       Row(){
//         Image($r('app.media.pre')).onClick((event: ClickEvent) => {
//           this.isone=true
//           AvplayerUtils.pre()
//         }).height(30).aspectRatio(1)
//         Image(this.playstate.isPlay?$r('app.media.play'):$r('app.media.suspend')).onClick((event: ClickEvent) => {
//           if(this.playstate.isPlay){
//             if(this.isone){
//               AvplayerUtils.play()
//               this.isone=false
//             }else{
//               AvplayerUtils.resume()
//             }
//
//           }else {
//             AvplayerUtils.pause()
//           }
//           this.playstate.isPlay=!this.playstate.isPlay
//         }).height(30).aspectRatio(1)
//         Image($r('app.media.next')).onClick((event: ClickEvent) => {
//           this.isone=true
//           AvplayerUtils.next()
//         }).height(30).aspectRatio(1)
//
//       }.justifyContent(FlexAlign.SpaceAround)
//       .width('100%')
//
//
//       // Row(){
//       //
//       //
//       // }.width('100%')
//       // .justifyContent(FlexAlign.SpaceBetween)
//     }
//     .height('100%')
//     .width('100%')
//   }
// }



import { AvplayerUtils } from '../utils/AvplayerUtils'
import { emitter } from '@kit.BasicServicesKit'
import { players, playertunnel, playertunnel1, playertunnel2, player_0, player_1, PlayState,
  SongItemType } from '../utils/common'
import { when } from '@ohos/hypium'


//为什么一进入这个地方,数据一开始的显示不出来,可恶
@Entry
@Component
struct Index {
  //背景颜色
//两个是为了搞渐变色的,但是渐变色的颜色获取是异步函数有点难调,我调不好,先放着
  @State topcolor:string='#1C1C21'
  @State bottomcolor:string='#121215'

  //没什么卵用,可以退休了
  @State isone:boolean=true

  //这个页面的核心数据,wcv好想死,早知道写之前先去问一下ai了
  @State
  playstate:PlayState=AvplayerUtils.playstate

  //mode切换的核心变量,当然本地在appstroage那里
  @StorageLink('mode') mode:number=0

  //这个是看音乐列表的核心判断变量
  @State showlist:boolean=false

  private lastBgUrl:string=''        // 记住"我现在关心哪张封面"

  //这个是抄ai的
  private async refreshBg(url:string){
    if(!url) return
    if(url === this.lastBgUrl) return          // 同一张封面，跳过（播放/暂停会反复触发这里）
    this.lastBgUrl = url                       // 先标记：我现在要的是这张

    try{
      let s = await AvplayerUtils.updateBg(url)
      if(url !== this.lastBgUrl) return        // 算完发现已经换歌了 → 结果作废
      this.topcolor = s[0]
      this.bottomcolor = s[1]
    }catch(e){
      this.lastBgUrl = ''                      // 失败了，允许下次重试
      console.log('ken','取色失败:',JSON.stringify(e))
    }
  }

  //这个主要是管订阅--包括核心数据,进度条数据,还有工具类的初始化,还有一进来的一些准备,比如一进来就要播放,不要让用户重复点击
  async aboutToAppear(): Promise<void> {
    //颜色操作
    // let s=await AvplayerUtils.updateBg(this.playstate.img)
    // this.topcolor=s[0]
    // this.bottomcolor=s[1]
    // this.bottomcolor=AvplayerUtils.

    // this.playstate=AvplayerUtils.playstate
    //这个是播放数据的接收
    emitter.on(playertunnel2,(date:emitter.EventData)=>{
      let d=date.data as players
      this.playstate=JSON.parse(d.mydata)
      this.refreshBg(this.playstate.img)
      console.log('ken','Index120具体播放界面的实现','现在数据'+JSON.stringify(d.mydata))
    })
    await AvplayerUtils.init()
    await this.refreshBg(this.playstate.img)
    //这个是播放时长的接收,就是不知道能不能让它快点显示,最好不要播放了接收到,这个可能会涉及到预加载的内容
    emitter.on(playertunnel,(date:emitter.EventData)=>{
      //原来的,不删好回滚
      // let d=date.data as player_0
      // this.playstate.duration=d.total

      //由于duration不是对象,只是一层嵌套所以可以实时同步ui
      this.playstate.duration=AvplayerUtils.playstate.duration
    })
    //这个获取到是时间变化的时候进度条的实时变化
    emitter.on(playertunnel1,(date)=>{
      // let d=date.data as player_1
      // this.playstate.time=d.time

      this.playstate.time=AvplayerUtils.playstate.time
    })
    //一进入页面直接播放,后面的代码直接粘贴到前面也不知道合不合适,能用就行
    if(this.playstate.isPlay){
      if(this.isone){
        AvplayerUtils.play()
        this.isone=false
      }else{
        AvplayerUtils.resume()
      }
    }else {
      AvplayerUtils.pause()
    }
    this.playstate.isPlay=!this.playstate.isPlay
  }

  build() {
    //这个是为了层叠空间让音乐列表生效
    Stack({alignContent:Alignment.Bottom}){
      //播放器本体
      Column() {
        Stack({alignContent:Alignment.Top}){
          Image($r('app.media.ic_stylus')).width(150)
          // .position({x:100})
            .rotate({angle:this.playstate.isPlay?-60:-45,centerX:'50%',centerY:'5%'})
            .animation({duration:600,curve:Curve.EaseInOut})
            .zIndex(100)
          Stack({alignContent:Alignment.Center}){
            Image($r('app.media.ic_cd')).height(300).width(300).borderRadius(150)
            Image(this.playstate.img).height(200).width(200).borderRadius(100).objectFit(ImageFit.Cover)
              // .rotate()
          }.margin({top:50})
          // .margin({top:40})
        }



        Column(){
          Text(this.playstate.name).fontSize(22).fontWeight(FontWeight.Bold)
            .margin({bottom:15})
          Text(this.playstate.author).fontSize(13)
        }.layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        Row(){
          Text(Math.floor((this.playstate.time)/1000/60)+':'+Math.floor((this.playstate.time)/1000%60))
            .fontColor(Color.White)
          Slider({
            min:0,
            max:this.playstate.duration,
            value:this.playstate.time
          }).onChange((val)=>{
            this.playstate.time=val
            AvplayerUtils.avplayer.seek(val)
          }).layoutWeight(1)
            .selectedColor(Color.White)
            .trackColor('#A6A6A6')

          Text(Math.floor((this.playstate.duration)/1000/60)+':'+Math.floor((this.playstate.duration)/1000%60))
            .fontColor(Color.White)
        }
        Row(){
          Image(this.mode==0?$r('app.media.ic_auto'): this.mode==1?$r('app.media.ic_repeat'):$r('app.media.ic_random'))
            .fillColor(Color.White)
            .onClick(async (event: ClickEvent) => {
            if(this.mode==2){
              this.mode=0
            }else this.mode++

          }).height(45).aspectRatio(1)

          Image($r('app.media.pre'))
            .fillColor(Color.White)
            .onClick(async (event: ClickEvent) => {
            this.isone=true
            await AvplayerUtils.pre()


          }).height(45).aspectRatio(1)
          // .fillColor(Color.White)
          Image(this.playstate.isPlay?$r('app.media.play'):$r('app.media.suspend'))
            .fillColor(Color.White)
            .onClick((event: ClickEvent) => {

            //方案1--全靠本地来控制,但是这个思维不灵活的人不要轻易尝试,很容易搞混,比如我
            // if(this.playstate.isPlay){
            //   if(this.isone){
            //     AvplayerUtils.play()
            //     this.isone=false
            //   }else{
            //     AvplayerUtils.resume()
            //   }
            //
            // }else {
            //   AvplayerUtils.pause()
            // }

            //方案二加入了图片是否在播放还是由本地的元素决定,但是本地的元素和静态类里面的高度绑定,静态类里面的状态是由真实的数据决定了,链条清晰
            AvplayerUtils.toggle()
            this.playstate.isPlay=AvplayerUtils.playstate.isPlay
          }).height(45).aspectRatio(1)
          // .fillColor(Color.White)
          Image($r('app.media.next'))
            .fillColor(Color.White)
            .onClick(async (event: ClickEvent) => {
            this.isone=true
            await AvplayerUtils.nextN()
            // await AvplayerUtils.next()



          }).height(45).aspectRatio(1)
          // .fillColor(Color.White)
          Image($r('app.media.ic_song_list'))
            .fillColor(Color.White)
            .onClick(async (event: ClickEvent) => {
            if(AvplayerUtils.playstate.playList){
              this.showlist=true
            }


          }).height(45).aspectRatio(1)
        }.justifyContent(FlexAlign.SpaceAround)
        .width('100%')
        .margin({bottom:20})

      }
      .height('100%')
      .width('100%')
      .onClick(()=>{
        //这个就是点击其他地方让列表消失的关键,层叠布局好啊,要学
        this.showlist=false
      })
      //暂时不想去碰的没什么卵用的注释--渐变色
      // .linearGradient(
      //   {
      //     direction:GradientDirection.Bottom,
      //     colors:[[this.topcolor,0.0],[this.bottomcolor,1.0]]
      //   }
      // )
      .linearGradient({
        angle: 180, // 渐变方向:180 = 从上到下
        colors: [
          ['#1DB954', 0.0],  // 顶部:当前的绿色
          ['#0B6B35', 0.6],  // 中部:深一点的绿
          ['#0A1F14', 1.0]   // 底部:接近黑绿,让按钮和字更突出
        ]
      })
      .backgroundColor('#03DC6C')

      //音乐列表本地
      if(this.showlist){
        Column(){
          Text('播放列表('+this.playstate.playList.length+')')
            .margin({left:20,top:20,bottom:20})

          Divider().color(Color.White)
          List(){
            ForEach(this.playstate.playList,(item:SongItemType,i:number)=>{
              ListItem(){
                Column(){
                  Row(){
                    Text((i+1).toString()).alignSelf(ItemAlign.Center)
                      .margin({right:10,left:20})
                      .fontColor('#9A9191')
                    Column(){
                      Text(item.name).fontColor(item.name==this.playstate.name?'#EC6C87':'#9A9191')
                        .fontSize(16)

                      Text(item.author).fontColor(item.name==this.playstate.name?'#EC6C87':'#9A9191')
                        .fontSize(13)
                    }.height('100%')
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Start)

                  }.justifyContent(FlexAlign.Start)
                  Divider().color(Color.White)
                }.width('100%')
                .alignItems(HorizontalAlign.Start)
                .onClick(()=>{
                  AvplayerUtils.togglemusic(item)
                })
                //没做点击切换:纯懒,索引不好找,当然可以找,而且要通知全部的数据更新,或许这个应该要在工具类里面写一个方法



              }.height(55)

            })
          }.layoutWeight(1)

        }.backgroundColor('#353333')
        .borderRadius({topLeft:10,topRight:10})
        .height('50%')
        .width('100%')
      }
    }.margin({top:20,bottom:20})


  }
}


