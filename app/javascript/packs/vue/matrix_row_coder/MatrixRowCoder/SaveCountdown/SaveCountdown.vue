<template>
  <div class="save-countdown">
    <transition
      name="save-countdown__duration-bar-animation"
      @after-enter="doSave">

      <div
        v-if="isCountingDown"
        class="save-countdown__duration-bar"/>
    </transition>

    <div
      v-if="!isCountingDown"
      class="save-countdown__status-bar"
      :class="{ 'save-countdown__status-bar--saving': isSaving, 'save-countdown__status-bar--saved-at-least-once': savedAtLeastOnce }"/>

    <button
      class="save-countdown__save-button"
      :class="{ 'save-countdown__save-button--showing': isCountingDown }"
      @click="doSave"
      type="button">

      Save Changes
    </button>
  </div>
</template>

<style src="./SaveCountdown.styl" lang="stylus"></style>

<script>
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'

export default {
  name: 'SaveCountdown',
  props: ['descriptor'],
  data: function () {
    return {
      isCountingDown: false
    }
  },
  computed: {
    needsCountdown: function () {
      return this.$store.getters[GetterNames.DoesDescriptorNeedCountdown](this.$props.descriptor.id)
    },
    isSaving: function () {
      return this.$props.descriptor.isSaving
    },
    savedAtLeastOnce: function () {
      return this.$props.descriptor.hasSavedAtLeastOnce
    }
  },
  methods: {
    doSave () {
      this.isCountingDown = false
      this.$store.dispatch(ActionNames.SaveObservationsFor, this.$props.descriptor.id)
    }
  },
  watch: {
    needsCountdown: function (needsCountdown) {
      if (needsCountdown) {
        this.isCountingDown = false
        requestAnimationFrame(_ => {
          this.isCountingDown = true
          this.$store.commit(MutationNames.CountdownStartedFor, this.$props.descriptor.id)
        })
      }
    }
  }
}
</script>
