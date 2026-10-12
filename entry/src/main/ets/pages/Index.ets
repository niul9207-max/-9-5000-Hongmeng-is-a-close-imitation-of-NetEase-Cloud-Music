import { AvplayerUtils } from '../utils/AvplayerUtils'
import { emitter } from '@kit.BasicServicesKit'
import { playertunnel, playertunnel1, player_0, player_1, PlayState } from '../utils/common'

@Entry
@Component
struct Index {
  // @State message: string = 'Hello World';
  @State isone:boolean=true
// @State isplayer:boolean=true
//   @State total:number=0
//   @State time:number=0
  playstate:PlayState= new PlayState()



  aboutToAppear(): void {
    AvplayerUtils.init()
    emitter.once(playertunnel,(date:emitter.EventData)=>{
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
      Image(this.playstate.img).height(200).aspectRatio(1).borderRadius(100)
      Row(){
        Image($r('app.media.pre')).onClick((event: ClickEvent) => {

        }).height(30).aspectRatio(1)
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
        }).height(30).aspectRatio(1)
        Image($r('app.media.next')).onClick((event: ClickEvent) => {

        }).height(30).aspectRatio(1)

      }
      Slider({
        min:0,
        max:this.playstate.duration,
        value:this.playstate.time
      }).onChange((val)=>{
        this.playstate.time=val
        AvplayerUtils.avplayer.seek(val)
      })
      Row(){
        Text(this.playstate.time+'')
        Text(this.playstate.duration+'')
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height('100%')
    .width('100%')
  }
}