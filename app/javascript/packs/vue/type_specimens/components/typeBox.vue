<template>
  <div id="typeBox">
    <div class="panel separate-bottom">
      <div class="content header">
        <h3
          v-if="taxon.id"
          class="flex-separate middle">
          <a
            :href="`/tasks/nomenclature/browse/${taxon.id}`"
            target="_blank"
            class="taxonname">
            <span v-html="taxon.cached_html"/>
            <span v-html="taxon.cached_author_year"/>
          </a>
          <div class="taxon-options">
            <radial-annotator :global-id="taxon.global_id"/>
          </div>
        </h3>
        <span
          v-if="typeMaterial.id"
          v-html="typeMaterial.object_tag"/>
      </div>
    </div>
    <div
      class="panel content"
      v-if="typesMaterial.length">
      <button
        type="button"
        @click="newType"
        class="button normal-input button-default">New type</button>
      <display-list
        :highlight="{ value: typeMaterial.id, key: 'id' }"
        :list="typesMaterial"
        :annotator="true"
        :edit="true"
        @edit="setTypeMaterial"
        @delete="removeTypeSpecimen"
        label="type_type"/>
    </div>
  </div>
</template>
<script>

import displayList from '../../components/displayList.vue'
import radialAnnotator from '../../components/annotator/annotator.vue'
import { GetterNames } from '../store/getters/getters'
import ActionNames from '../store/actions/actionNames'

export default {
  components: {
    radialAnnotator,
    displayList
  },
  computed: {
    typeMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterial]
    },
    typesMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterials]
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  methods: {
    reloadPage () {
      window.location.href = '/tasks/type_material/edit_type_material'
    },
    removeTypeSpecimen (item) {
      this.$store.dispatch(ActionNames.RemoveTypeSpecimen, item.id)
    },
    setTypeMaterial (material) {
      this.$store.dispatch(ActionNames.LoadTypeMaterial, material)
    },
    newType () {
      this.$store.dispatch(ActionNames.SetNewTypeMaterial)
    }
  }
}
</script>
<style lang="scss" scoped>
  .taxon-options {
    display: flex;
    justify-content: space-between;
  }
  .radial-annotator {
    width:30px;
    margin-left: 14px;
  }
  .header {
    padding: 1em;
    border: 1px solid #f5f5f5;
    .circle-button {
     margin: 0px;
   }
  }
  .taxonname {
    font-size: 14px;
  }
</style>
