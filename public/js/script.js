 $(document).ready(function(){
    var voteId, votedForm, voteAction, voteList = [];

    //Vote and update the points on the UI
    $(document).on('click', '#submit', function(e){
        votedForm = $(this).parent('form');
        voteAction = $(this).parent('form').attr('action');
        voteId = voteAction.split('/').pop();
        if(voteList.indexOf(voteId) === -1)
        voteList.push(voteId);
        
        $.ajax({
            url: voteAction,
            type: "POST"
        }).done(function(data,text,jQxhr){
           var result = JSON.parse(data);
           votedForm.find('.button').attr('disabled', true)
           if(typeof result === 'object' && result != null)
            votedForm.find('.points').text(result.points);
        });
    });

    //Empty form submit check
    $(document).on('click', '#newpost', function(e){
        newPostForm = $(this).parent('form');
        if(newPostForm.find('textarea').val().length === 0){
            return;
        }
        newPostForm.submit();
    });

    //Download as spreadsheet
    $(document).on('click', '#download', function(e){
        voteAction = $(this).parent('form').attr('action');

        $.ajax({
            url: voteAction,
            type: "POST"
        }).done(function(data,text,jQxhr){
           console.log(data);
        });
    });


});


