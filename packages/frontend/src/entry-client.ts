import './style.css'
import { createApp } from './main'

const { app, router } = createApp();

router.isReady().then(() => {
  app.mount("#app");

  // Add this to show content only after hydration is complete
  document.body.classList.add('hydrated');

  console.log("hydrated");
});