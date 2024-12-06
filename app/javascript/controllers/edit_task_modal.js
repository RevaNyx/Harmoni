

function newFunction() {
  document.addEventListener("DOMContentLoaded", () => {
    console.log("Modal script loaded!");

    const editButton = document.getElementById("edit-task-button");
    const modal = document.getElementById("edit-task-modal");
    const closeButton = document.getElementById("close-edit-task");

    console.log("Edit Button:", editButton);
    console.log("Modal:", modal);
    console.log("Close Button:", closeButton);

    if (editButton && modal && closeButton) {
      console.log("Elements found! Setting up event listeners...");
      // Show the modal when the edit button is clicked
      editButton.addEventListener("click", () => {
        console.log("Opening modal...");
        modal.style.display = "block";
      });

      // Hide the modal when the close button is clicked
      closeButton.addEventListener("click", () => {
        console.log("Closing modal...");
        modal.style.display = "none";
      });
    } else {
      console.error("Modal elements not found on the page.");
    }
  });
}

