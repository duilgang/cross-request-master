// 浏览器API兼容层 - 支持Chrome和夸克浏览器
(function (global) {
  'use strict';

  // 检查并创建统一的浏览器API命名空间
  let browserAPI = global.browser || global.chrome || global.browser || {};

  // 如果全局没有browser命名空间但有chrome，则尝试兼容
  if (!global.browser && global.chrome) {
    // 创建browser兼容层
    global.browser = {
      // 复制chrome API
      runtime: global.chrome.runtime,
      storage: global.chrome.storage,
      tabs: global.chrome.tabs,
      
      // Promise 化的 API
      storage: {
        local: {
          get: function(keys) {
            return new Promise((resolve, reject) => {
              global.chrome.storage.local.get(keys, (result) => {
                if (global.chrome.runtime.lastError) {
                  reject(global.chrome.runtime.lastError);
                } else {
                  resolve(result);
                }
              });
            });
          },
          set: function(items) {
            return new Promise((resolve, reject) => {
              global.chrome.storage.local.set(items, () => {
                if (global.chrome.runtime.lastError) {
                  reject(global.chrome.runtime.lastError);
                } else {
                  resolve();
                }
              });
            });
          }
        }
      },
      
      tabs: {
        query: function(queryInfo) {
          return new Promise((resolve, reject) => {
            global.chrome.tabs.query(queryInfo, (result) => {
              if (global.chrome.runtime.lastError) {
                reject(global.chrome.runtime.lastError);
              } else {
                resolve(result);
              }
            });
          });
        },
        sendMessage: function(tabId, message) {
          return new Promise((resolve, reject) => {
            global.chrome.tabs.sendMessage(tabId, message, (response) => {
              if (global.chrome.runtime.lastError) {
                reject(global.chrome.runtime.lastError);
              } else {
                resolve(response);
              }
            });
          });
        }
      },
      
      runtime: {
        // 保持原有的 API
        ...global.chrome.runtime,
        
        // 添加 Promise 版本
        sendMessage: function(message) {
          return new Promise((resolve, reject) => {
            global.chrome.runtime.sendMessage(message, (response) => {
              if (global.chrome.runtime.lastError) {
                reject(global.chrome.runtime.lastError);
              } else {
                resolve(response);
              }
            });
          });
        }
      }
    };
    
    browserAPI = global.browser;
  }

  // 暴露统一的API接口
  global.CrossRequestBrowserAPI = browserAPI;

  // 对于 background.js 和 popup.js，替换原生 chrome 调用
  if (typeof global.chrome !== 'undefined') {
    // 为兼容性保留 chrome API 检查
    global.ChromeAPI = global.chrome;
  }

})(typeof window !== 'undefined' ? window : typeof global !== 'undefined' ? global : this);