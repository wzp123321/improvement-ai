// 原型沙箱入口 —— 随原型一起放在 <项目根>/prototype/。
// 它只做三件事：引组件库、整体安装、挂载当前原型。不要在这里写业务逻辑。
//
// 与项目 src/main.ts 的关系：**照它抄**。组件库的引入路径、主题 CSS、语言包、
// 全局指令，项目怎么引这里就怎么引——原型要验证的是「在项目里长什么样」，
// 沙箱自己另挑一套引法就失去了这个意义。

import { createApp } from 'vue'

// ⚠ 必须**整体安装**组件库，不能只按需 import。
// `te-tablebar` 等组件内部用 resolveComponent('te-search') 按名取子组件，
// 不全局注册时解析失败，渲染成空的未知标签——搜索框整块消失且**不报任何错**。
// 依据：rules/ui-prototype-standard.md §1 接入前提。
import TsWebPackage from '@tiansu/ts-web-package'
import '@tiansu/ts-web-package/dist/index.css'

// ⚠ 每次换原型只改这一行（指向当前要预览的 .vue）。
import Prototype from './S01_页面名.vue'

createApp(Prototype).use(TsWebPackage).mount('#app')
