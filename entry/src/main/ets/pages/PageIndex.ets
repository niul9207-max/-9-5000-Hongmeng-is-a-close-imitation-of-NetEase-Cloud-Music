import image from '@ohos.multimedia.image';
import { SongItemType, songs } from '../utils/common';

@Entry
@Component
struct PageIndex {
  @State message: string = 'Hello World';
  @State current:number=0
  @Builder
  bottomicon(){
    Column(){
      Image($r('app.media.bottom1')).height(20).aspectRatio(1)
    }

  }

  build() {
    Column() {
      Tabs({barPosition:BarPosition.End,index:$$this.current}){
        TabContent(){
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

        }.tabBar(
          this.bottomicon()
        )
      }
    }
    .height('100%')
    .width('100%')
  }
}