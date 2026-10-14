/**
 *                             _ooOoo_
 *                            o8888888o
 *                            88" . "88
 *                            (| -_- |)
 *                            O\  =  /O
 *                         ____/`---'\____
 *                       .'  \\|     |//  `.
 *                      /  \\|||  :  |||//  \
 *                     /  _||||| -:- |||||-  \
 *                     |   | \\\  -  /// |   |
 *                     | \_|  ''\---/''  |   |
 *                     \  .-\__  `-`  ___/-. /
 *                   ___`. .'  /--.--\  `. . ___
 *                ."" '<  `.___\_<|>_/___.'  >'"".
 *               | | :  `- \`.;`\ _ /`;.`/ - ` : | |
 *               \  \ `-.   \_ __\ /__ _/   .-` /  /
 *         ========`-.____`-.___\_____/___.-`____.-'========
 *                              `=---='
 *         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 *                佛祖保佑       永无BUG     永不修改
 *
 *                          夜深灯火伴星河
 *                          指落键盘作雨歌
 *                          一行报错愁千缕
 *                          半盏凉茶梦几何
 *                          清缓存后寻旧路
 *                          编译静候过长坡
 *                          但愿一次皆通过
 *                          此后代码不起波
 */
/*
 * +----------------------------------+
 * |  此文件由 择 精心编写            |
 * |  运行正常,请勿触碰              |
 * |  运行异常,先 Clean 再重启       |
 * +----------------------------------+
 */
import media from "@ohos.multimedia.media"
import { emitter } from "@kit.BasicServicesKit"
import { players, playertunnel, playertunnel1, playertunnel2, PlayState, songs } from "./common"
import { image } from "@kit.ImageKit"
import { effectKit } from "@kit.ArkGraphics2D"
import { http } from "@kit.NetworkKit"

export class AvplayerUtils{
  static avplayer:media.AVPlayer=null!
  static playstate:PlayState=new PlayState()
  private constructor() {
  }


  //这个函数从网络上拷贝下来的
  async updateBg(url: string): Promise<string[]> {
    // 下载封面为二进制数据
    const res = await http.createHttp().request(url, { expectDataType: http.HttpDataType.ARRAY_BUFFER })
    // 二进制 → PixelMap(像素图,取色器的输入)
    const pixelMap = await image.createImageSource(res.result as ArrayBuffer).createPixelMap()
    const picker = await effectKit.createColorPicker(pixelMap)
    const c = await picker.getMainColor()   // 主色,含 red/green/blue/alpha,范围 0~255
    let s:string[]=[]
    s[0]=`rgb(${c.red},${c.green},${c.blue})`
    s[1]=`rgb(${Math.floor(c.red * 0.4)},${Math.floor(c.green * 0.4)},${Math.floor(c.blue * 0.4)})`

    // 底部用同一颜色压暗到 40%,形成上亮下暗的渐变
    return s
  }

  //init函数主要就是建新的播放器对象还有,设置一些监听之类的
    static async init(){
    if(AvplayerUtils.avplayer)return
    AvplayerUtils.avplayer=await  media.createAVPlayer()
      AvplayerUtils.avplayer.on('stateChange',(state)=>{
        switch (state){
          case 'initialized':{
            AvplayerUtils.avplayer.prepare()
            break
          }
          case 'prepared':{
            AvplayerUtils.avplayer.play()
          }
          // 暂时不需要管播放模式的问题,直接默认顺序播放就行
          case 'stopped':{

          }


        }
      })
      AvplayerUtils.avplayer.on('durationUpdate',(val)=>{
        emitter.emit(playertunnel,{data:{'total':val}})
      })
      AvplayerUtils.avplayer.on('timeUpdate',(val)=>{
        emitter.emit(playertunnel1,{data:{'time':val}})
      })
      //接下来是对象处理环节
      // AvplayerUtils.playstate.img=songs[0].img
      // AvplayerUtils.playstate.name=songs[0].name
      // AvplayerUtils.playstate.url=songs[0].url
      // AvplayerUtils.playstate.author=songs[0].author
      // AvplayerUtils.playstate.playIndex=0
      // AvplayerUtils.playstate.playList=songs
      // console.log('ken','静态类里面'+JSON.stringify(AvplayerUtils.playstate))
      emitter.on(playertunnel2,(date:emitter.EventData)=>{
        let d=date.data as players
        AvplayerUtils.playstate=JSON.parse(d.mydata)
        console.log('ken','AvplayerUtils81','现在数据'+JSON.stringify(d.mydata))
      })


   }
   static play(){
    // AvplayerUtils.avplayer.url='http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/3.m4a'
    AvplayerUtils.avplayer.url=AvplayerUtils.playstate.url
   }

   static seek(val:number){
    AvplayerUtils.avplayer.seek(val)
   }

   static resume(){
    AvplayerUtils.avplayer.play()
   }
   static pause(){
      AvplayerUtils.avplayer.pause()
   }
   static pre(){
     if(AvplayerUtils.playstate.playIndex<=0){
       return;
     }
      AvplayerUtils.avplayer.reset()
     let ind=--AvplayerUtils.playstate.playIndex
     // AvplayerUtils.avplayer.reset()
     // AvplayerUtils.playstate.img=songs[ind].img
     // AvplayerUtils.playstate.name=songs[ind].name
     // AvplayerUtils.playstate.url=songs[ind].url
     // AvplayerUtils.playstate.author=songs[ind].author
     AvplayerUtils.playstate.img=AvplayerUtils.playstate.playList[ind].img
     AvplayerUtils.playstate.name=AvplayerUtils.playstate.playList[ind].name
     AvplayerUtils.playstate.url=AvplayerUtils.playstate.playList[ind].url
     AvplayerUtils.playstate.author=AvplayerUtils.playstate.playList[ind].author
     console.log('ken','状态上:'+AvplayerUtils.avplayer.state)
     AvplayerUtils.play()
     console.log('ken','状态下:'+AvplayerUtils.avplayer.state)
     emitter.emit(playertunnel2,{data:{
       'mydata':JSON.stringify(AvplayerUtils.playstate)
     }})

   }
   static  next(){
      if(AvplayerUtils.playstate.playIndex>=AvplayerUtils.playstate.playList.length-1){
        return;
      }
     let ind=++AvplayerUtils.playstate.playIndex
     AvplayerUtils.avplayer.reset()
     // AvplayerUtils.playstate.img=songs[ind].img
     // AvplayerUtils.playstate.name=songs[ind].name
     // AvplayerUtils.playstate.url=songs[ind].url
     // AvplayerUtils.playstate.author=songs[ind].author
     AvplayerUtils.playstate.img=AvplayerUtils.playstate.playList[ind].img
     AvplayerUtils.playstate.name=AvplayerUtils.playstate.playList[ind].name
     AvplayerUtils.playstate.url=AvplayerUtils.playstate.playList[ind].url
     AvplayerUtils.playstate.author=AvplayerUtils.playstate.playList[ind].author
     console.log('ken','状态上:'+AvplayerUtils.avplayer.state)
     AvplayerUtils.play()
     console.log('ken','状态下:'+AvplayerUtils.avplayer.state)
     emitter.emit(playertunnel2,{data:{
       'mydata':JSON.stringify(AvplayerUtils.playstate)
     }})
   }
 }