function initMessageForm() {

  var $selector = $('#message_form .recepients.chips-autocomplete');
  var populateData = $selector.data('chip');

  $selector.material_chip({
    data: populateData,
    placeholder : "+ Recepient",
    autocompleteOptions: {
      classes:{
        "ui-autocomplete":"chip-input-autocomplete"
      },
      appendTo : ".recepients",
      position: { my: "left top", at: "left bottom"},
      source: function( request, response ) {
        $.ajax( {
          url: "/users/search",
          dataType: "json",
          data: {
            term: request.term
          },
          success: function( data ) {
            var recepients = $.map(data, function( element, i ) {
              return [{id:element.id , label:element.name, avatar:element.avatar}];
            });
            response( recepients );
          },
          error: function(jqXHR, textStatus, errorThrown){
            console.log(textStatus);
          }
        } );
      }
    }
  });
  $('#message_form .chips input').on('focus blur', function (e) {
    chipData = ($(this).parents('.chips').material_chip('data'));
    $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    $(this).parents('.form-group').toggleClass('hasValue', (chipData.length > 0));
  }).trigger('blur');

  $('#message_form').submit(function(e){
    var recepient_ids = $.map($('.recepients.chips-autocomplete').material_chip('data'), function( element, i ) {
      return [element.id];
    });
    $("#message_form #group_users").val(recepient_ids.toString());
  });

  $('#message_form .sleek_form .form-group input.form-control, #message_form .sleek_form .form-group select.form-control, #message_form .sleek_form .form-group textarea.form-control').on('focus blur', function (e) {
    $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0));
  }).trigger('blur');

}

function initConvoChatForm(convo_id) {
  console.log(convo_id);
  var $selector = $('#user_chat_pm_'+convo_id+' .recepients.chips-autocomplete');
  var populateData = $selector.data('chip');

  $selector.material_chip({
    data: populateData,
    placeholder : "+",
    autocompleteOptions: {
      classes:{
        "ui-autocomplete":"chip-input-autocomplete"
      },
      appendTo : ".recepients",
      position: { my: "left top", at: "left bottom"},
      source: function( request, response ) {
        $.ajax( {
          url: "/users/search",
          dataType: "json",
          data: {
            term: request.term
          },
          success: function( data ) {
            var recepients = $.map(data, function( element, i ) {
              return [{id:element.id , label:element.name, avatar:element.avatar}];
            });
            response( recepients );
          },
          error: function(jqXHR, textStatus, errorThrown){
            console.log(textStatus);
          }
        } );
      }
    }
  });
  $('#user_chat_pm_'+convo_id+' .chips input').on('focus blur', function (e) {
    chipData = ($(this).parents('.chips').material_chip('data'));
    $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    $(this).parents('.form-group').toggleClass('hasValue', (chipData.length > 0));
  }).trigger('blur');

  $('#user_chat_pm_'+convo_id+' .user_chat_pm_reply').submit(function(e){
    var recepient_ids = $.map($('#user_chat_pm_'+convo_id+' .recepients.chips-autocomplete').material_chip('data'), function( element, i ) {
      return [element.id];
    });
    $('#user_chat_pm_'+convo_id+' .user_chat_pm_reply .group_users_input').val(recepient_ids.toString());
  });

  // $('#user_chat_pm_'+convo_id+' .user_pm_group input').on('focus blur', function (e) {
  //   $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
  //   $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0));
  // }).trigger('blur');

}

