import Rails from "@rails/ujs";
Rails.start();

import "@hotwired/turbo-rails";
import * as bootstrap from "bootstrap";
import "@popperjs/core";

import { Turbo } from "@hotwired/turbo-rails";

document.addEventListener("DOMContentLoaded", function () {
    const csrfToken = document.querySelector("meta[name='csrf-token']").content;
    if (csrfToken) {
      window.fetch = ((originalFetch) => {
        return (...args) => {
          const [resource, config] = args;
          const updatedConfig = {
            ...config,
            headers: {
              ...config?.headers,
              'X-CSRF-Token': csrfToken,
            },
          };
          return originalFetch(resource, updatedConfig);
        };
      })(window.fetch);
    }
  });
  
  
  

