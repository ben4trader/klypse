<script setup lang="ts">
import SectionFooter from '../sections/SectionFooter.vue';
import { onMounted, ref } from 'vue';

// Define types for our star and nebula objects
interface Star {
  type: string;
  top: string;
  left: string;
  delay: string;
  duration: string;
  xMove: number;
  yMove: number;
  pulseSpeed: string;
  opacity: number;
  scale: number;
}

interface Nebula {
  top: string;
  left: string;
  scale: number;
  rotate: number;
  xMove: number;
  yMove: number;
  duration: string;
}

// For the star positions and truly random movements - add proper typing
const starPositions = ref<Star[]>([]);
const nebulaPositions = ref<Nebula[]>([]);

// Generate random star positions with completely random movement angles
const generateRandomStars = (): Star[] => {
  const stars: Star[] = [];
  
  // Generate small stars
  for (let i = 0; i < 15; i++) {
    const angle = Math.random() * 360;
    const distance = 5 + Math.random() * 15; // Random distance between 5-20px
    const xMove = Math.sin(angle * (Math.PI/180)) * distance;
    const yMove = Math.cos(angle * (Math.PI/180)) * distance;
    
    stars.push({
      type: 'small',
      top: `${Math.random() * 100}%`,
      left: `${Math.random() * 100}%`,
      delay: `${Math.random() * 15}s`,
      duration: `${20 + Math.random() * 40}s`, // Random duration between 20-60s
      xMove,
      yMove,
      pulseSpeed: `${3 + Math.random() * 5}s`,
      opacity: 0.3 + Math.random() * 0.6,
      scale: 0.8 + Math.random() * 0.4
    });
  }
  
  // Generate medium stars
  for (let i = 0; i < 10; i++) {
    const angle = Math.random() * 360;
    const distance = 5 + Math.random() * 15;
    const xMove = Math.sin(angle * (Math.PI/180)) * distance;
    const yMove = Math.cos(angle * (Math.PI/180)) * distance;
    
    stars.push({
      type: 'medium',
      top: `${Math.random() * 100}%`,
      left: `${Math.random() * 100}%`,
      delay: `${Math.random() * 15}s`,
      duration: `${20 + Math.random() * 40}s`,
      xMove,
      yMove,
      pulseSpeed: `${4 + Math.random() * 6}s`,
      opacity: 0.4 + Math.random() * 0.5,
      scale: 0.8 + Math.random() * 0.4
    });
  }
  
  // Generate large stars
  for (let i = 0; i < 5; i++) {
    const angle = Math.random() * 360;
    const distance = 5 + Math.random() * 15;
    const xMove = Math.sin(angle * (Math.PI/180)) * distance;
    const yMove = Math.cos(angle * (Math.PI/180)) * distance;
    
    stars.push({
      type: 'large',
      top: `${Math.random() * 100}%`,
      left: `${Math.random() * 100}%`,
      delay: `${Math.random() * 15}s`,
      duration: `${20 + Math.random() * 40}s`,
      xMove,
      yMove,
      pulseSpeed: `${5 + Math.random() * 7}s`,
      opacity: 0.5 + Math.random() * 0.5,
      scale: 0.8 + Math.random() * 0.4
    });
  }
  
  return stars;
};

// Generate random nebula positions
const generateRandomNebulas = (): Nebula[] => {
  const nebulas: Nebula[] = [];
  
  for (let i = 0; i < 3; i++) {
    const angle = Math.random() * 360;
    const distance = 15 + Math.random() * 15;
    const xMove = Math.sin(angle * (Math.PI/180)) * distance;
    const yMove = Math.cos(angle * (Math.PI/180)) * distance;
    
    nebulas.push({
      top: `${Math.random() * 100}%`,
      left: `${Math.random() * 100}%`,
      scale: 0.8 + Math.random() * 0.8,
      rotate: Math.random() * 360,
      xMove,
      yMove,
      duration: `${40 + Math.random() * 20}s`
    });
  }
  
  return nebulas;
};

// Generate the random elements on component creation
starPositions.value = generateRandomStars();
nebulaPositions.value = generateRandomNebulas();

onMounted(() => {
  // Create occasional shooting stars with random angles
  const createRandomShootingStar = () => {
    const cosmos = document.querySelector('.cosmic-nebula-bg');
    if (!cosmos) return;
    
    const star = document.createElement('div');
    star.classList.add('shooting-star-random');
    
    // Random position
    star.style.top = `${Math.random() * 100}%`;
    star.style.left = `${Math.random() * 100}%`;
    
    // Random direction
    const angle = Math.random() * 360;
    const distance = 300 + Math.random() * 200;
    const duration = 2 + Math.random() * 2;
    
    // Set random speed and direction via custom properties
    star.style.setProperty('--angle', `${angle}deg`);
    star.style.setProperty('--distance', `${distance}px`);
    star.style.setProperty('--duration', `${duration}s`);
    
    cosmos.appendChild(star);
    
    // Remove after animation completes
    setTimeout(() => {
      star.remove();
    }, duration * 1000 + 100);
  };
  
  // Create random shooting stars occasionally
  setInterval(createRandomShootingStar, 10000 + Math.random() * 8000);
  
  // Create an initial shooting star
  setTimeout(createRandomShootingStar, 2000);
});
</script>

<template>
  <div class="flex w-full min-h-screen">
    <!-- Make the cosmic background cover the entire viewport -->
    <div class="fixed inset-0 cosmic-nebula-bg">
      <!-- Fixed elements for the background -->
      <div class="cosmic-particles"></div>
      
      <!-- Randomly positioned stars with custom animations for each -->
      <div
        v-for="(star, index) in starPositions"
        :key="`star-${index}`"
        :class="`star-${star.type}`"
        :style="{
          top: star.top, 
          left: star.left,
          animationDelay: star.delay,
          '--x-move': `${star.xMove}px`,
          '--y-move': `${star.yMove}px`,
          '--duration': star.duration,
          '--pulse-speed': star.pulseSpeed,
          '--max-opacity': star.opacity,
          '--scale': star.scale
        }"
      ></div>
      
      <!-- Randomly positioned nebula clouds with custom animations -->
      <div
        v-for="(nebula, index) in nebulaPositions"
        :key="`nebula-${index}`"
        class="nebula-cloud"
        :style="{
          top: nebula.top,
          left: nebula.left,
          transform: `scale(${nebula.scale}) rotate(${nebula.rotate}deg)`,
          '--x-move': `${nebula.xMove}px`,
          '--y-move': `${nebula.yMove}px`,
          '--duration': nebula.duration
        }"
      ></div>
    </div>

    <!-- Keep the content container structure -->
    <div class="relative flex w-full flex-col">
      <slot name="header" />

      <main class="flex-grow">
        <!-- Main content -->
        <div class="sm:px-8 mt-0 lg:mt-20">
          <div class="mx-auto w-full max-w-7xl lg:px-8">
            <div class="relative px-4 sm:px-8 lg:px-12">
              <div class="mx-auto max-w-2xl lg:max-w-5xl">
                <div class="xl:relative">
                  <div class="mx-auto max-w-2xl">
                    <article>
                      <slot name="main" />
                    </article>
                  </div>
                </div>
              </div>
            </div>
            <slot name="cta" />
          </div>
        </div>
      </main>

      <SectionFooter />
    </div>
  </div>
</template>

<style>
/* Advanced cosmic background with black gradient - now covering full viewport */
.cosmic-nebula-bg {
  position: fixed;
  width: 100%;
  height: 100%;
  background: linear-gradient(125deg, #000000 0%, #080818 25%, #101025 50%, #080818 75%, #000000 100%);
  overflow: hidden;
  z-index: -1; /* Ensure the background stays behind content */
}

/* Stellar nebula effect with first pseudo-element */
.cosmic-nebula-bg::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 20% 30%, rgba(147, 51, 234, 0.12) 0%, transparent 40%),
    radial-gradient(circle at 80% 60%, rgba(79, 70, 229, 0.12) 0%, transparent 50%),
    radial-gradient(circle at 40% 80%, rgba(59, 130, 246, 0.1) 0%, transparent 45%),
    radial-gradient(circle at 60% 10%, rgba(236, 72, 153, 0.12) 0%, transparent 35%);
  filter: blur(8px);
  opacity: 0.6;
  mix-blend-mode: screen;
  animation: nebulaPulse 25s ease-in-out infinite alternate;
}

/* Star field effect with second pseudo-element */
.cosmic-nebula-bg::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(1px at 50% 10%, white, transparent),
    radial-gradient(1px at 80% 20%, white, transparent),
    radial-gradient(1px at 15% 30%, white, transparent),
    radial-gradient(1px at 33% 80%, white, transparent),
    radial-gradient(1px at 70% 40%, white, transparent),
    radial-gradient(1px at 90% 15%, white, transparent),
    radial-gradient(1px at 45% 50%, white, transparent),
    radial-gradient(1px at 10% 90%, white, transparent);
  background-size: 100% 100%;
}

/* Glowing stars with reduced glow intensity */
.star-small, .star-medium, .star-large {
  position: absolute;
  border-radius: 50%;
  background-color: white;
  z-index: 1;
  animation: starMove var(--duration, 30s) linear infinite;
  opacity: 0;
}

.star-small {
  width: 1px;
  height: 1px;
  box-shadow: 0 0 3px 1px rgba(255, 255, 255, 0.4);
  animation: starPulse var(--pulse-speed, 4s) ease-in-out infinite alternate,
             starMove var(--duration, 30s) linear infinite;
}

.star-medium {
  width: 2px;
  height: 2px;
  box-shadow: 0 0 5px 1px rgba(255, 255, 255, 0.5);
  animation: starPulse var(--pulse-speed, 5s) ease-in-out infinite alternate,
             starMove var(--duration, 35s) linear infinite;
}

.star-large {
  width: 3px;
  height: 3px;
  box-shadow: 0 0 7px 2px rgba(255, 255, 255, 0.6);
  animation: starPulse var(--pulse-speed, 6s) ease-in-out infinite alternate,
             starMove var(--duration, 40s) linear infinite;
}

/* Individual star movement - using a separate animation for movement */
@keyframes starMove {
  0% {
    transform: translate(0, 0) scale(var(--scale, 1));
  }
  25% {
    transform: translate(calc(var(--x-move, 0px) * 0.25), calc(var(--y-move, 0px) * 0.25)) scale(var(--scale, 1));
  }
  50% {
    transform: translate(calc(var(--x-move, 0px) * 0.5), calc(var(--y-move, 0px) * 0.5)) scale(var(--scale, 1) * 1.1);
  }
  75% {
    transform: translate(calc(var(--x-move, 0px) * 0.75), calc(var(--y-move, 0px) * 0.75)) scale(var(--scale, 1));
  }
  100% {
    transform: translate(var(--x-move, 0px), var(--y-move, 0px)) scale(var(--scale, 1));
  }
}

/* Pulse animation is separate from movement */
@keyframes starPulse {
  0% {
    opacity: 0.1;
    box-shadow: 0 0 2px 1px rgba(255, 255, 255, 0.2);
  }
  50% {
    opacity: var(--max-opacity, 0.7);
    box-shadow: 0 0 5px 2px rgba(255, 255, 255, 0.4);
  }
  100% {
    opacity: 0.2;
    box-shadow: 0 0 3px 1px rgba(255, 255, 255, 0.3);
  }
}

/* Nebula clouds with custom movement */
.nebula-cloud {
  position: absolute;
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background: radial-gradient(circle at center, 
    rgba(147, 51, 234, 0.08) 0%, 
    rgba(79, 70, 229, 0.06) 30%, 
    rgba(59, 130, 246, 0.04) 70%, 
    transparent 100%);
  filter: blur(15px);
  opacity: 0.4;
  animation: nebulaFloat var(--duration, 45s) ease-in-out infinite;
}

@keyframes nebulaFloat {
  0% {
    transform: translate(0, 0) scale(1) rotate(0deg);
    opacity: 0.3;
  }
  33% {
    transform: translate(calc(var(--x-move, 15px) * 0.3), calc(var(--y-move, 15px) * 0.3)) scale(1.05) rotate(2deg);
    opacity: 0.4;
  }
  66% {
    transform: translate(calc(var(--x-move, 15px) * 0.7), calc(var(--y-move, 15px) * 0.7)) scale(1.1) rotate(4deg);
    opacity: 0.5;
  }
  100% {
    transform: translate(var(--x-move, 15px), var(--y-move, 15px)) scale(0.95) rotate(-3deg);
    opacity: 0.35;
  }
}

/* Shooting star effect with more random behavior */
.shooting-star-random {
  position: absolute;
  width: 2px;
  height: 2px;
  background-color: white;
  border-radius: 50%;
  box-shadow: 0 0 8px 2px rgba(255, 255, 255, 0.7);
  animation: shootingStar var(--duration, 3s) ease-out forwards;
}

@keyframes shootingStar {
  0% {
    transform: rotate(var(--angle, 45deg)) translateX(0) scale(0);
    opacity: 0;
  }
  10% {
    transform: rotate(var(--angle, 45deg)) translateX(30px) scale(1);
    opacity: 1;
  }
  100% {
    transform: rotate(var(--angle, 45deg)) translateX(var(--distance, 300px)) scale(0);
    opacity: 0;
  }
}

/* Floating particles */
.cosmic-particles {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(1px at 20% 30%, rgba(255, 255, 255, 0.6), transparent),
    radial-gradient(1px at 40% 70%, rgba(255, 255, 255, 0.6), transparent),
    radial-gradient(1px at 60% 80%, rgba(255, 255, 255, 0.6), transparent),
    radial-gradient(1px at 80% 10%, rgba(255, 255, 255, 0.6), transparent);
  animation: floatParticle 30s ease infinite;
  opacity: 0.7;
}

/* Floating animation */
@keyframes floatParticle {
  0%, 100% {
    transform: translateY(0) translateX(0);
  }
  25% {
    transform: translateY(-10px) translateX(5px);
  }
  50% {
    transform: translateY(0) translateX(10px);
  }
  75% {
    transform: translateY(10px) translateX(5px);
  }
}

/* Nebula pulse animation */
@keyframes nebulaPulse {
  0%, 100% {
    opacity: 0.4;
    transform: scale(1);
  }
  50% {
    opacity: 0.6;
    transform: scale(1.05);
  }
}
</style>