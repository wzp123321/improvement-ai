import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// 沙箱自己的 Vite 配置：`vite` 与 `@vitejs/plugin-vue` 从**项目的** node_modules 解析
// （Node 向上查找天然支持，不需要在这里再装一份，也不需要 package.json）——
// 用的是项目同版本的 Vue 与编译器，这正是「跑在项目里」的意义。
//
// 不配置 alias：原型不 import 项目代码（`@/` 取不到也不该取），它只依赖组件库。
// 若某原型确实需要项目内的类型，走 `_notes.md` 记成未决问题，不要在沙箱里搭桥。
export default defineConfig({
  plugins: [vue()],
  server: {
    // 端口与项目 dev server 错开，避免同时跑时抢占。
    // 项目若已占用此端口，改这里即可；不要为此改项目配置。
    port: 5199,
    host: '127.0.0.1',
  },
})
