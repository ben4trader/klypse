<script setup lang="ts">
import { onMounted, Ref, ref } from 'vue';
import { Bars3Icon } from '@heroicons/vue/24/outline'
import { useAccount, UserSession, isLoggedIn } from '../../state/account';
import { useConfig } from '../../config';
import { ClientOnly } from '../ClientOnly';

// Import your logo image
import logoImage from '../../assets/images/klypse-logo.png';
import SectionMenu from './SectionMenu.vue';

const mobileMenuOpen = ref(false)

const config = useConfig();
const account = ref<Ref<UserSession | undefined>>();
const betaFlag = ref<boolean>(config.betaFlag);

onMounted(async () => {
  account.value = await useAccount();
});

</script>

<template>
  <header class="relative z-50 flex flex-none flex-col mt-3">
    <div class="top-0 z-10 h-16 pt-1">
      <div class="sm:px-8 w-full ">
        <div class="mx-auto w-full max-w-7xl lg:px-8">
          <div class="relative px-4 sm:px-8 lg:px-12">
            <div class="mx-auto max-w-2xl lg:max-w-5xl">
              <div class="relative flex gap-2 items-center">
                <div class="flex flex-1 items-center">
                  <router-link to="/" class="flex items-center">
                    <img 
                      :src="logoImage" 
                      alt="Klypse" 
                      class="klypse-logo-img h-12 sm:h-16 md:h-20"
                    />
                  </router-link>
                </div>

                <div class="hidden sm:flex flex-1 justify-end md:justify-center">
                </div>

                <ClientOnly>
                  <div class="flex justify-end md:flex-1 pointer-events-auto">
                    <slot>
                      <router-link v-if="isLoggedIn()" to="/write" 
                      class="sm:inline-flex justify-center rounded-full py-0.5
                      px-3 sm:px-4 text-sm sm:text-md text-white font-semibold
                      bg-indigo-600 hover:bg-indigo-500 whitespace-nowrap transition-colors">New Post</router-link>
                    </slot>

                    <div v-if="betaFlag && isLoggedIn()"
                      class="ml-4 pl-4 sm:ml-6 sm:pl-6 flex items-center border-l border-zinc-700/30">
                      <div class="relative" data-headlessui-state="">
                        <button type="button"
                          class="lg:hidden inline-flex items-center justify-center rounded-md text-gray-300 hover:text-white"
                          @click="mobileMenuOpen = true">
                          <span class="sr-only">Open main menu</span>
                          <Bars3Icon class="h-6 w-6" aria-hidden="true" />
                        </button>

                        <button @click="mobileMenuOpen = true"
                          class="hidden lg:flex items-center font-semibold text-gray-300 hover:text-white"
                          id="headlessui-menu-button-1" type="button" aria-haspopup="menu" aria-expanded="false"
                          data-headlessui-state="">
                          <span class="hidden items-center sm:flex">Account<svg aria-hidden="true" fill="none"
                              xmlns="http://www.w3.org/2000/svg" class="ml-3 h-3 w-3 stroke-slate-400">
                              <path d="M9.75 4.125 6 7.875l-3.75-3.75" stroke-width="1.5" stroke-linecap="round"
                                stroke-linejoin="round"></path>
                            </svg>
                          </span>
                        </button>
                      </div>
                    </div>

                  </div>
                </ClientOnly>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>


  <SectionMenu v-if="mobileMenuOpen" @close="mobileMenuOpen = false" />

</template>

<style>
.klypse-logo-img {
  transition: filter 0.5s ease;
}

/* Optional: Add a subtle glow animation to the logo */
@keyframes logoGlow {
  0%, 100% {
    filter: drop-shadow(0 0 2px rgba(165, 180, 252, 0.3));
  }
  50% {
    filter: drop-shadow(0 0 8px rgba(165, 180, 252, 0.6));
  }
}

/* Apply the animation */
.klypse-logo-img:hover {
  animation: logoGlow 3s infinite;
}
</style>