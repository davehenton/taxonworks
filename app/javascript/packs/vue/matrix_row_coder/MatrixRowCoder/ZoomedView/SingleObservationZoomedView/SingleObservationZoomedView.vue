<template>
  <zoomed-view :descriptor="descriptor">
    <div class="single-observation-zoomed-view">
      <div class="single-observation-zoomed-view__descriptor-details">
        <h2 class="single-observation-zoomed-view__descriptor-title">{{ descriptor.title }}</h2>
        <slot/>
        <descriptor-details :descriptor="descriptor"/>
      </div>
      <div
        v-if="observation"
        class="single-observation-zoomed-view__observation-details">

        <observation-details :observation="observation"/>
      </div>
    </div>
  </zoomed-view>
</template>

<style src="./SingleObservationZoomedView.styl" lang="stylus"></style>

<script>
import observationDetails from '../../ObservationDetails/ObservationDetails.vue'
import descriptorDetails from '../../DescriptorDetails/DescriptorDetails.vue'
import zoomedView from '../ZoomedView.vue'

export default {
  name: 'SingleObservationZoomedView',
  props: ['descriptor', 'observation'],
  components: {
    observationDetails,
    descriptorDetails,
    zoomedView
  }
}
</script>
