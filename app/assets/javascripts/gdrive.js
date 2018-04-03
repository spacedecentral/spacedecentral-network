$(document).ready(function(){

  $(document).on('mouseenter', '#subdropdown', function(e){
    $(this).parents('#file_actions').addClass('open');
    $(this).parents('#file_actions').prev('a').attr('aria-expanded', true);
    if($(this).next('ul.dropdown-menu').is(':hidden')){
      $(this).next('ul.dropdown-menu').addClass('open')
    }
    e.preventDefault();
    e.stopPropagation();
  });

  $(document).on('hidden.bs.dropdown', '.program_dropdown', function(){
    $('.dropdown-submenu ul.dropdown-menu').removeClass('open');
  });

  $(document).on('mouseenter', 'ul.dropdown-menu li', function(){
    if($(this).parents('li.dropdown-submenu').length == 0){
      $('.dropdown-submenu ul.dropdown-menu').removeClass('open');
    }
  });

  $(document).on('click', '.program_file_sort_by_update', function(){
    var newval = $(this).attr("data-sort-by");
    if ( $("#program_file_sort_by").val() == newval ) {
      var curdir = $("#program_file_sort_dir").val();
      $("#program_file_sort_dir").val(curdir == 0 ? 1 : 0);
    } else {
      $("#program_file_sort_by").val(newval);
    }
    $("#program_file_filter_form").submit();
  });


});
