# ArkTS 学习资料汇总

> 整理时间: 2025-11-07 21:00:00
> 来源: 华为开发者网站 (https://developer.huawei.com/consumer/cn/)
> 说明: 基于公开搜索结果整理的ArkTS相关资料

---

## 目录

1. [ArkTS 语言概述](#1-arkts-语言概述)
2. [ArkTS 设计理念](#2-arkts-设计理念)
3. [ArkTS 相比 TypeScript 的特性差异](#3-arkts-相比-typescript-的特性差异)
4. [ArkTS 基本语法组成](#4-arkts-基本语法组成)
5. [ArkTS 扩展语法范式](#5-arkts-扩展语法范式)
6. [学习资源链接](#6-学习资源链接)
7. [相关视频教程](#7-相关视频教程)

---

## 1. ArkTS 语言概述

ArkTS是鸿蒙生态的应用开发语言，在保持TypeScript（简称TS）基本语法风格的基础上，进一步通过规范强化静态检查和分析，使得在程序运行之前的开发期能检测更多错误，并提升运行时性能。

### 主要特性

- **静态检查强化**: 在开发期检测更多错误，降低运行时错误风险
- **性能优化**: 减少运行时类型检查，降低运行时负载
- **并发能力增强**: 针对JavaScript/TS并发能力支持有限的问题，ArkTS对并发编程API和能力进行了增强
- **生态兼容**: 支持与JS/TS高效互操作，兼容JS/TS生态
- **语法保留**: 保留了TS大部分的语法特性，易于上手

### 适用场景

ArkTS主要用于HarmonyOS应用开发，从HarmonyOS NEXT Developer Preview 0版本开始成为主要的开发语言。

---

## 2. ArkTS 设计理念

为更好地支持HarmonyOS应用的开发和运行，ArkTS在TS的基础上，进一步通过规范强化静态检查和分析，这样做有两个好处：

1. **编译时错误检测**: 许多错误在编译时可以被检测出来，不用等到运行时，这大大降低了代码运行错误的风险，有利于程序的健壮性
2. **运行时性能提升**: 减少运行时的类型检查，从而降低了运行时负载，有助于提升执行性能

ArkTS保留了TS大部分的语法特性，这可以帮助开发者更容易上手ArkTS。同时，对于已有的标准TS代码，仅需对少部分代码进行ArkTS语法适配，大部分代码可以直接复用。

---

## 3. ArkTS 相比 TypeScript 的特性差异

ArkTS通过规范约束了TS中过于灵活而影响开发正确性或者给运行时带来不必要额外开销的特性。

### 3.1 不支持在运行时更改对象布局

**TypeScript/JavaScript 中的做法:**
```typescript
// 可以在运行时动态添加属性
let obj = {};
obj.newProperty = "value";  // 动态添加属性
delete obj.newProperty;     // 动态删除属性
```

**ArkTS 中的约束:**
运行时支持此类特性需要大量的性能开销，ArkTS不支持在运行时更改对象的布局。

**ArkTS 替代方案:**
```typescript
// 使用可选属性
interface MyObject {
  existingProperty: string;
  optionalProperty?: string;  // 可选属性
}

let obj: MyObject = {
  existingProperty: "value"
};

// 通过赋值undefined来替代删除属性
obj.optionalProperty = undefined;
```

### 3.2 对象字面量须标注类型

**TypeScript 中的做法:**
```typescript
// 可以没有类型标注
let point = { x: 10, y: 20 };
```

**ArkTS 中的要求:**
```typescript
// 必须标注类型
interface Point {
  x: number;
  y: number;
}

let point: Point = { x: 10, y: 20 };
```

**原因说明:**
如果编译器不知道变量point的确切类型，由于对象布局不能确定，编译器无法深度地优化这段代码，造成性能瓶颈。没有类型也会造成属性的类型缺少限制，例如point.x的类型在此时为number，它也可以被赋值成其他类型，造成额外的运行时检查和开销。

### 3.3 不支持structural typing

**TypeScript 中的做法:**
```typescript
// structural typing - 只要结构相同就可以赋值
interface C {
  s: string;
}

interface D {
  s: string;
}

function foo(c: C) {
  console.log(c.s);
}

let d: D = { s: "hello" };
foo(d);  // 可以正常工作，因为结构相同
```

**ArkTS 中的约束:**
ArkTS采用了nominal typing类型系统，不支持structural typing。

**原因说明:**
在ArkTS已经采用了nominal typing类型系统的前提下，如果额外支持structural typing给语言实现和开发者均会带来不必要的复杂度。这种灵活性可能不符合开发者的意图，容易带来程序行为的正确性问题。另外，由于类型D和类型C布局不同，那么foo中对c.s这个属性访问就不能被优化成根据固定偏移量访问的方式，从而给运行时性能造成瓶颈。

---

## 4. ArkTS 基本语法组成

以一个具体的示例来说明ArkTS的基本组成。如下图所示，当开发者点击按钮时，文本内容从"Hello World"变为"Hello ArkUI"。

### 4.1 基本组成元素

1. **装饰器 (Decorators)**
   - 用于装饰类、结构、方法以及变量，并赋予其特殊的含义
   - 例如: `@Entry`、`@Component`、`@State`
   - `@Component`表示自定义组件
   - `@Entry`表示该自定义组件为入口组件
   - `@State`表示组件中的状态变量，状态变量变化会触发UI刷新

2. **UI描述 (UI Description)**
   - 以声明式的方式来描述UI的结构
   - 例如: `build()`方法中的代码块

3. **自定义组件 (Custom Components)**
   - 可复用的UI单元，可组合其他组件
   - 例如: 被`@Component`装饰的`struct Hello`

4. **系统组件 (System Components)**
   - ArkUI框架中默认内置的基础和容器组件
   - 可直接被开发者调用
   - 例如: `Column`、`Text`、`Divider`、`Button`

5. **属性方法 (Property Methods)**
   - 组件可以通过链式调用配置多项属性
   - 例如: `fontSize()`、`width()`、`height()`、`backgroundColor()`

6. **事件方法 (Event Methods)**
   - 组件可以通过链式调用设置多个事件的响应逻辑
   - 例如: 跟随在`Button`后面的`onClick()`

### 4.2 重要约束

- **自定义变量命名**: 自定义变量不能与基础通用属性/事件名重复

---

## 5. ArkTS 扩展语法范式

ArkTS扩展了多种语法范式来使开发更加便捷：

### 5.1 @Builder/@BuilderParam
- **作用**: 特殊的封装UI描述的方法
- **用途**: 细粒度的封装和复用UI描述

### 5.2 @Extend/@Styles
- **作用**: 扩展内置组件和封装属性样式
- **用途**: 更灵活地组合内置组件

### 5.3 stateStyles
- **作用**: 多态样式
- **用途**: 可以依据组件的内部状态的不同，设置不同样式

---

## 6. 学习资源链接

### 6.1 官方文档
- [ArkTS语言介绍](https://developer.huawei.com/consumer/cn/arkts/) - ArkTS语言官方介绍页面
- [ArkTS基本语法概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-basic-syntax-overview-0000001531611153-V2) - 官方语法指南
- [ArkTS入门指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts) - 初学者入门指南

### 6.2 相关论坛话题
- [HarmonyOS/OpenHarmony应用开发-ArkTS语言基本语法说明](https://developer.huawei.com/consumer/cn/forum/topic/0207120995607635039) - 开发者社区讨论

---

## 7. 相关视频教程

### 7.1 官方视频课程
- [ArkTS基础语法视频教程](https://developer.huawei.com/consumer/cn/training/course/video/C101677067459311952)
  - 时长: 11分钟
  - 评分: 4.7分
  - 内容: 讲解ArkTS基础语法，以及数据类型案例介绍
  - 观看人数: 8.2K

### 7.2 在线课程
- [HarmonyOS第一课 - ArkTS语法介绍](https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717496870909384)
  - 类型: 在线MOOC课程
  - 内容: 系统的ArkTS语法介绍

---

## 8. 开发建议

### 8.1 学习路径建议
1. **TypeScript基础**: 确保有良好的TypeScript基础
2. **ArkTS特性理解**: 重点理解ArkTS与TS的差异
3. **实践练习**: 通过实际项目练习ArkTS语法
4. **官方文档**: 经常查阅官方文档获取最新信息

### 8.2 迁移建议
- 现有TS代码大部分可以直接复用
- 重点关注对象类型标注和静态类型约束
- 避免使用运行时动态特性
- 充分利用ArkTS的装饰器和声明式UI特性

### 8.3 性能优化建议
- 始终为对象字面量标注类型
- 避免运行时对象布局变更
- 使用nominal typing而非structural typing
- 充分利用编译时错误检测

---

## 9. 总结

ArkTS作为HarmonyOS生态的应用开发语言，在保持TypeScript语法风格的基础上，通过强化静态检查和约束，提供了更好的开发体验和运行时性能。开发者可以通过学习ArkTS的特性和最佳实践，更高效地开发HarmonyOS应用。

建议开发者从官方文档和视频教程开始，结合实际项目进行练习，逐步掌握ArkTS的开发技巧。同时关注官方更新，及时了解新特性和最佳实践。

---

*本资料汇总基于华为开发者网站公开信息整理，如有更新请以官方文档为准。*

