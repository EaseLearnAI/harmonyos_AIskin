# ArkTS 开发文档合集

本文档由爬虫自动生成，包含 100 个页面的内容。

生成时间: 2025-11-08 00:00:54

---

## 1. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 2. 基本语法概述-学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-basic-syntax-overview

---

在初步了解ArkTS语言后，本指南将以具体的示例来说明ArkTS的基本组成。

如下图所示，点击“按钮”时，文本内容从“Hello World”变为“Hello ArkUI”。

**图1** 示例效果图

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107151457.85739640828461166207368509689872:50001231000000:2800:04D8952249FDC57E300648941092EE0B1A4FD891100ED25F98C797D4373F9C15.gif)

本示例中，ArkTS的基本组成如下所示。

**图2** ArkTS的基本组成

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107151457.11255075194358628669074873229511:50001231000000:2800:3D409BBE05A54713EF2C529477ABD10D0D016A0A8DF43B6171F688B08434A29D.png)

说明

自定义变量不能与基础通用属性/事件名重复。

  * 装饰器： 用于装饰类、结构、方法以及变量，并赋予其特殊的含义。如上述示例中@Entry、@Component和@State都是装饰器，[@Component](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-create-custom-components#component)表示自定义组件，[@Entry](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-create-custom-components#entry)表示该自定义组件为入口组件，[@State](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state)表示组件中的状态变量，状态变量变化会触发UI刷新。

  * [UI描述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-declarative-ui-description)：以声明式的方式来描述UI的结构，例如build()方法中的代码块。

  * [自定义组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-create-custom-components)：可复用的UI单元，可组合其他组件，如上述被@Component装饰的struct Hello。

  * 系统组件：ArkUI框架中默认内置的基础和容器组件，可以直接调用，例如示例中的Column、Text、Divider、Button。

  * [属性方法](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-component-general-attributes)：组件可以通过链式调用配置多项属性，如fontSize()、width()、height()、backgroundColor()等。

  * [事件方法](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-component-general-events)：组件可以通过链式调用设置多个事件的响应逻辑，如跟随在Button后面的onClick()。

除此之外，ArkTS扩展了多种语法范式来使开发更加便捷：

  * [@Builder](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-builder)/[@BuilderParam](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-builderparam)：特殊的封装UI描述的方法，细粒度的封装和复用UI描述。

  * [@Extend](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-extend)/[@Styles](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-style)：扩展系统组件和封装属性样式，更灵活地组合系统组件。

  * [stateStyles](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-statestyles)：多态样式，可以依据组件的内部状态的不同，设置不同样式。

[__学习UI范式基本语法](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-paradigm-basic-syntax "学习UI范式基本语法")

[ 声明式UI描述 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-declarative-ui-description "声明式UI描述")

相关推荐

 _文档_[组件封装](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-ui-component-encapsulation "组件封装")

 _文档_[自定义组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ui-js-custom-components "自定义组件")

 _文档_[@ReusableV2装饰器：组件复用](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-reusablev2 "@ReusableV2装饰器：组件复用")

 _文档_[自定义组件的基本用法](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-components-custom-basic-usage "自定义组件的基本用法")

 _文档_[如何实现类似插槽的功能](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-arkui-31 "如何实现类似插槽的功能")

 _文档_[组件冗余刷新解决方案](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-redundancy-refresh-guide "组件冗余刷新解决方案")

 _文档_[其他状态管理概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-other-state-mgmt-functions-overview "其他状态管理概述")

 _文档_[属性修改器 (AttributeModifier)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-user-defined-extension-attributemodifier "属性修改器 \(AttributeModifier\)")

_文档_[组件扩展概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-extend-components-overview "组件扩展概述")

 _文档_[BuilderNode](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-arkui-buildernode "BuilderNode")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 3. 404

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-basic-syntax

---

*（内容为空）*

### 相关链接


---

## 4. 状态管理概述-学习UI范式状态管理-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-overview

---

### 状态管理V1与V2能力对比 __

V1能力 | V2能力 | 说明  
---|---|---  
@Observed | @ObservedV2 |  表明当前对象为可观察对象。但两者能力并不相同。 @Observed可观察第一层的属性，需要搭配@ObjectLink使用才能生效。 @ObservedV2本身无观察能力，仅代表当前class可被观察，如果要观察其属性，需要搭配@Trace使用。  
@Track | @Trace |  V1装饰器@Track为精确观察，可以不依赖@Observed单独使用。不使用则无法做到类属性的精准观察。 V2@Trace装饰的属性可以被精确跟踪观察。  
@Component | @ComponentV2 |  @Component为搭配V1状态变量使用的自定义组件装饰器。 @ComponentV2为搭配V2状态变量使用的自定义组件装饰器。  
@State |  无外部初始化：@Local 外部初始化一次：@Param@Once | @State和@Local类似都是数据源的概念，区别是@State可以外部传入初始化，而@Local无法外部传入初始化。  
@Prop | @Param | @Prop和@Param类似都是自定义组件参数的概念。当输入参数为复杂类型时，@Prop为深拷贝，@Param为引用。  
@Link | @Param@Event | @Link是框架自己封装实现的双向同步，对于V2开发者可以通过@Param@Event自己实现双向同步。  
@ObjectLink | @Param | 直接兼容，@ObjectLink需要被@Observed装饰的class的实例初始化，@Param没有此限制。  
@Provide | @Provider | 兼容。  
@Consume | @Consumer | 兼容。  
@Watch | @Monitor |  @Watch用于监听V1状态变量的变化，具有监听状态变量本身和其第一层属性变化的能力。状态变量可观察到的变化会触发其@Watch监听事件。 @Monitor用于监听V2状态变量的变化，搭配@Trace使用，可有深层监听的能力。状态变量在一次事件中多次变化时，仅会以最终的结果判断是否触发@Monitor监听事件。  
LocalStorage | 全局@ObservedV2@Trace | 兼容。  
AppStorage | AppStorageV2 | 兼容。  
Environment | 调用Ability接口获取系统环境变量 | Environment获取环境变量能力和AppStorage耦合。在V2中可直接调用Ability接口获取系统环境变量。  
PersistentStorage | PersistenceV2 | PersistentStorage持久化能力和AppStorage耦合，PersistenceV2持久化能力可独立使用。  
自定义组件生命周期 | 自定义组件生命周期 | 均支持。[aboutToAppear](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-lifecycle#abouttoappear)、[onDidBuild](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-lifecycle#ondidbuild12)、[aboutToDisappear](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-lifecycle#abouttodisappear)。  
页面生命周期 | 页面生命周期 | 均支持。[onPageShow](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-lifecycle#onpageshow)、[onPageHide](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-lifecycle#onpagehide)、[onBackPress](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-lifecycle#onbackpress)。  
@Reusable | @ReusableV2 | 组件复用。包括：[aboutToReuse](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-lifecycle#abouttoreuse10)、[aboutToRecycle](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-lifecycle#abouttorecycle10)。  
$$ | !! | 双向绑定。V2建议使用!!实现双向绑定。  
@CustomDialog | [openCustomDialog](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-uicontext-promptaction#opencustomdialog12)接口 | 自定义弹窗。V2建议使用openCustomDialog实现自定义弹窗功能。  
WithTheme | WithTheme |  主题。用于设置应用局部页面自定义主题风格。包括：[onWillApplyTheme](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-lifecycle#onwillapplytheme12)。 从API version 18开始，该接口支持在状态管理V2组件中使用。  
系统预置UI组件库 | 系统预置UI组件库 |  系统预置UI组件库 。支持V1的系统预置UI组件，例如：[Dialog](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ohos-arkui-advanced-dialog)、[ProgressButton](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ohos-arkui-advanced-progressbutton)、[SegmentButton](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ohos-arkui-advanced-segmentbutton)。 从API version 18开始，系统预置UI组件支持在状态管理V2组件中使用，例如：[DialogV2](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ohos-arkui-advanced-dialogv2)、[ProgressButtonV2](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ohos-arkui-advanced-progressbuttonv2)、[SegmentButtonV2](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ohos-arkui-advanced-segmentbuttonv2)。  
animateTo | 部分场景不支持 | 当前某些场景下，在状态管理V2中使用animateTo动画，会产生异常效果，详见：[在状态管理V2中使用animateTo动画效果异常](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-local#在状态管理v2中使用animateto动画效果异常)。  
  
有关V1向V2的迁移可参考[迁移指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-v1-v2-migration)，有关V1与V2的混用可参考[混用文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-custom-component-mixed-scenarios)。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 5. 学习UI范式状态管理-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management

---

* **[状态管理概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-overview)**  

  * **[状态管理（V1）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-v1)**  

  * **[状态管理（V2）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-v2)**  

  * **[V1V2混用指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/v1v2-mixing)**  

  * **[V1->V2迁移指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/v1v2-migration)**  

[__@Reusable装饰器：组件复用](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-reusable "@Reusable装饰器：组件复用")

[ 状态管理概述 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-overview "状态管理概述")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 6. 所有HarmonyOS版本-版本说明 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1

---

## 发布类型说明 __

HarmonyOS开发者套件版本的发布类型定义如下：

**表1** 发布类型说明类型 | 版本类型说明 | 版本作用  
---|---|---  
Canary | 早期体验版本，特性功能待稳定。 | 您可以反馈使用过程中遇到的问题，我们将全力解决。  
Beta | 公开发布的Beta版本，特性功能待稳定。 | 您可以反馈您的使用体验，使产品做得更好。  
Release | 正式发布版本，承诺质量，特性功能稳定。 | 您可以基于新功能完成最后的工作，发布应用。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [所有HarmonyOS版本](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-allversion)
- [HarmonyOS 6.0.1(21) Beta](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/601)
- [HarmonyOS 6.0.0(20)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/600)
- [HarmonyOS 5.1.1(19)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/511)
- [HarmonyOS 5.1.0(18)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/510)
- [HarmonyOS 5.0.5(17)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/505)


---

## 7. 应用开发导读-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1

---

## 开发 __  
  
从HarmonyOS NEXT Developer Preview1（API 11）版本开始，HarmonyOS SDK以Kit维度提供丰富、完备的开放能力，涵盖应用框架、系统、媒体、图形、应用服务、AI六大领域，例如：

  * 应用框架相关Kit开放能力：Ability Kit（程序框架服务）、ArkUI（方舟UI框架）等。
  * 系统相关Kit开放能力：Universal Keystore Kit（密钥管理服务）、Network Kit（网络服务）等。
  * 媒体相关Kit开放能力：Audio Kit（音频服务）、Media Library Kit（媒体文件管理服务）等。
  * 图形相关Kit开放能力：ArkGraphics 2D（方舟2D图形服务）、Graphics Accelerate Kit（图形加速服务）等。
  * 应用服务相关Kit开放能力：Game Service Kit（游戏服务）、Location Kit（位置服务）等。
  * AI相关Kit开放能力：Intents Kit（意图框架服务）、CANN Kit（CANN 服务）等。

我们针对重点开放能力提供了开发指导，助力开发者高效开发。详情请参见“开发”目录下相关内容。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [HarmonyOS术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/glossary)


---

## 8. 开发说明-API参考概述 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1

---

## 错误码使用说明 __

ArkTS API在使用过程中，可能会遇到错误。

在可能出现错误的各个接口处，开发者可参考文档中提供的**错误码** 部分，了解对应接口可能出现的错误码ID及错误信息，并根据需要进行处理。

当前ArkTS API分为异步接口和同步接口，以下为对应的错误处理方式：

  * 针对同步接口，错误统一通过异常形式抛出，开发者需要通过try-catch的方式处理可能抛出的异常。

  * 针对异步接口，错误可能包括异常和rejection，开发者若使用await/async方式，需要通过try-catch的方式处理可能抛出的异常和rejection。

  * 针对异步接口，错误可能包括异常和rejection，开发者若使用Promise方式，需要通过try-catch的方式处理同步抛出的异常（一般为401异常），并通过Promise的catch()方法或then()方法中的onrejected回调函数处理rejection。

  * 针对callback形式的异步接口（不推荐使用），错误可能包括异常和回调返回的错误，开发者若使用callback方式，需要通过try-catch的方式处理同步抛出的异常（一般为401异常），并处理通过回调参数呈现的错误（即BusinessError对象）。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [开发说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api)
- [系统能力SystemCapability使用指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/syscap)
- [通用错误码](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/errorcode-universal)
- [筛选您使用的API版本](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/doc-updates#section1810915471038)
- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-allversion)
- [系统能力SystemCapability使用指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/syscap)


---

## 9. 多设备场景-开发 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1

---

* **[手机](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faq-phone)**  

[手机 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faq-phone "手机")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

在 FAQ 中进行搜索 __

____

只搜索章节标题

 __请输入您想要搜索的关键词

### 相关链接

- [手机](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faq-phone)
- [手机](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faq-phone)


---

## 10. HarmonyOS 6.0.0(20) 的行为变更汇总-变更预告 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1

---

## OS平台API行为的变更 __

Kit | 变更描述 | 变更引入版本 | 变更影响 | 影响设备类型 | 变更生效规则  
---|---|---|---|---|---  
Ability Kit | [AbilityDelegator.startAbility()接口错误码变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#section284) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
[借助Want进行文件分享时擦除不合法的URI](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025041851851) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
ArkTS | [通过字面量定义的数组在删除元素后再使用该字面量定义数组时数组内容异常](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025042210344) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | 全部生效  
ArkUI | [GridRow组件columns参数和GridCol组件span参数默认值变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025040702131) | 6.0.0(20) Beta1 | 中 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
[width和height支持的matchParent接口规格变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025040275645) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
[文本与输入、信息展示、按钮与选择、滚动与滑动、图形绘制组件接口支持Resource类型](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#section383) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | 全部生效  
[UI Input相关NDK接口行为变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025040107071) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
[使用字面量初始化CustomDialogController类实例导致的编译行为变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025071721132) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
ArkWeb | [ArkWeb基于上游社区的Chromium内核从114升级为132版本](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025050804757) | 6.0.0(20) Beta1 | 大 | phone, tablet, 2in1 | 全部生效  
Connectivity Kit | [蓝牙BLE接口错误码变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025040175433) | 6.0.0(20) Beta1 | 中 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
Core File Kit | [@ohos.file.fs.d.ts中copy接口在拷贝后，对目标文件原有数据处理方式发生变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025040165962) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
Driver Development Kit | [SendPipeRequest和SendPipeRequestWithAshmem传入错误参数时，返回值由USB_DDK_SUCCESS变更为USB_DDK_INVALID_PARAMETER](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#section336) | 6.0.0(20) Beta1 | 小 | 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
Image Kit | [ImageInfo对象mimeType返回值变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#section406) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
Media Kit | [播放器所使用的内存归属变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025040590071) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
User Authentication Kit | [@ohos.useriam.userAuth限制应用从后台发起带交互界面的身份认证变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#section390) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | 全部生效  
其他 | [mincore接口功能补齐至与Linux一致](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025033190005) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | 全部生效  
[ptrace syscall操作未被停住的线程由返回0改为返回ESRCH.1](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#section170) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | 全部生效  
[限制ptrace接口仅可在开发者调试模式下使用](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6001#ch2025040675033) | 6.0.0(20) Beta1 | 小 | phone, tablet, 2in1 | 全部生效  
Ability Kit | [Ability Kit相关公共事件行为变更，增加管控](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025051312838) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 全部生效  
ArkTS | [TreeSet/TreeMap扩容导致比较器丢失问题正向修复](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025062036364) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | targetSdkVersion ≥ 6.0.0(20)变更生效  
ArkUI | [位置控件功能变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025051227329) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 全部生效  
[通用属性drawModifier接口行为变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025061956154) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 全部生效  
[半模态SIDE侧边样式新增避让软键盘能力](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025061805350) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 全部生效  
[CanvasRenderer的font接口支持自定义字体行为变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025062517095) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 全部生效  
[去除保存控件系统提示弹框变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025070747763) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 6.0.0(20) Beta1新增接口，仅对使用6.0.0(20) Beta1开发的应用生效  
Basic Services Kit | [zlib.unzipFile和zlib.decompressFile解压文件接口变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025061279339) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 全部生效  
Data Augmentation Kit | [retrieval.VectorQuery接口value字段变更为可选](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025070161508) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 6.0.0(20) Beta1新增接口，仅对使用6.0.0(20) Beta1开发的应用生效  
Localization Kit | [泰国、沙特阿拉伯、阿富汗和伊朗的默认历法变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025063039411) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 全部生效  
NDK开发 | [libc++ condition_variable::wait_for接口变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025062308656) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 全部生效  
Share Kit | [on('dataReceive')接口新增必填参数capabilities](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6002#ch2025071525869) | 6.0.0(20) Beta2 | 小 | phone, tablet, 2in1 | 6.0.0(20) Beta1新增接口，仅对使用6.0.0(20) Beta1开发的应用生效  
Car Kit | [Car Kit接口新增801、1003810001、1003810002错误码](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6003#ch2025082874213) | 6.0.0(20) Beta3 | 小 | phone, tablet, 2in1 | 全部生效  
Data Augmentation Kit | [rag.streamRun接口思考过程输出变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6003#ch2025080515191) | 6.0.0(20) Beta3 | 小 | phone, tablet, 2in1 | 6.0.0(20) Beta2新增接口，仅对使用6.0.0(20) Beta2开发的应用生效  
Device Security Kit | [SECURITY_AUDIT_NOTIFY_EVENT_FILE_INTERCEPTED、FILE_INTERCEPTED枚举值变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6003#ch2025072609886) | 6.0.0(20) Beta3 | 小 | phone, tablet, 2in1 | 6.0.0(20) Beta2新增接口，仅对使用6.0.0(20) Beta2开发的应用生效  
ArkTS | [禁止在编译产物为JS的HAR包中使用注解](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-for-all-apps-6004#ch2025081914674) | 6.0.0(20) Beta5 | 小 | phone, tablet, 2in1 | 全部生效

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [HarmonyOS 6.0.0(20) 的行为变更汇总](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/all-changelogs-600)
- [HarmonyOS 5.1.1(19)无行为变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/all-changelogs-511)
- [HarmonyOS 5.1.0(18)的行为变更汇总](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/all-changelogs-510)
- [HarmonyOS 5.0.5(17)无行为变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/all-changelogs-505)
- [HarmonyOS 5.0.4(16)无行为变更](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/all-changelogs-504)
- [HarmonyOS 5.0.3(15)的行为变更汇总](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/all-changelogs-503)


---

## 11. 应用开发导读-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide

---

## 开发 __  
  
从HarmonyOS NEXT Developer Preview1（API 11）版本开始，HarmonyOS SDK以Kit维度提供丰富、完备的开放能力，涵盖应用框架、系统、媒体、图形、应用服务、AI六大领域，例如：

  * 应用框架相关Kit开放能力：Ability Kit（程序框架服务）、ArkUI（方舟UI框架）等。
  * 系统相关Kit开放能力：Universal Keystore Kit（密钥管理服务）、Network Kit（网络服务）等。
  * 媒体相关Kit开放能力：Audio Kit（音频服务）、Media Library Kit（媒体文件管理服务）等。
  * 图形相关Kit开放能力：ArkGraphics 2D（方舟2D图形服务）、Graphics Accelerate Kit（图形加速服务）等。
  * 应用服务相关Kit开放能力：Game Service Kit（游戏服务）、Location Kit（位置服务）等。
  * AI相关Kit开放能力：Intents Kit（意图框架服务）、CANN Kit（CANN 服务）等。

我们针对重点开放能力提供了开发指导，助力开发者高效开发。详情请参见“开发”目录下相关内容。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [HarmonyOS术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/glossary)


---

## 12. 快速入门-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start

---

* **[开发准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/start-overview)**  

  * **[构建第一个HarmonyOS应用（ArkTS）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/start-with-ets-stage)**  

[__应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide "应用开发导读")

[ 开发准备 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/start-overview "开发准备")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [HarmonyOS术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/glossary)


---

## 13. 开发基础知识-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals

---

* **[应用程序包基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-package-fundamentals)**  

  * **[应用配置文件（Stage模型）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-configuration-file-stage)**  

  * **[应用配置文件（FA模型）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-configuration-file-fa)**  

  * **[典型场景的开发指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-typical-scenarios)**  

  * **[应用程序包常见问题](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/common_problem_of_application)**  

  * **[应用程序包术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-package-glossary)**  

[__构建第一个HarmonyOS应用（ArkTS）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/start-with-ets-stage "构建第一个HarmonyOS应用（ArkTS）")

[ 应用程序包基础知识 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-package-fundamentals "应用程序包基础知识")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [HarmonyOS术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/glossary)


---

## 14. 资源分类与访问-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access

---

### 获取指定配置的资源 __

**基本概念**

开发者可以在工程的resources目录下添加限定词目录，满足多语言、深浅色模式等不同类型的系统设置。然而，在获取资源时，由于限定词目录匹配规则，只能筛选出最匹配的资源，无法获取其它目录资源。

应用如果有获取指定配置的资源的诉求，可以通过以下方法进行获取。

**接口说明**

接口名 | 描述  
---|---  
[getOverrideResourceManager](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-resource-manager#getoverrideresourcemanager12)(configuration?: [Configuration](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-resource-manager#configuration)) : [ResourceManager](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-resource-manager#resourcemanager) | 获取可以加载指定配置的资源的资源管理对象，使用同步方式返回。  
[getOverrideConfiguration](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-resource-manager#getoverrideconfiguration12)() : [Configuration](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-resource-manager#configuration) | 获取指定的配置，使用同步方式返回。  
[updateOverrideConfiguration](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-resource-manager#updateoverrideconfiguration12)(configuration: [Configuration](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-resource-manager#configuration)) : void | 更新指定的配置。  
  
**示例**

以获取非当前系统语言的资源为例，说明如何获取指定配置的资源。假设工程中定义了中文、英文、日文的同名资源如下：

  * entry/src/main/resources/zh_CN/element/string.json

      
      1. {
        2.   "string": [
        3.     {
        4.       "name": "greetings",
        5.       "value": "你好，世界"
        6.     }
        7.   ]
        8. }
    
    

  * entry/src/main/resources/en_US/element/string.json

      
      1. {
        2.   "string": [
        3.     {
        4.       "name": "greetings",
        5.       "value": "Hello, world"
        6.     }
        7.   ]
        8. }
    
    

  * entry/src/main/resources/ja_JP/element/string.json

      
      1. {
        2.   "string": [
        3.     {
        4.       "name": "greetings",
        5.       "value": "こんにちは、世界"
        6.     }
        7.   ]
        8. }
    
    

在Index.ets中，分别获取三种语言的资源并显示在文本框中，运行设备当前系统语言为中文，entry/src/main/ets/pages/Index.ets的代码如下：
      
      1. import { common } from '@kit.AbilityKit';
        2. import { BusinessError } from '@kit.BasicServicesKit';
        3. 
         
        4. @Entry
        5. @Component
        6. struct Index {
        7.   @State englishString: string = "";
        8.   @State germanString: string = "";
        9. 
         
        10.   getString(): string {
        11.     let resMgr = this.getUIContext().getHostContext()?.resourceManager;
        12.     if (!resMgr) {
        13.       return "";
        14.     }
        15.     let currentLanguageString: string = "";
        16.     try {
        17.       let resId = $r('app.string.greetings').id;
        18. 
         
        19.       //获取符合当前系统语言地区、颜色模式、分辨率等配置的资源
        20.       currentLanguageString = resMgr.getStringSync(resId);
        21. 
         
        22.       //获取符合当前系统颜色模式、分辨率等配置的英文资源
        23.       let overrideConfig = resMgr.getOverrideConfiguration();
        24.       overrideConfig.locale = "en_US"; //指定资源的语言为英语，地区为美国
        25.       let overrideResMgr = resMgr.getOverrideResourceManager(overrideConfig);
        26.       this.englishString = overrideResMgr.getStringSync(resId);
        27. 
         
        28.       //获取符合当前系统颜色模式、分辨率等配置的日文资源
        29.       overrideConfig.locale = "ja_JP"; //指定资源的语言为日文，地区为日本
        30.       overrideResMgr.updateOverrideConfiguration(overrideConfig); //等效于resMgr.updateOverrideConfiguration(overrideConfig)
        31.       this.germanString = overrideResMgr.getStringSync(resId);
        32.     } catch (err) {
        33.       const code = (err as BusinessError).code;
        34.       const message = (err as BusinessError).message;
        35.       console.error(`get override resource failed, error code: ${code}, error msg: ${message}`);
        36.     }
        37.     return currentLanguageString;
        38.   }
        39. 
         
        40.   build() {
        41.     Row() {
        42.       Column() {
        43.         Text(this.getString())
        44.           .fontSize(50)
        45.           .fontWeight(FontWeight.Bold)
        46.         Text(this.englishString)
        47.           .fontSize(50)
        48.           .fontWeight(FontWeight.Bold)
        49.         Text(this.germanString)
        50.           .fontSize(50)
        51.           .fontWeight(FontWeight.Bold)
        52.       }
        53.       .width('100%')
        54.     }
        55.     .height('100%')
        56.   }
        57. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [HarmonyOS术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/glossary)


---

## 15. 学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts

---

* **[初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)**  

  * **[ArkTS语言介绍](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts)**  

  * **[ArkTS编程规范](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-coding-style-guide)**  

  * **[从TypeScript到ArkTS的适配指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/typescript-to-arkts-migration)**  

  * **[ArkTS高性能编程实践](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-high-performance-programming)**  

  * **[面向其他语言的ArkTS迁移指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-for-other-languages)**  

[__资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access "资源分类与访问")

[ 初识ArkTS语言 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started "初识ArkTS语言")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [HarmonyOS术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/glossary)


---

## 16. 初识ArkTS语言-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started

---

ArkTS是HarmonyOS应用的默认开发语言，在[TypeScript](https://www.typescriptlang.org/)（简称TS）生态基础上做了扩展，保持TS的基本风格。通过规范定义，从而强化了开发期的静态检查和分析，提升了程序执行的稳定性和性能。

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107151025.26941324578593046749474028183431:50001231000000:2800:89D0FF2926C2803BB365A74F30D9FE0E9E9B3E41C1DDEEF2EB104D2A8CE7FD72.png)

深入学习请看[ArkTS学习路线](https://developer.huawei.com/consumer/cn/arkts/)和[ArkTS视频课程](https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717496870909384?pathId=101667550095504391)。

自API version 10起，ArkTS进一步通过规范强化静态检查和分析，其主要特性及标准TS的差异包括[从TypeScript到ArkTS的适配规则](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/typescript-to-arkts-migration-guide)：

  * 强制使用静态类型：静态类型是ArkTS最重要的特性之一。如果使用静态类型，那么程序中变量的类型就是确定的。同时，由于所有类型在程序实际运行前都是已知的，编译器可以验证代码的正确性，从而减少运行时的类型检查，有助于性能提升。

  * 禁止在运行时改变对象布局：为实现最优性能，ArkTS禁止在程序执行期间更改对象布局。

  * 限制运算符语义：为获得更好的性能并鼓励编写清晰的代码，ArkTS限制了部分运算符的语义。例如，一元加法运算符仅能作用于数字，不能用于其他类型变量。

  * 不支持Structural typing：对Structural typing的支持需要在语言、编译器和运行时进行大量的考虑和仔细的实现，当前ArkTS不支持该特性。根据实际场景的需求和反馈，后续会重新考虑是否支持Structural typing。

ArkTS兼容TS/JavaScript（简称JS）生态，开发者可以使用TS/JS进行开发或复用已有代码。HarmonyOS系统对TS/JS支持的详细情况见[兼容TS/JS的约束](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-migration-background#方舟运行时兼容tsjs)。

未来，ArkTS会结合应用开发/运行的需求持续演进，逐步增强并行和并发能力、扩展系统类型，以及引入分布式开发范式等更多特性。

如需深入了解ArkTS语言，可参考[ArkTS具体指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-overview)。

[__学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts "学习ArkTS语言")

[ ArkTS语言介绍 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts "ArkTS语言介绍")

相关推荐

 _文档_[ArkTS语法适配背景](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-migration-background "ArkTS语法适配背景")

 _文档_[ArkTS语言基础类库](https://developer.huawei.com/consumer/cn/doc/atomic-guides/atomic-arkts-utils "ArkTS语言基础类库")

 _文档_[对象key代码补全失效](https://developer.huawei.com/consumer/cn/doc/architecture-guides/educate-v1_1-ts_130-0000002427291057 "对象key代码补全失效")

 _文档_[ArkTS是否支持匿名内部类](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-arkts-97 "ArkTS是否支持匿名内部类")

 _文档_[ArkTS简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-overview "ArkTS简介")

 _文档_[ArkTS类的方法是否支持重载](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-arkts-45 "ArkTS类的方法是否支持重载")

 _文档_[如何在ArkTS中实现自定义装饰器能力](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-arkts-78 "如何在ArkTS中实现自定义装饰器能力")

 _文档_[使用 Json Stream 进行反序列化](https://developer.huawei.com/consumer/cn/doc/cangjie-guides-V5/sample_json_reader-V5 "使用 Json Stream 进行反序列化")

 _文档_[convert 使用示例](https://developer.huawei.com/consumer/cn/doc/cangjie-guides-V5/convert_samples-V5 "convert 使用示例")

 _文档_[从TypeScript到ArkTS的适配规则](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/typescript-to-arkts-migration-guide "从TypeScript到ArkTS的适配规则")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 17. ArkTS编程规范-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-coding-style-guide

---

### 空格应该突出关键字和重要信息，避免不必要的空格 __

**【级别】建议**

**【描述】**

空格应该突出关键字和重要信息。总体建议如下：

  1. if, for, while, switch等关键字与左括号(之间加空格。
  2. 在函数定义和调用时，函数名称与参数列表的左括号(之间不加空格。
  3. 关键字else或catch与其之前的大括号}之间加空格。
  4. 任何打开大括号({)之前加空格，有两个例外：

a) 在作为函数的第一个参数或数组中的第一个元素时，对象之前不用加空格，例如：foo({ name: 'abc' })。

b) 在模板中，不用加空格，例如：abc${name}。

  5. 二元操作符(+ - * = < > <= >= === !== && ||)前后加空格；三元操作符(? :)符号两侧均加空格。
  6. 数组初始化中的逗号和函数中多个参数之间的逗号后加空格。
  7. 在逗号(,)或分号(;)之前不加空格。
  8. 数组的中括号([])内侧不要加空格。
  9. 不要出现多个连续空格。在某行中，多个空格若不是用来作缩进的，通常是个错误。

**【反例】**
      
      1. // if 和左括号 ( 之间没有加空格
        2. if(isJedi) {
        3.   fight();
        4. }
        5. 
         
        6. // 函数名fight和左括号 ( 之间加了空格
        7. function fight (): void {
        8.   console.info('Swooosh!');
        9. }
    
    

**【正例】**
      
      1. // if 和左括号之间加一个空格
        2. if (isJedi) {
        3.   fight();
        4. }
        5. 
         
        6. // 函数名fight和左括号 ( 之间不加空格
        7. function fight(): void {
        8.   console.info('Swooosh!');
        9. }
    
    

**【反例】**
      
      1. if (flag) {
        2.   // ...
        3. }else {  // else 与其前面的大括号 } 之间没有加空格
        4.   // ...
        5. }
    
    

**【正例】**
      
      1. if (flag) {
        2.   // ...
        3. } else {  // else 与其前面的大括号 } 之间增加空格
        4.   // ...
        5. }
    
    

**【正例】**
      
      1. function foo() {  // 函数声明时，左大括号 { 之前加个空格
        2.   // ...
        3. }
        4. 
         
        5. bar('attr', {  // 左大括号前加个空格
        6.   age: '1 year',
        7.   sbreed: 'Bernese Mountain Dog',
        8. });
    
    

**【正例】**
      
      1. const arr = [1, 2, 3];  // 数组初始化中的逗号后面加个空格，逗号前面不加空格
        2. myFunc(bar, foo, baz);  // 函数的多个参数之间的逗号后加个空格，逗号前面不加空格

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 18. 从TypeScript到ArkTS的适配指导-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/typescript-to-arkts-migration

---

* **[ArkTS语法适配背景](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-migration-background)**  

  * **[从TypeScript到ArkTS的适配规则](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/typescript-to-arkts-migration-guide)**  

  * **[适配指导案例](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-more-cases)**  

[__ArkTS编程规范](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-coding-style-guide "ArkTS编程规范")

[ ArkTS语法适配背景 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-migration-background "ArkTS语法适配背景")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 19. ArkTS高性能编程实践-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-high-performance-programming

---

### 循环中常量提取，减少属性访问次数 __

如果常量在循环中不会改变，可以将其提取到循环外部，减少访问次数。
      
      1. class Time {
        2.   static start: number = 0;
        3.   static info: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        4. }
        5. 
         
        6. function getNum(num: number): number {
        7.   let total: number = 348;
        8.   for (let index: number = 0x8000; index > 0x8; index >>= 1) {
        9.     // 此处会多次对Time的info及start进行查找，并且每次查找出来的值是相同的
        10.     total += ((Time.info[num - Time.start] & index) !== 0) ? 1 : 0;
        11.   }
        12.   return total;
        13. }
    
    

优化后的代码如下，可以将Time.info[num - Time.start]提取为常量，这样可以显著减少属性访问次数，提升性能。
      
      1. class Time {
        2.   static start: number = 0;
        3.   static info: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        4. }
        5. 
         
        6. function getNum(num: number): number {
        7.   let total: number = 348;
        8.   const info = Time.info[num - Time.start];  // 从循环中提取不变量
        9.   for (let index: number = 0x8000; index > 0x8; index >>= 1) {
        10.     if ((info & index) != 0) {
        11.       total++;
        12.     }
        13.   }
        14.   return total;
        15. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 20. 面向其他语言的ArkTS迁移指导-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-for-other-languages

---

* **[从Java到ArkTS的迁移指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/getting-started-with-arkts-for-java-programmers)**  

  * **[从Swift到ArkTS的迁移指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/getting-started-with-arkts-for-swift-programmers)**  

[__ArkTS高性能编程实践](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-high-performance-programming "ArkTS高性能编程实践")

[ 从Java到ArkTS的迁移指导 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/getting-started-with-arkts-for-java-programmers "从Java到ArkTS的迁移指导")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 21. HarmonyOS术语-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/glossary

---

### **HarmonyOS** __

HarmonyOS是新一代的智能终端操作系统，为不同设备的智能化、互联与协同提供了统一的语言。带来简洁、流畅、连续、安全可靠的全场景交互体验。

2024年HarmonyOS以全新架构发布，命名为HarmonyOS NEXT。HarmonyOS NEXT于2024年6月21日公开发布首个Developer Beta版本，并于2024年10月22日正式公开发布首个Release版本（版本号5.0.0）。HarmonyOS NEXT采用[OpenHarmony](/consumer/cn/doc/harmonyos-guides/glossary#section15569823194110)作为操作系统底座，并通过OpenHarmony兼容性标准认证。全新架构下的HarmonyOS实现了对全场景体验的底层优化，系统更流畅，隐私安全能力更强大。给消费者带来更高效、更流畅、更便捷、更安全的智能化操作体验。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [HarmonyOS术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/glossary)


---

## 22. 文档变更说明-版本说明 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/doc-updates#section1810915471038

---

### 新增文档 __

**ArkUI**

  * [自定义节点](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-user-defined-node-V5)：介绍ArkUI框架提供底层实体节点部分基础能力。 
    * [自定义占位节点](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-user-defined-place-hoder-V5)：可以将自定义节点挂载在占位节点上，实现自定义节点与原生组件的混合显示。
    * [FrameNode](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-user-defined-arktsnode-framenode-V5)：表示组件的实体节点，提供完全自定义节点和原生组件节点代理两个能力。
    * [RenderNode](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-user-defined-arktsnode-rendernode-V5)：仅提供了设置渲染相关属性、自定义绘制内容以及节点操作的能力。
    * [BuilderNode](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-user-defined-arktsnode-buildernode-V5)：通过无状态的UI方法生成组件树，可以控制开始创建的时间。
  * [旋转屏动画增强](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-rotation-transition-animation-V5)：介绍在原旋转屏动画基础上，如何配置渐隐和渐现的转场效果。
  * [粒子动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-particle-animation-V5)：介绍粒子在颜色、透明度、大小、速度、加速度、自旋角度等维度变化做动画的实现方法。
  * [事件分发](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-common-events-distribute-V5)**：** 介绍触控事件的分发机制和事件响应链的收集方法。
  * [设置主题换肤](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/theme_skinning-V5)**：** 介绍应用级和页面级的主题设置能力，并提供局部深浅色模式设置、动态换肤等功能描述。

**ArkTS**

  * [共享模块开发指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-sendable-module-V5)：支持共享模块，提供共享模块的使用规格与示例。
  * [已接入Sendable的系统对象](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-sendable#sendable支持的数据类型)：目前ArkTS已支持多线程Sendable，具体可见对应支持Sendable的对象清单。

**Account Kit**

[应用跟随系统未成年人模式](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/account-get-minorsprotection-V5)：介绍应用如何实现跟随系统未成年人模式。

**AR Engine**

[命中检测与运动跟踪](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arengine-hitresult-and-tracking-V5)**：** 介绍如何实现命中检测与运动跟踪。

**ArkGraphics 3D**

新增提供ArkGraphics 3D各模块，为开发者提供基础3D场景绘制能力，供开发者便捷、高效地构建3D场景并完成渲染。

  * [ArkGraphics 3D场景搭建以及管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkgraphics3d-scene-V5)：介绍3D场景中光源、相机、模型三个关键部分的创建及管理。
  * [ArkGraphics 3D资源创建以及使用](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkgraphics3d-resource-V5)：介绍3D场景中材质、着色器、图片资源及环境资源等的创建及使用。
  * [ArkGraphics 3D场景动画控制以及管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkgraphics3d-animation-V5)：介绍3D场景中动画的创建、控制及使用。

**Cloud Foundation Kit**

介绍如何使用Cloud Foundation Kit在应用中[开发云函数](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/cloudfoundation-function-service-V5)、[开发云数据库](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/cloudfoundation-database-service-V5)、[开发云存储](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/cloudfoundation-storage-service-V5)。

**Core Vision Kit**

[主体分割](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/core-vision-subject-segmentation-V5)：介绍如何检测出图片中区别于背景的的前景物体或区域（即“显著主体”），并将其从背景中分离出来。

**Connectivity Kit**

[WLAN服务开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/wlan-overview-V5)：介绍WLAN服务的实现原理、模式，以及P2P模块的开发指导。

**Device Certificate Kit**

[设备真实性证明](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/device-attestation-intro-V5)：介绍系统提供的设备真实性证明和应用身份证明的能力。应用可校验业务请求是否来自真实设备和合法应用，帮助开发者识别黑灰产的攻击行为。

**Device Security Kit**

从[Device Security Kit简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/devicesecurity-introduction-V5)、[服务配额](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/devicesecurity-quota-V5)、[开发准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/devicesecurity-deviceverify-activateservice-V5)、[应用设备状态检测](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/devicesecurity-deviceverify-develop-V5)、[系统完整性检测](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/devicesecurity-sysintegrity-check-V5)、[URL检测](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/devicesecurity-urlthreat-check-V5)、（该特性在6月11日补丁版本带入）[可信应用服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/devicesecurity-taas-dev-V5)，全面介绍应用如何实现对某台设备上的使用状态、设备环境进行管理和检测。

**Graphics Accelerate Kit**

[顶点标记](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/graphics-accelerate-fg-mv-V5)：介绍增强模式的运动估计原理及顶点标记方法。

**Map Kit**

  * [区划选择控件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/map-location-division-V5)：介绍如何集成区划选择控件，实现指定国家的区划信息的加载。
  * [地图截图](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/map-screenshots-V5)：介绍如何实现地图截图，将当前屏幕显示区域进行截屏。

**Natural Language Kit**

  * [分词](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/natural-language-getwordsegmentation-V5)：介绍如何实现将一段文本切分成独立的词语单元，识别出句子中的每个词汇。
  * [实体抽取](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/natural-language-getentity-V5)：介绍如何实现从文本中识别出具有特定意义的实体，例如人名、地名、时间日期、数字、电话号码、邮箱地址等。

**Payment Kit**

  * [支付并签约](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/payment-pay-and-sign-V5)：介绍如何接入支付并签约能力，让用户在支付完成后快速与商户建立签约代扣的关系。
  * [签约代扣](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/payment-partner-withhold-V5)：介绍如何实现服务商模式签约代扣。

**Pen Kit**

介绍如何实现接入[手写套件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/pen-suite-V5)、[报点预测](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/pen-point-prediction-V5)、[一笔成形](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/pen-instant-shape-V5)，助力应用创造更多的手写应用场景。

**PDF Kit**

介绍如何实现[打开PDF文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/pdf-open-docunent-V5)、以及如何在PDF文档中[添加页眉页脚](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/pdf-add-headerfooter-V5)、[添加水印](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/pdf-add-watermark-V5)、[添加背景](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/pdf-add-background-V5)、添加批注、[添加书签](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/pdf-add-bookmark-V5)。

**Scan Kit**

[“扫码直达”服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/scan-directservice-V5)：介绍如何接入“扫码直达”服务，确保用户可通过锁屏、控制中心等系统级的常驻入口，扫应用的二维码、条形码并跳转到应用对应服务页面。

**Share Kit**

  * [宿主应用配置操作区](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/share-app-actions-V5)：介绍如何通过配置移除系统操作区能力。
  * [应用内处理分享内容](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/share-interface-description-V5)：介绍目标应用如何通过UIAbility处理分享内容。
  * [二级面板关闭分享面板](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/share-sec-panel-back-V5)：介绍二级面板如何直接关闭分享面板。

**Remote Communication Kit**

  * [上传下载文件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/remote-communication-updownload-V5)：介绍如何将文件上传到服务器或者从服务器下载文件。
  * [设置TLS版本和加密套件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/remote-communication-settls-V5)：介绍如何设置TLS版本号以及指定加密套件。
  * 介绍如何[使用fetch发送异步网络请求 (C/C++)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/remote-communication-fetchsyncnetworkrequests-c-V5)、[使用fetchsync发起同步网络请求 (C/C++)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/remote-communication-fetchnetworkrequests-c-V5)等，实现[获取服务器资源](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/remote-communication-getserverresources-c-V5)、[发送数据到服务器](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/remote-communication-senddatatoserver-c-V5)、[断点续传](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/remote-communication-httpresume-c-V5)、[双向证书校验](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/remote-communication-certificateverification-c-V5)、[拦截器](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/remote-communication-interceptor-c-V5)**。**

**Store kit**

[支持应用归因服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/store-attribution-introduction-V5)：介绍如何实现[登记归因来源及转化](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/store-attribution-developmentguide-V5)、[归因结果回传](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/store-attribution-receive-V5)。

**Wallet Kit**

从[Wallet Kit简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/wallet-introduction-V5)、[创建Wallet Kit服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/wallet-preparations-V5)、[数字车钥匙](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/wallet-carkey-overview-V5)、[接入交通卡](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/wallet-transport-overview-V5)，全面介绍如何使用Wallet Kit在应用中接入数字车钥匙和交通卡。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [所有HarmonyOS版本](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-allversion)
- [HarmonyOS 6.0.1(21) Beta](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/601)
- [HarmonyOS 6.0.0(20)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/600)
- [HarmonyOS 5.1.1(19)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/511)
- [HarmonyOS 5.1.0(18)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/510)
- [HarmonyOS 5.0.5(17)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/505)


---

## 23. 所有HarmonyOS版本-版本说明 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-allversion

---

## 发布类型说明 __

HarmonyOS开发者套件版本的发布类型定义如下：

**表1** 发布类型说明类型 | 版本类型说明 | 版本作用  
---|---|---  
Canary | 早期体验版本，特性功能待稳定。 | 您可以反馈使用过程中遇到的问题，我们将全力解决。  
Beta | 公开发布的Beta版本，特性功能待稳定。 | 您可以反馈您的使用体验，使产品做得更好。  
Release | 正式发布版本，承诺质量，特性功能稳定。 | 您可以基于新功能完成最后的工作，发布应用。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [所有HarmonyOS版本](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-allversion)
- [HarmonyOS 6.0.1(21) Beta](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/601)
- [HarmonyOS 6.0.0(20)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/600)
- [HarmonyOS 5.1.1(19)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/511)
- [HarmonyOS 5.1.0(18)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/510)
- [HarmonyOS 5.0.5(17)](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/505)


---

## 24. ArkTS简介-ArkTS（方舟编程语言）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-overview

---

ArkTS是HarmonyOS应用开发的官方高级语言。  
  
ArkTS在[TypeScript](https://www.typescriptlang.org/)（简称TS）生态基础上做了进一步扩展，保持了TS的基本风格，同时通过规范定义强化开发期静态检查和分析，提升代码健壮性，并实现更好的程序执行稳定性和性能。对比标准TS的差异可以参考[从TypeScript到ArkTS的适配规则](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/typescript-to-arkts-migration-guide)。ArkTS同时也支持与TS/JavaScript（简称JS）高效互操作。

ArkTS基础类库和容器类库增强了语言的基础功能，提供包括[高精度浮点运算](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-arkts-decimal)、[二进制Buffer](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/buffer)、[XML生成解析转换](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/xml-overview)和多种容器库等能力，协助开发者简化开发工作，提升开发效率。

针对TS/JS并发能力支持有限的问题，ArkTS对并发编程API和能力进行了增强，提供了[TaskPool](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/taskpool-introduction)和[Worker](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/worker-introduction)两种并发API供开发者选择。另外，ArkTS进一步提出了Sendable的概念来支持对象在并发实例间的引用传递，提升ArkTS对象在并发实例间的通信性能。

方舟编译运行时（ArkCompiler）支持ArkTS、TS和JS的编译运行，目前主要分为ArkTS编译工具链和ArkTS运行时两部分。ArkTS编译工具链负责将高级语言编译为方舟字节码文件（*.abc），ArkTS运行时则负责在设备侧运行字节码文件，执行程序逻辑。

未来，ArkTS会结合应用开发/运行的需求持续演进，逐步提供并发能力增强、系统类型增强、分布式开发范式等更多特性。

[__ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts "ArkTS（方舟编程语言）")

[ ArkTS基础类库 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-utils "ArkTS基础类库")

相关推荐

 _文档_[ArkTS运行时概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-runtime-overview "ArkTS运行时概述")

 _文档_[ArkTS语言基础类库](https://developer.huawei.com/consumer/cn/doc/atomic-guides/atomic-arkts-utils "ArkTS语言基础类库")

 _文档_[TaskPool和Worker的异同点](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-arkts-27 "TaskPool和Worker的异同点")

 _文档_[ArkTS线程间通信概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/interthread-communication-overview "ArkTS线程间通信概述")

 _文档_[ArkTS跨语言交互](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-cross-language-interaction "ArkTS跨语言交互")

 _文档_[静态类型和垃圾收集](https://developer.huawei.com/consumer/cn/doc/cangjie-guides-V5/cj-wp-statictype-V5 "静态类型和垃圾收集")

 _文档_[ArkTS语法适配背景](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-migration-background "ArkTS语法适配背景")

 _文档_[初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started "初识ArkTS语言")

 _文档_[初识仓颉语言](https://developer.huawei.com/consumer/cn/doc/cangjie-guides-V5/basic-V5 "初识仓颉语言")

 _文档_[模块化运行简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/module-principle "模块化运行简介")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkTS简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-overview)
- [ArkTS基础类库](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-utils)


---

## 25. 工具概述-开发环境搭建 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-tools-overview

---

### 开发流程 __

开发一个应用/元服务流程如图所示：

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175630.89713448968700715194176607140058:50001231000000:2800:FBA609AC30B5B289D0DD2F91A534A28ED0961D405525E2DC38A2F347A2693079.png)

**一、开发准备**

获取HUAWEI DevEco Studio请单击[链接下载](https://developer.huawei.com/consumer/cn/download/)，完成开发工具的安装。

DevEco Studio开发环境依赖于网络环境，需要连接上网络才能确保工具的正常使用。在部分企业网络受限的情况下，需要[配置代理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-environment-config)信息。

**二、开发应用/元服务**

DevEco Studio集成了Phone、Tablet、2in1、Car等设备的典型场景模板，可以通过工程向导轻松地[创建一个新的工程](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-create-new-project)。

接下来还需要定义应用/元服务的UI、开发业务功能等编码工作，可以根据[应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)来查看具体的开发过程，通过查看[API接口文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api)查阅需要调用的API接口。

在开发代码的过程中，可以[使用预览器查看应用/元服务效果](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-previewer-01)，支持实时预览、动态预览、双向预览等功能，使编码的过程更高效。

**三、运行、调试和测试应用/元服务**

应用/元服务开发完成后，可以[使用真机进行调试](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-debug-device)（需要申请调测证书进行签名），支持单步调试、跨语言调试等调试手段，使得应用/元服务调试更加高效。

HarmonyOS应用/元服务开发完成后，在发布到应用/元服务市场前，还需要[对应用进行测试](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-test)，主要包含Instrument Test、Local Test，确保HarmonyOS应用/元服务纯净、安全，给用户带来更好的使用体验。

**四、发布应用/元服务**

HarmonyOS应用/元服务开发、测试完成后，需要[将应用/元服务发布至应用市场](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-publish-app#section6406135115814)，以便应用市场对应用/元服务进行分发，普通消费者可以通过应用市场获取到对应的HarmonyOS应用/元服务。需要注意的是，发布到华为应用市场的HarmonyOS应用/元服务，必须使用应用市场颁发的发布证书进行签名。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [工具概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-tools-overview)
- [下载与安装DevEco Studio](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-software-install)
- [使用新UI](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-new-ui)
- [工程创建](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-project)
- [离线环境配置指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-no-network)
- [筛选您使用的API版本](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/doc-updates#section1810915471038)


---

## 26. 动态加载-ArkTS模块化-ArkTS运行时-ArkTS（方舟编程语言）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-dynamic-import

---

### 动态import变量表达式 __

DevEco Studio中模块间的依赖关系通过oh-package.json5中的dependencies字段进行配置。dependencies列表中所有的模块默认都会进行安装（本地模块）或下载（远程模块），但是不会默认参与编译。HAP/HSP编译时会以入口文件（一般为Index.ets/Index.ts）开始搜索依赖关系，搜索到的模块或文件才会加入编译。

在编译期，静态import和常量动态import可以被打包工具rollup及其插件识别解析，加入依赖树中，参与编译流程，最终生成方舟字节码。但是，如果是变量动态import，该变量值可能需要进行运算或外部传入才能得到，在编译态无法解析其内容，也就无法加入编译。为了将这部分模块/文件加入编译，还需要额外增加一个runtimeOnly的buildOption配置，用于指定动态import的变量实际的模块名或文件路径。

**1\. runtimeOnly字段schema配置格式**

在HAP/HSP/HAR的build-profile.json5中的buildOption中增加runtimeOnly配置项，仅在通过变量动态import时配置，静态import和常量动态import无需配置；并且，通过变量动态import加载API时也无需配置runtimeOnly。如下实例说明如何配置通过变量动态import其他模块，以及变量动态import本模块自己的单文件：
      
      1. // 变量动态import其他模块myhar
        2. let harName = 'myhar';
        3. import(harName).then((obj: ESObject) => {
        4.     console.info('DynamicImport I am a har');
        5. })
        6. 
         
        7. // 变量动态import本模块自己的单文件src/main/ets/index.ets
        8. let filePath = './utils/Calc';
        9. import(filePath).then((obj: ESObject) => {
        10.     console.info('DynamicImport I am a file');
        11. })
    
    

对应的runtimeOnly配置：
      
      1. "buildOption": {
        2.   "arkOptions": {
        3.     "runtimeOnly": {
        4.       "packages": [ "myhar" ],  // 配置本模块变量动态import其他模块名，要求与dependencies中配置的名字一致。
        5.       "sources": [ "./src/main/ets/utils/Calc.ets" ]  // 配置本模块变量动态import自己的文件路径，路径相对于当前build-profile.json5文件。
        6.     }
        7.   }
        8. }
    
    

"runtimeOnly"的"packages"：用于配置本模块变量动态import其他模块名，要求与dependencies中配置的名字一致。

"runtimeOnly"的"sources"：用于配置本模块变量动态import自己的文件路径，路径相对于当前build-profile.json5文件。

**2\. 使用实例**

  * **HAP变量动态import HAR模块名**
        
        1. // HAR's Index.ets
            2. export function add(a: number, b: number): number {
            3.   let c = a + b;
            4.   console.info('DynamicImport I am a HAR, %d + %d = %d', a, b, c);
            5.   return c;
            6. }
        
        1. // HAP's src/main/ets/pages/Index.ets
            2. let packageName = 'myhar';
            3. import(packageName).then((ns:ESObject) => {
            4.   console.info('DynamicImport ns.add(3, 5) = %d', ns.add(3, 5));
            5. });
        
        1. // HAP's oh-package.json5
            2. "dependencies": {
            3.   "myhar": "file:../myhar"
            4. }
        
        1. // HAP's build-profile.json5
            2. "buildOption": {
            3.   "arkOptions": {
            4.     "runtimeOnly": {
            5.       "packages": [
            6.         "myhar"  // 仅用于使用变量动态import其他模块名场景，静态import或常量动态import无需配置。
            7.       ]
            8.     }
            9.   }
            10. }

  * **HAP变量动态import HSP模块名**
        
        1. // HSP's Index.ets
            2. export function add(a: number, b: number): number {
            3.   let c = a + b;
            4.   console.info('DynamicImport I am a HSP, %d + %d = %d', a, b, c);
            5.   return c;
            6. }
        
        1. // HAP's src/main/ets/pages/Index.ets
            2. let packageName = 'myhsp';
            3. import(packageName).then((ns:ESObject) => {
            4.   console.info('DynamicImport ns.add(3, 5) = %d', ns.add(3, 5));
            5. });
        
        1. // HAP's oh-package.json5
            2. "dependencies": {
            3.   "myhsp": "file:../myhsp"
            4. }
        
        1. // HAP's build-profile.json5
            2. "buildOption": {
            3.   "arkOptions": {
            4.     "runtimeOnly": {
            5.       "packages": [
            6.         "myhsp"  // 仅用于使用变量动态import其他模块名场景，静态import或常量动态import无需配置。
            7.       ]
            8.     }
            9.   }
            10. }

  * **HAP变量动态import远程HAR模块名**
        
        1. // HAP's src/main/ets/pages/Index.ets
            2. let packageName = '@ohos/crypto-js';
            3. import(packageName).then((ns:ESObject) => {
            4.   console.info('DynamicImport @ohos/crypto-js: ' + ns.CryptoJS.MD5(123456));
            5. });
        
        1. // HAP's oh-package.json5
            2. "dependencies": {
            3.   "@ohos/crypto-js": "2.0.3-rc.0"
            4. }
        
        1. // HAP's build-profile.json5
            2. "buildOption": {
            3.   "arkOptions": {
            4.     "runtimeOnly": {
            5.       "packages": [
            6.         "@ohos/crypto-js"  // 仅用于使用变量动态import其他模块名场景，静态import或常量动态import无需配置。
            7.       ]
            8.     }
            9.   }
            10. }

  * **HAP变量动态import ohpm包**
        
        1. // HAP's src/main/ets/pages/Index.ets
            2. let packageName = 'json5';
            3. import(packageName).then((ns:ESObject) => {
            4.   console.info('DynamicImport json5');
            5. });
        
        1. // HAP's oh-package.json5
            2. "dependencies": {
            3.   "json5": "1.0.2"
            4. }
        
        1. // HAP's build-profile.json5
            2. "buildOption": {
            3.   "arkOptions": {
            4.     "runtimeOnly": {
            5.       "packages": [
            6.         "json5"  // 仅用于使用变量动态import其他模块名场景，静态import或常量动态import无需配置。
            7.       ]
            8.     }
            9.   }
            10. }

  * **HAP变量动态import自己的单文件**
        
        1. // HAP's src/main/ets/Calc.ets
            2. export function add(a: number, b: number): number {
            3.   let c = a + b;
            4.   console.info('DynamicImport I am a HAP, %d + %d = %d', a, b, c);
            5.   return c;
            6. }
        
        1. // HAP's src/main/ets/pages/Index.ets
            2. let filePath = '../Calc';
            3. import(filePath).then((ns:ESObject) => {
            4.   console.info('DynamicImport ns.add(3, 5) = %d', ns.add(3, 5));
            5. });
        
        1. // HAP's build-profile.json5
            2. "buildOption": {
            3.   "arkOptions": {
            4.     "runtimeOnly": {
            5.       "sources": [
            6.         "./src/main/ets/Calc.ets"  // 仅用于使用变量动态import模块自己单文件场景，静态import或常量动态import无需配置。
            7.       ]
            8.     }
            9.   }
            10. }

  * **HAP变量动态import自己的Native库**
        
        1. // libnativeapi.so's index.d.ts
            2. export const add: (a: number, b: number) => number;
        
        1. // HAP's src/main/ets/pages/Index.ets
            2. let soName = 'libnativeapi.so';
            3. import(soName).then((ns:ESObject) => {
            4.   console.info('DynamicImport libnativeapi.so: ' + ns.default.add(2, 3));
            5. });
        
        1. // HAP's oh-package.json5
            2. "dependencies": {
            3.   "libnativeapi.so": "file:./src/main/cpp/types/libnativeapi"
            4. }
        
        1. // HAP's build-profile.json5
            2. "buildOption": {
            3.   "arkOptions": {
            4.     "runtimeOnly": {
            5.       "packages": [
            6.         "libnativeapi.so"  // 仅用于使用变量动态import其他模块名场景，静态import或常量动态import无需配置。
            7.       ]
            8.     }
            9.   }
            10. }

  * **HAP变量动态import加载API**
        
        1. // HAP's src/main/ets/pages/Index.ets
            2. let packageName = '@system.app';
            3. import(packageName).then((ns:ESObject) => { ns.default.terminate(); });
            4. packageName = '@system.router';
            5. import(packageName).then((ns:ESObject) => { ns.default.clear(); });
            6. packageName = '@ohos.curves';
            7. import(packageName).then((ns:ESObject) => { ns.default.springMotion(0.555, 0.75, 0.001); });
            8. packageName = '@ohos.matrix4';
            9. import(packageName).then((ns:ESObject) => { ns.default.identity(); });
            10. packageName = '@ohos.hilog';
            11. import(packageName).then((ns:ESObject) => { ns.default.info(0x0000, 'testTag', '%{public}s', 'DynamicImport @ohos.hilog.'); });

通过变量动态import加载API时无需配置runtimeOnly。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkTS简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-overview)
- [ArkTS基础类库](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-utils)


---

## 27. 构建HAR-配置构建流程-构建应用 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-build-har#section19788284410

---

### 操作步骤 __

  1. 将工程级build-profile.json5的useNormalizedOHMUrl设置为true。

说明

从DevEco Studio NEXT Beta1（5.0.3.800）版本开始，工程级build-profile.json5中useNormalizedOHMUrl字段默认为true，byteCodeHar缺省默认值为true，无需执行步骤1和2。
         
         1. {
              2.   "app": {
              3.     "products": [
              4.       {
              5.          "buildOption": {
              6.            "strictMode": {
              7.              "useNormalizedOHMUrl": true
              8.            }
              9.          }
              10.       }
              11.     ]
              12.   }
              13. }

  2. 在HAR模块的build-profile.json5中，将byteCodeHar设置为true。
         
         1. {
              2.   "buildOption": {
              3.     "arkOptions": {
              4.       "byteCodeHar": true
              5.     }
              6.   }
              7. }

  3. 点击DevEco Studio右上角图标![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.70035337957233056976053668601408:50001231000000:2800:E3463CDE39743A056F8BEE8E3BD168826D64729DAC60461EE41504163713FA00.png)，选择**Build Mode，** 默认为**< Default>**模式：在编译App时使用release模式，编译HAP/HSP/HAR时使用debug模式。

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.04538203378385697300806020133121:50001231000000:2800:8E821F087418AC597FF34A74CF29B6B1EA89653D37D4CA3189A87D6E066AF8F7.png)

  4. （可选）在编译模式为release时，为保护代码资产，建议开启混淆，在模块级build-profile.json5文件的release的buildOptionSet配置中，将obfuscation/ruleOptions下的enable字段设置为true。混淆相关能力和具体规则请参考[代码混淆](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-build-obfuscation)。
         
         1. {
              2.   "apiType": "stageMode",
              3.   "buildOption": {
              4.   },
              5.   "buildOptionSet": [
              6.     {
              7.       "name": "release",
              8.       "arkOptions": {
              9.         // 混淆相关参数
              10.         "obfuscation": {
              11.           "ruleOptions": {
              12.             // true表示进行混淆，false表示不进行混淆。5.0.3.600及以上版本默认为false
              13.             "enable": true,
              14.             // 混淆规则文件
              15.             "files": [
              16.               "./obfuscation-rules.txt"
              17.             ]
              18.           },
              19.           // consumerFiles中指定的混淆配置文件会在构建依赖这个library的工程或library时被应用
              20.           "consumerFiles": [
              21.             "./consumer-rules.txt"
              22.           ]
              23.         }
              24.       },
              25.     },
              26.   ],
              27.   "targets": [
              28.     {
              29.       "name": "default"
              30.     }
              31.   ]
              32. }

  5. （可选）如果开发者希望自定义打包到HAR产物中的文件，可在HAR模块的build-profile.json5文件中，配置include或exclude字段，支持glob语法。
         
         1. "buildOption": {
              2.   "packingOptions": {
              3.     "asset": {
              4.       "include": ["./src/router.json5","router.json5"],    // 配置打包到HAR产物中的文件
              5.       "exclude": ["./config/*"]     // 配置不打包到HAR产物中的文件
              6.     }
              7.   }
              8. }

说明

     * 配置include字段时，以下目录不生效，即不会被打包到产物中：node_modules、oh_modules、.preview、build、.cxx、.test。
     * 配置exclude字段时，以下文件不生效，默认会打包：oh-package.json5。

  6. 选中HAR模块的根目录，点击**Build > Make Module '<module-name>'**启动构建。

说明

若修改了HAR模块级oh-package.json5文件的version字段，请先执行**Build > Clean Project**操作，再重新进行Build全量构建。

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.31331856024238517225301061349947:50001231000000:2800:7B1EB10A27017E7338976B52D37C9D2997CE4BE2DFD51CC11EA456C0607002A1.png)

构建完成后，build目录下生成HAR包产物。

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.66989105269069512202770965011809:50001231000000:2800:30219DC1848A7487753F9381B39F21EF0B8E8DD84566631357723FF2E3313255.png)

HAR包产物解压后，结构如下：

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.64909735777230277372806980932321:50001231000000:2800:B9362402B9274FFC6E556EF67E10322059917EF9DE4305F7881D97575E7AA2E4.png)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor)
- [配置文件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-configuration-file)
- [配置构建流程](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-configuration)
- [多模块管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-multi-module)
- [添加依赖项](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-dependencies)
- [配置多目标产物](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-customized-multi-targets-and-products)


---

## 28. ArkGuard混淆原理及功能-ArkGuard源码混淆-ArkTS编译工具链-ArkTS（方舟编程语言）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/source-obfuscation

---

### -keep-property-name __

指定想保留的属性名，支持使用[名称类通配符](/consumer/cn/doc/harmonyos-guides/source-obfuscation#保留选项支持的通配符)。按如下方式进行配置，表示保留名称为firstName和lastName的属性：
      
      1. -keep-property-name
        2. firstName
        3. lastName
    
    

**使用该选项时，需要注意以下事项：**

  1. 该选项在开启-enable-property-obfuscation时生效。

  2. 属性白名单作用于全局。即代码中出现多个重名属性，只要与-keep-property-name配置白名单名称相同，均不会被混淆。

**需要手动配置白名单的属性名**

1.如果代码中通过字符串拼接、变量访问或使用defineProperty方法定义对象属性，则这些属性名应被保留。例如：
      
      1. // example.js
        2. var obj = {x0: '0', x1: '1', x2: '2'};
        3. for (var i = 0; i <= 2; i++) {
        4.     console.info(obj['x' + i]);  // x0, x1, x2应该被保留
        5. }
        6. 
         
        7. Object.defineProperty(obj, 'y', {});  // y应该被保留
        8. Object.getOwnPropertyDescriptor(obj, 'y');  // y应该被保留
        9. console.info(obj.y);
        10. 
         
        11. obj.s1 = 'a';
        12. let key = 's1';
        13. console.info(obj[key]);        // key对应的变量值s1应该被保留
        14. 
         
        15. obj.t1 = 'b';
        16. console.info(obj['t' + '1']);        // t1应该被保留
    
    

对于如下的字符串常量形式的属性调用，可以选择性保留：
      
      1. // 混淆配置：
        2. // -enable-property-obfuscation
        3. // -enable-string-property-obfuscation
        4. 
         
        5. // example.ts
        6. var obj = {t:'1', m:'2'};
        7. obj.t = 'a';
        8. console.info(obj['t']); // 此时，'t'会被正确混淆，t可以选择性保留
        9. 
         
        10. obj['m'] = 'b';
        11. console.info(obj['m']); // 此时，'m'会被正确混淆，m可以选择性保留
    
    

2.对于间接或直接导出的类或对象的属性名的场景，如果混淆后出现问题，可以使用[-keep-property-name](/consumer/cn/doc/harmonyos-guides/source-obfuscation#section-keep-property-name)来保留这些属性名。
      
      1. // 间接导出MyClass
        2. class MyClass {
        3.   greet() {}
        4. }
        5. let alias = new MyClass();
        6. export { alias };
        7. 
         
        8. // 直接导出MyClass1
        9. export class MyClass1 {
        10.   exampleName: 'jack' 
        11.   exampleAge: 100
        12. }
    
    

3.在ArkTS/TS/JS文件中使用so库的API（如示例中的add）时，需手动保留API名称。
      
      1. // src/main/cpp/types/libentry/Index.d.ts
        2. export const addNum: (a: number, b: number) => number;
        3. 
         
        4. // example.ets
        5. import testNapi from 'libentry.so';
        6. 
         
        7. testNapi.addNum(2, 3); // addNum需要保留，示例如：-keep-property-name addNum
    
    

4.JSON数据解析和对象序列化时，需要保留使用到的字段，例如：

示例JSON文件结构（test.json）：
      
      1. {
        2.   "jsonProperty": "value",
        3.   "otherProperty": "value2"
        4. }
    
    
      
      1. import jsonData from './test.json';
        2. 
         
        3. let jsonProp = jsonData.jsonProperty; // jsonProperty应该被保留
        4. 
         
        5. class jsonTest {
        6.   prop1: string = '';
        7.   prop2: number = 0
        8. }
        9. 
         
        10. let obj = new jsonTest();
        11. const jsonStr = JSON.stringify(obj); // prop1 和 prop2 会被混淆，应该被保留
    
    

5.使用到的数据库相关的字段，需要手动保留。例如，数据库键值对类型（ValuesBucket）中的属性：
      
      1. import { ValuesBucket } from '@kit.ArkData';
        2. 
         
        3. const valueBucket: ValuesBucket = {
        4.   ID1: 'ID1', // ID1应该被保留
        5.   NAME1: 'jack', // NAME1应该被保留
        6.   AGE1: 20, // AGE1应该被保留
        7.   SALARY1: 100 // SALARY1应该被保留
        8. }
    
    

6.源码中自定义装饰器修饰了成员变量、成员方法、参数，同时其源码编译的中间产物为js文件时（如编译release源码HAR或者源码包含@ts-ignore、@ts-nocheck），这些装饰器所在的成员变量/成员方法名称需要被保留。这是由于ts高级语法特性转换为js标准语法时，将上述装饰器所在的成员变量/成员方法名称硬编码为字符串常量。

示例：
      
      1. function CustomDecorator(target: Object, propertyKey: string) {}
        2. function MethodDecorator(target: Object, propertyKey: string, descriptor: PropertyDescriptor) {}
        3. function ParamDecorator(target: Object, propertyKey: string, parameterIndex: number) {}
        4. 
         
        5. class A {
        6.   // 1.成员变量装饰器
        7.   @CustomDecorator
        8.   propertyName1: string = ""   // propertyName1 需要被保留
        9.   // 2.成员方法装饰器
        10.   @MethodDecorator
        11.   methodName1() {} // methodName1 需要被保留
        12.   // 3.方法参数装饰器
        13.   methodName2(@ParamDecorator param: string): void {} // methodName2 需要被保留
        14. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkTS简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-overview)
- [ArkTS基础类库](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-utils)


---

## 29. 构建HAR-配置构建流程-构建应用 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-build-har#section16598338112415

---

### 操作步骤 __

  1. 将工程级build-profile.json5的useNormalizedOHMUrl设置为true。

说明

从DevEco Studio NEXT Beta1（5.0.3.800）版本开始，工程级build-profile.json5中useNormalizedOHMUrl字段默认为true，byteCodeHar缺省默认值为true，无需执行步骤1和2。
         
         1. {
              2.   "app": {
              3.     "products": [
              4.       {
              5.          "buildOption": {
              6.            "strictMode": {
              7.              "useNormalizedOHMUrl": true
              8.            }
              9.          }
              10.       }
              11.     ]
              12.   }
              13. }

  2. 在HAR模块的build-profile.json5中，将byteCodeHar设置为true。
         
         1. {
              2.   "buildOption": {
              3.     "arkOptions": {
              4.       "byteCodeHar": true
              5.     }
              6.   }
              7. }

  3. 点击DevEco Studio右上角图标![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.70035337957233056976053668601408:50001231000000:2800:E3463CDE39743A056F8BEE8E3BD168826D64729DAC60461EE41504163713FA00.png)，选择**Build Mode，** 默认为**< Default>**模式：在编译App时使用release模式，编译HAP/HSP/HAR时使用debug模式。

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.04538203378385697300806020133121:50001231000000:2800:8E821F087418AC597FF34A74CF29B6B1EA89653D37D4CA3189A87D6E066AF8F7.png)

  4. （可选）在编译模式为release时，为保护代码资产，建议开启混淆，在模块级build-profile.json5文件的release的buildOptionSet配置中，将obfuscation/ruleOptions下的enable字段设置为true。混淆相关能力和具体规则请参考[代码混淆](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-build-obfuscation)。
         
         1. {
              2.   "apiType": "stageMode",
              3.   "buildOption": {
              4.   },
              5.   "buildOptionSet": [
              6.     {
              7.       "name": "release",
              8.       "arkOptions": {
              9.         // 混淆相关参数
              10.         "obfuscation": {
              11.           "ruleOptions": {
              12.             // true表示进行混淆，false表示不进行混淆。5.0.3.600及以上版本默认为false
              13.             "enable": true,
              14.             // 混淆规则文件
              15.             "files": [
              16.               "./obfuscation-rules.txt"
              17.             ]
              18.           },
              19.           // consumerFiles中指定的混淆配置文件会在构建依赖这个library的工程或library时被应用
              20.           "consumerFiles": [
              21.             "./consumer-rules.txt"
              22.           ]
              23.         }
              24.       },
              25.     },
              26.   ],
              27.   "targets": [
              28.     {
              29.       "name": "default"
              30.     }
              31.   ]
              32. }

  5. （可选）如果开发者希望自定义打包到HAR产物中的文件，可在HAR模块的build-profile.json5文件中，配置include或exclude字段，支持glob语法。
         
         1. "buildOption": {
              2.   "packingOptions": {
              3.     "asset": {
              4.       "include": ["./src/router.json5","router.json5"],    // 配置打包到HAR产物中的文件
              5.       "exclude": ["./config/*"]     // 配置不打包到HAR产物中的文件
              6.     }
              7.   }
              8. }

说明

     * 配置include字段时，以下目录不生效，即不会被打包到产物中：node_modules、oh_modules、.preview、build、.cxx、.test。
     * 配置exclude字段时，以下文件不生效，默认会打包：oh-package.json5。

  6. 选中HAR模块的根目录，点击**Build > Make Module '<module-name>'**启动构建。

说明

若修改了HAR模块级oh-package.json5文件的version字段，请先执行**Build > Clean Project**操作，再重新进行Build全量构建。

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.31331856024238517225301061349947:50001231000000:2800:7B1EB10A27017E7338976B52D37C9D2997CE4BE2DFD51CC11EA456C0607002A1.png)

构建完成后，build目录下生成HAR包产物。

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.66989105269069512202770965011809:50001231000000:2800:30219DC1848A7487753F9381B39F21EF0B8E8DD84566631357723FF2E3313255.png)

HAR包产物解压后，结构如下：

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107175842.64909735777230277372806980932321:50001231000000:2800:B9362402B9274FFC6E556EF67E10322059917EF9DE4305F7881D97575E7AA2E4.png)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor)
- [配置文件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-configuration-file)
- [配置构建流程](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-configuration)
- [多模块管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-multi-module)
- [添加依赖项](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-dependencies)
- [配置多目标产物](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-customized-multi-targets-and-products)


---

## 30. MVVM模式-状态管理（V1）-学习UI范式状态管理-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-mvvm#代码示例

---

### 代码示例 __

按MVVM模式组织结构，重构如下：
      
      1. ├── src
        2. │   ├── ets
        3. │   │   ├── model
        4. │   │   │   ├── ThingModel.ets
        5. │   │   │   └── TodoListModel.ets
        6. │   │   ├── pages
        7. │   │   │   ├── Index.ets
        8. │   │   ├── views
        9. │   │   │   ├── AllChooseComponent.ets
        10. │   │   │   ├── ThingComponent.ets
        11. │   │   │   ├── TodoComponent.ets
        12. │   │   │   └── TodoListComponent.ets
        13. │   │   ├── viewModel
        14. │   │   │   ├── ThingViewModel.ets
        15. │   │   │   └── TodoListViewModel.ets
        16. │   └── resources
        17. │   │   ├── rawfile
        18. │   │   │   ├── default_tasks.json
        19. │
    
    

文件代码如下：

  * ThingModel.ets

      
      1. export default class ThingModel {
        2.   thingName: string = 'Todo';
        3.   isFinish: boolean = false;
        4. }
    
    

  * TodoListModel.ets

      
      1. import { common } from '@kit.AbilityKit';
        2. import { util } from '@kit.ArkTS';
        3. import ThingModel from './ThingModel';
        4. 
         
        5. export default class TodoListModel {
        6.   things: Array<ThingModel> = [];
        7. 
         
        8.   constructor(things: Array<ThingModel>) {
        9.     this.things = things;
        10.   }
        11. 
         
        12.   async loadTasks(context: common.UIAbilityContext) {
        13.     let getJson = await context.resourceManager.getRawFileContent('default_tasks.json');
        14.     let textDecoderOptions: util.TextDecoderOptions = { ignoreBOM: true };
        15.     let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
        16.     let result = textDecoder.decodeToString(getJson, { stream: false });
        17.     this.things = JSON.parse(result);
        18.   }
        19. }
    
    

  * Index.ets
        
        1. import { common } from '@kit.AbilityKit';
            2. // import ViewModel
            3. import TodoListViewModel from '../viewModel/TodoListViewModel';
            4. 
           
            5. // import View
            6. import { TodoComponent } from '../views/TodoComponent';
            7. import { AllChooseComponent } from '../views/AllChooseComponent';
            8. import { TodoListComponent } from '../views/TodoListComponent';
            9. 
           
            10. @Entry
            11. @Component
            12. struct TodoList {
            13.   @State todoListViewModel: TodoListViewModel = new TodoListViewModel(); // View绑定ViewModel的数据
            14.   private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            15. 
           
            16.   async aboutToAppear() {
            17.     await this.todoListViewModel.loadTasks(this.context);
            18.   }
            19. 
           
            20.   build() {
            21.     Column() {
            22.       Row({ space: 40 }) {
            23.         // 全部待办
            24.         TodoComponent()
            25.         // 全选
            26.         AllChooseComponent({ todoListViewModel: this.todoListViewModel })
            27.       }
            28. 
           
            29.       Column() {
            30.         TodoListComponent({ thingViewModelArray: this.todoListViewModel.things })
            31.       }
            32.     }
            33.     .height('100%')
            34.     .width('100%')
            35.     .margin({ top: 5, bottom: 5 })
            36.     .backgroundColor('#90f1f3f5')
            37.   }
            38. }

    * AllChooseComponent.ets
        
        1. import TodoListViewModel from "../viewModel/TodoListViewModel";
            2. 
           
            3. @Component
            4. export struct AllChooseComponent {
            5.   @State titleName: string = '全选';
            6.   @Link todoListViewModel: TodoListViewModel;
            7. 
           
            8.   build() {
            9.     Row() {
            10.       Button(`${this.titleName}`, { type: ButtonType.Capsule })
            11.         .onClick(() => {
            12.           this.todoListViewModel.chooseAll(); // View层点击事件发生时，调用ViewModel层方法chooseAll处理逻辑
            13.           this.titleName = this.todoListViewModel.isChoosen ? '全选' : '取消全选';
            14.         })
            15.         .fontSize(30)
            16.         .fontWeight(FontWeight.Bold)
            17.         .backgroundColor('#f7f6cc74')
            18.     }
            19.     .padding({ left: this.todoListViewModel.isChoosen ? 15 : 0 })
            20.     .width('100%')
            21.     .margin({ top: 10, bottom: 10 })
            22.   }
            23. }

    * ThingComponent.ets
        
        1. import ThingViewModel from "../viewModel/ThingViewModel";
            2. 
           
            3. @Component
            4. export struct ThingComponent {
            5.   @ObjectLink thing: ThingViewModel;
            6. 
           
            7.   @Builder
            8.   displayIcon(icon: Resource) {
            9.     Image(icon)
            10.       .width(28)
            11.       .height(28)
            12.       .onClick(() => {
            13.         this.thing.updateIsFinish(); // View层点击事件发生时，调用ViewModel层方法updateIsFinish处理逻辑
            14.       })
            15.   }
            16. 
           
            17.   build() {
            18.     // 待办事项
            19.     Row({ space: 15 }) {
            20.       if (this.thing.isFinish) {
            21.         // 此处'app.media.finished'仅作示例，请开发者自行替换，否则imageSource创建失败会导致后续无法正常执行。
            22.         this.displayIcon($r('app.media.finished'));
            23.       } else {
            24.         // 此处'app.media.unfinished'仅作示例，请开发者自行替换，否则imageSource创建失败会导致后续无法正常执行。
            25.         this.displayIcon($r('app.media.unfinished'));
            26.       }
            27. 
           
            28.       Text(`${this.thing.thingName}`)
            29.         .fontSize(24)
            30.         .decoration({ type: this.thing.isFinish ? TextDecorationType.LineThrough : TextDecorationType.None })
            31.         .onClick(() => {
            32.           this.thing.addSuffixes(); // View层点击事件发生时，调用ViewModel层方法addSuffixes处理逻辑
            33.         })
            34.     }
            35.     .height('8%')
            36.     .width('90%')
            37.     .padding({ left: 15 })
            38.     .opacity(this.thing.isFinish ? 0.3 : 1)
            39.     .border({ width: 1 })
            40.     .borderColor(Color.White)
            41.     .borderRadius(25)
            42.     .backgroundColor(Color.White)
            43.   }
            44. }

    * TodoComponent.ets
        
        1. @Component
            2. export struct TodoComponent {
            3.   build() {
            4.     Row() {
            5.       Text('全部待办')
            6.         .fontSize(30)
            7.         .fontWeight(FontWeight.Bold)
            8.     }
            9.     .padding({ left: 15 })
            10.     .width('50%')
            11.     .margin({ top: 10, bottom: 10 })
            12.   }
            13. }

    * TodoListComponent.ets
        
        1. import ThingViewModel from "../viewModel/ThingViewModel";
            2. import { ThingViewModelArray } from "../viewModel/TodoListViewModel"
            3. import { ThingComponent } from "./ThingComponent";
            4. 
           
            5. @Component
            6. export struct TodoListComponent {
            7.   @ObjectLink thingViewModelArray: ThingViewModelArray;
            8. 
           
            9.   build() {
            10.     Column() {
            11.       List() {
            12.         ForEach(this.thingViewModelArray, (item: ThingViewModel) => {
            13.           // 待办事项
            14.           ListItem() {
            15.             ThingComponent({ thing: item })
            16.               .margin(5)
            17.           }
            18.         }, (item: ThingViewModel) => {
            19.           return item.thingName;
            20.         })
            21.       }
            22.     }
            23.   }
            24. }

    * ThingViewModel.ets
        
        1. import ThingModel from "../model/ThingModel";
            2. 
           
            3. @Observed
            4. export default class ThingViewModel {
            5.   @Track thingName: string = 'Todo';
            6.   @Track isFinish: boolean = false;
            7. 
           
            8.   updateTask(thing: ThingModel) {
            9.     this.thingName = thing.thingName;
            10.     this.isFinish = thing.isFinish;
            11.   }
            12. 
           
            13.   updateIsFinish(): void {
            14.     this.isFinish = !this.isFinish;
            15.   }
            16. 
           
            17.   addSuffixes(): void {
            18.     this.thingName += '啦';
            19.   }
            20. }

    * TodoListViewModel.ets
        
        1. import ThingViewModel from "./ThingViewModel";
            2. import { common } from "@kit.AbilityKit";
            3. import TodoListModel from "../model/TodoListModel";
            4. 
           
            5. @Observed
            6. export class ThingViewModelArray extends Array<ThingViewModel> {
            7. }
            8. 
           
            9. @Observed
            10. export default class TodoListViewModel {
            11.   @Track isChoosen: boolean = true;
            12.   @Track things: ThingViewModelArray = new ThingViewModelArray();
            13. 
           
            14.   async loadTasks(context: common.UIAbilityContext) {
            15.     let todoList = new TodoListModel([]);
            16.     await todoList.loadTasks(context);
            17.     for (let thing of todoList.things) {
            18.       let todoListViewModel = new ThingViewModel();
            19.       todoListViewModel.updateTask(thing);
            20.       this.things.push(todoListViewModel);
            21.     }
            22.   }
            23. 
           
            24.   chooseAll(): void {
            25.     for (let thing of this.things) {
            26.       thing.isFinish = this.isChoosen;
            27.     }
            28.     this.isChoosen = !this.isChoosen;
            29.   }
            30. }

    * default_tasks.json
        
        1. [
            2.   {"thingName": "7.30起床", "isFinish": false},
            3.   {"thingName": "8.30早餐", "isFinish": false},
            4.   {"thingName": "11.30中餐", "isFinish": false},
            5.   {"thingName": "17.30晚餐", "isFinish": false},
            6.   {"thingName": "21.30夜宵", "isFinish": false},
            7.   {"thingName": "22.30洗澡", "isFinish": false},
            8.   {"thingName": "1.30睡觉", "isFinish": false}
            9. ]

MVVM模式拆分后的代码结构更加清晰，模块职责更明确。新页面需要使用事件组件，比如TodoListComponent组件，只需导入组件。

效果图如下：

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107151634.05400207159316037371651743697879:50001231000000:2800:C1AA00E660BC22E2256E5A753E2F8336E35A811E8EF5DB31247E4EA459947EEF.gif)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 31. 从Java到ArkTS的迁移指导-面向其他语言的ArkTS迁移指导-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/getting-started-with-arkts-for-java-programmers

---

### 复杂数据类型 __

Java类型体系 | ArkTS类型体系 | ArkTS示例代码 | 核心差异说明  
---|---|---|---  
**数组** ：int[] arr = new int[5]; | **Array** ：let arr: Array<number> = [1, 2, 3]; |  // 固定长度初始化（类似Java） let fixedArr: number[] = new Array<number>(5); // 动态长度语法糖 let dynamicArr = [4, 5, 6]; |  Java数组长度固定。 ArkTS的Array是动态数组，支持push/pop等操作；可直接用[]简化初始化。数组不会越界，当数组下标超过数组长度时会得到undefined。  
**集合 - List** ：List<String> list = new ArrayList<>(); | **Array** ：let strList: Array<string> = ['a', 'b']; |  strList.push('c'); // 向数组末尾添加元素 let firstItem = strList[0]; // 索引访问 |  Java集合通过接口（如List）与实现类（如ArrayList）分离。 ArkTS数组兼具基础类型与集合特性，语法更简洁。  
**集合 - Map** ：Map<String, Integer> map = new HashMap<>(); | **Map** ：let map: Map<string, number> = new Map(); |  map.set('key', 1); // 添加键值对 let value = map.get('key'); // 获取值 map.has('key'); // 检查键是否存在 |  Java的Map需显式声明泛型类型。 ArkTS的Map操作更直接，支持链式调用（如map.set('a', 1).set('b', 2)）。  
**接口** ：interface Shape { double area(); } | **interface** ：interface Shapes { area(): number; } |  class Rectangles implements Shapes { public width: number = 0; public height: number = 0; area(): number { return this.width * this.height; } } | 语法结构相似，但ArkTS接口实现无需显式修饰符（如Java的public），且支持可选属性（如name?: string）。  
**类** ：class Circle implements Shape { /* 类定义 */ } | **class** ：class Circles implements Shape { /* 类定义 */ } |  class Circles { radius: number; constructor(radius: number = 10) { // 支持参数默认值 this.radius = radius; } } | ArkTS类支持属性默认值、可选参数，构造函数参数可直接声明为类属性（如constructor(public name: string)），语法更简洁。  
**枚举** ：enum Color { RED, GREEN, BLUE; } | **enum** ：enum Colors { Red, Green, Blue } |  enum Colors { Red = 1, Green, Blue }; let color = Colors.Green; // 值为2（自动递增） | 基本概念一致，但ArkTS枚举不支持Java中的自定义构造函数和方法，仅支持简单的数值或字符串枚举。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 32. task.h-头文件-C API-Function Flow Runtime Kit（任务并发调度服务）-基础功能-系统 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-references/capi-task-h

---

### 函数 ____  
  
支持设备PhonePC/2in1TabletTVWearable

名称 | 描述  
---|---  
[FFRT_C_API int ffrt_task_attr_init(ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_init) | 初始化任务属性。  
[FFRT_C_API void ffrt_task_attr_set_name(ffrt_task_attr_t* attr, const char* name)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_set_name) | 设置任务名字。  
[FFRT_C_API const char* ffrt_task_attr_get_name(const ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_get_name) | 获取任务名字。  
[FFRT_C_API void ffrt_task_attr_destroy(ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_destroy) | 销毁任务属性。  
[FFRT_C_API void ffrt_task_attr_set_qos(ffrt_task_attr_t* attr, ffrt_qos_t qos)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_set_qos) | 设置任务QoS。  
[FFRT_C_API ffrt_qos_t ffrt_task_attr_get_qos(const ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_get_qos) | 获取任务QoS。  
[FFRT_C_API void ffrt_task_attr_set_delay(ffrt_task_attr_t* attr, uint64_t delay_us)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_set_delay) | 设置任务延迟时间。  
[FFRT_C_API uint64_t ffrt_task_attr_get_delay(const ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_get_delay) | 获取任务延迟时间。  
[FFRT_C_API void ffrt_task_attr_set_queue_priority(ffrt_task_attr_t* attr, ffrt_queue_priority_t priority)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_set_queue_priority) | 设置并行队列任务优先级。  
[FFRT_C_API ffrt_queue_priority_t ffrt_task_attr_get_queue_priority(const ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_get_queue_priority) | 获取并行队列任务优先级。  
[FFRT_C_API void ffrt_task_attr_set_stack_size(ffrt_task_attr_t* attr, uint64_t size)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_set_stack_size) | 设置任务栈大小。  
[FFRT_C_API uint64_t ffrt_task_attr_get_stack_size(const ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_attr_get_stack_size) | 获取任务栈大小。  
[FFRT_C_API int ffrt_this_task_update_qos(ffrt_qos_t qos)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_this_task_update_qos) | 更新任务QoS。  
[FFRT_C_API ffrt_qos_t ffrt_this_task_get_qos(void)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_this_task_get_qos) | 获取任务QoS。  
[FFRT_C_API uint64_t ffrt_this_task_get_id(void)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_this_task_get_id) | 获取任务id。  
[FFRT_C_API void *ffrt_alloc_auto_managed_function_storage_base(ffrt_function_kind_t kind)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_alloc_auto_managed_function_storage_base) | 申请函数执行结构的内存。  
[FFRT_C_API void ffrt_submit_base(ffrt_function_header_t* f, const ffrt_deps_t* in_deps, const ffrt_deps_t* out_deps,const ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_submit_base) | 提交任务调度执行。  
[FFRT_C_API ffrt_task_handle_t ffrt_submit_h_base(ffrt_function_header_t* f, const ffrt_deps_t* in_deps,const ffrt_deps_t* out_deps, const ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_submit_h_base) | 提交任务调度执行并返回任务句柄。  
[FFRT_C_API void ffrt_submit_f(ffrt_function_t func, void* arg, const ffrt_deps_t* in_deps, const ffrt_deps_t* out_deps,const ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_submit_f) | 提交任务调度执行，是ffrt_submit_base接口的简化包装形式。该接口假定任务不需要销毁回调函数，给定的任务函数和参数被包装为通用任务结构，并将封装后的任务结构和其他参数传递给ffrt_submit_base接口。  
[FFRT_C_API ffrt_task_handle_t ffrt_submit_h_f(ffrt_function_t func, void* arg, const ffrt_deps_t* in_deps,const ffrt_deps_t* out_deps, const ffrt_task_attr_t* attr)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_submit_h_f) | 提交任务调度执行并返回任务句柄，是ffrt_submit_h_base接口的简化包装形式。该接口假定任务不需要销毁回调函数，给定的任务函数和参数被包装为通用任务结构，并将封装后的任务结构和其他参数传递给ffrt_submit_h_base接口。  
[FFRT_C_API uint32_t ffrt_task_handle_inc_ref(ffrt_task_handle_t handle)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_handle_inc_ref) | 增加任务句柄的引用数。  
[FFRT_C_API uint32_t ffrt_task_handle_dec_ref(ffrt_task_handle_t handle)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_handle_dec_ref) | 减少任务句柄的引用计数。  
[FFRT_C_API void ffrt_task_handle_destroy(ffrt_task_handle_t handle)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_task_handle_destroy) | 销毁任务句柄。  
[FFRT_C_API void ffrt_wait_deps(const ffrt_deps_t* deps)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_wait_deps) | 等待依赖的任务完成，当前任务开始执行。  
[FFRT_C_API void ffrt_wait(void)](/consumer/cn/doc/harmonyos-references/capi-task-h#ffrt_wait) | 等待之前所有提交任务完成，当前任务开始执行。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [安全](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/system-security-api)
- [网络](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/system-network-api)
- [基础功能](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/system-basicfun-api)
- [Basic Services Kit（基础服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/basic-services-api)
- [Desktop Extension Kit（桌面拓展服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/status-bar-extension-api)
- [Function Flow Runtime Kit（任务并发调度服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/function-flow-runtime-api)


---

## 33. @ohos.taskpool（启动任务池）-ArkTS API-ArkTS（方舟编程语言）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-taskpool

---

### 简单使用 __  
  
**示例一**
      
      1. // 支持普通函数、引用入参传递
        2. @Concurrent
        3. function printArgs(args: string): string {
        4.   console.info("func: " + args);
        5.   return args;
        6. }
        7. 
         
        8. async function taskpoolExecute(): Promise<void> {
        9.   // taskpool.execute(task)
        10.   let task: taskpool.Task = new taskpool.Task(printArgs, "create task, then execute");
        11.   console.info("taskpool.execute(task) result: " + await taskpool.execute(task));
        12.   // taskpool.execute(function)
        13.   console.info("taskpool.execute(function) result: " + await taskpool.execute(printArgs, "execute task by func"));
        14. }
        15. 
         
        16. taskpoolExecute();
    
    

**示例二**
      
      1. // b.ets
        2. export let c: string = "hello";
    
    
      
      1. // 引用import变量
        2. // a.ets(与b.ets位于同一目录中)
        3. import { c } from "./b";
        4. 
         
        5. @Concurrent
        6. function printArgs(a: string): string {
        7.   console.info(a);
        8.   console.info(c);
        9.   return a;
        10. }
        11. 
         
        12. async function taskpoolExecute(): Promise<void> {
        13.   // taskpool.execute(task)
        14.   let task: taskpool.Task = new taskpool.Task(printArgs, "create task, then execute");
        15.   console.info("taskpool.execute(task) result: " + await taskpool.execute(task));
        16. 
         
        17.   // taskpool.execute(function)
        18.   console.info("taskpool.execute(function) result: " + await taskpool.execute(printArgs, "execute task by func"));
        19. }
        20. 
         
        21. taskpoolExecute();
    
    

**示例三**
      
      1. // 支持async函数
        2. @Concurrent
        3. async function delayExecute(): Promise<Array<Object>> {
        4.   let ret = await Promise.all<Object>([
        5.     new Promise<Object>(resolve => setTimeout(resolve, 1000, "resolved"))
        6.   ]);
        7.   return ret;
        8. }
        9. 
         
        10. async function taskpoolExecute(): Promise<void> {
        11.   taskpool.execute(delayExecute).then((result: Object) => {
        12.     console.info("taskPoolTest task result: " + result);
        13.   }).catch((err: string) => {
        14.     console.error("taskpool test occur error: " + err);
        15.   });
        16. }
        17. 
         
        18. taskpoolExecute();
    
    

**示例四**
      
      1. // c.ets
        2. @Concurrent
        3. function strSort(inPutArr: Array<string>): Array<string> {
        4.   let newArr = inPutArr.sort();
        5.   return newArr;
        6. }
        7. 
         
        8. export async function func1(): Promise<void> {
        9.   console.info("taskpoolTest start");
        10.   let strArray: Array<string> = ['c test string', 'b test string', 'a test string'];
        11.   let task: taskpool.Task = new taskpool.Task(strSort, strArray);
        12.   console.info("func1 result:" + await taskpool.execute(task));
        13. }
        14. 
         
        15. export async function func2(): Promise<void> {
        16.   console.info("taskpoolTest2 start");
        17.   let strArray: Array<string> = ['c test string', 'b test string', 'a test string'];
        18.   taskpool.execute(strSort, strArray).then((result: Object) => {
        19.     console.info("func2 result: " + result);
        20.   }).catch((err: string) => {
        21.     console.error("taskpool test occur error: " + err);
        22.   });
        23. }
    
    
      
      1. // index.ets
        2. import { func1, func2 } from "./c";
        3. 
         
        4. func1();
        5. func2();
    
    

**示例五**
      
      1. // 任务取消成功
        2. @Concurrent
        3. function inspectStatus(arg: number): number {
        4.   // 第一次检查任务是否已经取消并作出响应
        5.   if (taskpool.Task.isCanceled()) {
        6.     console.info("task has been canceled before 2s sleep.");
        7.     return arg + 2;
        8.   }
        9.   // 2s sleep
        10.   let t: number = Date.now();
        11.   while (Date.now() - t < 2000) {
        12.     continue;
        13.   }
        14.   // 第二次检查任务是否已经取消并作出响应
        15.   if (taskpool.Task.isCanceled()) {
        16.     console.info("task has been canceled after 2s sleep.");
        17.     return arg + 3;
        18.   }
        19.   return arg + 1;
        20. }
        21. 
         
        22. async function taskpoolCancel(): Promise<void> {
        23.   let task: taskpool.Task = new taskpool.Task(inspectStatus, 100); // 100: test number
        24.   taskpool.execute(task).then((res: Object) => {
        25.     console.info("taskpool test result: " + res);
        26.   }).catch((err: string) => {
        27.     console.error("taskpool test occur error: " + err);
        28.   });
        29.   // 1s后取消task
        30.   setTimeout(() => {
        31.     try {
        32.       taskpool.cancel(task);
        33.     } catch (e) {
        34.       console.error(`taskpool: cancel error code: ${e.code}, info: ${e.message}`);
        35.     }
        36.   }, 1000);
        37. }
        38. 
         
        39. taskpoolCancel();
    
    

**示例六**
      
      1. // 已执行的任务取消失败
        2. @Concurrent
        3. function inspectStatus(arg: number): number {
        4.   // 第一次检查任务是否已经取消并作出响应
        5.   if (taskpool.Task.isCanceled()) {
        6.     return arg + 2;
        7.   }
        8.   // 延时0.5s
        9.   let t: number = Date.now();
        10.   while (Date.now() - t < 500) {
        11.     continue;
        12.   }
        13.   // 第二次检查任务是否已经取消并作出响应
        14.   if (taskpool.Task.isCanceled()) {
        15.     return arg + 3;
        16.   }
        17.   return arg + 1;
        18. }
        19. 
         
        20. async function taskpoolCancel(): Promise<void> {
        21.   let task: taskpool.Task = new taskpool.Task(inspectStatus, 100); // 100: test number
        22.   taskpool.execute(task).then((res: Object) => {
        23.     console.info("taskpool test result: " + res);
        24.   }).catch((err: string) => {
        25.     console.error("taskpool test occur error: " + err);
        26.   });
        27. 
         
        28.   setTimeout(() => {
        29.     try {
        30.       taskpool.cancel(task); // 任务已执行,取消失败
        31.     } catch (e) {
        32.       console.error(`taskpool: cancel error code: ${e.code}, info: ${e.message}`);
        33.     }
        34.   }, 3000); // 延时3s，确保任务已执行
        35. }
        36. 
         
        37. taskpoolCancel();
    
    

**示例七**
      
      1. // 待执行的任务组取消成功
        2. @Concurrent
        3. function printArgs(args: number): number {
        4.   let t: number = Date.now();
        5.   while (Date.now() - t < 1000) {
        6.     continue;
        7.   }
        8.   console.info("printArgs: " + args);
        9.   return args;
        10. }
        11. 
         
        12. async function taskpoolGroupCancelTest(): Promise<void> {
        13.   let taskGroup1: taskpool.TaskGroup = new taskpool.TaskGroup();
        14.   taskGroup1.addTask(printArgs, 10); // 10: test number
        15.   taskGroup1.addTask(printArgs, 20); // 20: test number
        16.   taskGroup1.addTask(printArgs, 30); // 30: test number
        17.   let taskGroup2: taskpool.TaskGroup = new taskpool.TaskGroup();
        18.   let task1: taskpool.Task = new taskpool.Task(printArgs, 100); // 100: test number
        19.   let task2: taskpool.Task = new taskpool.Task(printArgs, 200); // 200: test number
        20.   let task3: taskpool.Task = new taskpool.Task(printArgs, 300); // 300: test number
        21.   taskGroup2.addTask(task1);
        22.   taskGroup2.addTask(task2);
        23.   taskGroup2.addTask(task3);
        24.   taskpool.execute(taskGroup1).then((res: Array<Object>) => {
        25.     console.info("taskpool execute res is:" + res);
        26.   }).catch((e: string) => {
        27.     console.error("taskpool execute error is:" + e);
        28.   });
        29.   taskpool.execute(taskGroup2).then((res: Array<Object>) => {
        30.     console.info("taskpool execute res is:" + res);
        31.   }).catch((e: string) => {
        32.     console.error("taskpool execute error is:" + e);
        33.   });
        34. 
         
        35.   try {
        36.     taskpool.cancel(taskGroup2);
        37.   } catch (e) {
        38.     console.error(`taskpool: cancel error code: ${e.code}, info: ${e.message}`);
        39.   }
        40. }
        41. 
         
        42. taskpoolGroupCancelTest()
    
    

**示例八**
      
      1. // 分别创建执行100个高、中、低优先级的任务，查看其各项信息
        2. @Concurrent
        3. function delay(): void {
        4.   let start: number = new Date().getTime();
        5.   while (new Date().getTime() - start < 500) {
        6.     continue;
        7.   }
        8. }
        9. 
         
        10. let highCount: number = 0;
        11. let mediumCount: number = 0;
        12. let lowCount: number = 0;
        13. let allCount: number = 100;
        14. for (let i = 0; i < allCount; i++) {
        15.   let task1: taskpool.Task = new taskpool.Task(delay);
        16.   let task2: taskpool.Task = new taskpool.Task(delay);
        17.   let task3: taskpool.Task = new taskpool.Task(delay);
        18.   taskpool.execute(task1, taskpool.Priority.LOW).then(() => {
        19.     lowCount++;
        20.   }).catch((e: string) => {
        21.     console.error("low task error: " + e);
        22.   })
        23.   taskpool.execute(task2, taskpool.Priority.MEDIUM).then(() => {
        24.     mediumCount++;
        25.   }).catch((e: string) => {
        26.     console.error("medium task error: " + e);
        27.   })
        28.   taskpool.execute(task3, taskpool.Priority.HIGH).then(() => {
        29.     highCount++;
        30.   }).catch((e: string) => {
        31.     console.error("high task error: " + e);
        32.   })
        33. }
        34. let start: number = new Date().getTime();
        35. while (new Date().getTime() - start < 1000) {
        36.   continue;
        37. }
        38. let taskpoolInfo: taskpool.TaskPoolInfo = taskpool.getTaskPoolInfo();
        39. let tid: number = 0;
        40. let taskIds: Array<number> = [];
        41. let priority: number = 0;
        42. let taskId: number = 0;
        43. let state: number = 0;
        44. let duration: number = 0;
        45. let name: string = "";
        46. let threadIS = Array.from(taskpoolInfo.threadInfos);
        47. for (let threadInfo of threadIS) {
        48.   tid = threadInfo.tid;
        49.   if (threadInfo.taskIds != undefined && threadInfo.priority != undefined) {
        50.     taskIds.length = threadInfo.taskIds.length;
        51.     priority = threadInfo.priority;
        52.   }
        53.   console.info("taskpool---tid is:" + tid + ", taskIds is:" + taskIds + ", priority is:" + priority);
        54. }
        55. let taskIS = Array.from(taskpoolInfo.taskInfos);
        56. for (let taskInfo of taskIS) {
        57.   taskId = taskInfo.taskId;
        58.   state = taskInfo.state;
        59.   if (taskInfo.duration != undefined) {
        60.     duration = taskInfo.duration;
        61.     name = taskInfo.name;
        62.   }
        63.   console.info("taskpool---taskId is:" + taskId + ", state is:" + state + ", duration is:" + duration + ", name is:" + name);
        64. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ability-api)
- [Accessibility Kit（无障碍服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/accessibility-api)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-api)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-api)
- [ArkTS API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-arkts)
- [@arkts.collections (ArkTS容器集)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-arkts-collections)


---

## 34. oh_predicates.h-头文件-C API-ArkData（方舟数据管理）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-references/capi-oh-predicates-h

---

### 函数 ____

支持设备PhonePC/2in1TabletTVWearable

名称 | 描述  
---|---  
[int OH_Predicates_NotLike(OH_Predicates *predicates, const char *field, const char *pattern)](/consumer/cn/doc/harmonyos-references/capi-oh-predicates-h#oh_predicates_notlike) | 设置OH_Predicates以匹配数据类型为字符串且值不类似于指定值的字段。 此方法类似于SQL语句中的“Not like”。  
[int OH_Predicates_Glob(OH_Predicates *predicates, const char *field, const char *pattern)](/consumer/cn/doc/harmonyos-references/capi-oh-predicates-h#oh_predicates_glob) | 设置OH_Predicates以匹配指定字段（数据类型为字符串）且值包含通配符的字段。 与like方法不同，此方法的输入参数区分大小写。  
[int OH_Predicates_NotGlob(OH_Predicates *predicates, const char *field, const char *pattern)](/consumer/cn/doc/harmonyos-references/capi-oh-predicates-h#oh_predicates_notglob) | 设置OH_Predicates以不匹配指定字段（数据类型为字符串）且值包含通配符的字段。 与Not Like方法不同，此方法的输入参数区分大小写。  
[int OH_Predicates_Having(OH_Predicates *predicates, const char *conditions, const OH_Data_Values *values)](/consumer/cn/doc/harmonyos-references/capi-oh-predicates-h#oh_predicates_having) | 设置OH_Predicates以指定条件来过滤分组结果，这些结果将出现在最终结果中。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ability-api)
- [Accessibility Kit（无障碍服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/accessibility-api)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-api)
- [ArkTS API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-arkts)
- [ArkTS组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-comp)
- [C API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-c)


---

## 35. 单元测试框架使用指导-自动化测试框架使用指导-单元测试和UI测试-应用测试 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/unittest-guidelines

---

### Mock能力 __  
  
从@ohos/hypium 1.0.1版本开始，单元测试框架支持Mock能力。配置方式参考上文[发布方式](/consumer/cn/doc/harmonyos-guides/unittest-guidelines#单元测试框架发布方式)。

说明

仅支持Mock应用工程中自定义对象，不支持Mock系统API对象。如需Mock系统API，请参考[系统模块Mock指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-test-mock#section8353132513310)。

不支持Mock对象的私有函数。 

**基础类**

Mockit是Mock的基础类，用于指定需要Mock的实例和函数。

接口名 | 功能说明  
---|---  
mockFunc | Mock某个类实例中的函数，支持使用异步函数。  
verify | 验证函数在对应参数下的执行行为是否符合预期，返回一个VerificationMode类。  
ignoreMock | 使用ignoreMock可以还原实例中被Mock后的函数，对被Mock后的函数有效。  
clear | 用例执行完毕后，对被Mock对象实例进行还原处理（还原之后对象恢复被Mock之前的功能）。  
clearAll | 用例执行完毕后，进行数据和内存清理，不会还原实例中被Mock后的函数。  
  
**VerificationMode**

VerificationMode用于验证被Mock函数的被调用次数，需同verify函数结合使用。

接口名 | 功能说明  
---|---  
times | 验证函数被调用过的次数符合预期。  
once | 验证函数被调用过一次。  
atLeast | 验证函数最少被调用的次数符合预期。  
atMost | 验证函数最多被调用的次数符合预期。  
never | 验证函数从未被调用过。  
  
**when**

when是一个函数，用于设置函数期望被Mock的值。

接口名 | 功能说明  
---|---  
when | 对传入后函数做检查，检查是否被Mock并标记过，返回一个内置函数，函数执行后返回一个类用于设置Mock值。  
  
使用when函数之后，需使用如下函数设置函数被Mock后的返回值。

接口名 | 功能说明  
---|---  
afterReturn | 设定一个自定义的期望返回值，比如某个字符串或者一个Promise。  
afterReturnNothing | 设定预期没有返回值，即undefined。  
afterAction | 设定预期返回一个函数执行的操作。  
afterThrow | 设定预期抛出异常，并指定异常描述信息。  
  
**ArgumentMatchers相关接口**

ArgumentMatchers用于用户自定义函数参数，当开发者想基于某类规则设定预期返回值时，可以使用。它以枚举值或函数的形式提供给开发者使用。

枚举名 | 功能说明  
---|---  
any | 设定用户传任何类型参数（undefined和null除外），执行的结果返回所设置的预期值，使用ArgumentMatchers.any方式调用。  
anyString | 设定用户传任何字符串参数，执行的结果都是预期的值，使用ArgumentMatchers.anyString方式调用。  
anyBoolean | 设定用户传任何boolean类型参数，执行的结果都是预期的值，使用ArgumentMatchers.anyBoolean方式调用。  
anyFunction | 设定用户传任何function类型参数，执行的结果都是预期的值，使用ArgumentMatchers.anyFunction方式调用。  
anyNumber | 设定用户传任何数字类型参数，执行的结果都是预期的值，使用ArgumentMatchers.anyNumber方式调用。  
anyObj | 设定用户传任何对象类型参数，执行的结果都是预期的值，使用ArgumentMatchers.anyObj方式调用。  
  
接口名 | 功能说明  
---|---  
matchRegexs | 设定用户传任何符合正则表达式验证的参数，执行的结果都是预期的值，使用ArgumentMatchers.matchRegexs(Regex)方式调用。  
  
说明

使用Mock能力时必须导入Mock能力模块： MockKit，when，开发者可根据实际需求导入对应模块。

例如：import { describe, expect, it, MockKit, when} from '@ohos/hypium'

**示例代码1** ：使用afterReturn/afterReturnNothing设置预期返回值
      
      1. import { describe, expect, it, MockKit, when } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   method_1(arg: string) {
        8.     return '888888';
        9.   }
        10. 
         
        11.   method_2(arg: string) {
        12.     return '999999';
        13.   }
        14. }
        15. export default function afterReturnTest() {
        16.   describe('afterReturnTest', () => {
        17.     it('afterReturnTest', 0, () => {
        18.       console.info("it1 begin");
        19.       // 创建一个Mock能力的对象MockKit
        20.       let mocker: MockKit = new MockKit();
        21.       // 初始化ClassName的对象claser，作为被Mock的对象实例
        22.       let claser: ClassName = new ClassName();
        23.       // 进行Mock操作，对ClassName类的method_1函数进行Mock
        24.       let mockfunc: Function = mocker.mockFunc(claser, claser.method_1);
        25.       // 期望claser.method_1函数被Mock后, 以'testA'为入参时调用函数返回结果'1',以'testB''为入参时调用函数返回结果undefined
        26.       when(mockfunc)('testA').afterReturn('1');
        27.       when(mockfunc)('testB').afterReturnNothing();
        28.       // 对Mock后的函数进行断言，看是否符合预期。分别传入参数'testA'和'testB'时，应该返回自定义的预期结果1和undefined
        29.       expect(claser.method_1('testA')).assertEqual('1'); // 断言执行通过
        30.       expect(claser.method_1('testB')).assertUndefined(); // 断言执行通过
        31.     })
        32.   })
        33. }
    
    

**示例代码2** ：使用ArgumentMatchers设定参数类型为any即接受任何参数（undefined和null除外）
      
      1. import { describe, expect, it, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   method_1(arg: string) {
        8.     return '888888';
        9.   }
        10. 
         
        11.   method_2(arg: string) {
        12.     return '999999';
        13.   }
        14. }
        15. export default function argumentMatchersAnyTest() {
        16.   describe('argumentMatchersAnyTest', () => {
        17.     it('testMockfunc', 0, () => {
        18.       console.info("it1 begin");
        19.       // 创建一个Mock能力的对象MockKit
        20.       let mocker: MockKit = new MockKit();
        21.       // 初始化ClassName的对象claser
        22.       let claser: ClassName = new ClassName();
        23.       // 进行Mock操作，对ClassName类的method_1函数进行Mock
        24.       let mockfunc: Function = mocker.mockFunc(claser, claser.method_1);
        25.       // 期望claser.method_1函数被Mock后, 参数为任一类型在被调用时均返回结果'1'
        26.       when(mockfunc)(ArgumentMatchers.any).afterReturn('1');
        27.       // 传入不同参数验证是否符合预期
        28.       expect(claser.method_1('test')).assertEqual('1'); // 断言执行通过
        29.       expect(claser.method_1("123")).assertEqual('1');// 断言执行通过
        30.       expect(claser.method_1("true")).assertEqual('1');// 断言执行通过
        31.     })
        32.   })
        33. }
    
    

**示例代码3** ：使用ArgumentMatchers设定参数类型为String
      
      1. import { describe, expect, it, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   method_1(arg: string) {
        8.     return '888888';
        9.   }
        10. 
         
        11.   method_2(arg: string) {
        12.     return '999999';
        13.   }
        14. }
        15. export default function argumentMatchersTest() {
        16.   describe('argumentMatchersTest', () => {
        17.     it('testMockfunc', 0, () => {
        18.       console.info("it1 begin");
        19.       // 创建一个Mock能力的对象MockKit
        20.       let mocker: MockKit = new MockKit();
        21.       // 初始化ClassName的对象claser
        22.       let claser: ClassName = new ClassName();
        23.       // 进行Mock操作,对ClassName类的method_1函数进行Mock
        24.       let mockfunc: Function = mocker.mockFunc(claser, claser.method_1);
        25.       // 期望claser.method_1函数被Mock后, 以任何string类型为参数调用函数时返回结果'1'
        26.       when(mockfunc)(ArgumentMatchers.anyString).afterReturn('1');
        27.       // 传入不同string类型参数，验证是否符合预期
        28.       expect(claser.method_1('test')).assertEqual('1'); // 断言执行通过
        29.       expect(claser.method_1('abc')).assertEqual('1'); // 断言执行通过
        30.     })
        31.   })
        32. }
    
    

**示例代码4** ：使用ArgumentMatchers设定参数类型为matchRegexs（Regex）即正则表达式
      
      1. import { describe, expect, it, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   method_1(arg: string) {
        8.     return '888888';
        9.   }
        10. 
         
        11.   method_2(arg: string) {
        12.     return '999999';
        13.   }
        14. }
        15. export default function matchRegexsTest() {
        16.   describe('matchRegexsTest', () => {
        17.     it('testMockfunc', 0, () => {
        18.       console.info("it1 begin");
        19.       // 创建一个Mock能力的对象MockKit
        20.       let mocker: MockKit = new MockKit();
        21.       // 初始化ClassName的对象claser
        22.       let claser: ClassName = new ClassName();
        23.       // 进行Mock操作，对ClassName类的method_1函数进行Mock
        24.       let mockfunc: Function = mocker.mockFunc(claser, claser.method_1);
        25.       // 期望claser.method_1函数被Mock后, 以"test"为入参调用函数时返回结果'1'
        26.       when(mockfunc)(ArgumentMatchers.matchRegexs(new RegExp("test"))).afterReturn('1');
        27.       // 传入test参数后验证是否符合预期
        28.       expect(claser.method_1('test')).assertEqual('1'); // 断言执行通过
        29.     })
        30.   })
        31. }
    
    

**示例代码5** ：使用verify函数验证被Mock函数在对应参数下的执行行为是否符合预期
      
      1. import { describe, it, MockKit } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   method_1(...arg: string[]) {
        8.     return '888888';
        9.   }
        10. 
         
        11.   method_2(...arg: string[]) {
        12.     return '999999';
        13.   }
        14. }
        15. export default function verifyTest() {
        16.   describe('verifyTest', () => {
        17.     it('testMockfunc', 0, () => {
        18.       console.info("it1 begin");
        19.       // 创建一个Mock能力的对象MockKit
        20.       let mocker: MockKit = new MockKit();
        21.       // 初始化ClassName的对象claser
        22.       let claser: ClassName = new ClassName();
        23.       // 进行Mock操作，对ClassName类的method_1和method_2两个函数进行Mock
        24.       mocker.mockFunc(claser, claser.method_1);
        25.       mocker.mockFunc(claser, claser.method_2);
        26.       // 函数调用
        27.       claser.method_1('abc', 'ppp');
        28.       claser.method_1('abc');
        29.       claser.method_1('xyz');
        30.       claser.method_1();
        31.       claser.method_1('abc', 'xxx', 'yyy');
        32.       claser.method_1();
        33.       claser.method_2('111');
        34.       claser.method_2('111', '222');
        35.       // 对Mock后的两个函数进行验证，验证method_2,参数仅为'111'时执行过一次
        36.       mocker.verify('method_2',['111']).once(); // 断言执行通过
        37.     })
        38.   })
        39. }
    
    

**示例代码6** ：使用ignoreMock函数还原指定被Mock函数实现
      
      1. import { describe, expect, it, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   method_1(...arg: number[]) {
        8.     return '888888';
        9.   }
        10. 
         
        11.   method_2(...arg: number[]) {
        12.     return '999999';
        13.   }
        14. }
        15. export default function ignoreMockTest() {
        16.   describe('ignoreMockTest', () => {
        17.     it('testMockfunc', 0, () => {
        18.       console.info("it1 begin");
        19.       // 创建一个Mock能力的对象MockKit
        20.       let mocker: MockKit = new MockKit();
        21.       // 初始化ClassName的对象claser
        22.       let claser: ClassName = new ClassName();
        23.       // 进行Mock操作，对ClassName类的method_1和method_2两个函数进行Mock
        24.       let func_1: Function = mocker.mockFunc(claser, claser.method_1);
        25.       let func_2: Function = mocker.mockFunc(claser, claser.method_2);
        26.       // 期望claser.method_1函数被Mock后, 以number类型为入参时调用函数返回结果'4'
        27.       when(func_1)(ArgumentMatchers.anyNumber).afterReturn('4');
        28.       // 期望claser.method_2函数被Mock后, 以number类型为入参时调用函数返回结果'5'
        29.       when(func_2)(ArgumentMatchers.anyNumber).afterReturn('5');
        30.       // 函数调用
        31.       expect(claser.method_1(123)).assertEqual("4");
        32.       expect(claser.method_2(456)).assertEqual("5");
        33.       // 现在对Mock后的两个函数的其中一个函数method_1进行还原处理
        34.       mocker.ignoreMock(claser, claser.method_1);
        35.       // 调用claser.method_1函数
        36.       expect(claser.method_1(123)).assertEqual('888888');// 断言执行通过
        37.     })
        38.   })
        39. }
    
    

**示例代码7** ：使用clear函数还原类中所有被Mock函数原有实现
      
      1. import { describe, expect, it, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   method_1(...arg: number[]) {
        8.     return '888888';
        9.   }
        10. 
         
        11.   method_2(...arg: number[]) {
        12.     return '999999';
        13.   }
        14. }
        15. export default function clearTest() {
        16.   describe('clearTest', () => {
        17.     it('testMockfunc', 0, () => {
        18.       console.info("it1 begin");
        19.       // 创建一个Mock能力的对象MockKit
        20.       let mocker: MockKit = new MockKit();
        21.       // 初始化ClassName的对象claser
        22.       let claser: ClassName = new ClassName();
        23.       // 进行Mock操作，对ClassName类的method_1和method_2两个函数进行Mock
        24.       let func_1: Function = mocker.mockFunc(claser, claser.method_1);
        25.       let func_2: Function = mocker.mockFunc(claser, claser.method_2);
        26.       // 期望claser.method_1函数被Mock后, 以任何number类型为参数调用函数时返回结果'4'
        27.       when(func_1)(ArgumentMatchers.anyNumber).afterReturn('4');
        28.       // 期望claser.method_2函数被Mock后, 以任何number类型为参数调用函数时返回结果'5'
        29.       when(func_2)(ArgumentMatchers.anyNumber).afterReturn('5');
        30.       // 函数调用
        31.       expect(claser.method_1(123)).assertEqual('4');
        32.       expect(claser.method_2(123)).assertEqual('5');
        33.       // 还原obj上所有的Mock能力
        34.       mocker.clear(claser);
        35.       // 调用claser.method_1,claser.method_2函数，测试结果
        36.       expect(claser.method_1(123)).assertEqual('888888');// 断言执行通过
        37.       expect(claser.method_2(123)).assertEqual('999999');// 断言执行通过
        38.     })
        39.   })
        40. }
    
    

**示例代码8** ：使用afterThrow函数抛出指定异常信息
      
      1. import { describe, expect, it, MockKit, when } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   method_1(arg: string) {
        8.     return '888888';
        9.   }
        10. }
        11. export default function afterThrowTest() {
        12.   describe('afterThrowTest', () => {
        13.     it('testMockfunc', 0, () => {
        14.       console.info("it1 begin");
        15.       // 创建一个Mock能力的对象MockKit
        16.       let mocker: MockKit = new MockKit();
        17.       // 初始化ClassName的对象claser
        18.       let claser: ClassName = new ClassName();
        19.       // 进行Mock操作,对ClassName类的method_1函数进行Mock
        20.       let mockfunc: Function = mocker.mockFunc(claser, claser.method_1);
        21.       // 期望claser.method_1函数被Mock后, 以'test'为参数调用函数时抛出error xxx异常
        22.       when(mockfunc)('test').afterThrow('error xxx');
        23.       // 执行Mock后的函数，捕捉异常并使用assertEqual对比msg否符合预期
        24.       try {
        25.         claser.method_1('test');
        26.       } catch (e) {
        27.         expect(e).assertEqual('error xxx'); // 断言执行通过
        28.       }
        29.     })
        30.   })
        31. }
    
    

**示例代码9** ：Mock异步返回Promise对象
      
      1. import { describe, expect, it, MockKit, when } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   async method_1(arg: string) {
        8.     return new Promise<string>((resolve: Function, reject: Function) => {
        9.       setTimeout(() => {
        10.         console.log('执行');
        11.         resolve('数据传递');
        12.       }, 2000);
        13.     });
        14.   }
        15. }
        16. export default function mockPromiseTest() {
        17.   describe('mockPromiseTest', () => {
        18.     it('testMockfunc', 0, async (done: Function) => {
        19.       console.info("it1 begin");
        20.       // 创建一个Mock能力的对象MockKit
        21.       let mocker: MockKit = new MockKit();
        22.       // 初始化ClassName的对象claser
        23.       let claser: ClassName = new ClassName();
        24.       // 进行Mock操作对ClassName类的method_1函数进行Mock
        25.       let mockfunc: Function = mocker.mockFunc(claser, claser.method_1);
        26.       // 期望claser.method_1函数被Mock后, 以'test'为参数调用函数时返回一个Promise对象
        27.       when(mockfunc)('test').afterReturn(new Promise<string>((resolve: Function, reject: Function) => {
        28.         console.log("do something");
        29.         resolve('success something');
        30.       }));
        31.       // 执行Mock后的函数，即对定义的Promise进行后续执行
        32.       let result = await claser.method_1('test');
        33.       expect(result).assertEqual("success something");// 断言执行通过
        34.       done();
        35.     })
        36.   })
        37. }
    
    

**示例代码10** ：使用times/atLeast函数验证被Mock函数调用次数
      
      1. import { describe, it, MockKit, when } from '@ohos/hypium'
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   method_1(...arg: string[]) {
        8.     return '888888';
        9.   }
        10. }
        11. export default function verifyTimesTest() {
        12.   describe('verifyTimesTest', () => {
        13.     it('test_verify_times', 0, () => {
        14.       // 创建一个Mock能力的对象MockKit
        15.       let mocker: MockKit = new MockKit();
        16.       // 初始化ClassName的对象claser
        17.       let claser: ClassName = new ClassName();
        18.       // 进行Mock操作对ClassName类的method_1函数进行Mock
        19.       let func_1: Function = mocker.mockFunc(claser, claser.method_1);
        20.       // 期望被Mock后的函数返回结果'4'
        21.       when(func_1)('123').afterReturn('4');
        22.       // 函数调用
        23.       claser.method_1('123', 'ppp');
        24.       claser.method_1('abc');
        25.       claser.method_1('xyz');
        26.       claser.method_1();
        27.       claser.method_1('abc', 'xxx', 'yyy');
        28.       claser.method_1('abc');
        29.       claser.method_1();
        30.       // 验证函数method_1且参数为'abc'时，执行过的次数是否为2
        31.       mocker.verify('method_1', ['abc']).times(2);// 断言执行通过
        32.        // 验证函数method_1且参数为空时，是否至少执行过2次
        33.       mocker.verify('method_1', []).atLeast(2);// 断言执行通过
        34.     })
        35.   })
        36. }
    
    

**示例代码11** ：Mock静态函数（从@ohos/hypium 1.0.16版本开始支持）
      
      1. import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
        2. 
         
        3. class ClassName {
        4.   constructor() {
        5.   }
        6. 
         
        7.   static method_1() {
        8.     return 'ClassName_method_1_call';
        9.   }
        10. }
        11. 
         
        12. export default function staticTest() {
        13.   describe('staticTest', () => {
        14.     it('staticTest_001', 0, () => {
        15.       let really_result = ClassName.method_1();
        16.       expect(really_result).assertEqual('ClassName_method_1_call');
        17.       // 创建MockKit对象
        18.       let mocker: MockKit = new MockKit();
        19.       // Mock类ClassName对象的某个函数method_1
        20.       let func_1: Function = mocker.mockFunc(ClassName, ClassName.method_1);
        21.       // 期望被mock后的函数返回结果'mock_data'
        22.       when(func_1)(ArgumentMatchers.any).afterReturn('mock_data');
        23.       let mock_result = ClassName.method_1();
        24.       expect(mock_result).assertEqual('mock_data');// 断言执行通过
        25.       // 清除Mock能力
        26.       mocker.clear(ClassName);
        27.       let really_result1 = ClassName.method_1();
        28.       expect(really_result1).assertEqual('ClassName_method_1_call');// 断言执行通过
        29.     })
        30.   })
        31. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用测试概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/app-testing-overview)
- [单元测试和UI测试](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ut)
- [自动化测试框架使用指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkxtest-guidelines)
- [单元测试框架使用指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/unittest-guidelines)
- [UI测试框架使用指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/uitest-guidelines)
- [白盒性能测试框架使用指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/perftest-guideline)


---

## 36. OH_Predicates-结构体-C API-ArkData（方舟数据管理）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates

---

### 成员函数 ____

支持设备PhonePC/2in1TabletTVWearable

名称 | 描述  
---|---  
[OH_Predicates *(*equalTo)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#equalto) | 函数指针，配置谓词以匹配数据字段等于指定值的字段。  
[OH_Predicates *(*notEqualTo)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#notequalto) | 函数指针，配置谓词以匹配数据字段不等于指定值的字段。 该方法等同于SQL语句中的“!=”。  
[OH_Predicates *(*beginWrap)(OH_Predicates *predicates)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#beginwrap) | 函数指针，向谓词添加左括号。 该方法等同于SQL语句中的“(”。  
[OH_Predicates *(*endWrap)(OH_Predicates *predicates)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#endwrap) | 函数指针，向谓词添加右括号。 该方法等同于SQL语句中的“)”。  
[OH_Predicates *(*orOperate)(OH_Predicates *predicates)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#oroperate) | 函数指针，将或条件添加到谓词中。 该方法等同于SQL语句中的“OR”。  
[OH_Predicates *(*andOperate)(OH_Predicates *predicates)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#andoperate) | 函数指针，向谓词添加和条件。 该方法等同于SQL语句中的“AND”。  
[OH_Predicates *(*isNull)(OH_Predicates *predicates, const char *field)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#isnull) | 函数指针，配置谓词以匹配值为null的字段。 该方法等同于SQL语句中的“IS NULL”。  
[OH_Predicates *(*isNotNull)(OH_Predicates *predicates, const char *field)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#isnotnull) | 函数指针，配置谓词以匹配值不为null的指定字段。 该方法等同于SQL语句中的“IS NOT NULL”。  
[OH_Predicates *(*like)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#like) | 函数指针，配置谓词以匹配数据字段为field且值类似于指定字符串的字段。 该方法等同于SQL语句中的“LIKE”。  
[OH_Predicates *(*between)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#between) | 函数指针，将谓词配置为匹配数据字段为field且其值在给定范围内的指定字段。 该方法等同于SQL语句中的“BETWEEN”。  
[OH_Predicates *(*notBetween)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#notbetween) | 函数指针，将谓词配置为匹配数据字段为field且其值超出给定范围内的指定字段。 该方法等同于SQL语句中的“NOT BETWEEN”。  
[OH_Predicates *(*greaterThan)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#greaterthan) | 函数指针，配置谓词以匹配数据字段为field且值大于指定值valueObject的字段。 该方法等同于SQL语句中的“>”。  
[OH_Predicates *(*lessThan)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#lessthan) | 函数指针，配置谓词以匹配数据字段为field且值小于指定值valueObject的字段。 该方法等同于SQL语句中的“<”。  
[OH_Predicates *(*greaterThanOrEqualTo)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#greaterthanorequalto) | 函数指针，配置谓词以匹配数据字段为field且值大于或等于指定值valueObject的字段。 该方法等同于SQL语句中的“>=”。  
[OH_Predicates *(*lessThanOrEqualTo)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#lessthanorequalto) | 函数指针，配置谓词以匹配数据字段为field且值小于或等于指定值valueObject的字段。 该方法等同于SQL语句中的“<=”。  
[OH_Predicates *(*orderBy)(OH_Predicates *predicates, const char *field, OH_OrderType type)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#orderby) | 函数指针，配置谓词以匹配其值按升序或降序排序的列。 该方法等同于SQL语句中的“ORDER BY”。  
[OH_Predicates *(*distinct)(OH_Predicates *predicates)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#distinct) | 函数指针，配置谓词以过滤重复记录并仅保留其中一个。 该方法等同于SQL语句中的“DISTINCT”。  
[OH_Predicates *(*limit)(OH_Predicates *predicates, unsigned int value)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#limit) | 函数指针，设置最大数据记录数的谓词。 该方法等同于SQL语句中的“LIMIT”。  
[OH_Predicates *(*offset)(OH_Predicates *predicates, unsigned int rowOffset)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#offset) | 函数指针，配置谓词以指定返回结果的起始位置。 该方法等同于SQL语句中的“OFFSET”。  
[OH_Predicates *(*groupBy)(OH_Predicates *predicates, char const *const *fields, int length)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#groupby) | 函数指针，配置R谓词按指定列分组查询结果。 该方法等同于SQL语句中的“GROUP BY”。  
[OH_Predicates *(*in)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#in) | 函数指针，配置谓词以匹配数据字段为field且值在给定范围内的指定字段。 该方法等同于SQL语句中的“IN”。  
[OH_Predicates *(*notIn)(OH_Predicates *predicates, const char *field, OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#notin) | 函数指针，配置谓词以匹配数据字段为field且值超出给定范围内的指定字段。 该方法等同于SQL语句中的“NOT IN”。  
[OH_Predicates *(*clear)(OH_Predicates *predicates)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#clear) | 函数指针，清空谓词。  
[int (*destroy)(OH_Predicates *predicates)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-predicates#destroy) | 销毁OH_Predicates对象，并回收该对象占用的内存。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ability-api)
- [Accessibility Kit（无障碍服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/accessibility-api)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-api)
- [ArkTS API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-arkts)
- [ArkTS组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-comp)
- [C API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-c)


---

## 37. OH_VObject-结构体-C API-ArkData（方舟数据管理）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-references/capi-rdb-oh-vobject

---

### 成员函数 ____  
  
支持设备PhonePC/2in1TabletTVWearable

名称 | 描述  
---|---  
[int (*putInt64)(OH_VObject *valueObject, int64_t *value, uint32_t count))](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-vobject#putint64) | 将int64类型的单个参数或者数组转换为OH_VObject类型的值。  
[int (*putDouble)(OH_VObject *valueObject, double *value, uint32_t count)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-vobject#putdouble) | 将double类型的单个参数或者数组转换为OH_VObject类型的值。  
[int (*putText)(OH_VObject *valueObject, const char *value)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-vobject#puttext) | 将char *类型的字符数组转换为OH_VObject类型的值。  
[int (*putTexts)(OH_VObject *valueObject, const char **value, uint32_t count)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-vobject#puttexts) | 将char *类型的字符串数组转换为OH_VObject类型的值。  
[int (*destroy)(OH_VObject *valueObject)](/consumer/cn/doc/harmonyos-references/capi-rdb-oh-vobject#destroy) | 销毁OH_VObject对象，并回收该对象占用的内存。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ability-api)
- [Accessibility Kit（无障碍服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/accessibility-api)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-api)
- [ArkTS API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-arkts)
- [ArkTS组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-comp)
- [C API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkdata-c)


---

## 38. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#基本知识

---

### 用户自定义注解 __  
  
**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 39. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#声明

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 40. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#类型

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 41. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#运算符

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 42. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#语句

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 43. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#函数

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 44. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#函数声明

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 45. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#可选参数

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 46. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#rest参数

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 47. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#返回类型

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 48. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#函数的作用域

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 49. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#函数调用

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 50. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#函数类型

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 51. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#箭头函数又名lambda函数

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 52. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#闭包

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 53. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#函数重载

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 54. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#类

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 55. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#字段

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 56. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#方法

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 57. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#构造函数

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 58. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#可见性修饰符

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 59. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#对象字面量

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 60. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#抽象类

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 61. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#接口

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 62. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#接口属性

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 63. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#接口继承

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 64. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#抽象类和接口

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 65. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#泛型类型和函数

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 66. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#泛型类和接口

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 67. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#泛型约束

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 68. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#泛型函数

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 69. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#泛型默认值

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 70. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#空安全

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 71. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#非空断言运算符

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 72. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#空值合并运算符

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 73. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#可选链

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 74. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#模块

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 75. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#导出

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 76. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#导入

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 77. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#顶层语句

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 78. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#关键字

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 79. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#this

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 80. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#注解

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 81. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#用户自定义注解

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 82. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#arkui支持

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 83. ArkTS语言介绍-学习ArkTS语言-基础入门 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts#arkui示例

---

### 用户自定义注解 __

**从API version 20及之后版本，支持用户自定义注解。**

**用户自定义注解的声明**

用户自定义注解的定义与interface的定义类似，其中的interface关键字以符号@为前缀。

注解字段仅限于下面列举的类型：

  * number
  * boolean
  * string
  * 枚举
  * 以上类型的数组 

说明

    * 如果使用其他类型用作注解字段的类型，则会发生编译错误。
    * 注解字段类型不支持BigInt。

注解字段的默认值必须使用常量表达式来指定。

常量表达式的场景如下所示：

  * 数字字面量
  * 布尔字面量
  * 字符串字面量
  * 枚举值（需要在编译时确定值）
  * 以上常量组成的数组 

说明

如果枚举值不能在编译时确定，会编译报错。

      
      1. // a.ts
        2. export enum X {
        3.   x = foo(); // x不是编译时能确定的常量
        4. }
        5. 
         
        6. // b.ets
        7. import {X} from './a';
        8. 
         
        9. @interface Position {
        10.   data: number = X.x; // 编译错误：注解字段的默认值必须使用常量表达式
        11. }
    
    

注解必须定义在顶层作用域（top-level），否则会出现编译报错。

注解的名称不能与注解定义所在作用域内可见的其他实体名称相同，否则会出现编译报错。

注解不支持类型Typescript中的合并，否则会出现编译报错。
      
      1. namespace ns {
        2.   @interface MataInfo { // 编译错误：注解必须定义在顶层作用域
        3.     // ...
        4.   }
        5. }
        6. 
         
        7. @interface Position {
        8.   // ...
        9. }
        10. 
         
        11. class Position { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        12.   // ...
        13. }
        14. 
         
        15. @interface ClassAuthor {
        16.   name: string;
        17. }
        18. 
         
        19. @interface ClassAuthor { // 编译错误：注解的名称不能与注解定义所在作用域内可见的其他实体名称相同
        20.   data: string;
        21. }
    
    

注解不是类型，把注解当类型使用时会出现编译报错（例如：对注解使用类型别名）。
      
      1. @interface Position {}
        2. type Pos = Position; // 编译错误：注解不是类型
    
    

注解不支持在类的getter和setter方法中添加，若添加注解会编译报错。
      
      1. @interface ClassAuthor {
        2.   authorName: string;
        3. }
        4. 
         
        5. @ClassAuthor({authorName: "John Smith"})
        6. class MyClass {
        7.   private _name: string = "Bob";
        8. 
         
        9.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        10.   get name() {
        11.     return this._name;
        12.   }
        13. 
         
        14.   @ClassAuthor({authorName: "John Smith"}) // 编译错误：注解不支持在类的getter和setter方法添加
        15.   set name(authorName: string) {
        16.     this._name = authorName;
        17.   }
        18. }
    
    

**用户自定义注解的使用**

注解声明示例如下：
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4. }
        5. @interface MyAnno {}
    
    

当前仅允许对class declarations和method declarations使用注解，对类和方法可以同时使用同一个注解。

注解用法示例如下：
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. class C1 {
        3.   // ...
        4. }
        5. 
         
        6. @ClassPreamble({authorName: "Bob"}) // revision的默认值为1
        7. class C2 {
        8.   // ...
        9. }
        10. 
         
        11. @MyAnno() // 对类和方法可以同时使用同一个注解
        12. class C3 {
        13.   @MyAnno()
        14.   foo() {}
        15.   @MyAnno()
        16.   static bar() {}
        17. }
    
    

注解中的字段顺序不影响使用。
      
      1. @ClassPreamble({authorName: "John", revision: 2})
        2. // the same as:
        3. @ClassPreamble({revision: 2, authorName: "John"})
    
    

使用注解时，必须给所有没有默认值的字段赋值，否则会发生编译错误。

说明

赋值应当与注解声明的类型一致，所赋的值与注解字段默认值的要求一样，只能使用常量表达式。
      
      1. @ClassPreamble() // 编译错误：authorName字段未定义
        2. class C1 {
        3.   // ...
        4. }
    
    

如果注解中定义了数组类型的字段，则使用数组字面量来设置该字段的值。
      
      1. @interface ClassPreamble {
        2.   authorName: string;
        3.   revision: number = 1;
        4.   reviewers: string[];
        5. }
        6. 
         
        7. @ClassPreamble(
        8.   {
        9.     authorName: "Alice",
        10.     reviewers: ["Bob", "Clara"]
        11.   }
        12. )
        13. class C3 {
        14.   // ...
        15. }
    
    

如果不需要定义注解字段，可以省略注解名称后的括号。
      
      1. @MyAnno
        2. class C4 {
        3.   // ...
        4. }
    
    

**导入和导出注解**

注解也可以被导入导出。针对导出，当前仅支持在定义时的导出，即export @interface的形式。

**示例：**
      
      1. export @interface MyAnno {}
    
    

针对导入，当前仅支持import {}和import * as两种方式。

**示例：**
      
      1. // a.ets
        2. export @interface MyAnno {}
        3. export @interface ClassAuthor {}
        4. 
         
        5. // b.ets
        6. import { MyAnno } from './a';
        7. import * as ns from './a';
        8. 
         
        9. @MyAnno
        10. @ns.ClassAuthor
        11. class C {
        12.   // ...
        13. }
    
    

  * 不允许在import中对注解进行重命名。

      
      1. import { MyAnno as Anno } from './a'; // 编译错误：不允许在import中对注解进行重命名
    
    

不允许对注解使用任何其他形式的 import/export，这会导致编译报错。

  * 由于注解不是类型，因此禁止使用type符号进行导入和导出。

      
      1. import type { MyAnno } from './a'; // 编译错误：注解不允许使用'type'符号进行导入和导出
    
    

  * 如果仅从模块导入注解，则不会触发模块的副作用。

      
      1. // a.ets
        2. export @interface Anno {}
        3. 
         
        4. export @interface ClassAuthor {}
        5. 
         
        6. console.info("hello");
        7. 
         
        8. // b.ets
        9. import { Anno } from './a';
        10. import * as ns from './a';
        11. 
         
        12. // 仅引用了Anno注解，不会导致a.ets的console.info执行
        13. class X {
        14.   // ...
        15. }
    
    

**.d.ets文件中的注解**

注解可以出现在.d.ets文件中。

可以在.d.ets文件中用环境声明（ambient declaration）来声明注解。
      
      1. ambientAnnotationDeclaration:
        2.   'declare' userDefinedAnnotationDeclaration
        3.   ;
    
    

**示例：**
      
      1. // a.d.ets
        2. export declare @interface ClassAuthor {}
    
    

上述声明中：

  * 不会引入新的注解定义，而是提供注解的类型信息。
  * 注解需定义在其他源代码文件中。
  * 注解的环境声明和实现需要完全一致，包括字段的类型和默认值。

      
      1. // a.d.ets
        2. export declare @interface NameAnno{name: string = ""}
        3. 
         
        4. // a.ets
        5. export @interface NameAnno{name: string = ""} // ok
    
    

环境声明的注解和class类似，也可以被import使用。
      
      1. // a.d.ets
        2. export declare @interface MyAnno {}
        3. 
         
        4. // b.ets
        5. import { MyAnno } from './a';
        6. 
         
        7. @MyAnno
        8. class C {
        9.   // ...
        10. }
    
    

**编译器自动生成的.d.ets文件**

当编译器根据ets代码自动生成.d.ets文件时，存在以下2种情况。

  1. 当注解定义被导出时，源代码中的注解定义会在.d.ets文件中保留。 
         
         1. // a.ets
              2. export @interface ClassAuthor {}
              3. 
            
              4. @interface MethodAnno { // 没导出
              5.   data: number;
              6. }
              7. 
            
              8. // a.d.ets 编译器生成的声明文件
              9. export declare @interface ClassAuthor {}

  2. 当下面所有条件成立时，源代码中实体的注解实例会在.d.ets文件中保留。

2.1 注解的定义被导出（import的注解也算作被导出）。

2.2 如果实体是类，则类被导出。

2.3 如果实体是方法，则类被导出，并且方法不是私有方法。
         
         1. // a.ets
              2. import { ClassAuthor } from './author';
              3. 
            
              4. export @interface MethodAnno {
              5.   data: number = 0;
              6. }
              7. 
            
              8. @ClassAuthor
              9. class MyClass {
              10.   @MethodAnno({data: 123})
              11.   foo() {}
              12. 
            
              13.   @MethodAnno({data: 456})
              14.   private bar() {}
              15. }
              16. 
            
              17. // a.d.ets 编译器生成的声明文件
              18. import {ClassAuthor} from "./author";
              19. 
            
              20. export declare @interface MethodAnno {
              21.   data: number = 0;
              22. }
              23. 
            
              24. @ClassAuthor
              25. export declare class MyClass {
              26.   @MethodAnno({data: 123})
              27.   foo(): void;
              28. 
            
              29.   bar; // 私有方法不保留注解
              30. }

**开发者生成的.d.ets文件**

开发者生成的.d.ets文件中的注解信息不会自动应用到实现的源代码中。

**示例：**
      
      1. // b.d.ets 开发者生成的声明文件
        2. @interface ClassAuthor {}
        3. 
         
        4. @ClassAuthor // 声明文件中有注解
        5. class C {
        6.   // ...
        7. }
        8. 
         
        9. // b.ets 开发者对声明文件实现的源代码
        10. @interface ClassAuthor {}
        11. 
         
        12. // 实现文件中没有注解
        13. class C {
        14.   // ...
        15. }
    
    

在最终编译产物中，class C没有注解。

**重复注解和继承**

同一个实体不能重复使用同一注解，否则会导致编译错误。
      
      1. @MyAnno({name: "123", value: 456})
        2. @MyAnno({name: "321", value: 654}) // 编译错误：不允许重复注释
        3. class C {
        4.   // ...
        5. }
    
    

子类不会继承基类的注解，也不会继承基类方法的注解。

**注解和抽象类、抽象方法**

不支持对抽象类或抽象方法使用注解，否则将导致编译错误。
      
      1. @MyAnno // 编译错误：不允许在抽象类和抽象方法上使用注解
        2. abstract class C {
        3.   @MyAnno
        4.   abstract foo(): void; // 编译错误：不允许在抽象类和抽象方法上使用注解
        5. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
- [快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/quick-start)
- [开发基础知识](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/development-fundamentals)
- [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access)
- [学习ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/learning-arkts)
- [初识ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)


---

## 84. Ability Kit（程序框架服务）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit

---

* **[Ability Kit简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/abilitykit-overview)**  

  * **[应用模型](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-models)**  

  * **[Stage模型开发指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/stage-model-development)**  

  * **[FA模型开发指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/fa-model-development)**  

  * **[Native子进程开发指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/native-childprocess-development)**  

  * **[Ability Kit术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-terminology)**  

[Ability Kit简介 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/abilitykit-overview "Ability Kit简介")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkWeb（方舟Web）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkweb)


---

## 85. Accessibility Kit (无障碍服务)-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit

---

* **[Accessibility Kit 简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibilitykit-overview)**  

  * **[提升应用的无障碍体验](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-approve-experience)**  

  * **[测试应用的无障碍功能](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/test-app-accessibility)**  

[__Ability Kit术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-terminology "Ability Kit术语")

[ Accessibility Kit 简介 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibilitykit-overview "Accessibility Kit 简介")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkWeb（方舟Web）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkweb)


---

## 86. ArkData（方舟数据管理）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata

---

* **[ArkData简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/data-mgmt-overview)**  

  * **[标准化数据定义](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/uniform-data-definition)**  

  * **[应用数据持久化](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/app-data-persistence)**  

  * **[同应用跨设备数据同步（分布式）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/distributed-data-sync)**  

  * **[数据可靠性与安全性](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/data-reliability-security)**  

  * **[跨应用数据共享](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/cross-app-data-share)**  

  * **[应用数据向量化 (ArkTS)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/aip-data-intelligence-embedding)**  

  * **[arkdata数据库调试工具](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata-debug-tool)**  

  * **[SQLite调试工具指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/sqlite-database-debug-tool)**  

  * **[ArkData术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/data-terminology)**  

[__测试屏幕朗读功能](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/test-screen-reader "测试屏幕朗读功能")

[ ArkData简介 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/data-mgmt-overview "ArkData简介")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkWeb（方舟Web）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkweb)


---

## 87. ArkTS（方舟编程语言）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts

---

* **[ArkTS简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-overview)**  

  * **[ArkTS基础类库](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-utils)**  

  * **[ArkTS并发](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-concurrency)**  

  * **[ArkTS跨语言交互](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-cross-language-interaction)**  

  * **[ArkTS运行时](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-runtime)**  

  * **[ArkTS编译工具链](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-compilation-tool-chain)**  

[__ArkData术语](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/data-terminology "ArkData术语")

[ ArkTS简介 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-overview "ArkTS简介")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkWeb（方舟Web）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkweb)


---

## 88. ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui

---

* **[ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)**  

  * **[UI开发 (ArkTS声明式开发范式)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-development)**  

  * **[UI开发 (基于NDK构建UI)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-use-ndk)**  

  * **[UI开发 (兼容JS的类Web开发范式)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ui-js-dev)**  

  * **[UI开发调试调优](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ui-debug-optimize)**  

  * **[窗口管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/window-manager)**  

  * **[屏幕管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/display-manager)**  

[__在build-profile.json5中配置arkOptions](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkoptions-guide "在build-profile.json5中配置arkOptions")

[ ArkUI简介 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview "ArkUI简介")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkWeb（方舟Web）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkweb)


---

## 89. ArkUI简介-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview

---

## 两种开发范式 __

针对不同的应用场景及技术背景，方舟UI框架提供了两种开发范式，分别是[基于ArkTS的声明式开发范式](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-development-overview)（简称“声明式开发范式”）和[兼容JS的类Web开发范式](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ui-js-overview)（简称“类Web开发范式”）。

  * **声明式开发范式** ：采用基于TypeScript声明式UI语法扩展而来的[ArkTS语言](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started)，从组件、动画和状态管理三个维度提供UI绘制能力。

  * **类Web开发范式** ：采用经典的HML、CSS、JavaScript三段式开发方式，即使用HML标签文件搭建布局、使用CSS文件描述样式、使用JavaScript文件处理逻辑。该范式更符合Web前端开发者的使用习惯，便于快速将已有的Web应用改造成方舟UI框架应用。

在开发一款新应用时，推荐采用声明式开发范式来构建UI，主要基于以下几点考虑：

  * **开发效率：** 声明式开发范式更接近自然语义的编程方式，开发者可以直观地描述UI，无需关心如何实现UI绘制和渲染，开发高效简洁。

  * **应用性能：** 如下图所示，两种开发范式的UI后端引擎和语言运行时是共用的，但是相比类Web开发范式，声明式开发范式无需JS框架进行页面DOM管理，渲染更新链路更为精简，占用内存更少，应用性能更佳。

  * **发展趋势** ：声明式开发范式后续会作为主推的开发范式持续演进，为开发者提供更丰富、更强大的能力。

**图1** 方舟UI框架示意图

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107151416.47241252248675461043249821581207:50001231000000:2800:B312EFC0A78DCFE20C8012A865D535BA9971DCCF1134B952F224A032B22DAA62.png)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 90. UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-development

---

* **[UI开发（ArkTS声明式开发范式）概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-development-overview)**  

  * **[学习UI范式基本语法](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-paradigm-basic-syntax)**  

  * **[学习UI范式状态管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management)**  

  * **[学习UI范式渲染控制](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control)**  

  * **[设置组件导航和页面路由](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-set-navigation-routing)**  

  * **[组件布局](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-layout-development)**  

  * **[列表与网格](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-list-and-grid)**  

  * **[使用文本](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-use-text)**  

  * **[媒体展示](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-media-display)**  

  * **[表单选择](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-form-selection)**  

  * **[添加组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-add-component)**  

  * **[使用弹窗](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-use-dialog)**  

  * **[几何图形绘制](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-draw-graphics)**  

  * **[添加交互响应](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-interaction-development-guide-overview)**  

  * **[使用动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-use-animation)**  

  * **[使用自定义能力](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-user-defined-capabilities)**  

  * **[UI国际化](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-internationalization)**  

  * **[无障碍与适老化](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-support-accessibility-friendliness)**  

  * **[主题设置](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-theme)**  

  * **[UI系统场景化能力](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-system-scenarization-capability)**  

[__ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview "ArkUI简介")

[ UI开发（ArkTS声明式开发范式）概述 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-development-overview "UI开发（ArkTS声明式开发范式）概述")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 91. UI开发（ArkTS声明式开发范式）概述-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-development-overview

---

## 开发流程 __

使用UI开发框架开发应用时，主要涉及如下开发过程。

任务 | 简介 | 相关指导  
---|---|---  
学习ArkTS | 介绍了ArkTS的基本语法、状态管理和渲染控制的场景。 |  \- [基本语法](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-basic-syntax-overview) \- [状态管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-overview) \- [渲染控制](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-overview)  
设置组件导航和页面路由 | 介绍了如何设置组件间的导航以及页面路由。 |  \- [组件导航（推荐）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-navigation-navigation) \- [页面路由](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-routing)  
组件布局 | 介绍了几种常用的布局方式。 | \- [常用布局](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-layout-development-overview)  
列表与网格 | 介绍了几种列表与网格组件的使用方法。 | \- [列表与网格](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-list-grid-development-overview)  
使用文本 | 介绍了输入框、富文本和属性字符串等文本组件的使用方法。 |  \- [文本显示](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-common-components-text-display) \- [文本输入](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-common-components-text-input) \- [富文本](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-common-components-richeditor) \- [图标小符号](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-common-components-symbol) \- [属性字符串](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-styled-string)  
媒体展示 | 介绍了几种媒体展示组件的使用方法。 |  \- [显示图片 (Image)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-graphics-display) \- [视频播放 (Video)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-common-components-video-player) \- [创建轮播 (Swiper)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-layout-development-create-looping) \- [创建弧形轮播 (ArcSwiper)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-layout-development-arcswiper)  
表单选择 | 介绍了几种常用表单选择组件的使用方法。 | \- [表单与选择组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-forms-overview)  
添加组件 | 介绍了XComponent和Progress组件的使用方法。 |  \- [自定义渲染 (XComponent)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/napi-xcomponent-guidelines) \- [进度条 (Progress)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-common-components-progress-indicator)  
使用弹窗 | 介绍了弹窗的应用场景与使用方法。 |  \- [使用弹出框](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-base-dialog-overview) \- [菜单](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-menu-overview) \- [气泡提示](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-popup-overview) \- [绑定模态页面](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-modal-overview) \- [即时反馈](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-create-toast) \- [设置浮层](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-create-overlaymanager)  
显示图形 | 介绍了如何显示图片、绘制自定义几何图形以及使用画布绘制自定义图形。 |  \- [几何图形](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-geometric-shape-drawing) \- [画布](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-drawing-customization-on-canvas)  
几何图形 | 介绍了如何绘制几何图形。 | \- [几何图形绘制](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-shape-overview)  
添加交互响应 | 介绍了交互基础机制、输入设备与事件和手势响应的能力。 |  \- [交互基础机制](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-interaction-basic-principles) \- [输入设备与事件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/rkts-interaction-development-guide-raw-input-event) \- [手势响应](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/rkts-interaction-development-guide-support-gesture)  
使用动画 | 介绍了组件和页面使用动画的典型场景。 |  \- [属性动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-attribute-animation-overview) \- [转场动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-transition-overview) \- [粒子动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-particle-animation) \- [组件动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-component-animation) \- [动画曲线](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-traditional-curve) \- [动画衔接](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-animation-smoothing) \- [动画效果](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-blur-effect) \- [帧动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-animator)  
使用自定义能力 | 介绍了自定义能力的基本概念和如何使用自定义能力。 |  \- [自定义组合](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-user-defined-composition) \- [自定义节点](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-user-defined-node) \- [自定义扩展](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-user-defined-modifier)  
UI国际化 | 介绍如何实现应用程序UI界面的国际化，包含资源配置和镜像布局。 | \- [UI国际化](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-internationalization)  
无障碍与适老化 | 介绍了无障碍和适老化的使用场景和使用方法。 |  \- [支持无障碍](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-universal-attributes-accessibility) \- [支持适老化](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-support-for-aging-adaptation)  
主题设置 | 介绍了应用级和页面级的主题设置能力。 |  \- [应用深浅色适配](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ui-dark-light-color-adaptation) \- [设置应用内主题换肤](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/theme_skinning)  
UI系统场景化能力 | 介绍了如何使用UIContext中对应的接口获取与实例绑定的对象，以及全屏方式拉起元服务的方法。 |  \- [使用UI上下文接口操作界面](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-global-interface) \- [全屏启动元服务组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-fullscreencomponent)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 92. 学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-paradigm-basic-syntax

---

* **[基本语法概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-basic-syntax-overview)**  
  
  * **[声明式UI描述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-declarative-ui-description)**  

  * **[自定义组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-custom-components)**  

  * **[组件扩展](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-extend-components)**  

  * **[@Styles装饰器：定义组件重用样式](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-style)**  

  * **[@Extend装饰器：定义扩展组件样式](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-extend)**  

  * **[stateStyles：多态样式](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-statestyles)**  

  * **[@AnimatableExtend装饰器：定义可动画属性](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-animatable-extend)**  

  * **[@Require装饰器：校验构造传参](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-require)**  

  * **[@Reusable装饰器：组件复用](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-reusable)**  

[__UI开发（ArkTS声明式开发范式）概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-ui-development-overview "UI开发（ArkTS声明式开发范式）概述")

[ 基本语法概述 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-basic-syntax-overview "基本语法概述")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 93. 声明式UI描述-学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-declarative-ui-description

---

## 配置事件 __

事件方法以“.”链式调用的方式配置系统组件支持的事件，建议每个事件方法单独写一行。

  * 使用箭头函数配置组件的事件方法。
        
        1. Button('Click me')
            2.   .onClick(() => {
            3.     this.myText = 'ArkUI';
            4.   })

  * 使用箭头函数表达式配置组件的事件方法，要求使用“() => {...}”，以确保函数与组件绑定，同时符合ArkTS语法规范。
        
        1. Button('add counter')
            2.   .onClick(() => {
            3.     this.counter += 2;
            4.   })

  * 使用组件的成员函数配置组件的事件方法，需要bind this。ArkTS语法不建议使用成员函数配合bind this来配置组件的事件方法。
        
        1. myClickHandler(): void {
            2.   this.counter += 2;
            3. }
            4. // ...
            5. Button('add counter')
            6.   .onClick(this.myClickHandler.bind(this))

  * 使用声明的箭头函数时可以直接调用，不需要bind this。
        
        1. fn = () => {
            2.   console.info(`counter: ${this.counter}`)
            3.   this.counter++
            4. }
            5. // ...
            6. Button('add counter')
            7.   .onClick(this.fn)

说明

箭头函数内部的this是词法作用域，由上下文确定。匿名函数可能会出现this指向不明确的问题，因此在ArkTS中不允许使用。

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 94. 自定义组件-学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-custom-components

---

* **[创建自定义组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-create-custom-components)**  

  * **[自定义组件生命周期](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-page-custom-components-lifecycle)**  

  * **[自定义组件的自定义布局](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-page-custom-components-layout)**  

  * **[自定义组件成员属性访问限定符使用限制](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-custom-components-access-restrictions)**  

[__声明式UI描述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-declarative-ui-description "声明式UI描述")

[ 创建自定义组件 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-create-custom-components "创建自定义组件")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 95. 组件扩展-学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-extend-components

---

* **[组件扩展概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-extend-components-overview)**  

  * **[@Builder装饰器：自定义构建函数](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-builder)**  

  * **[@LocalBuilder装饰器： 维持组件关系](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-localbuilder)**  

  * **[@BuilderParam装饰器：引用@Builder函数](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-builderparam)**  

  * **[wrapBuilder：封装全局@Builder](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-wrapbuilder)**  

[__自定义组件成员属性访问限定符使用限制](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-custom-components-access-restrictions "自定义组件成员属性访问限定符使用限制")

[ 组件扩展概述 __](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-extend-components-overview "组件扩展概述")

意见反馈

以上内容对您是否有帮助？

 __

__

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

[社区提问](https://developer.huawei.com/consumer/cn/forum/)[智能客服提问](https://developer.huawei.com/consumer/cn/customerService/#/bot-dev-top/faq-top/faq-talk-top)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 96. @Styles装饰器：定义组件重用样式-学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-style

---

## 装饰器使用说明 __

  * 当前@Styles仅支持[通用属性](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-component-general-attributes)和[通用事件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-component-general-events)。

  * @Styles可以定义在组件内或全局，在全局定义时需在方法名前面添加function关键字，组件内定义时则不需要添加function关键字。请参考用例[组件内styles和全局styles的用法](/consumer/cn/doc/harmonyos-guides/arkts-style#组件内styles和全局styles的用法)。

  * 组件内@Styles的优先级高于全局@Styles。框架优先找当前组件内的@Styles，如果找不到，则会全局查找。

说明

只能在当前文件内使用@Styles，不支持export。

若需要实现样式导出，推荐使用[AttributeModifier](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-user-defined-extension-attributemodifier)。

定义在组件内的@Styles可以通过this访问组件的常量和状态变量，并可以在@Styles里通过事件来改变状态变量的值，示例如下：
      
      1. @Entry
        2. @Component
        3. struct FancyUse {
        4.   @State heightValue: number = 50;
        5. 
         
        6.   @Styles
        7.   fancy() {
        8.     .height(this.heightValue)
        9.     .backgroundColor(Color.Blue)
        10.     .onClick(() => {
        11.       this.heightValue = 100;
        12.     })
        13.   }
        14. 
         
        15.   build() {
        16.     Column() {
        17.       Button('change height')
        18.         .fancy()
        19.     }
        20.     .height('100%')
        21.     .width('100%')
        22.   }
        23. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 97. @Extend装饰器：定义扩展组件样式-学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-extend

---

### 使用规则 __

  * 和@Styles不同，@Extend支持封装指定组件的私有属性、私有事件和自身定义的全局方法。
        
        1. // @Extend(Text)可以支持Text的私有属性fontColor
            2. @Extend(Text)
            3. function fancy() {
            4.   .fontColor(Color.Red)
            5. }
            6. 
           
            7. // superFancyText可以调用预定义的fancy
            8. @Extend(Text)
            9. function superFancyText(size: number) {
            10.   .fontSize(size)
            11.   .fancy()
            12. }

  * 和@Styles不同，@Extend装饰的方法支持参数，开发者可以在调用时传递参数，调用遵循TS方法传值调用。
        
        1. // xxx.ets
            2. @Extend(Text)
            3. function fancy(fontSize: number) {
            4.   .fontColor(Color.Red)
            5.   .fontSize(fontSize)
            6. }
            7. 
           
            8. @Entry
            9. @Component
            10. struct FancyUse {
            11.   build() {
            12.     Row({ space: 10 }) {
            13.       Text('Fancy')
            14.         .fancy(16)
            15.       Text('Fancy')
            16.         .fancy(24)
            17.     }
            18.   }
            19. }

  * @Extend装饰的方法的参数可以为function，作为Event事件的句柄。
        
        1. @Extend(Text)
            2. function makeMeClick(onClick: () => void) {
            3.   .backgroundColor(Color.Blue)
            4.   .onClick(onClick)
            5. }
            6. 
           
            7. @Entry
            8. @Component
            9. struct FancyUse {
            10.   @State label: string = 'Hello World';
            11. 
           
            12.   onClickHandler() {
            13.     this.label = 'Hello ArkUI';
            14.   }
            15. 
           
            16.   build() {
            17.     Row({ space: 10 }) {
            18.       Text(`${this.label}`)
            19.         .makeMeClick(() => {
            20.           this.onClickHandler();
            21.         })
            22.     }
            23.   }
            24. }

  * @Extend的参数可以为[状态变量](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-overview)，当状态变量改变时，UI可以正常的被刷新渲染。
        
        1. @Extend(Text)
            2. function fancy(fontSize: number) {
            3.   .fontColor(Color.Red)
            4.   .fontSize(fontSize)
            5. }
            6. 
           
            7. @Entry
            8. @Component
            9. struct FancyUse {
            10.   @State fontSizeValue: number = 20;
            11. 
           
            12.   build() {
            13.     Row({ space: 10 }) {
            14.       Text('Fancy')
            15.         .fancy(this.fontSizeValue)
            16.         .onClick(() => {
            17.           this.fontSizeValue = 30;
            18.         })
            19.     }
            20.   }
            21. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 98. stateStyles：多态样式-学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-statestyles

---

### 基础场景 __

下面的示例展示了stateStyles最基本的使用场景。Button1处于第一个组件，Button2处于第二个组件。按压时显示为pressed态指定的黑色。使用Tab键走焦，Button1获焦并显示为focused态指定的粉色。当Button2获焦的时候，Button2显示为focused态指定的粉色，Button1失焦显示normal态指定的蓝色。
      
      1. @Entry
        2. @Component
        3. struct StateStylesSample {
        4.   build() {
        5.     Column() {
        6.       Button('Button1')
        7.         .stateStyles({
        8.           focused: {
        9.             .backgroundColor('#ffffeef0')
        10.           },
        11.           pressed: {
        12.             .backgroundColor('#ff707070')
        13.           },
        14.           normal: {
        15.             .backgroundColor('#ff2787d9')
        16.           }
        17.         })
        18.         .margin(20)
        19.       Button('Button2')
        20.         .stateStyles({
        21.           focused: {
        22.             .backgroundColor('#ffffeef0')
        23.           },
        24.           pressed: {
        25.             .backgroundColor('#ff707070')
        26.           },
        27.           normal: {
        28.             .backgroundColor('#ff2787d9')
        29.           }
        30.         })
        31.     }.margin('30%')
        32.   }
        33. }
    
    

**图1** 获焦态和按压态

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107151554.22844801652468775918887757320454:50001231000000:2800:66C5D292B64FA3E21E459034AE53A9D188B8D241A5AC20F4ED450CDDEDE707B8.gif)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 99. @AnimatableExtend装饰器：定义可动画属性-学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-animatable-extend

---

## 使用场景 __

以下示例通过改变Text组件宽度实现逐帧布局的效果。
      
      1. @AnimatableExtend(Text)
        2. function animatableWidth(width: number) {
        3.   .width(width)
        4. }
        5. 
         
        6. @Entry
        7. @Component
        8. struct AnimatablePropertyExample {
        9.   @State textWidth: number = 80;
        10. 
         
        11.   build() {
        12.     Column() {
        13.       Text("AnimatableProperty")
        14.         .animatableWidth(this.textWidth)
        15.         .animation({ duration: 2000, curve: Curve.Ease })
        16.       Button("Play")
        17.         .onClick(() => {
        18.           this.textWidth = this.textWidth == 80 ? 160 : 80;
        19.         })
        20.     }.width("100%")
        21.     .padding(10)
        22.   }
        23. }
    
    

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107151556.04203219458385050484298395995987:50001231000000:2800:9FE7F183B2A3D42FA9C42773A43CBBC895607500DC29FB4A6AB6803C99511100.gif)

以下示例实现折线的动画效果。 
      
      1. class Point {
        2.   x: number
        3.   y: number
        4. 
         
        5.   constructor(x: number, y: number) {
        6.     this.x = x
        7.     this.y = y
        8.   }
        9. 
         
        10.   plus(rhs: Point): Point {
        11.     return new Point(this.x + rhs.x, this.y + rhs.y);
        12.   }
        13. 
         
        14.   subtract(rhs: Point): Point {
        15.     return new Point(this.x - rhs.x, this.y - rhs.y);
        16.   }
        17. 
         
        18.   multiply(scale: number): Point {
        19.     return new Point(this.x * scale, this.y * scale);
        20.   }
        21. 
         
        22.   equals(rhs: Point): boolean {
        23.     return this.x === rhs.x && this.y === rhs.y;
        24.   }
        25. }
        26. 
         
        27. // PointVector实现了AnimatableArithmetic<T>接口
        28. class PointVector extends Array<Point> implements AnimatableArithmetic<PointVector> {
        29.   constructor(value: Array<Point>) {
        30.     super();
        31.     value.forEach(p => this.push(p));
        32.   }
        33. 
         
        34.   plus(rhs: PointVector): PointVector {
        35.     let result = new PointVector([]);
        36.     const len = Math.min(this.length, rhs.length);
        37.     for (let i = 0; i < len; i++) {
        38.       result.push((this as Array<Point>)[i].plus((rhs as Array<Point>)[i]));
        39.     }
        40.     return result;
        41.   }
        42. 
         
        43.   subtract(rhs: PointVector): PointVector {
        44.     let result = new PointVector([]);
        45.     const len = Math.min(this.length, rhs.length);
        46.     for (let i = 0; i < len; i++) {
        47.       result.push((this as Array<Point>)[i].subtract((rhs as Array<Point>)[i]));
        48.     }
        49.     return result;
        50.   }
        51. 
         
        52.   multiply(scale: number): PointVector {
        53.     let result = new PointVector([]);
        54.     for (let i = 0; i < this.length; i++) {
        55.       result.push((this as Array<Point>)[i].multiply(scale));
        56.     }
        57.     return result;
        58.   }
        59. 
         
        60.   equals(rhs: PointVector): boolean {
        61.     if (this.length != rhs.length) {
        62.       return false;
        63.     }
        64.     for (let i = 0; i < this.length; i++) {
        65.       if (!(this as Array<Point>)[i].equals((rhs as Array<Point>)[i])) {
        66.         return false;
        67.       }
        68.     }
        69.     return true;
        70.   }
        71. 
         
        72.   get(): Array<Object[]> {
        73.     let result: Array<Object[]> = [];
        74.     this.forEach(p => result.push([p.x, p.y]));
        75.     return result;
        76.   }
        77. }
        78. 
         
        79. @AnimatableExtend(Polyline)
        80. function animatablePoints(points: PointVector) {
        81.   .points(points.get())
        82. }
        83. 
         
        84. @Entry
        85. @Component
        86. struct AnimatablePropertyExample {
        87.   @State points: PointVector = new PointVector([
        88.     new Point(50, Math.random() * 200),
        89.     new Point(100, Math.random() * 200),
        90.     new Point(150, Math.random() * 200),
        91.     new Point(200, Math.random() * 200),
        92.     new Point(250, Math.random() * 200),
        93.   ])
        94. 
         
        95.   build() {
        96.     Column() {
        97.       Polyline()
        98.         .animatablePoints(this.points)
        99.         .animation({ duration: 1000, curve: Curve.Ease })// 设置动画参数
        100.         .size({ height: 220, width: 300 })
        101.         .fill(Color.Green)
        102.         .stroke(Color.Red)
        103.         .backgroundColor('#eeaacc')
        104.       Button("Play")
        105.         .onClick(() => {
        106.           // points是实现了可动画协议的数据类型，points在动画过程中可按照定义的运算规则、动画参数从之前的PointVector变为新的PointVector数据，产生每一帧的PointVector数据，进而产生动画
        107.           this.points = new PointVector([
        108.             new Point(50, Math.random() * 200),
        109.             new Point(100, Math.random() * 200),
        110.             new Point(150, Math.random() * 200),
        111.             new Point(200, Math.random() * 200),
        112.             new Point(250, Math.random() * 200),
        113.           ]);
        114.         })
        115.     }.width("100%")
        116.     .padding(10)
        117.   }
        118. }
    
    

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20251107151556.73392921133809339920519602450473:50001231000000:2800:73F18E9312157F57D61FEC79F0C58CDB389154283FB35B846F942FE1AC023571.gif)

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

## 100. @Require装饰器：校验构造传参-学习UI范式基本语法-UI开发 (ArkTS声明式开发范式)-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者

**来源URL:** https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-require

---

## 使用场景 __

当Child组件内使用@Require装饰器和@Prop、@State、@Provide、@BuilderParam、@Param和普通变量(无状态装饰器修饰的变量)结合使用时，父组件Index在构造Child时必须传参，否则编译不通过。
      
      1. @Entry
        2. @Component
        3. struct Index {
        4.   @State message: string = 'Hello World';
        5. 
         
        6.   @Builder
        7.   buildTest() {
        8.     Row() {
        9.       Text('Hello, world')
        10.         .fontSize(30)
        11.     }
        12.   }
        13. 
         
        14.   build() {
        15.     Row() {
        16.       // 构造Child时需传入所有@Require对应参数，否则编译失败。
        17.       Child({
        18.         regular_value: this.message,
        19.         state_value: this.message,
        20.         provide_value: this.message,
        21.         initMessage: this.message,
        22.         message: this.message,
        23.         buildTest: this.buildTest,
        24.         initBuildTest: this.buildTest
        25.       })
        26.     }
        27.   }
        28. }
        29. 
         
        30. @Component
        31. struct Child {
        32.   @Builder
        33.   buildFunction() {
        34.     Column() {
        35.       Text('initBuilderParam')
        36.         .fontSize(30)
        37.     }
        38.   }
        39. 
         
        40.   @Require regular_value: string = 'Hello';
        41.   @Require @State state_value: string = 'Hello';
        42.   @Require @Provide provide_value: string = 'Hello';
        43.   @Require @BuilderParam buildTest: () => void;
        44.   @Require @BuilderParam initBuildTest: () => void = this.buildFunction;
        45.   @Require @Prop initMessage: string = 'Hello';
        46.   @Require @Prop message: string;
        47. 
         
        48.   build() {
        49.     Column() {
        50.       Text(this.initMessage)
        51.         .fontSize(30)
        52.       Text(this.message)
        53.         .fontSize(30)
        54.       this.initBuildTest();
        55.       this.buildTest();
        56.     }
        57.     .width('100%')
        58.     .height('100%')
        59.   }
        60. }
    
    

使用[@ComponentV2](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-componentv2)修饰的自定义组件ChildPage通过父组件ParentPage进行初始化，因为有@Require装饰@Param，所以父组件必须进行构造赋值。
      
      1. @ObservedV2
        2. class Info {
        3.   @Trace name: string = '';
        4.   @Trace age: number = 0;
        5. }
        6. 
         
        7. @ComponentV2
        8. struct ChildPage {
        9.   @Require @Param childInfo: Info = new Info();
        10.   @Require @Param state_value: string = 'Hello';
        11. 
         
        12.   build() {
        13.     Column() {
        14.       Text(`ChildPage childInfo name :${this.childInfo.name}`)
        15.         .fontSize(20)
        16.         .fontWeight(FontWeight.Bold)
        17.       Text(`ChildPage childInfo age :${this.childInfo.age}`)
        18.         .fontSize(20)
        19.         .fontWeight(FontWeight.Bold)
        20.       Text(`ChildPage state_value age :${this.state_value}`)
        21.         .fontSize(20)
        22.         .fontWeight(FontWeight.Bold)
        23.     }
        24.   }
        25. }
        26. 
         
        27. @Entry
        28. @ComponentV2
        29. struct ParentPage {
        30.   info1: Info = { name: 'Tom', age: 25 };
        31.   label1: string = 'Hello World';
        32.   @Local info2: Info = { name: 'Tom', age: 25 };
        33.   @Local label2: string = 'Hello World';
        34. 
         
        35.   build() {
        36.     Column() {
        37.       Text(`info1: ${this.info1.name}  ${this.info1.age}`) // Text1
        38.         .fontSize(30)
        39.         .fontWeight(FontWeight.Bold)
        40.       // 父组件ParentPage构造子组件ChildPage时进行了构造赋值。
        41.       // 为ChildPage中被@Require @Param装饰的childInfo和state_value属性传入了值。
        42.       ChildPage({ childInfo: this.info1, state_value: this.label1 }) // 创建自定义组件。
        43.       Line()
        44.         .width('100%')
        45.         .height(5)
        46.         .backgroundColor('#000000').margin(10)
        47.       Text(`info2: ${this.info2.name}  ${this.info2.age}`) // Text2。
        48.         .fontSize(30)
        49.         .fontWeight(FontWeight.Bold)
        50.       // 同上，在父组件创建子组件的过程中进行构造赋值。
        51.       ChildPage({ childInfo: this.info2, state_value: this.label2 }) // 创建自定义组件。
        52.       Line()
        53.         .width('100%')
        54.         .height(5)
        55.         .backgroundColor('#000000').margin(10)
        56.       Button('change info1&info2')
        57.         .onClick(() => {
        58.           this.info1 = { name: 'Cat', age: 18 }; // Text1不会刷新，原因是info1没有装饰器装饰，监听不到值的改变。
        59.           this.info2 = { name: 'Cat', age: 18 }; // Text2会刷新，原因是info2有装饰器装饰，能够监听到值的改变。
        60.           this.label1 = 'Luck'; // 不会刷新，原因是label1没有装饰器装饰，监听不到值的改变。
        61.           this.label2 = 'Luck'; // 会刷新，原因是label2有装饰器装饰，可以监听到值的改变。
        62.         })
        63.     }
        64.   }
        65. }
    
    

从API version 18开始，使用@Require装饰@State、@Prop、@Provide装饰的状态变量，可以在无本地初始值的情况下直接在组件内使用，不会编译报错。
      
      1. @Entry
        2. @Component
        3. struct Index {
        4.   message: string = 'Hello World';
        5. 
         
        6.   build() {
        7.     Column() {
        8.       Child({ message: this.message })
        9.     }
        10.   }
        11. }
        12. 
         
        13. @Component
        14. struct Child {
        15.   @Require @State message: string;
        16. 
         
        17.   build() {
        18.     Column() {
        19.       Text(this.message) // 从API version 18开始，可以编译通过。
        20.     }
        21.   }
        22. }

### 相关链接

- [版本说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/overview-503-beta1?istab=1&m=1)
- [指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide?istab=1&m=1)
- [API参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/development-intro-api?istab=1&m=1)
- [FAQ](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit?istab=1&m=1)
- [变更预告](https://developer.huawei.com/consumer/cn/doc/harmonyos-roadmap/changelogs-pre?istab=1&m=1)
- [Ability Kit（程序框架服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ability-kit)
- [Accessibility Kit (无障碍服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/accessibility-kit)
- [ArkData（方舟数据管理）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkdata)
- [ArkTS（方舟编程语言）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts)
- [ArkUI（方舟UI框架）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [ArkUI简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-overview)


---

