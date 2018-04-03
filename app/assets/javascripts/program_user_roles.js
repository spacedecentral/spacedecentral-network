// CREW tab
$(function(){

  $(document).on('click', '.program_crews_lists ul.nav li a', function(){
    $('input#role').val($(this).attr('data-role'));
    $('form#program_crews_filter_form').submit();
  });

});
