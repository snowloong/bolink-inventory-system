/*** 
 * @Author: yaoruidong yaord@meix.com
 * @Date: 2025-07-28 23:56:29
 * @LastEditors: yaoruidong yaord@meix.com
 * @LastEditTime: 2025-07-29 00:03:13
 * @FilePath: /bolink-inventory-system/desktop/src/store/index.js
 * @Description: 
 * @
 */
/*** 
 * @Author: yaoruidong yaord@meix.com
 * @Date: 2025-07-28 23:56:29
 * @LastEditors: yaoruidong yaord@meix.com
 * @LastEditTime: 2025-07-29 00:03:05
 * @FilePath: /bolink-inventory-system/desktop/src/store/index.js
 * @Description: 
 * @
 */
import { configureStore } from '@reduxjs/toolkit'
import authReducer from './slices/authSlice'
import productReducer from './slices/productSlice'
import inventoryReducer from './slices/inventorySlice'

export const store = configureStore({
  reducer: {
    auth: authReducer,
    products: productReducer,
    inventory: inventoryReducer,
  },
})

// TODO: 实现认证状态管理
// TODO: 实现产品状态管理
// TODO: 实现库存状态管理
// TODO: 实现持久化存储 