import React from 'react'
import { Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import Dashboard from './pages/dashboard'
import Products from './pages/products'
import Inventory from './pages/inventory'
import Purchase from './pages/purchase'
import Sales from './pages/sales'
import Reports from './pages/reports'

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/products" element={<Products />} />
        <Route path="/inventory" element={<Inventory />} />
        <Route path="/purchase" element={<Purchase />} />
        <Route path="/sales" element={<Sales />} />
        <Route path="/reports" element={<Reports />} />
      </Routes>
    </Layout>
  )
}

export default App

// TODO: 实现应用初始化逻辑
// TODO: 实现全局状态管理
// TODO: 实现主题切换 