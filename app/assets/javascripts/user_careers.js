// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function(){

    var origin_form_data = null;

    $('.close-career-modal').click(function(){

        if( origin_form_data != $('#edit-career-modal form').serialize() && !confirm("Your changes are unsaved, do you want to proceed?")) {
            return false;
        }
        $('#edit-career-modal').modal('toggle');

    });
    $("#add_career_button").data("association-insertion-method", 'after')

    $('.link-edit-career').bind('ajax:complete', function() {

        $("#edit-career-modal #add_career_button").data("association-insertion-method", 'after')
        $('#career_forms')
            .on('cocoon:before-insert', function() {
            })
            .on('cocoon:after-insert', function() {
                addCareerEvents();
            })
            .on("cocoon:before-remove", function(e) {

            })
            .on("cocoon:after-remove", function() {
                checkCareerData();
            });
        if ($('#edit-career-modal .nested-career-fields').length < 1)
        {
            $('#add_career_button').click();
            origin_form_data = $('#edit-career-modal form').serialize();

        }else{
            addCareerEvents();
            origin_form_data = $('#edit-career-modal form').serialize();
            setTimeout(addCareerEvents,300);
        }
    });

});

function addCareerEvents(){
    $('.sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control').unbind('focus blur');
    $('.sleek_form .form-group input.form-control, .sleek_form .form-group select.form-control, .sleek_form .form-group textarea.form-control').on('focus blur', function (e) {
        $(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
        $(this).parents('.form-group').toggleClass('hasValue', (this.value.length > 0));
        checkCareerData();
    }).trigger('blur');

    $('#edit-career-modal .remove_career_button').unbind( "click" );
    $('#edit-career-modal .remove_career_button').click(function () {
        careerRow = $(this).parents('.career_row');

        careerRow.find('.form-control').val("");
        careerRow.find('.form-control').parents('.form-group').removeClass('hasValue');

        if ($('#edit-career-modal .nested-career-fields:visible').length > 1) {
            $(this).prev().click();
        }
        checkCareerData();
    });

}
function checkCareerData() {


    if ($('#edit-career-modal .nested-career-fields:visible').length > 1) {
        $('#edit-career-modal .remove_career_button').show();
    }else{
        shouldShow = false;
        $('#edit-career-modal .nested-career-fields:visible').find('.form-control').each(function() {
            if (this.value.length > 0){
                shouldShow = true;
            }
        });

        $('#edit-career-modal .nested-career-fields:visible').find("input[type=hidden]").val(!shouldShow);

        if (shouldShow){
            $('#edit-career-modal .remove_career_button').show();
        }else{
            $('#edit-career-modal .remove_career_button').hide();
        }

    }
}
