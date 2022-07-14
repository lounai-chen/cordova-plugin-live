import { Component, Renderer, ViewChild } from "@angular/core";
import {
  NavController,
  App,
  NavParams,
  ModalController,
  ViewController,
  ToastController,
  Content,
  Slides,
} from "ionic-angular";
import { AppLang } from "../../app/app.lang";
import { AppMember } from "../../app/app.member";
import { ApiConfig } from "../../app/api.config";
import { MemberApi } from "../../providers/member.api";
import { AppUtil } from "../../app/app.util";
import { AppStat } from "../../app/app.stat";
import { CommonApi } from "../../providers/common.api";
import { TabsPage } from "../tabs/tabs";
import { InAppBrowser } from "@ionic-native/in-app-browser";
/*
  Generated class for the Member page.

  See http://ionicframework.com/docs/v2/components/#navigation for more info on
  Ionic pages and navigation.
*/
import { IonicPage } from "ionic-angular";
import { timeout } from "rxjs/operator/timeout";
@IonicPage()
@Component({
  selector: "page-member",
  templateUrl: "member.html",
  providers: [MemberApi, CommonApi],
})
export class MemberPage {
  @ViewChild("header") header;
  @ViewChild("notice") notice;
  @ViewChild("ionbutons") ionbutons;
  @ViewChild(Content) content: Content;
  @ViewChild("bannerSildes") bannerSlides: Slides;
  config = ApiConfig;
  Lang = AppLang.Lang;
  member = AppMember.GetInstance();
  couponcount = 0;
  winmedalcount = 0;
  total_days = 0;
  memberInfo: any = {};
  credits: number = 0;
  inst_credits: number = 0;
  Util = AppUtil;
  stat = AppStat;
  // 是否已有栗子树
  hasLizitree = false;
  // 动画
  positionAnimation = false;
  chestnuttree_module = false;
  noReadyMessageCount = AppUtil.unreadMsgCount;
  // 是不是老师
  isTeacher: boolean = false;
  adminInstid = "";
  belongsInstid = "";
  liveStatus = '等待推流...';
  bannerList = [];
  switchflg = AppUtil.isMicroMessager ? "W" : AppUtil.isIOS ? "I" : "A";
  hasAddTree = false;
  isNewVer = globalcfg.appver.split(".").join("") > 233;
  constructor(
    public navCtrl: NavController,
    public app: App,
    public navParams: NavParams,
    public modalCtrl: ModalController,
    public viewCtrl: ViewController,
    private toastCtrl: ToastController,
    public commonApi: CommonApi,
    public _render: Renderer,
    public memberApi: MemberApi,
    private iab: InAppBrowser
  ) {}

  ionViewDidLoad() {
    this.bannerList = [];
    //判断是否开放栗子树模块
    this.commonApi
      .getcommonconfig({ cfgkeys: "chestnuttree_switch" }, false)
      .then((result) => {
        var data = result.data;
        if (result && result.code == 0 && data) {
          if (data.chestnuttree_switch && data.chestnuttree_switch == "1") {
            this.chestnuttree_module = true;
          }
        }
        this.getBannerList();
      });
      
      this.createSDK();
  }
  ionSlideTap() {
    //有些首页可能设置slides的loop可能失败，没有在首未补一张图片
    if (this.bannerSlides.length() == this.bannerList.length) {
      this.clickBanner(
        this.bannerList[this.bannerSlides.getActiveIndex()].action,
        this.bannerSlides.getActiveIndex() + 1
      );
      return;
    }
    if (this.bannerSlides.isEnd()) {
      this.clickBanner(this.bannerList[0].action, 1);
      return;
    }
    if (this.bannerSlides.isBeginning()) {
      this.clickBanner(
        this.bannerList[this.bannerList.length - 1].action,
        this.bannerList.length
      );
      return;
    }
    this.clickBanner(
      this.bannerList[this.bannerSlides.getActiveIndex() - 1].action,
      this.bannerSlides.getActiveIndex()
    );
  }
  clickBanner(link, index?) {
     //开启预览
    LivePlugin.preview(function(t){alert('ok: '+t)},function(e){alert('error: '+e)});  
    return;
   
  }
  ionViewWillLeave() {}
  ionViewWillEnter() {
    this.positionAnimation = false;
  }
  ionViewDidEnter() {
    this.getmemberInfo();
    if (this.Util.homePageCouponList.length > 0) {
      this._render.setElementStyle(
        TabsPage.homeTab.tabs._tabbar.nativeElement,
        "display",
        "none"
      );
    }
    if (
      this.Util.homePageCouponList.length <= 0 &&
      this.Util.medalList.length > 0
    ) {
      let modal = this.modalCtrl.create("UserMedalDetailPage", {
        medalList: this.Util.medalList,
        isGetShow: 1,
        isModalDlg: 1,
      });
      modal.present();
    }
    AppUtil.pushStateSelf("member");
    this.noReadyMessageCount = AppUtil.unreadMsgCount;
    this.getMmberLevel();
  }
  getMmberLevel() {
    if (
      AppUtil.isopenlevelInstid ||
      AppUtil.curLevelInstid.indexOf(AppUtil.AppEdition) >= 0
    ) {
      this.memberApi.getMemberSaleLevel({}).then((res) => {
        if (res.code == 0 && res.data) {
          AppUtil.memberLevel = res.data.sale_level || 0;
          AppUtil.getLevelLabel();
        }
      });
    }
  }
  getBannerList() {
    this.commonApi
      .getcommonbannerdata(
        "app_member",
        AppUtil.isLargeScreen ? "ipad" : "normal"
      )
      .then((result) => {
        if (
          result.code == 0 &&
          result.data &&
          Array.isArray(result.data.bannerdata)
        ) {
          for (let item of result.data.bannerdata) {
            if (
              !item.support_os ||
              (item.support_os && item.support_os.indexOf(this.switchflg) >= 0)
            ) {
              this.bannerList.push(item);
            }
          }
        }
      });
  }

liveStart(){
  //LivePlugin.start('123',function(t){alert('ok: '+t)},function(e){alert('error: '+e)})
  CameraPreview.startCamera({x: 50, y: 50, width: 300, height:300, camera: "front", tapPhoto: true, previewDrag: false, toBack: true});
}
  gotoAction() {
    this.Util.homePageCouponList = [];
    this._render.setElementStyle(
      TabsPage.homeTab.tabs._tabbar.nativeElement,
      "display",
      "flex"
    );
  }
  contentScroll() {
    // let scrolltop = 0;
    // if(!this.Util.isMicroMessager){
    //   scrolltop = this.notice.nativeElement.offsetTop - this.ionbutons.nativeElement.offsetTop;
    // }else{
    //   scrolltop = this.notice.nativeElement.offsetTop + this.notice.nativeElement.offsetHeight;
    // }
    // if(this.content.scrollTop>scrolltop){
    //   this._render.setElementStyle(this.header.nativeElement, "opacity", '1');
    //   this._render.setElementStyle(this.header.nativeElement, "z-index", '10');
    // }else{
    //   this._render.setElementStyle(this.header.nativeElement, "opacity", '0');
    //   this._render.setElementStyle(this.header.nativeElement, "z-index", '-1');
    // }
  }
  gotoMyClockIn() {
    this.stat.onOperationEvent("CheckInClick", 0, "");
    let modal = null;
    if (this.Util.isClockInActivity) {
      modal = this.modalCtrl.create("UserClockInActivityPage", {
        isModalDlg: 1,
      });
    } else {
      modal = this.modalCtrl.create("UserClockInPage", { isModalDlg: 1 });
    }
    modal.present();
    modal.onDidDismiss((res) => {
      this.getmemberInfo();
      if (
        this.Util.homePageCouponList.length <= 0 &&
        this.Util.medalList.length > 0
      ) {
        let modal = this.modalCtrl.create("UserMedalDetailPage", {
          medalList: this.Util.medalList,
          isGetShow: 1,
          isModalDlg: 1,
        });
        modal.present();
      }
    });
  }
  hiddenscroll() {
    //获取当前组件的ID
    let aboutContent = document.querySelector("#aboutContent");
    //获取当前组件下的scroll-content元素
    let scroll: any = aboutContent.querySelector(".scroll-content");
    if (this.hasLizitree) {
      scroll.style.overflow = "auto";
    } else {
      scroll.style.overflow = "hidden";
    }
  }
  // 领取栗子种子
  getLiziSeed() {
    this.positionAnimation = true;
    this.memberApi.seedmemberlizitree(false).then((result) => {
      if (result.code == 0) {
        var self = this;
        setTimeout(() => {
          self.hasLizitree = true;
          if (!this.hasAddTree) {
            this.bannerList.unshift({
              action: "lizitree",
              pic: this.memberInfo.member_tree_bannerimg,
            });
            this.hasAddTree = true;
          }
        }, 900);
      } else {
        this.hasLizitree = false;
        this.msgAlter(AppLang.Lang["seedisnosuccess"]);
      }
    });
  }
  getmemberInfo() {
    if (this.member.id == 0) {
      return;
    }
    let postData = { isthridLogin: this.member.isthridLogin ? "wx" : "" };
    this.memberApi.getmemberinfo(postData, false).then((result) => {
      if (result.code == 0 && result.data) {
        AppUtil.memberRegionid = result.data.member_regionid;
        this.adminInstid = result.data.admin_instid || "";
        this.belongsInstid = result.data.belongs_instid || "";
        this.memberInfo = result.data;
        //token未返回, 不应更新本地存储的UserInfo
        result.data.token = this.member.token;
        this.member.updateInfo(result.data, this.member.isthridLogin, false);
        this.winmedalcount = result.data.winmedalcount || 0;
        this.couponcount = result.data.coupon_count || 0;
        this.total_days = result.data.total_days || 0;
        this.credits = Number(result.data.credits) || 0;
        this.inst_credits = Number(result.data.inst_credits) || 0;
        if (AppUtil.AppEdnSwitchMode == "1") {
          this.credits += this.inst_credits;
        } else if (AppUtil.AppEdition == "EE") {
          this.credits = this.inst_credits;
        }
        this.isTeacher = result.data.isteacher == 0 ? false : true;
        this.hasLizitree = result.data.hasSeed == 1 ? true : false;
        if (!this.hasAddTree && this.chestnuttree_module && this.hasLizitree) {
          this.bannerList.unshift({
            action: "lizitree",
            pic: this.memberInfo.member_tree_bannerimg,
          });
          this.hasAddTree = true;
        }
      }
      if (this.Util.isMicroMessager) {
        this.Util.setWeixinDefaultShareForMP(this.commonApi);
      }
    });
  }
  // 去栗子树页面
  gotoLiziTree() {
    this.stat.onOperationEvent("TreeClick", 0, "");
    //当在微信公众号或网页版时, Tab打开的第一层Page,如果是Push的, 返回按钮的行为无法控制
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("LiziTreePage", { isModalDlg: 1 });
      modal.present();
    } else {
      this.navCtrl.push("LiziTreePage", { isModalDlg: 0 });
    }
  }
  gotoSetting() {
    //当在微信公众号或网页版时, Tab打开的第一层Page,如果是Push的, 返回按钮的行为无法控制
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserSettingPage", { isModalDlg: 1 });
      modal.present();
    } else {
      this.navCtrl.push("UserSettingPage", { isModalDlg: 0 });
    }
    //this.app.getRootNav().push('UserSettingPage');
  }
  gotoWecom() {
    this.stat.onOperationEvent("WDKFpv", "", "");
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("QrcodeEntrancePage", {
        isModalDlg: 1,
      });
      modal.present();
    } else {
      this.navCtrl.push("QrcodeEntrancePage", { isModalDlg: 0 });
    }
  }
  gotoNotifications() {
    //当在微信公众号或网页版时, Tab打开的第一层Page,如果是Push的, 返回按钮的行为无法控制
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserNotificationsPage", {
        isModalDlg: 1,
      });
      modal.present();
      modal.onDidDismiss(() => {
        this.noReadyMessageCount = AppUtil.unreadMsgCount;
      });
    } else {
      this.navCtrl.push("UserNotificationsPage", { isModalDlg: 0 });
    }
  }
  gotoPolicyColumnList() {
    //当在微信公众号或网页版时, Tab打开的第一层Page,如果是Push的, 返回按钮的行为无法控制
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("CourseListPage", {
        isModalDlg: 1,
        catetype: "PC",
      });
      modal.present();
    } else {
      this.navCtrl.push("CourseListPage", { isModalDlg: 0, catetype: "PC" });
    }
  }
  gotoContactUs() {
    //当在微信公众号或网页版时, Tab打开的第一层Page,如果是Push的, 返回按钮的行为无法控制
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("ContactUsPage", { isModalDlg: 1 });
      modal.present();
    } else {
      this.navCtrl.push("ContactUsPage", { isModalDlg: 0 });
    }
  }
  
  shareWecom(){
    WecomPlugin.share_txt('arg0 hello world',function(t){alert('ok: '+t)},function(e){alert('error: '+e)})
  }


  createSDK() {

    var el = document.createElement("link");
    el.rel = "stylesheet";
    el.href = "https://g.alicdn.com/de/prismplayer/2.9.21/skins/default/aliplayer-min.css";
    document.body.appendChild(el);

 


    let scriptEl = document.createElement("script");
    scriptEl.src =
      "https://g.alicdn.com/de/prismplayer/2.9.21/aliplayer-min.js";
    document.body.appendChild(scriptEl);
    scriptEl.onload = () => {
      
    };


  }

  liveTest(){
      var th = this;
      const bodyEl:any = window.document.querySelector("#myBody"); 
      bodyEl.style.visibility = 'hidden'
      bodyEl.style.background = "transparent"   
      LivePlugin.init("rtmp://rtmp.huayustech.com/chesnutapp/36558?auth_key=1657508395-0-0-05e4bae1269e78a3699d5953f23260bd",
        '1','1','0','0','1','600','600','450','650',
        function(t){ 
          alert('ok: '+t);
          th.liveStatus = t;   
        },
        function(e){alert('error: '+e)}
      )
  }

    liveTest2(){ //在webview以上
      var th = this;
      const bodyEl:any = window.document.querySelector("#myBody"); 
      bodyEl.style.visibility = 'hidden'
      bodyEl.style.background = "transparent"   
      LivePlugin.init("rtmp://rtmp.huayustech.com/chesnutapp/36558?auth_key=1657508395-0-0-05e4bae1269e78a3699d5953f23260bd",
        '1','1','0','0','0','600','600','450','650',
        function(t){ 
          alert('ok: '+t);
          th.liveStatus = t;   
        },
        function(e){alert('error: '+e)}
      )
  }


  PlayerInit(){

    var th = this;
    const bodyEl:any = window.document.querySelector("#myBody"); 
    bodyEl.style.visibility = 'hidden'
    bodyEl.style.background = "transparent"   

    LivePlugin.InitPlayer(
      'artc://alibo.huayustech.com/chesnutapp/36558_md6-RTS?auth_key=1657508395-0-0-4c5651d0a9ca54bbac29b638ee6f6c75',
       '-1','-1', 0 , 50 ,
       function(t){ 
        alert('ok: '+t);
        th.liveStatus = t;   
      },
      function(e){alert('error: '+e)}
    );
  }

  PlayerStart(){
    LivePlugin.PlayerStart(function(t){ 
      alert('ok: '+t);
     
    },
    function(e){alert('error: '+e)});
  }

  PlayerPause(){
    LivePlugin.PlayerPause(function(t){ 
      alert('ok: '+t);
     
    },
    function(e){alert('error: '+e)});
  }

  PlayerResume(){
    LivePlugin.PlayerResume(function(t){ 
      alert('ok: '+t);
     
    },
    function(e){alert('error: '+e)});
  }



  initPalyVideo(){
     
    var th = this; 
    setTimeout(() => {
      try {
        this.initPalyVideo2();
      }
      catch (ex) { console.log("ex:" + ex); }
    }, 8500);

  }

  initPalyVideo2(){
    alert('准备开始播放2'); 

    // var player = new window[`Aliplayer`](
    //   {
    //     id: "videoPlay",
       
    //     source: 'artc://alibo.huayustech.com/chesnutapp/36558_md6-RTS?auth_key=1657508395-0-0-4c5651d0a9ca54bbac29b638ee6f6c75', //播放地址，可以是第三方直播地址，或阿里云直播服务中的拉流地址。
    //     //source: 'https://alibo.huayustech.com/chesnutapp/36558_md6-RTS.m3u8?auth_key=1669508713-0-0-9c495bfd20165bf331603fdc5e63294d', //m3u8
    //     //sourse:'rtmp://alibo.huayustech.com/chesnutapp/36558_md6-RTS?auth_key=1669508713-0-0-3d12e02dac541aaa253a997b184f9b8f', // rtmp
    //     autoplay: true,   
        
    //     isLive: true, //是否为直播播放。
    //     rePlay: false,
    //     playsinline: true,
    //     preload: true,
    //     width: '100%',
    //     height: "150",
    //     controlBarVisibility: `hover`,
    //     useH5Prism: true,
    //     "skipRtsSupportCheck": skipCheck,
       
    //    // skinLayout: false,
    //     x5LandscapeAsFullScreen: true,
    //     x5_orientation:`landscape`,
    //   },
    //   function () {
    //     console.log("The player is created.");
    //   }
    // );


    /**
 * 创建播放器
 */
    const createPlayer = (skipCheck) => {
      const player =  new window[`Aliplayer`]({
        id: "videoPlay",       
        source: 'artc://alibo.huayustech.com/chesnutapp/36558_md6-RTS?auth_key=1657508395-0-0-4c5651d0a9ca54bbac29b638ee6f6c75', //播放地址，可以是第三方直播地址，或阿里云直播服务中的拉流地址。
        "skipRtsSupportCheck": skipCheck,

        isLive: true, //是否为直播播放。
        rePlay: false,
        playsinline: true,
        preload: true,
        width: '100%',
        height: "150",
        controlBarVisibility: `hover`,
        useH5Prism: true,

        x5LandscapeAsFullScreen: true,
        x5_orientation:`landscape`,

      }, function (player) {
          console.log("The player is created");
        }
      );

      player.on('error', e => {
        console.log('[Player Error]', e.paramData);
      })
    }

    /**
     * 检查浏览器是否在自定义的受信任列表中
     */
    const checkBrowserWhiteList = () => {
      // 判断逻辑可以按照需求实现，例如通过userAgent判断是某个受信任的浏览器
      // return true
      return false
    };

    createPlayer(checkBrowserWhiteList());


  }

  gotoUserStatistics2(){ 
    LivePlugin.preview(function(t){alert('ok: '+t)},function(e){alert('error: '+e)});  
    return;
  }
  gotoMyLectureHall2() {  
 //开启直播
 var th = this;
     LivePlugin.start(function(t){
     // th.initPalyVideo();
    },function(e){alert('error: '+e)});  
     return; 
  }
  LiveFlash() {  
   
    LivePlugin.LiveFlash(function(t){

  
    
   },function(e){alert('error: '+e)});  
    return; 
 }
 StopPreview() {  
   
  LivePlugin.StopPreview(function(t){
  
 },function(e){alert('error: '+e)});  
  return; 
}
RestartPushAync() {  
  LivePlugin.RestartPushAync(function(t){
  
 },function(e){alert('error: '+e)});  
  return; 
}
ResumeAsync() {  
  LivePlugin.ResumeAsync(function(t){
  
 },function(e){alert('error: '+e)});  
  return; 
}
Pause() {  
  LivePlugin.Pause(function(t){
  
 },function(e){alert('error: '+e)});  
  return; 
}
CameraDirection() {  
  LivePlugin.CameraDirection(function(t){
  
 },function(e){alert('error: '+e)});  
  return; 
}
preview() {  
 
  var th = this;
  LivePlugin.preview(function(t){
   
 },function(e){alert('error: '+e)});  
  return; 
} 
  
  gotoMyBusinessCard2(){
 
    LivePlugin.stop(function(t){
      //alert('ok: '+t)
  },function(e){alert('error: '+e)});  

    const bodyEl:any = window.document.querySelector("#myBody"); 
    bodyEl.style.visibility = 'visible'
    bodyEl.style.background = "#fff"
    return;  
 }
  gotoMyPurchaseTest() {
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserPurchaseExamPage", {
        isModalDlg: 1,
      });
      modal.present();
    } else {
      this.navCtrl.push("UserPurchaseExamPage", { isModalDlg: 0 });
    }
  }
  gotoMyCoupon() {
     
         LivePlugin.stop(function(t){alert('ok: '+t)},function(e){alert('error: '+e)});  
         return;

 
  }
  gotoMyMedal() {
    this.stat.onOperationEvent("MedalClick", 0, "");
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserMedalPage", { isModalDlg: 1 });
      modal.present();
    } else {
      this.navCtrl.push("UserMedalPage", { isModalDlg: 0 });
    }
  }
  gotoMyLevel() {
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserLevelPage", {
        isModalDlg: 1,
        headportrait: this.member.headportrait,
        needlevelList: 1,
      });
      modal.present();
    } else {
      this.navCtrl.push("UserLevelPage", {
        isModalDlg: 0,
        headportrait: this.member.headportrait,
        needlevelList: 1,
      });
    }
  }
  gotoMyBusinessCard() {
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserBusinessCardPage", {
        isModalDlg: 1,
      });
      modal.present();
    } else {
      this.navCtrl.push("UserBusinessCardPage", { isModalDlg: 0 });
    }
  }
  gotoMyStudyReport(e) {
    e.stopPropagation();
    if (!this.Util.isPurchasePTCourse) {
      let modal = this.modalCtrl.create(
        "UserStudyReportPromptPage",
        {},
        { enterAnimation: "direct-enter" }
      );
      modal.present();
      modal.onDidDismiss((res) => {
        if (res == 1) {
          TabsPage.homeTab.tabs.select(1);
        }
      });
      return;
    }
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserStudyReportPage", {
        isModalDlg: 1,
      });
      modal.present();
    } else {
      this.navCtrl.push("UserStudyReportPage", { isModalDlg: 0 });
    }
  }
  gotoUserStatistics() {
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserStudyStatisticsPage", {
        isModalDlg: 1,
        adminInstid: this.adminInstid,
        belongsInstid: this.belongsInstid,
      });
      modal.present();
    } else {
      this.navCtrl.push("UserStudyStatisticsPage", {
        isModalDlg: 0,
        adminInstid: this.adminInstid,
        belongsInstid: this.belongsInstid,
      });
    }
  }
  gotoMyLectureHall() {
    if (
      AppUtil.isCapturePopstate &&
      AppUtil.isMicroMessager &&
      ApiConfig.IsZhiNengPaltform
    ) {
      let modal = this.modalCtrl.create("MyTrainPage", {
        isModalDlg: 1,
        memberId: this.member.id,
      });
      modal.present();
      return;
    }
    if (this.member.id == 0) {
      return;
    }
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserLectureHallPage", {
        isModalDlg: 1,
        memberId: this.member.id,
      });
      modal.present();
    } else {
      this.navCtrl.push("UserLectureHallPage", {
        isModalDlg: 0,
        memberId: this.member.id,
      });
    }
  }
  gotoMyCache() {
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserCachePage", { isModalDlg: 1 });
      modal.present();
    } else {
      this.navCtrl.push("UserCachePage", { isModalDlg: 0 });
    }
  }
  gotoMyPayRecord() {
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserPayRecordPage", { isModalDlg: 1 });
      modal.present();
    } else {
      this.navCtrl.push("UserPayRecordPage", { isModalDlg: 0 });
    }
  }
  gotoMyCertificate() {
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserCertificatePage", {
        isModalDlg: 1,
      });
      modal.present();
    } else {
      this.navCtrl.push("UserCertificatePage", { isModalDlg: 0 });
    }
  }

  gotoBuyForFriend() {
    if (AppUtil.isCapturePopstate && AppUtil.isMicroMessager) {
      let modal = this.modalCtrl.create("UserGiveRecordPage", {
        isModalDlg: 1,
      });
      modal.present();
    } else {
      this.navCtrl.push("UserGiveRecordPage", { isModalDlg: 0 });
    }
  }

  gotoSimulateExam() {
    let modal = this.modalCtrl.create("ExamListPage", { isModalDlg: 1 });
    modal.present();
  }

  dismiss() {
    this.viewCtrl.dismiss();
  }
  public msgAlter(msg) {
    AppUtil.Toast(this.toastCtrl, msg);
  }
}
