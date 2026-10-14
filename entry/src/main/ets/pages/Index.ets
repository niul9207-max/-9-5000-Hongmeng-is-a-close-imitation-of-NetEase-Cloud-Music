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
import { players, playertunnel, playertunnel1, playertunnel2, player_0, player_1, PlayState } from '../utils/common'


//为什么一进入这个地方,数据一开始的显示不出来,可恶
@Entry
@Component
struct Index {
  @State isone:boolean=true
  @State
  playstate:PlayState=AvplayerUtils.playstate
  async aboutToAppear(): Promise<void> {
    this.playstate=AvplayerUtils.playstate
    //这个是播放数据的接收
    emitter.on(playertunnel2,(date:emitter.EventData)=>{
      let d=date.data as players
      this.playstate=JSON.parse(d.mydata)
      console.log('ken','Index120具体播放界面的实现','现在数据'+JSON.stringify(d.mydata))
    })
    await AvplayerUtils.init()
    //这个是播放时长的接收,就是不知道能不能让它快点显示,最好不要播放了接收到,这个可能会涉及到预加载的内容
    emitter.on(playertunnel,(date:emitter.EventData)=>{
      let d=date.data as player_0
      this.playstate.duration=d.total
    })
    //这个获取到是时间变化的时候进度条的实时变化
    emitter.on(playertunnel1,(date)=>{
      let d=date.data as player_1
      this.playstate.time=d.time
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
    Column() {
      Stack({alignContent:Alignment.Center}){
        Image($r('app.media.ic_cd')).height(300).width(300).borderRadius(150)

        Image(this.playstate.img).height(200).width(200).borderRadius(100).objectFit(ImageFit.Cover)

      }


      Column(){
        Text(this.playstate.name).fontSize(22).fontWeight(FontWeight.Bold)
          .margin({bottom:15})
        Text(this.playstate.author).fontSize(13)
      }.layoutWeight(1)

      .justifyContent(FlexAlign.Center)

      Row(){
        Text(Math.floor((this.playstate.time)/1000/60)+':'+Math.floor((this.playstate.time)/1000%60))
        Slider({
          min:0,
          max:this.playstate.duration,
          value:this.playstate.time
        }).onChange((val)=>{
          this.playstate.time=val
          AvplayerUtils.avplayer.seek(val)
        }).layoutWeight(1)
        Text(Math.floor((this.playstate.duration)/1000/60)+':'+Math.floor((this.playstate.duration)/1000%60))
      }
      Row(){
        Image($r('app.media.pre')).onClick((event: ClickEvent) => {
          this.isone=true
          AvplayerUtils.pre()
        }).height(45).aspectRatio(1)
        Image(this.playstate.isPlay?$r('app.media.play'):$r('app.media.suspend')).onClick((event: ClickEvent) => {
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
        }).height(45).aspectRatio(1)
        Image($r('app.media.next')).onClick((event: ClickEvent) => {
          this.isone=true
          AvplayerUtils.next()
        }).height(45).aspectRatio(1)

      }.justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .margin({bottom:20})

    }
    .height('100%')
    .width('100%')
  }
}