<template>
  <div class="confidence_annotator">
    <div
      class="switch-radio separate-bottom"
      v-if="preferences">
      <template
      v-for="(item, index) in tabOptions">
        <template
        v-if="item == 'new' || preferences[item].length && preferences[item].find(keyword => { return !confidenceAlreadyCreated(keyword) })">
          <input
            v-model="view"
            :value="item"
            :id="`switch-picker-${index}`"
            name="switch-picker-options"
            type="radio"
            class="normal-input button-active"
          >
          <label
            :for="`switch-picker-${index}`"
            class="capitalize">{{ item }}
          </label>
        </template>
      </template>
    </div>

    <template
    v-if="preferences && view != 'new' && view != 'all'">
      <div class="field separate-bottom">
        <template
        v-for="keyword in preferences[view]">
          <button
            v-if="!confidenceAlreadyCreated(keyword)"
            @click="createNewWithId(keyword.id)"
            type="button"
            class="normal-input button-submit tag_button">
            {{ keyword.name }}
          </button>
        </template>
      </div>
    </template>

    <modal
      class="transparent-modal"
      v-if="view == 'all'"
      @close="view = 'new'">
      <h3 slot="header">Confidence level</h3>
      <div slot="body">
        <template v-for="keyword in preferences[view]">
          <button v-if="!confidenceAlreadyCreated(keyword)" @click="createNewWithId(keyword.id)" type="button"
                  class="normal-input button-submit tag_button"> {{ keyword.name }}
          </button>
        </template>
      </div>
    </modal>

    <template v-if="view == 'new'">
      <autocomplete
        url="/confidence_levels/autocomplete"
        label="label"
        min="2"
        placeholder="Confidence level"
        @getInput="confidence.confidence_level_attributes.name = $event"
        @getItem="createNewWithId($event.id)"
        class="separate-bottom"
        param="term"/>
      <textarea class="separate-bottom" placeholder="Definition... (minimum is 20 characters)"
                v-model="confidence.confidence_level_attributes.definition"/>
      <div>
        <button @click="createNew()" :disabled="!validateFields"
                class="button button-submit normal-input separate-bottom" type="button">Create
        </button>
      </div>
    </template>
    <display-list :label="['confidence_level', 'object_tag']" :list="list" @delete="removeItem" class="list"/>
  </div>
</template>
<script>

  import CRUD from '../request/crud.js'
  import annotatorExtend from '../components/annotatorExtend.js'
  import autocomplete from '../../autocomplete.vue'
  import modal from '../../modal.vue'
  import displayList from './displayList.vue'

  export default {
    mixins: [CRUD, annotatorExtend],
    components: {
      autocomplete,
      modal,
      displayList
    },
    computed: {
      validateFields() {
        return this.confidence.confidence_level_attributes.name &&
          this.confidence.confidence_level_attributes.definition
      }
    },
    data: function () {
      return {
        preferences: undefined,
        view: 'quick',
        tabOptions: ['quick', 'recent', 'pinboard', 'all', 'new'],
        confidence: this.newConfidence()
      }
    },
    mounted: function () {
      this.loadTabList('ConfidenceLevel')
    },
    methods: {
      newConfidence() {
        return {
          confidence_level_attributes: {
            name: '',
            definition: ''
          },
          annotated_global_entity: decodeURIComponent(this.globalId)
        }
      },
      loadTabList(type) {
        let tabList
        let allList
        let promises = []
        let that = this

        promises.push(this.getList(`/confidence_levels/select_options?klass=${this.objectType}`).then(response => {
          tabList = response.body
        }))
        promises.push(this.getList(`/controlled_vocabulary_terms.json?of_type[]=${type}`).then(response => {
          allList = response.body
        }))

        Promise.all(promises).then(() => {
          tabList['all'] = allList
          that.preferences = tabList
        })
      },
      createNew() {
        this.create('/confidences', {confidence: this.confidence}).then(response => {
          this.confidence = this.newConfidence()
          this.list.push(response.body)
        })
      },
      createNewWithId(id) {
        this.create('/confidences', {
          confidence: {
            confidence_level_id: id,
            annotated_global_entity: decodeURIComponent(this.globalId)
          }
        }).then(response => {
          this.confidence = this.newConfidence()
          this.list.push(response.body)
        })
      },
      confidenceAlreadyCreated(confidence) {
        return this.list.find(item => {
          return confidence.id == item.confidence_level_id
        })
      }
    }
  }
</script>
<style type="text/css" lang="scss">
  .radial-annotator {
    .confidence_annotator {
      textarea {
        padding-top: 14px;
        padding-bottom: 14px;
        width: 100%;
        height: 100px;
      }
      .vue-autocomplete-input {
        width: 100%;
      }
    }
  }
</style>
