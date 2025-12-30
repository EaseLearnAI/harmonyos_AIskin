@Component
export struct BottomNavigation {
  @Prop currentRoute: string = '/'
  onNavigate?: (route: string) => void

  build() {
    Row() {
      this.NavItem('首页', 'home', '/')
      this.NavItem('产品分析', 'flask', '/product')
      this.NavItem('肌肤检测', 'camera', '/skinstatus')
      // 隐藏"我的"导航项，但不删除代码
      // this.NavItem('我的', 'user', '/profile')
    }
    .width('100%')
    .height(64)
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundColor('#FFFFFF')
    .padding({ top: 8, bottom: 8, left: 0, right: 0 })
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: -2
    })
  }

  @Builder
  NavItem(label: string, icon: string, route: string) {
    Column() {
      Column() {
        this.IconView(icon, route)
      }
        .margin({ bottom: 4 })

      Text(label)
        .fontSize(11)
        .fontColor(this.currentRoute === route ? '#F8BBD0' : '#8E8E93')
        .fontWeight(this.currentRoute === route ? FontWeight.Medium : FontWeight.Normal)
        .opacity(this.currentRoute === route ? 1 : 0.8)
    }
    .width(80)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.onNavigate) {
        this.onNavigate(route)
      }
    })
  }

  @Builder
  IconView(icon: string, route: string) {
    if (icon === 'home') {
      // 首页：iOS风格房屋图标
      if (this.currentRoute === route) {
        // 激活状态：填充样式
        Column() {
          // 屋顶（使用三个小方块模拟三角形）
          Row() {
            Column()
              .width(2)
              .height(2)
              .backgroundColor('#F8BBD0')
              .margin({ right: 1 })
            Column()
              .width(4)
              .height(4)
              .backgroundColor('#F8BBD0')
            Column()
              .width(2)
              .height(2)
              .backgroundColor('#F8BBD0')
              .margin({ left: 1 })
          }
          .width(10)
          .height(4)
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 2 })
          
          // 主体（填充）
          Column()
            .width(16)
            .height(12)
            .borderRadius(1.5)
            .backgroundColor('#F8BBD0')
        }
        .width(24)
        .height(24)
        .justifyContent(FlexAlign.Center)
      } else {
        // 未激活状态：轮廓样式
        Column() {
          // 屋顶（轮廓）
          Row() {
            Column()
              .width(2)
              .height(2)
              .border({
                width: 1.5,
                color: '#8E8E93',
                style: BorderStyle.Solid
              })
              .margin({ right: 1 })
            Column()
              .width(4)
              .height(4)
              .border({
                width: 1.5,
                color: '#8E8E93',
                style: BorderStyle.Solid
              })
            Column()
              .width(2)
              .height(2)
              .border({
                width: 1.5,
                color: '#8E8E93',
                style: BorderStyle.Solid
              })
              .margin({ left: 1 })
          }
          .width(10)
          .height(4)
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 2 })
          
          // 主体（轮廓）
          Column()
            .width(16)
            .height(12)
            .border({
              width: 2,
              color: '#8E8E93',
              style: BorderStyle.Solid
            })
            .borderRadius(1.5)
        }
        .width(24)
        .height(24)
        .justifyContent(FlexAlign.Center)
      }
    } else if (icon === 'flask') {
      // 产品分析：iOS风格烧瓶图标
      if (this.currentRoute === route) {
        // 激活状态：填充样式
        Column() {
          // 顶部（圆形填充）
          Column()
            .width(8)
            .height(8)
            .borderRadius(4)
            .backgroundColor('#F8BBD0')
            .margin({ bottom: 2 })
          // 连接线
          Column()
            .width(2.5)
            .height(2)
            .backgroundColor('#F8BBD0')
            .margin({ bottom: 1 })
          // 底部（梯形填充）
          Column()
            .width(14)
            .height(10)
            .borderRadius({ bottomLeft: 2, bottomRight: 2 })
            .backgroundColor('#F8BBD0')
        }
        .width(24)
        .height(24)
        .justifyContent(FlexAlign.Center)
      } else {
        // 未激活状态：轮廓样式
        Column() {
          // 顶部（圆形轮廓）
          Column()
            .width(8)
            .height(8)
            .border({
              width: 2,
              color: '#8E8E93',
              style: BorderStyle.Solid
            })
            .borderRadius(4)
            .margin({ bottom: 2 })
          // 连接线
          Column()
            .width(2.5)
            .height(2)
            .border({
              width: { left: 1.5, right: 1.5 },
              color: '#8E8E93',
              style: BorderStyle.Solid
            })
            .margin({ bottom: 1 })
          // 底部（梯形轮廓）
          Column()
            .width(14)
            .height(10)
            .border({
              width: { left: 2, right: 2, bottom: 2 },
              color: '#8E8E93',
              style: BorderStyle.Solid
            })
            .borderRadius({ bottomLeft: 2, bottomRight: 2 })
        }
        .width(24)
        .height(24)
        .justifyContent(FlexAlign.Center)
      }
    } else if (icon === 'camera') {
      // 肌肤检测：iOS风格相机图标
      if (this.currentRoute === route) {
        // 激活状态：填充样式
        Stack({ alignContent: Alignment.Center }) {
          // 相机主体（填充）
          Column()
            .width(18)
            .height(14)
            .borderRadius(2)
            .backgroundColor('#F8BBD0')
          
          // 镜头外圈（白色边框）
          Column()
            .width(9)
            .height(9)
            .border({
              width: 2,
              color: '#FFFFFF',
              style: BorderStyle.Solid
            })
            .borderRadius(4.5)
            .backgroundColor('#F8BBD0')
          
          // 镜头内圈（白色填充）
          Column()
            .width(4)
            .height(4)
            .borderRadius(2)
            .backgroundColor('#FFFFFF')
        }
        .width(24)
        .height(24)
      } else {
        // 未激活状态：轮廓样式
        Stack({ alignContent: Alignment.Center }) {
          // 相机主体（轮廓）
          Column()
            .width(18)
            .height(14)
            .border({
              width: 2,
              color: '#8E8E93',
              style: BorderStyle.Solid
            })
            .borderRadius(2)
          
          // 镜头（轮廓）
          Column()
            .width(9)
            .height(9)
            .border({
              width: 2,
              color: '#8E8E93',
              style: BorderStyle.Solid
            })
            .borderRadius(4.5)
        }
        .width(24)
        .height(24)
      }
    } else if (icon === 'user') {
      // 我的：iOS风格用户图标
      if (this.currentRoute === route) {
        // 激活状态：填充样式
        Column() {
          // 头部（圆形填充）
          Column()
            .width(10)
            .height(10)
            .borderRadius(5)
            .backgroundColor('#F8BBD0')
            .margin({ bottom: 2 })
          // 身体（半圆填充）
          Column()
            .width(12)
            .height(8)
            .borderRadius({ bottomLeft: 6, bottomRight: 6 })
            .backgroundColor('#F8BBD0')
        }
        .width(24)
        .height(24)
        .justifyContent(FlexAlign.Center)
      } else {
        // 未激活状态：轮廓样式
        Column() {
          // 头部（圆形轮廓）
          Column()
            .width(10)
            .height(10)
            .border({
              width: 2,
              color: '#8E8E93',
              style: BorderStyle.Solid
            })
            .borderRadius(5)
            .margin({ bottom: 2 })
          // 身体（半圆轮廓）
          Column()
            .width(12)
            .height(8)
            .border({
              width: { left: 2, right: 2, bottom: 2 },
              color: '#8E8E93',
              style: BorderStyle.Solid
            })
            .borderRadius({ bottomLeft: 6, bottomRight: 6 })
        }
        .width(24)
        .height(24)
        .justifyContent(FlexAlign.Center)
      }
    } else {
      // 默认图标
      Column()
        .width(24)
        .height(24)
        .borderRadius(12)
        .backgroundColor(this.currentRoute === route ? '#F8BBD0' : '#8E8E93')
        .opacity(this.currentRoute === route ? 1 : 0.3)
    }
  }
}
