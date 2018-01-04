// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function(){

    var origin_form_data = null;

    $('.close-education-modal').click(function(){

        if( origin_form_data != $('#edit-education-modal form').serialize() && !confirm("Your changes are unsaved, do you want to proceed?")) {
            return false;
        }
        $('#edit-education-modal').modal('toggle');

    });
    $("#add_education_button").data("association-insertion-method", 'after')

    $('.link-edit-education').bind('ajax:complete', function() {
        $('#education_forms')
            .on('cocoon:before-insert', function() {
            })
            .on('cocoon:after-insert', function() {
                addEducationEvents();
            })
            .on("cocoon:before-remove", function(e) {

            })
            .on("cocoon:after-remove", function() {
                checkEducationData();
            });
        if ($('#edit-education-modal .nested-education-fields').length < 1)
        {
            $('#add_education_button').click();
            origin_form_data = $('#edit-education-modal form').serialize();

        }else{
            addEducationEvents();
            origin_form_data = $('#edit-education-modal form').serialize();
            setTimeout(addEducationEvents,300);
        }
    });

});

function populateEducationForm() {
  $('.sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control').unbind('focus blur');
  $('.sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control').on('focus blur', function (e) {
      $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
      $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0));
  }).trigger('blur');
}

function addEducationEvents(){
    $('.sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control').unbind('focus blur');
    $('.sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control').on('focus blur', function (e) {
        $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
        $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0));
        checkEducationData();
    }).trigger('blur');

    $('#edit-education-modal .remove_education_button').unbind( "click" );
    $('#edit-education-modal .remove_education_button').click(function () {
        educationRow = $(this).parents('.education_row');

        educationRow.find('.form-control').val("");
        educationRow.find('.form-control').parents('.form-group').removeClass('hasValue');

        if ($('#edit-education-modal .nested-education-fields:visible').length > 1) {
            $(this).prev().click();
        }
        checkEducationData();
    });

}
function checkEducationData() {


    if ($('#edit-education-modal .nested-education-fields:visible').length > 1) {
        $('#edit-education-modal .remove_education_button').show();
    }else{
        shouldShow = false;
        $('#edit-education-modal .nested-education-fields:visible').find('.form-control').each(function() {
            if (this.value.length > 0){
                shouldShow = true;
            }
        });

        $('#edit-education-modal .nested-education-fields:visible').find("input[type=hidden]").val(!shouldShow);

        if (shouldShow){
            $('#edit-education-modal .remove_education_button').show();
        }else{
            $('#edit-education-modal .remove_education_button').hide();
        }

    }
}
