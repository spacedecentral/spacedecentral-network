// CREW tab
$(function(){

  $(document).on('click', '.mission_crews_lists ul.nav li a', function(){
    $('input#role').val($(this).attr('data-role'));
    $('form#mission_crews_filter_form').submit();
  });

});
