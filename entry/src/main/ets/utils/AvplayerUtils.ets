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
import { playertunnel, playertunnel1, playertunnel2, PlayState, songs } from "./common"

export class AvplayerUtils{
  static avplayer:media.AVPlayer=null!
  static playstate:PlayState=new PlayState()
  private constructor() {
  }
    static async init(){
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


        }
      })
      AvplayerUtils.avplayer.on('durationUpdate',(val)=>{
        emitter.emit(playertunnel,{data:{'total':val}})
      })
      AvplayerUtils.avplayer.on('timeUpdate',(val)=>{
        emitter.emit(playertunnel1,{data:{'time':val}})
      })
      //接下来是对象处理环节
      AvplayerUtils.playstate.img=songs[0].img
      AvplayerUtils.playstate.name=songs[0].name
      AvplayerUtils.playstate.url=songs[0].url
      AvplayerUtils.playstate.author=songs[0].author
      AvplayerUtils.playstate.playIndex=0
      AvplayerUtils.playstate.playList=songs
      console.log('ken','静态类里面'+JSON.stringify(AvplayerUtils.playstate))
      emitter.emit(playertunnel2,{data:{
    'mydata':JSON.stringify(AvplayerUtils.playstate)
      }})


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
      AvplayerUtils.avplayer.reset()
     let ind=--AvplayerUtils.playstate.playIndex
     AvplayerUtils.avplayer.reset()
     AvplayerUtils.playstate.img=songs[ind].img
     AvplayerUtils.playstate.name=songs[ind].name
     AvplayerUtils.playstate.url=songs[ind].url
     AvplayerUtils.playstate.author=songs[ind].author
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
     AvplayerUtils.playstate.img=songs[ind].img
     AvplayerUtils.playstate.name=songs[ind].name
     AvplayerUtils.playstate.url=songs[ind].url
     AvplayerUtils.playstate.author=songs[ind].author
     console.log('ken','状态上:'+AvplayerUtils.avplayer.state)
     AvplayerUtils.play()
     console.log('ken','状态下:'+AvplayerUtils.avplayer.state)
     emitter.emit(playertunnel2,{data:{
       'mydata':JSON.stringify(AvplayerUtils.playstate)
     }})
   }
 }