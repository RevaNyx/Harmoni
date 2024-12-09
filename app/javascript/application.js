import Rails from "@rails/ujs";
Rails.start();

import "@hotwired/turbo-rails";
import * as bootstrap from "bootstrap";
import "@popperjs/core";

document.addEventListener("turbo:before-fetch-request", (event) => {
  const { headers } = event.detail.fetchOptions || {};
  headers["X-CSRF-Token"] = document.querySelector('meta[name="csrf-token"]').content;
});
