<template>
  <div :class="cn('animate-pulse rounded-md bg-slate-200', $attrs.class as string ?? '')" v-bind="$attrs" />
</template>

<script setup lang="ts">
import { cn } from '@/lib/utils'
</script>