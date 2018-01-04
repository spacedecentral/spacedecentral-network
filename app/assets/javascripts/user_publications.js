var origin_form_data = null;
var MAX_FILE_SIZE_UPLOAD = 20971520; //20MB
var VALID_FILE_TYPES = [
  "application/x-latex",
  "application/x-tex",
  "application/pdf",
  "application/msword",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
];

var isSupportDragDrop = function() {
  var div = document.createElement( 'div' );
  return ( ( 'draggable' in div ) || ( 'ondragstart' in div && 'ondrop' in div ) ) && 'FormData' in window && 'FileReader' in window;
}();

function showautopubform(){
  $(".add_manual_publication_form").hide();
  $(".auto_publication_form").show();
}

function showmanualpubform(){
  $(".auto_publication_form").hide();
  $(".add_manual_publication_form").show();
}

function showPaperFile(file) {
  $('.attached-file-box .file-name').text(file.name);
  $('.attach-btn').hide();
  $('.attach-text').hide();
  $('#publication_keep_private').removeClass('hidden');
  $('#previewUpload').show();
  $("#user_publication_keep_private").prop('checked', true);
}

function initAuthorsMaterialChip() {
  var populateData = $('.authors.chips-autocomplete').data('chip');

  $('.authors.chips-autocomplete').material_chip({
    data: populateData,
    addOnBlur: true,
    placeholder : "+ Author",
    autocompleteOptions: {
      classes:{
        "ui-autocomplete":"chip-input-autocomplete"
      },
      appendTo : ".authors",
      position: { my: "left top+15", at: "left bottom"},
      source: function( request, response ) {
        $.ajax( {
          url: "/users/search",
          dataType: "json",
          data: {
            term: request.term
          },
          success: function( data ) {
            user_authors = $.map(data, function( element, i ) {
              return [{id:element.id , label:element.name, avatar:element.avatar}];
            });
            response( user_authors );
          },
          error: function(jqXHR, textStatus, errorThrown){
            console.log(textStatus);
          }
        } );
      }
    }
  });
}

function initTagsMaterialChip() {
  var populateData = $('.tags.chips-autocomplete').data('chip');
  $('.tags.chips-autocomplete').material_chip({
    data: populateData,
    addOnBlur: true,
    placeholder : "+ Tag",
    autocompleteOptions: {
      classes:{
        "ui-autocomplete":"chip-input-autocomplete"
      },
      appendTo : ".tags",
      position: { my: "left top+15", at: "left bottom"},
      source: function( request, response ) {
        $.ajax( {
          url: "/tags",
          dataType: "json",
          data: {
            term: request.term
          },
          success: function( data ) {
            response( data );
          },
          error: function(jqXHR, textStatus, errorThrown){
            console.log(textStatus);
          }
        } );
      }
    }
  });
}

function initPublicationFormData() {
  $('#publication-form .attach-btn').on('click', function(event) {
    event.preventDefault();
    /* Act on the event */
    $('#publication-form #user_publication_paper').click();
  });

  $('#remove-paper-file').click(function(){
    $('.attach-btn').show();
    $('.attach-text').show();
    $('#publication_keep_private').addClass('hidden');
    $('.attached-file-box .file-name').text("");
    $('#previewUpload').hide();
    $("#user_publication_keep_private").prop('checked', false);
    $("#user_publication_keep_private").val(0);
    $("#user_publication_paper").val("");
    $("#user_publication_is_clear_paper_file").val(true);
  });

  $("#user_publication_paper").change(function(){
    $(".file-error-messages").html('');
    $("#user_publication_is_clear_paper_file").val(false);
    if (this.files && this.files[0]) {
      var file = this.files[0];
      var size = file.size;
      if (size > MAX_FILE_SIZE_UPLOAD) {
        $("#user_publication_paper").val("");
        $(".file-error-messages").html("<div class='error-help-block'><p class=''>Please choose file less than 20 MB</p></div>");
        return false;
      }

      if (VALID_FILE_TYPES.indexOf(file.type) === -1) {
        $("#user_publication_paper").val("");
        $(".file-error-messages").html("<div class='error-help-block'><p class=''>Not support " + file.name.split(".").pop() + " file</p></div>");
        return false;
      }

      showPaperFile(this.files[0]);
    }
  });

  $('#user_publication_publication_date').datepicker({
    dateFormat: 'yy-mm-dd',
    changeYear: true,
    changeMonth: true,
    onSelect: function(dateText) {
      $(this).parents('.form-group').toggleClass('hasValue', this.value.length > 0);
    }
  });

  initAuthorsMaterialChip();

  initTagsMaterialChip();

  $('#add-publication-form form').submit(function(e){
    var tag_ids = $.map($('.tags.chips-autocomplete').material_chip('data'), function( element, i ) {
      return [element.id || element.label];
    });
    $("#add-publication-form #publication_tags_field").val(tag_ids.toString());

    var author_ids = $.map($('.authors.chips-autocomplete').material_chip('data'), function( element, i ) {
      return [element.id || element.label];
    });
    $("#add-publication-form #publication_authors_field").val(author_ids.toString());
  });

  $('.chips input').on('focus blur', function (e) {
    var chipData = ($(this).parents('.chips').material_chip('data'));
    $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    $(this).parents('.form-group').toggleClass('hasValue', (chipData.length > 0));
  }).trigger('blur');

  $('.sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control').on('focus blur', function (e) {
    $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0));
  }).trigger('blur');

  if (isSupportDragDrop) {
    $(document).on('dragenter', function (e)
      {
        e.stopPropagation();
        e.preventDefault();
      });
    $(document).on('dragover', function (e)
      {
        e.stopPropagation();
        e.preventDefault();
        $('#add-publication-form #drop-file-mask').show();
      });
    $(document).on('mouseleave',function(e){
      $('#add-publication-form #drop-file-mask').hide();
    });
    $(document).on('drop', function (e)
      {
        e.stopPropagation();
        e.preventDefault();
        $('#add-publication-form #drop-file-mask').hide();
      });
    drop_mask = document.getElementById('drop-file-mask');
    drop_mask.ondrop = function (e) {
      e.preventDefault();
      $('#user_publication_paper').prop("files", e.dataTransfer.files);
      // showPaperFile(e.dataTransfer.files[0]);
      $(this).hide();
    }
  }

  $("#add-publication-modal #add_location_button").data("association-insertion-method", 'after')
  $('#publication_location_forms')
    .on('cocoon:before-insert', function() {
    })
    .on('cocoon:after-insert', function() {
      addLocationEvents();
    })
    .on("cocoon:before-remove", function(e) {

    })
    .on("cocoon:after-remove", function() {
      checkLocationData();
    });
  if ($('#add-publication-modal .nested-location-fields').length < 1)
  {
    $('#add_location_button').click();
    origin_form_data = $('#add-publication-modal form').serialize();

  }else{
    addLocationEvents();
    origin_form_data = $('#add-publication-modal form').serialize();
    setTimeout(addLocationEvents,300);
  }
}

function addLocationEvents(){
  $('#publication_location_forms').find('.form-group input.form-control, .form-group select.form-control, .form-group textarea.form-control').unbind('focus blur');
  $('#publication_location_forms').find('.form-group input.form-control, .form-group select.form-control, .form-group textarea.form-control').on('focus blur', function (e) {
    $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0));
    checkLocationData();
  }).trigger('blur');

  $('#add-publication-modal .remove_location_button').unbind( "click" );
  $('#add-publication-modal .remove_location_button').click(function () {
    locationRow = $(this).parents('.location_row');

    locationRow.find('.form-control').val("");
    locationRow.find('.form-control').parents('.form-group').removeClass('hasValue');

    if ($('#add-publication-modal .nested-location-fields:visible').length > 1) {
      $(this).prev().click();
    }
    checkLocationData();
  });

}
function checkLocationData() {
  if ($('#add-publication-modal .nested-location-fields:visible').length > 1) {
    $('#add-publication-modal .remove_location_button').show();
  }else{
    shouldShow = false;
    $('#add-publication-modal .nested-location-fields:visible').find('.form-control').each(function() {
      if (this.value.length > 0){
        shouldShow = true;
      }
    });

    $('#add-publication-modal .nested-location-fields:visible').find("input[type=hidden]").val(!shouldShow);

    if (shouldShow){
      $('#add-publication-modal .remove_location_button').show();
    }else{
      $('#add-publication-modal .remove_location_button').hide();
    }
  }
}

$(document).ready(function() {
  $(document).on('click', '.close-publication-modal', function(){
    if( (origin_form_data != $('#add-publication-modal form').serialize() || $("#user_publication_paper").val() != "") && !confirm("Your changes are unsaved, do you want to proceed?")) {
      return false;
    }
    $('#add-publication-modal').modal('toggle');
  });
});
