<template>
  <div id="new_taxon_name_task">
    <h1>{{ (getTaxon.id ? 'Edit' : 'New') }} taxon name</h1>
    <div>
      <nav-header :menu="menu"/>
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item separate-right">
          <spinner
            :full-screen="true"
            :legend="(loading ? 'Loading...' : 'Saving changes...')"
            :logo-size="{ width: '100px', height: '100px'}"
            v-if="loading || getSaving"/>
          <basic-information class="separate-bottom"/>
          <div class="new-taxon-name-block">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <source-picker class="separate-top separate-bottom"/>
          </div>
          <div class="new-taxon-name-block">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <status-picker class="separate-top separate-bottom"/>
          </div>
          <div class="new-taxon-name-block">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <relationship-picker class="separate-top separate-bottom"/>
          </div>
          <div class="new-taxon-name-block">
            <type-block
              v-if="getTaxon.id && showForThisGroup(['FamilyGroup','GenusGroup', 'SpeciesGroup'], getTaxon)"
              class="separate-top separate-bottom"/>
          </div>
          <div
            class="new-taxon-name-block"
            v-if="showForThisGroup(['SpeciesGroup','GenusGroup'], getTaxon)">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <block-layout anchor="original-combination">
              <h3 slot="header">Original Combination</h3>
              <div slot="body">
                <pick-original-combination/>
              </div>
            </block-layout>
          </div>
          <div
            class="new-taxon-name-block"
            v-if="showForThisGroup(['SpeciesGroup','GenusGroup'], getTaxon)">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <gender-block class="separate-top separate-bottom"/>
          </div>
          <div
            class="new-taxon-name-block"
            v-if="getTaxon.id && showForThisGroup(['SpeciesGroup','GenusGroup'], getTaxon)">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <etymology class="separate-top separate-bottom"/>
          </div>
        </div>
        <div
          v-if="getTaxon.id"
          class="cright item separate-left">
          <div id="cright-panel">
            <check-changes/>
            <taxon-name-box class="separate-bottom"/>
            <soft-validation class="separate-top"/>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import showForThisGroup from './helpers/showForThisGroup'
var sourcePicker = require('./components/sourcePicker.vue').default
var relationshipPicker = require('./components/relationshipPicker.vue').default
var statusPicker = require('./components/statusPicker.vue').default
var navHeader = require('./components/navHeader.vue').default
var taxonNameBox = require('./components/taxonNameBox.vue').default
var etymology = require('./components/etymology.vue').default
var genderBlock = require('./components/gender.vue').default
var checkChanges = require('./components/checkChanges.vue').default
var typeBlock = require('./components/type.vue').default
var basicInformation = require('./components/basicInformation.vue').default
var originalCombination = require('./components/originalCombination.vue').default
var pickOriginalCombination = require('./components/pickOriginalCombination.vue').default

var softValidation = require('./components/softValidation.vue').default
var spinner = require('../../components/spinner.vue').default
var blockLayout = require('./components/blockLayout').default

const GetterNames = require('./store/getters/getters').GetterNames
const ActionNames = require('./store/actions/actions').ActionNames

export default {
  components: {
    etymology,
    sourcePicker,
    spinner,
    navHeader,
    statusPicker,
    taxonNameBox,
    relationshipPicker,
    basicInformation,
    softValidation,
    blockLayout,
    originalCombination,
    pickOriginalCombination,
    typeBlock,
    genderBlock,
    checkChanges
  },
  computed: {
    getTaxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    getSaving () {
      return this.$store.getters[GetterNames.GetSaving]
    },
    menu () {
      return {
        'Basic information': true,
        'Author': true,
        'Status': true,
        'Relationship': true,
        'Type': showForThisGroup(['SpeciesGroup', 'GenusGroup', 'FamilyGroup'], this.getTaxon),
        'Original combination': showForThisGroup(['SpeciesGroup', 'GenusGroup'], this.getTaxon),
        'Etymology': showForThisGroup(['SpeciesGroup', 'GenusGroup'], this.getTaxon),
        'Gender': showForThisGroup(['SpeciesGroup', 'GenusGroup'], this.getTaxon)
      }
    }
  },
  data: function () {
    return {
      loading: true
    }
  },
  mounted: function () {
    var that = this

    $(window).scroll(function () {
      let element = document.querySelector('#cright-panel')
      if (element) {
        if (($(window).scrollTop() > 154) && (that.isMinor())) {
          element.classList.add('cright-fixed-top')
        } else {
          element.classList.remove('cright-fixed-top')
        }
      }
    })

    let taxonId = location.pathname.split('/')[4]
    this.initLoad().then(function () {
      if (/^\d+$/.test(taxonId)) {
        that.$store.dispatch(ActionNames.LoadTaxonName, taxonId).then(function () {
          that.$store.dispatch(ActionNames.LoadTaxonStatus, taxonId)
          that.$store.dispatch(ActionNames.LoadTaxonRelationships, taxonId)
          that.loading = false
        })
      } else {
        that.loading = false
      }
    })
  },
  methods: {
    isMinor: function () {
      let element = document.querySelector('#cright-panel')
      let navBar = document.querySelector('#taxonNavBar')

      if (element && navBar) {
        return ((element.offsetHeight + navBar.offsetHeight) < window.innerHeight)
      } else {
        return true
      }
    },
    showForThisGroup: showForThisGroup,
    initLoad: function () {
      let actions = [
        this.$store.dispatch(ActionNames.LoadRanks),
        this.$store.dispatch(ActionNames.LoadStatus),
        this.$store.dispatch(ActionNames.LoadRelationships)
      ]
      return new Promise(function (resolve, reject) {
        Promise.all(actions).then(function () {
          return resolve(true)
        })
      })
    }
  }
}

</script>
<style lang="scss">
  #new_taxon_name_task {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;
    max-width: 1240px;

    .cleft, .cright {
      min-width: 350px;
      max-width: 350px;
      width: 300px;
    }
    #cright-panel {
      width: 350px;
      max-width: 350px;
    }
    .cright-fixed-top {
      top:68px;
      width: 1240px;
      z-index:200;
      position: fixed;
    }
    .anchor {
       display:block;
       height:65px;
       margin-top:-65px;
       visibility:hidden;
    }
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }
  }

</style>
