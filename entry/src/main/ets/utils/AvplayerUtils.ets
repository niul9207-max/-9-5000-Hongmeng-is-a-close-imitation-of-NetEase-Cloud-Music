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
import { players, playertunnel, playertunnel1, playertunnel2, PlayState, SongItemType, songs } from "./common"
import { image } from "@kit.ImageKit"
import { effectKit } from "@kit.ArkGraphics2D"
import { http } from "@kit.NetworkKit"
import { ss } from "../constant/data"


//整个playstate的母体就在这里,哎早知道就用Appstorage这个东西了,emitter一点都不方便,还容易搞混
//一共三个地方有emit,嗯,现在我觉得可能没有真正的母体,因为有一个emit在PageIndex那个漫游的点击事件里面,还有就是在上一首下一首的函数里面,on倒是挺多,工具类,PageIndex,Index都注册了一个
export class AvplayerUtils{

  //播放器
  static avplayer:media.AVPlayer=null!

  //这个地方维持的核心数据
  static playstate:PlayState=new PlayState()

  //单例化的关键,毕竟这个语言没有真正的静态化
  private constructor() {
  }

  //这个是播放的那个切换状态,比老师的外部变量好用多了,外部变量太容易搞混了,果然外面的是靠不足的,还剩得让核心数据自己说话
  static toggle(){
    if(AvplayerUtils.avplayer.state=="playing"){
      AvplayerUtils.avplayer.pause()
      AvplayerUtils.playstate.isPlay=true
    }else {
      AvplayerUtils.resume()

      AvplayerUtils.playstate.isPlay=false
    }
    emitter.emit(playertunnel2,{data:{
      'mydata':JSON.stringify(AvplayerUtils.playstate)
    }})
  }

  //这个函数从网络上拷贝下来的,渐变色,至今没什么卵用
  static async updateBg(url: string): Promise<string[]> {
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
  // static async updateBg(pixelMap: image.PixelMap) {
  //   const picker = await effectKit.createColorPicker(pixelMap) // 取色器:从图片提取颜色
  //   const c = await picker.getMainColor() // 主色,含 red/green/blue(0~255)
  //   return `rgb(${c.red},${c.green},${c.blue})`
  // }



  //init函数主要就是建新的播放器对象还有,设置一些监听之类的,mode模式stop监听是需要改一下的,但是鄙人懒惰不想改
    static async init(){
    if(AvplayerUtils.avplayer)return
    AvplayerUtils.avplayer=await  media.createAVPlayer()
      AvplayerUtils.avplayer.on('stateChange', async (state)=>{
        switch (state){
          case 'initialized':{
            AvplayerUtils.avplayer.prepare()
            break
          }
          case 'prepared':{
            AvplayerUtils.playstate.duration=AvplayerUtils.avplayer.duration
            emitter.emit(playertunnel, { data:{'total':AvplayerUtils.avplayer.duration} })
            AvplayerUtils.avplayer.play()
            break
          }
          // 暂时不需要管播放模式的问题,直接默认顺序播放就行
          case 'completed':{
            let mode=AppStorage.get<number>('mode')
            if(mode==0){
              AvplayerUtils.next()
            console.log('ken1','这个时候状态是','顺序',mode)
            }else if(mode==2){
              // await AvplayerUtils.avplayer.prepare()
              AvplayerUtils.avplayer.play()
              console.log('ken1','这个时候状态是','单例')

            }else {
              console.log('ken1','这个时候状态是','随机')
              let ind=Math.floor(Math.random()*10000%AvplayerUtils.playstate.playList.length)
              // let ind=++AvplayerUtils.playstate.playIndex
              await AvplayerUtils.avplayer.reset()
              AvplayerUtils.playstate.img=AvplayerUtils.playstate.playList[ind].img
              AvplayerUtils.playstate.name=AvplayerUtils.playstate.playList[ind].name
              AvplayerUtils.playstate.url=AvplayerUtils.playstate.playList[ind].url
              AvplayerUtils.playstate.author=AvplayerUtils.playstate.playList[ind].author
              AvplayerUtils.playstate.isPlay=false
              AvplayerUtils.playstate.time=0
              AvplayerUtils.playstate.duration=0
              console.log('ken','状态上:'+AvplayerUtils.avplayer.state)
              AvplayerUtils.play()
              console.log('ken','状态下:'+AvplayerUtils.avplayer.state)
              emitter.emit(playertunnel2,{data:{
                'mydata':JSON.stringify(AvplayerUtils.playstate)
              }})
            }
          }


        }
      })
      AvplayerUtils.avplayer.on('durationUpdate',(val)=>{
        AvplayerUtils.playstate.duration=val
        emitter.emit(playertunnel,{data:{'total':val}})
      })
      AvplayerUtils.avplayer.on('timeUpdate',(val)=>{
        AvplayerUtils.playstate.time=val
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

   //播放,这个东西其实分得不够细,哎,后面功能的实现受到了影响,果然老师上课的演示是怎么方便怎么来,后面先加功能要重写好多东西,想死
   static play(){
    // AvplayerUtils.avplayer.url='http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/3.m4a'
    AvplayerUtils.avplayer.url=AvplayerUtils.playstate.url
   }

   //调节播放进度
   static seek(val:number){
    AvplayerUtils.avplayer.seek(val)
   }

   //这个也是播放,是为了弥补上面函数的缺陷设置的
   static resume(){
    AvplayerUtils.avplayer.play()
   }

   //暂停
   static pause(){
      AvplayerUtils.avplayer.pause()
   }

   //上一首,这里除了要改自己这里的核心数据还要改其他地方的
   static async pre(){
     if(AvplayerUtils.playstate.playIndex<=0){
       return;
     }
      await AvplayerUtils.avplayer.reset()
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
     AvplayerUtils.playstate.isPlay=false
     AvplayerUtils.playstate.time=0
     AvplayerUtils.playstate.duration=0
     console.log('ken','状态上:'+AvplayerUtils.avplayer.state)
     AvplayerUtils.play()
     console.log('ken','状态下:'+AvplayerUtils.avplayer.state)
     emitter.emit(playertunnel2,{data:{
       'mydata':JSON.stringify(AvplayerUtils.playstate)
     }})

   }

//下一首,也要emit
   static async next(){
      if(AvplayerUtils.playstate.playIndex>=AvplayerUtils.playstate.playList.length-1){
        return;
      }
     let ind=++AvplayerUtils.playstate.playIndex
     await AvplayerUtils.avplayer.reset()
     // AvplayerUtils.playstate.img=songs[ind].img
     // AvplayerUtils.playstate.name=songs[ind].name
     // AvplayerUtils.playstate.url=songs[ind].url
     // AvplayerUtils.playstate.author=songs[ind].author
     AvplayerUtils.playstate.img=AvplayerUtils.playstate.playList[ind].img
     AvplayerUtils.playstate.name=AvplayerUtils.playstate.playList[ind].name
     AvplayerUtils.playstate.url=AvplayerUtils.playstate.playList[ind].url
     AvplayerUtils.playstate.author=AvplayerUtils.playstate.playList[ind].author
     AvplayerUtils.playstate.isPlay=false
     AvplayerUtils.playstate.time=0
     AvplayerUtils.playstate.duration=0
     console.log('ken','状态上:'+AvplayerUtils.avplayer.state)
     AvplayerUtils.play()
     console.log('ken','状态下:'+AvplayerUtils.avplayer.state)
     emitter.emit(playertunnel2,{data:{
       'mydata':JSON.stringify(AvplayerUtils.playstate)
     }})
   }

   //这个是切换音乐
  static async togglemusic(s:SongItemType){
    let ind=AvplayerUtils.playstate.playList.findIndex((item:SongItemType)=>{return item.name==s.name})
    await AvplayerUtils.avplayer.reset()
    AvplayerUtils.playstate.img=AvplayerUtils.playstate.playList[ind].img
    AvplayerUtils.playstate.name=AvplayerUtils.playstate.playList[ind].name
    AvplayerUtils.playstate.url=AvplayerUtils.playstate.playList[ind].url
    AvplayerUtils.playstate.author=AvplayerUtils.playstate.playList[ind].author
    AvplayerUtils.playstate.playIndex=ind
    AvplayerUtils.playstate.isPlay=false
    AvplayerUtils.playstate.time=0
    AvplayerUtils.playstate.duration=0
    AvplayerUtils.play()
    emitter.emit(playertunnel2,{data:{
      'mydata':JSON.stringify(AvplayerUtils.playstate)
    }})
  }

//很简单,找到音乐并播放,就是togglemusic和next的结合版,由于只是复用代码,加上我稍微改了一下,我可能也不是很清楚一些东西
  static async findmusic_play(sss:SongItemType){
    let ind=AvplayerUtils.playstate.playList.findIndex((item:SongItemType)=>{return item.name==sss.name})
    if(ind>=0){
      await AvplayerUtils.avplayer.reset()
      AvplayerUtils.playstate.img=AvplayerUtils.playstate.playList[ind].img
      AvplayerUtils.playstate.name=AvplayerUtils.playstate.playList[ind].name
      AvplayerUtils.playstate.url=AvplayerUtils.playstate.playList[ind].url
      AvplayerUtils.playstate.author=AvplayerUtils.playstate.playList[ind].author
      AvplayerUtils.playstate.playIndex=ind
      AvplayerUtils.playstate.isPlay=false
      AvplayerUtils.playstate.time=0
      AvplayerUtils.playstate.duration=0
      AvplayerUtils.play()
      emitter.emit(playertunnel2,{data:{
        'mydata':JSON.stringify(AvplayerUtils.playstate)
      }})
    }else {
      let item=sss
      let pos=AvplayerUtils.playstate.playList.length==0 ?0:AvplayerUtils.playstate.playIndex+1
      ss.splice(AvplayerUtils.playstate.playIndex+1,0,item)
      let s:PlayState= {
        img: item.img,
        name: item.name,
        author: item.author,
        url: item.url,
        playIndex: pos,
        // playIndex: AvplayerUtils.playstate.playIndex+1,
        time: 0,
        duration: 0,
        isPlay: true,
        playMode: 'auto',
        playList: ss
      }
      emitter.emit(playertunnel2,{data:{
        'mydata':JSON.stringify(s)
      }})
    }

  }
 }