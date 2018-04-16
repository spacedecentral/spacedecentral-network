$(document).on('click', '#upload-cover-button', function(){
  $('#user_cover_photo').trigger("click");
});

$(document).on('click', "#remove-cover-button", function(){
  $('#user_remove_cover_photo').val(1);
  $('#user_remove_cover_photo').parents('form').submit();
});

$(document).on('change', "#user_cover_photo", function(){
  $(this).parents('form').submit();
});

function initUserForm() {
  $("#user_avatar").change(function(){
    if (this.files && this.files[0]) {
      var reader = new FileReader();

      reader.onload = function (e) {
        $('#user_avatar_image').attr('src', e.target.result);
        $("#user_remove_avatar").val(0);
        $("#remove_avatar").show();
      }

      reader.readAsDataURL(this.files[0]);
    }
  });

  $("#remove_avatar").click(function(){
    $("#user_remove_avatar").val(1);
    $('#user_avatar_image').attr('src',$("#user_default_avatar").attr('src'));
    $(this).hide();

  });

  $('.sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control').on('focus blur', function (e) {
    $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0));
  }).trigger('blur');

  var skillTags = $('.skills.chips-autocomplete').data('chip');
  $('.skills.chips-autocomplete').material_chip({
    data: skillTags,
    addOnBlur: true,
    placeholder : "Type your Skills and Interests...",
    placeholderWidth: 220,
    autocompleteOptions: {
      classes:{
        "ui-autocomplete":"chip-input-autocomplete"
      },
      appendTo:".skills.chips-autocomplete",
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
          }
        } );
      }
    }
  });

  $('#edit-profile-modal form').submit(function(e){
    skill_ids = $.map($('.skills.chips-autocomplete').material_chip('data'), function( element, i ) {
      return [element.id || element.label];
    });
    $("#edit-profile-modal #user_skills_field").val(skill_ids.toString());
  });

  $('.chips input').on('focus blur', function (e) {
    chipData = ($(this).parents('.chips').material_chip('data'));
    $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    $(this).parents('.form-group').toggleClass('hasValue', (chipData.length > 0));
  }).trigger('blur');
}

$(document).on('click', '#show-more-program', function(){
  $('#profile-program-tab').click();
  $('html, body').animate({scrollTop: top }, 1000);
});

$(document).on('click', '#show-follower-more', function(){
  $('#profile-follower-tab').click();
  $('html, body').animate({scrollTop: top }, 1000);
});

$(document).on('click', '#show-more-publication', function(){
  $('#profile-publication-tab').click();
  $('html, body').animate({scrollTop: top }, 1000);
});

$(document).on('click', '#show-more-activity', function(){
  $('#profile-activity-tab').click();
  $('html, body').animate({scrollTop: top }, 1000);
});
