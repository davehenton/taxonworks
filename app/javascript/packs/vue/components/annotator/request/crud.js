import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)

Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

const ajaxCall = function (type, url, data) {
  return new Promise(function (resolve, reject) {
    Vue.http[type](url, data).then(response => {
      return resolve(response)
    }, response => {
      handleError(response.body)
      return reject(response)
    })
  })
}

const handleError = function (json) {
  if (typeof json !== 'object') return
  let errors = Object.keys(json)
  let errorMessage = ''

  errors.forEach(function (item) {
    errorMessage += json[item].join('<br>')
  })

  TW.workbench.alert.create(errorMessage, 'error')
}

const create = function (url, data) {
  return ajaxCall('post', url, data)
}

const update = function (url, data) {
  return ajaxCall('patch', url, data)
}

const destroy = function (url, data) {
  return ajaxCall('delete', url, data)
}

const getList = function (url) {
  return ajaxCall('get', url, null)
}

const vueCrud = {
  methods: {
    create: create,
    update: update,
    destroy: destroy,
    getList: getList
  }
}

export default vueCrud
