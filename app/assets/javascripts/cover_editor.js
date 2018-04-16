$(document).ready( function() {
    var startPos = {x : null , y: null};
    var startImagePos = {x : null , y: null};
    var mouseDownFlag = false;
    var firstCSS = $(".cover-editor .imgbg").css("background-position");
    $(".cover-editor .imgbg").mousedown(function(event){
        startPos.x = event.pageX;
        startPos.y = event.pageY;
        mouseDownFlag = true;
        var displacement = $(this).css("background-position").split(' ');
        startImagePos.x = Number(displacement[0].replace(/[^0-9-]/g, ''));
        startImagePos.y = Number(displacement[1].replace(/[^0-9-]/g, ''));

    }).mousemove(function(event){
        if (mouseDownFlag){

            newPosY =startImagePos.y +(event.pageY - startPos.y);
            if((-newPosY+45) > 0){
                newCss = startImagePos.x + "px " + newPosY + "px";
                $(this).css("background-position",newCss);
            }


        }

    }).mouseup(function(event){
        mouseDownFlag = false;
    }).mouseout(function(event){
        mouseDownFlag = false;
    });

    $(".cover-editor .cancel-button").click(function(){
        $(this).parents(".cover-editor").toggleClass("hidden");
    })

    $(".reposition-cover-button").click(function(){
        $(".cover-editor").toggleClass("hidden");
        $(".cover-editor .imgbg").css("background-position",firstCSS);
    });

    $("form.edit_user").submit(function(){
        var displacement = $(".cover-editor .imgbg").css("background-position").split(' ');
        cover_dy = Number(displacement[1].replace(/[^0-9-]/g, ''));
        $("#user_cover_dy").val((-cover_dy+45));

    });
    $("form.edit_program").submit(function(){
        var displacement = $(".cover-editor .imgbg").css("background-position").split(' ');
        cover_dy = Number(displacement[1].replace(/[^0-9-]/g, ''));
        $("#program_cover_dy").val((-cover_dy+45));

    });

});
