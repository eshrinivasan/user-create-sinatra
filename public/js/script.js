    $(document).ready(function(){
        var voteId, votedForm, voteAction, voteList = [];
        
        var pathname = window.location.pathname;
        var teamname = window.location.pathname.split('/').slice(1,2).toString();

        //Vote
        $(document).on('click', '#submit', function(e){
            self = $(this);
            voteAction = $(this).parent('form').attr('action');
            
            $.ajax({
                url: pathname+voteAction,
                type: "POST"
            }).done(function(data,text,jQxhr){
                var result = JSON.parse(data);
                self.parent('form').find('.button').attr('disabled', true)
                if(typeof result === 'object' && result != null)
                self.parent('form').find('.points').text(result.points);
            });
    });

    //Empty form submit check and Send comment
    $(document).on('click', '#newpost', function(e){
        votedForm = $(this).parent('form');
        voteAction = $(this).parent('form').attr('action');
        if(votedForm.find('textarea').val().length === 0){
            return;
        }
        votedForm.attr('action', teamname+voteAction);
        votedForm.submit();
    });

    //Empty form submit check and Done
    $(document).on('click', '#closeit', function(e){
        votedForm = $(this).parent('form');
        voteAction = $(this).parent('form').attr('action');
        if(votedForm.find("input[type='checkbox']").prop('checked') === false){
            return;
        }
        votedForm.attr('action', teamname+voteAction);
        votedForm.submit();
    });

    //Delete only self created post
    $(document).on('click', '#delete', function(e){
        votedForm = $(this).parent('form');
        voteAction = $(this).parent('form').attr('action');
        votedForm.attr('action', pathname+voteAction);
        votedForm.submit();
    });

    //Download as spreadsheet
    $(document).on('click', '#download', function(e){
        voteAction = $(this).parent('form').attr('action');
        $.ajax({
            url: teamname+voteAction,
            type: "POST"
        }).done(function(data,text,jQxhr){
           console.log(data);
        });
    });
});


