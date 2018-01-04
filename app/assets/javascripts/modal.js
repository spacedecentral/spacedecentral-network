function confirmCloseModal() {
  $('.confirm-close-modal').unbind('shown.bs.modal, ajax:send, hide.bs.modal');
  var formChanged = false;
  var formIsUnsaved = true;

  $('.confirm-close-modal').on('shown.bs.modal', function() {
    formIsUnsaved = true;
  });

  $('.confirm-close-modal form').on('change', function() {
    formChanged = true;
  });

  $('.confirm-close-modal form').on('ajax:send', function() {
    formIsUnsaved = false;
  });

  $('.confim-close-modal form').bind("ajax:success", function(){
    formIsUnsaved = false;
  });

  $(document).on("ajax:remotipartSubmit", function(e, data){
    formIsUnsaved = false;
  });

  $('.confirm-close-modal').on('hide.bs.modal', function() {
    if (formChanged && formIsUnsaved) {
      if(confirm("Your changes are unsaved, do you want to proceed?")) {
        formChanged = false;
        formIsUnsaved = true;
        return true;
      }
      return false;
    }
  });
}
