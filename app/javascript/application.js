// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./controllers/edit_task_modal";
import "@rails/ujs";

// Start Rails UJS
Rails.start();
