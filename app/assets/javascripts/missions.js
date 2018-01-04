// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


  var mission_id = window.location.pathname.split('/')
  if( mission_id.length > 1){
    mission_id = mission_id[2]
  }

$(function() {
  $(document).on('change', '.js-object-type-select', function(e) {
    e.preventDefault();

    if ($(this).val() === 'project') {
      $('.js-project-parent-field').removeClass('hidden')
      $('.js-project-parent-field select').attr('disabled', false);
    } else {
      $('.js-project-parent-field').addClass('hidden');
      $('.js-project-parent-field select').attr('disabled', true);
    }
  });

  // Show the tab corresponding with the hash in the URL, or the first tab.
  function showTabFromHash() {
    var hash = window.location.hash;
    if (hash != '') {
        var selector = hash ? 'a[href="' + hash + '"]' : $('#mission_tabs li.active > a');
        var tabselector = hash.split('#')[1];
        //check for the tab content
        //if its not there call tab_render_control to render partial content into tab
        if( $('#'+tabselector).find(".platform-show-container").length == 0 ) {
          $.get("/missions/"+mission_id+"/tab_render_control?selector="+tabselector, function(){});
        }
        $('#mission_tabs '+selector).tab('show');
    }
  }

  // We use pushState if it's available so the page won't jump, otherwise a shim.
  function changeHash(hash) {
    if (history && history.pushState) {
      history.pushState(null, null, window.location.pathname + window.location.search + '#' + hash);
    } else {
      scrollV = document.body.scrollTop;
      scrollH = document.body.scrollLeft;
      window.location.hash = hash;
      document.body.scrollTop = scrollV;
      document.body.scrollLeft = scrollH;
    }
  }

  // Change the URL when tabs are clicked
  $('#mission_tabs a').on('click', function(e) {
    var hash = this.href.split('#')[1];
    var tabselector = hash;
    //check for the tab content
    //if its not there call tab_render_control to render partial content into tab
    if( $('#'+tabselector).find(".platform-show-container").length == 0 ) {
      $.get("/missions/"+mission_id+"/tab_render_control?selector="+tabselector, function(){});
    }
    if (typeof hash != 'undefined' && hash != '') {
        changeHash(tabselector);
    }
  });
  // Set the correct tab when the page loads
  showTabFromHash();
  // Set the correct tab when a user uses their back/forward button
  $(window).on('hashchange', showTabFromHash);

  $('.close-mission-modal').click(function(){
      if( origin_form_data != $('#edit-mission-modal form').serialize() && !confirm("Your changes are unsaved, do you want to proceed?")) {
          return false;
      }
      $('#edit-mission-modal').modal('toggle');
  });

  $('#upload-cover-button').click(function(){
      $('#mission_cover').trigger("click");
  });

  $("#remove-cover-button").click(function(){
      $('#mission_remove_cover').val(1);
      $('#mission_remove_cover').parents('form').submit();
  });
  $("#mission_cover").change(function(){
      $(this).parents('form').submit();
  });

  var origin_form_data = null;

  $('.link-edit-mission').bind('ajax:complete', function() {
    $('.sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control').on('focus blur', function (e) {
        $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
        $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0));
    }).trigger('blur');

    origin_form_data = $('#edit-mission-modal form').serialize();
  });

});
